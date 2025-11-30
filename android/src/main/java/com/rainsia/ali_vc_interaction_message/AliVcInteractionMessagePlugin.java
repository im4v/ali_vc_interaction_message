package com.rainsia.ali_vc_interaction_message;

import android.app.Activity;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.aliyun.im.AliVCIMEngine;
import com.aliyun.im.AliVCIMGroupInterface;
import com.aliyun.im.common.Error;
import com.aliyun.im.interaction.ImAuth;
import com.aliyun.im.interaction.ImJoinGroupReq;
import com.aliyun.im.interaction.ImJoinGroupRsp;
import com.aliyun.im.interaction.ImLeaveGroupReq;
import com.aliyun.im.interaction.ImLogLevel;
import com.aliyun.im.interaction.ImLoginReq;
import com.aliyun.im.interaction.ImSdkCallback;
import com.aliyun.im.interaction.ImSdkConfig;
import com.aliyun.im.interaction.ImSdkValueCallback;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * AliVcInteractionMessagePlugin
 */
public class AliVcInteractionMessagePlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, EventChannel.StreamHandler {
    private static final String METHOD_CHANNEL_NAME = "ali_vc_interaction_message";
    private static final String EVENT_CHANNEL_NAME = "ali_vc_interaction_message_event";


    // 方法通道
    private MethodChannel channel;
    // 事件通道
    private EventChannel eventChannel;
    // 当前Activity
    private Activity activity;
    // 事件处理器
    private EventChannel.EventSink eventSink = null;
    // 事件 Handler
    private Handler uiThreadHandler = new Handler(Looper.getMainLooper());

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), METHOD_CHANNEL_NAME);
        channel.setMethodCallHandler(this);
        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), EVENT_CHANNEL_NAME);
        eventChannel.setStreamHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            // 延迟两秒返回结果，测试异步调用
            new Thread(() -> {
                try {
                    Thread.sleep(2000);
                    if (eventSink != null) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("method", "getPlatformVersion");
                        map.put("code", 200);
                        map.put("msg", "成功");
                        map.put("data", Build.VERSION.RELEASE);
                        uiThreadHandler.post(() -> eventSink.success(map));
                    }
                } catch (InterruptedException e) {
                    e.printStackTrace();
                } catch(Exception e) {
                    e.printStackTrace();
                }
            }).start();
        } else if (call.method.equals("isInited")) {
            result.success(AliVCIMEngine.instance().isInited());
        } else if (call.method.equals("isLogin")) {
            result.success(AliVCIMEngine.instance().isLogin());
        } else if (call.method.equals("init")) {
            ImSdkConfig config = new ImSdkConfig();
            config.deviceId = call.argument("deviceId"); //[选填]
            config.appId = call.argument("appId"); //[必填]传空会返回初始化失败-2；请务必在创建应用后，将示例中的APP_ID替换为您应用的AppId，否则无法使用；
            config.appSign = call.argument("appSign"); //[必填]传空会返回初始化失败-2；请务必在创建应用后，将示例中的APP_SIGN替换为您应用的AppSign，否则无法使用；
            config.logLevel = ImLogLevel.DEBUG; //[选填]，指定Log日志可输出的最小等级，默认是ImLogLevel.DEBUG；若需要关闭Log日志，则设置为ImLogLevel.NONE；
            // 初始化返回非0，表示初始化失败，其中1001:重复初始化、1002:创建底层引擎失败、-1:底层重复初始化、-2:初始化配置信息有误
            int ret = AliVCIMEngine.instance().init(activity.getApplicationContext(), config);
                if (eventSink != null) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("method", "init");
                    map.put("code", (ret==0||ret==1001)?200:500);
                    map.put("msg", ret==0?"成功":"失败");
                    uiThreadHandler.post(() -> eventSink.success(map));
                }

        } else if (call.method.equals("login")) {
            ImLoginReq req = new ImLoginReq();

            req.user.userId = call.argument("userId");
            String nonce = call.argument("nonce");
            long timestamp = Long.parseLong(call.argument("timestamp"));
            String role = "";
            String appToken = call.argument("appToken");
            // 透传业务额外信息
//            Map<String, Object> data = new HashMap<>();
//            data.put("level", "high");
//            req.user.userExtension = App.getGson().toJson(data).toString();

            req.userAuth = new ImAuth(nonce, timestamp, role, appToken);
            AliVCIMEngine.instance().login(req, new ImSdkCallback() {
                @Override
                public void onSuccess() {
                    if (eventSink != null) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("method", "login");
                        map.put("code", 200);
                        map.put("msg", "成功");
                        map.put("data", "");
                        uiThreadHandler.post(() -> eventSink.success(map));
                    }

                }

                @Override
                public void onFailure(Error error) {
                    if (eventSink != null) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("method", "login");
                        map.put("code", 500);
                        map.put("msg", error.getMsg());
                        uiThreadHandler.post(() -> eventSink.success(map));
                    }

                }
            });
        } else if (call.method.equals("logout")) {
            AliVCIMEngine.instance().logout(new ImSdkCallback() {
                @Override
                public void onSuccess() {
                    if (eventSink != null) {
                        // 回调flutter中的方法
                        Map<String, Object> map = new HashMap<>();
                        map.put("method", "logout");
                        map.put("code", 200);
                        map.put("msg", "成功");
                        uiThreadHandler.post(() -> eventSink.success(map));
                    }

                }

                @Override
                public void onFailure(Error error) {    if (eventSink != null) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("method", "logout");
                    map.put("code", 500);
                    map.put("msg", error.getMsg());
                    uiThreadHandler.post(() -> eventSink.success(map));
                }

                }
            });
        } else if (call.method.equals("joinGroup")) {
            ImJoinGroupReq req = new ImJoinGroupReq();
            req.groupId = call.argument("groupId");

            AliVCIMGroupInterface groupInterface = AliVCIMEngine.instance().getGroupManager();
            groupInterface.joinGroup(req, new ImSdkValueCallback<ImJoinGroupRsp>() {
                @Override
                public void onSuccess(ImJoinGroupRsp data) {
                    if (eventSink != null) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("method", "joinGroup");
                        map.put("code", 200);
                        map.put("msg", "成功");
                        map.put("data", data.groupInfo.getGroupId());
                        uiThreadHandler.post(() -> eventSink.success(map));
                    }

                }

                @Override
                public void onFailure(Error error) {    if (eventSink != null) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("method", "joinGroup");
                    map.put("code", 500);
                    map.put("msg", error.getMsg());
                    uiThreadHandler.post(() -> eventSink.success(map));
                }

                }
            });
        } else if (call.method.equals("leaveGroup")) {
            ImLeaveGroupReq req = new ImLeaveGroupReq();
            req.groupId = call.argument("groupId");

            AliVCIMGroupInterface groupInterface = AliVCIMEngine.instance().getGroupManager();
            groupInterface.leaveGroup(req, new ImSdkCallback() {
                @Override
                public void onSuccess() {    if (eventSink != null) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("method", "leaveGroup");
                    map.put("code", 200);
                    map.put("msg", "成功");
                    uiThreadHandler.post(() -> eventSink.success(map));
                }

                }

                @Override
                public void onFailure(Error error) {    if (eventSink != null) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("method", "leaveGroup");
                    map.put("code", 500);
                    map.put("msg", error.getMsg());
                    uiThreadHandler.post(() -> eventSink.success(map));
                }

                }
            });
        } else if (call.method.equals("unInit")) {
            result.success(AliVCIMEngine.instance().unInit());
        }
        result.notImplemented();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        eventSink.endOfStream();
        eventChannel.setStreamHandler(null);
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        activity = activityPluginBinding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        this.onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
        this.onAttachedToActivity(activityPluginBinding);
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
        eventSink = null;
    }
}
