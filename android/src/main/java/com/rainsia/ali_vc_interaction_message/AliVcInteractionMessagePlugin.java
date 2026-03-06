package com.rainsia.ali_vc_interaction_message;

import android.app.Activity;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import com.aliyun.im.AliVCIMEngine;
import com.aliyun.im.AliVCIMGroupInterface;
import com.aliyun.im.AliVCIMMessageInterface;
import com.aliyun.im.common.Error;
import com.aliyun.im.interaction.ImAuth;
import com.aliyun.im.interaction.ImCancelMuteAllReq;
import com.aliyun.im.interaction.ImCancelMuteUserReq;
import com.aliyun.im.interaction.ImDeleteMessageReq;
import com.aliyun.im.interaction.ImGroupInfoStatus;
import com.aliyun.im.interaction.ImGroupListener;
import com.aliyun.im.interaction.ImGroupMemberChangeInfo;
import com.aliyun.im.interaction.ImGroupMuteStatus;
import com.aliyun.im.interaction.ImJoinGroupReq;
import com.aliyun.im.interaction.ImJoinGroupRsp;
import com.aliyun.im.interaction.ImLeaveGroupReq;
import com.aliyun.im.interaction.ImListGroupUserReq;
import com.aliyun.im.interaction.ImListGroupUserRsp;
import com.aliyun.im.interaction.ImListMuteUsersReq;
import com.aliyun.im.interaction.ImListMuteUsersRsp;
import com.aliyun.im.interaction.ImListRecentMessageReq;
import com.aliyun.im.interaction.ImListRecentMessageRsp;
import com.aliyun.im.interaction.ImLogLevel;
import com.aliyun.im.interaction.ImLoginReq;
import com.aliyun.im.interaction.ImMessage;
import com.aliyun.im.interaction.ImMessageLevel;
import com.aliyun.im.interaction.ImMessageListener;
import com.aliyun.im.interaction.ImMuteAllReq;
import com.aliyun.im.interaction.ImMuteUserReq;
import com.aliyun.im.interaction.ImQueryGroupReq;
import com.aliyun.im.interaction.ImQueryGroupRsp;
import com.aliyun.im.interaction.ImSdkCallback;
import com.aliyun.im.interaction.ImSdkConfig;
import com.aliyun.im.interaction.ImSdkValueCallback;
import com.aliyun.im.interaction.ImSendMessageToGroupReq;
import com.aliyun.im.interaction.ImSendMessageToGroupRsp;
import com.aliyun.im.interaction.ImSendMessageToUserReq;
import com.aliyun.im.interaction.ImSendMessageToUserRsp;
import com.aliyun.im.interaction.ImSortType;
import com.google.gson.Gson;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

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

    // 群组接口
    private AliVCIMGroupInterface groupInterface;

    // 消息接口
    private AliVCIMMessageInterface messageInterface;

    // 消息监听器
    private ImMessageListener messageListener;

    // 群组监听器
    private ImGroupListener groupListener;

    Gson gson = new Gson();

    // 获取群组管理器
    private AliVCIMGroupInterface getGroupInterface() {
        try {
            if (groupInterface == null) {
                groupInterface = AliVCIMEngine.instance().getGroupManager();
            }
            return groupInterface;
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
            return null;
        }
    }

    // 获取消息管理器
    private AliVCIMMessageInterface getMessageInterface() {
        try {
            if (messageInterface == null) {
                messageInterface = AliVCIMEngine.instance().getMessageManager();
            }
            return messageInterface;
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
            return null;
        }
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), METHOD_CHANNEL_NAME);
        channel.setMethodCallHandler(this);
        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), EVENT_CHANNEL_NAME);
        eventChannel.setStreamHandler(this);
    }

    // ========== 私有方法 ==========
    /**
     * 处理获取平台版本号方法调用
     */
    private void handleGetPlatformVersion(@NonNull MethodCall call, @NonNull Result result) {
        try {
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
                } catch (Exception e) {
                    Log.e("AliVCIMGroupInterface", e.getMessage());
                }
            }).start();
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理是否初始化方法调用
     */
    private void handleIsInited(@NonNull MethodCall call, @NonNull Result result) {
        try {
            result.success(AliVCIMEngine.instance().isInited());
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
            result.error("500", e.getMessage(), null);
        }
    }

    /**
     * 处理是否登录方法调用
     */
    private void handleIsLogin(@NonNull MethodCall call, @NonNull Result result) {
        try {
            result.success(AliVCIMEngine.instance().isLogin());
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
            result.error("500", e.getMessage(), null);
        }
    }

    /**
     * 处理初始化方法调用
     */
    private void handleInit(@NonNull MethodCall call, @NonNull Result result) {
        try {
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
                map.put("code", (ret == 0 || ret == 1001) ? 200 : 500);
                map.put("msg", ret == 0 ? "成功" : "失败");
                uiThreadHandler.post(() -> eventSink.success(map));
            }
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理注销方法调用
     */
    private void handleUnInit(@NonNull MethodCall call, @NonNull Result result) {
        try {
            result.success(AliVCIMEngine.instance().unInit());
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
            result.error("500", e.getMessage(), null);
        }
    }

    /**
     * 处理登录方法调用
     */
    private void handleLogin(@NonNull MethodCall call, @NonNull Result result) {
        try {
            ImLoginReq req = new ImLoginReq();

            req.user.userId = call.argument("userId");
            String nonce = call.argument("nonce");
            long timestamp = Long.parseLong(call.argument("timestamp"));
            String role = call.argument("role");
            String appToken = call.argument("appToken");
            // 透传业务额外信息
            Map<String, Object> data = new HashMap<>();
            data.put("nickName", call.argument("nickName"));
            data.put("avatar", call.argument("avatar"));
            req.user.userExtension = gson.toJson(data);

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
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理注销方法调用
     */
    private void handleLogout(@NonNull MethodCall call, @NonNull Result result) {
        try {
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
                public void onFailure(Error error) {
                    if (eventSink != null) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("method", "logout");
                        map.put("code", 500);
                        map.put("msg", error.getMsg());
                        uiThreadHandler.post(() -> eventSink.success(map));
                    }
                }
            });
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理查询群信息方法调用
     */
    private void handleQueryGroupInfo(@NonNull MethodCall call, @NonNull Result result) {
        try {
            AliVCIMGroupInterface gi = getGroupInterface();
            if (gi != null) {
                ImQueryGroupReq req = new ImQueryGroupReq();
                req.groupId = call.argument("groupId");
                gi.queryGroup(req, new ImSdkValueCallback<ImQueryGroupRsp>() {
                    @Override
                    public void onSuccess(ImQueryGroupRsp data) {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "queryGroupInfo");
                            map.put("code", 200);
                            map.put("msg", "成功");
                            map.put("data", gson.toJson(data));
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }

                    @Override
                    public void onFailure(Error error) {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "queryGroupInfo");
                            map.put("code", 500);
                            map.put("msg", error.getMsg());
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }
                });
            }
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理查询群所有用户方法调用
     */
    private void handleListGroupAllUser(@NonNull MethodCall call, @NonNull Result result) {
        try {
            Log.i("AliVCInteractionMessage", "calling listGroupAllUser");
            AliVCIMGroupInterface gi = getGroupInterface();
            if (gi != null) {
                ImListGroupUserReq req = new ImListGroupUserReq();
                req.groupId = call.argument("groupId");
                req.sortType = ImSortType.ASC;
                req.pageSize = 30;
                String nextPageToken = call.argument("nextPageToken");
                if (nextPageToken != null) {
                    req.nextPageToken = Long.parseLong(nextPageToken);
                }
                gi.listGroupUser(req, new ImSdkValueCallback<ImListGroupUserRsp>() {
                    @Override
                    public void onSuccess(ImListGroupUserRsp data) {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "listGroupAllUser");
                            map.put("code", 200);
                            map.put("msg", "成功");
                            map.put("data", gson.toJson(data));
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }

                    @Override
                    public void onFailure(Error error) {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "listGroupAllUser");
                            map.put("code", 500);
                            map.put("msg", error.getMsg());
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }
                });
            }
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理加入群方法调用
     */
    private void handleJoinGroup(@NonNull MethodCall call, @NonNull Result result) {
        try {
            ImJoinGroupReq joinGroupReq = new ImJoinGroupReq();
            joinGroupReq.groupId = call.argument("groupId");

            AliVCIMGroupInterface gi = getGroupInterface();
            if (gi != null) {
                gi.joinGroup(joinGroupReq, new ImSdkValueCallback<ImJoinGroupRsp>() {
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
                    public void onFailure(Error error) {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "joinGroup");
                            map.put("code", 500);
                            map.put("msg", error.getMsg());
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }
                });
            }
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理退出群方法调用
     */
    private void handleLeaveGroup(@NonNull MethodCall call, @NonNull Result result) {
        try {
            ImLeaveGroupReq leaveGroupReq = new ImLeaveGroupReq();
            leaveGroupReq.groupId = call.argument("groupId");

            AliVCIMGroupInterface gi = getGroupInterface();
            if (gi != null) {
                gi.leaveGroup(leaveGroupReq, new ImSdkCallback() {
                    @Override
                    public void onSuccess() {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "leaveGroup");
                            map.put("code", 200);
                            map.put("msg", "成功");
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }

                    @Override
                    public void onFailure(Error error) {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "leaveGroup");
                            map.put("code", 500);
                            map.put("msg", error.getMsg());
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }
                });
            }
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理全体禁言方法调用
     */
    private void handleMuteAll(@NonNull MethodCall call, @NonNull Result result) {
        try {
            ImMuteAllReq req = new ImMuteAllReq();
            req.groupId = call.argument("groupId");
            groupInterface.muteAll(req, new ImSdkCallback() {
                @Override
                public void onSuccess() {
                    if (eventSink != null) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("method", "muteAll");
                        map.put("code", 200);
                        map.put("msg", "成功");
                        uiThreadHandler.post(() -> eventSink.success(map));
                    }
                }

                @Override
                public void onFailure(Error error) {
                    if (eventSink != null) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("method", "muteAll");
                        map.put("code", 500);
                        map.put("msg", error.getMsg());
                        uiThreadHandler.post(() -> eventSink.success(map));
                    }
                }
            });
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理取消全体禁言方法调用
     */
    private void handleCancelMuteAll(@NonNull MethodCall call, @NonNull Result result) {
        try {
            ImCancelMuteAllReq req = new ImCancelMuteAllReq();
            req.groupId = call.argument("groupId");
            AliVCIMGroupInterface gi = getGroupInterface();
            if (gi != null) {
                gi.cancelMuteAll(req, new ImSdkCallback() {
                    @Override
                    public void onSuccess() {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "cancelMuteAll");
                            map.put("code", 200);
                            map.put("msg", "成功");
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }

                    @Override
                    public void onFailure(Error error) {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "cancelMuteAll");
                            map.put("code", 500);
                            map.put("msg", error.getMsg());
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }
                });
            }
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理禁言用户方法调用
     */
    private void handleMuteUser(@NonNull MethodCall call, @NonNull Result result) {
        try {
            ImMuteUserReq req = new ImMuteUserReq();
            req.groupId = call.argument("groupId");
            req.userList.add(call.argument("userId"));
            AliVCIMGroupInterface gi = getGroupInterface();
            if (gi != null) {
                gi.muteUser(req, new ImSdkCallback() {
                    @Override
                    public void onSuccess() {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "muteUser");
                            map.put("code", 200);
                            map.put("msg", "成功");
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }

                    @Override
                    public void onFailure(Error error) {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "muteUser");
                            map.put("code", 500);
                            map.put("msg", error.getMsg());
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }
                });
            }
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理取消禁言用户方法调用
     */
    private void handleCancelMuteUser(@NonNull MethodCall call, @NonNull Result result) {
        try {
            ImCancelMuteUserReq req = new ImCancelMuteUserReq();
            req.groupId = call.argument("groupId");
            req.userList.add(call.argument("userId"));
            AliVCIMGroupInterface gi = getGroupInterface();
            if (gi != null) {
                gi.cancelMuteUser(req, new ImSdkCallback() {
                    @Override
                    public void onSuccess() {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "cancelMuteUser");
                            map.put("code", 200);
                            map.put("msg", "成功");
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }

                    @Override
                    public void onFailure(Error error) {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "cancelMuteUser");
                            map.put("code", 500);
                            map.put("msg", error.getMsg());
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }
                });
            }
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理查询禁言用户方法调用
     */
    private void handleListMuteUsers(@NonNull MethodCall call, @NonNull Result result) {
        try {
            ImListMuteUsersReq req = new ImListMuteUsersReq();
            req.groupId = call.argument("groupId");
            AliVCIMGroupInterface gi = getGroupInterface();
            if (gi != null) {
                gi.listMuteUsers(req, new ImSdkValueCallback<ImListMuteUsersRsp>() {
                    @Override
                    public void onSuccess(ImListMuteUsersRsp data) {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "listMuteUsers");
                            map.put("code", 200);
                            map.put("msg", "成功");
                            map.put("data", gson.toJson(data));
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }

                    @Override
                    public void onFailure(Error error) {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "listMuteUsers");
                            map.put("code", 500);
                            map.put("msg", error.getMsg());
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }
                });
            }
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理查询最近消息方法调用
     */
    private void handleListRecentMessage(@NonNull MethodCall call, @NonNull Result result) {
        try {
            ImListRecentMessageReq listRecentMessageReq = new ImListRecentMessageReq();
            listRecentMessageReq.groupId = call.argument("groupId");
            AliVCIMMessageInterface mi = getMessageInterface();
            if (mi != null) {
                mi.listRecentMessage(listRecentMessageReq, new ImSdkValueCallback<ImListRecentMessageRsp>() {

                    @Override
                    public void onSuccess(ImListRecentMessageRsp data) {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "listRecentMessage");
                            map.put("code", 200);
                            map.put("msg", "成功");
                            map.put("data", gson.toJson(data));
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }

                    @Override
                    public void onFailure(Error error) {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "listRecentMessage");
                            map.put("code", 500);
                            map.put("msg", error.getMsg());
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }
                });
            }
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理发送群组消息方法调用
     */
    private void handleSendGroupMessage(@NonNull MethodCall call, @NonNull Result result) {
        try {
            ImSendMessageToGroupReq req = new ImSendMessageToGroupReq();
            /**
             * 设置消息等级，默认为NORMAL，使用详情参见【消息分级限流】说明
             */
            req.level = ImMessageLevel.NORMAL;
            req.type = call.argument("type");
            req.data = call.argument("message");
            req.groupId = call.argument("groupId");
            // 需确保已经加入群成功（即在AliVCIMGroupInterface.joinGroup回调成功之后），再发送群组消息，否则会返回错误码425
            AliVCIMMessageInterface mi = getMessageInterface();
            if (mi != null) {
                mi.sendGroupMessage(req, new ImSdkValueCallback<ImSendMessageToGroupRsp>() {

                    @Override
                    public void onSuccess(ImSendMessageToGroupRsp data) {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "sendGroupMessage");
                            map.put("code", 200);
                            map.put("msg", "成功");
                            map.put("data", gson.toJson(data));
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }

                    @Override
                    public void onFailure(Error error) {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "sendGroupMessage");
                            map.put("code", 500);
                            map.put("msg", error.getMsg());
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }
                });
            }
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理发送点对点消息方法调用
     */
    private void handleSendC2cMessage(@NonNull MethodCall call, @NonNull Result result) {
        try {
            ImSendMessageToUserReq req = new ImSendMessageToUserReq();
            req.type = call.argument("type");
            req.data = call.argument("message");
            req.receiverId = call.argument("userId");

            // 需确保对方在线，否则会返回错误码424，此时建议待对方上线后再重发
            AliVCIMMessageInterface mi = getMessageInterface();
            if (mi != null) {
                mi.sendC2cMessage(req, new ImSdkValueCallback<ImSendMessageToUserRsp>() {
                    @Override
                    public void onSuccess(ImSendMessageToUserRsp data) {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "sendC2cMessage");
                            map.put("code", 200);
                            map.put("msg", "成功");
                            map.put("data", gson.toJson(data));
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }

                    @Override
                    public void onFailure(Error error) {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "sendC2cMessage");
                            map.put("code", 500);
                            map.put("msg", error.getMsg());
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }
                });
            }
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理删除群组消息方法调用
     */
    private void handleDeleteMessage(@NonNull MethodCall call, @NonNull Result result) {
        try {
            ImDeleteMessageReq req = new ImDeleteMessageReq();
            req.groupId = call.argument("groupId");
            req.messageId = call.argument("messageId");
            AliVCIMMessageInterface mi = getMessageInterface();
            if (mi != null) {
                mi.deleteMessage(req, new ImSdkCallback() {
                    @Override
                    public void onSuccess() {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "deleteMessage");
                            map.put("code", 200);
                            map.put("msg", "成功");
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }

                    @Override
                    public void onFailure(Error error) {
                        if (eventSink != null) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("method", "deleteMessage");
                            map.put("code", 500);
                            map.put("msg", error.getMsg());
                            uiThreadHandler.post(() -> eventSink.success(map));
                        }
                    }
                });
            }
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理添加消息监听器方法调用
     */
    private void handleAddMessageListener(@NonNull MethodCall call, @NonNull Result result) {
        try {
            messageListener = new ImMessageListener() {
                /// 接收到C2C消息
                @Override
                public void onRecvC2cMessage(ImMessage msg) {
                    if (eventSink != null) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("method", "onRecvC2cMessage");
                        map.put("code", 200);
                        map.put("msg", "成功");
                        map.put("data", gson.toJson(msg));
                        uiThreadHandler.post(() -> eventSink.success(map));
                    }
                }

                /// 接收到群消息
                @Override
                public void onRecvGroupMessage(ImMessage msg, String groupId) {
                    if (eventSink != null) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("method", "onRecvGroupMessage");
                        map.put("code", 200);
                        map.put("msg", "成功");
                        map.put("data", gson.toJson(msg));
                        uiThreadHandler.post(() -> eventSink.success(map));
                    }
                }

                ///  删除群消息
                @Override
                public void onDeleteGroupMessage(String msgId, String groupId) {
                    if (eventSink != null) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("method", "onDeleteGroupMessage");
                        map.put("code", 200);
                        map.put("msg", "成功");
                        map.put("data", msgId);
                        uiThreadHandler.post(() -> eventSink.success(map));
                    }
                }
            };
            //监听消息
            AliVCIMMessageInterface mi = getMessageInterface();
            if (mi != null) {
                mi.addMessageListener(messageListener);
            }
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理添加群组监听器方法调用
     */
    private void handleAddGroupListener(@NonNull MethodCall call, @NonNull Result result) {
        try {
            groupListener = new ImGroupListener() {
                /**
                 * 群组成员变化通知
                 *
                 * @param groupMemberChangeInfo 群成员变化信息
                 * @apiNote v1.4.1新增；若重写该接口，则不再回调旧接口，请务必迁移旧的逻辑；
                 */
                @Override
                public void onMemberChange(ImGroupMemberChangeInfo groupMemberChangeInfo) {
                    // 可以监听这个回调，在群人员变化后，更新当前房间的人数、累积访问量（观看数）
                    // 若当前是大群（群人数超过一定量级），即groupMemberChangeInfo.isBigGroup()返回true，群成员变化的通知会控制频率，通知可能不及时；若需要实时通知，可通过OpenAPI对接该回调接口；
                    if (eventSink != null) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("method", "onMemberChange");
                        map.put("code", 200);
                        map.put("msg", "成功");
                        map.put("data", gson.toJson(groupMemberChangeInfo));
                        uiThreadHandler.post(() -> eventSink.success(map));
                    }
                }

                /**
                 * 退出群组通知
                 *
                 * @param groupId 群组ID
                 * @param reason  退出原因 ， 1: 群被解散， 2：被踢出来了
                 */
                @Override
                public void onExit(String groupId, int reason) {
                    if (eventSink != null) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("method", "onExit");
                        map.put("code", 200);
                        map.put("msg", "成功");
                        map.put("data", reason);
                        uiThreadHandler.post(() -> eventSink.success(map));
                    }
                }

                /**
                 * 群组禁言状态通知
                 *
                 * @param groupId 群组ID
                 * @param status  群组禁言状态
                 */
                @Override
                public void onMuteChange(String groupId, ImGroupMuteStatus status) {
                    if (eventSink != null) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("method", "onMuteChange");
                        map.put("code", 200);
                        map.put("msg", "成功");
                        map.put("data", gson.toJson(status));
                        uiThreadHandler.post(() -> eventSink.success(map));
                    }
                }

                /**
                 * 群组信息变化通知
                 *
                 * @param groupId 群组ID
                 * @param info    群组信息
                 */
                @Override
                public void onInfoChange(String groupId, ImGroupInfoStatus info) {
                    if (eventSink != null) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("method", "onMuteChange");
                        map.put("code", 200);
                        map.put("msg", "成功");
                        map.put("data", gson.toJson(info));
                        uiThreadHandler.post(() -> eventSink.success(map));
                    }
                }
            };
            AliVCIMGroupInterface gi = getGroupInterface();
            if (gi != null) {
                gi.addGroupListener(groupListener);
            }
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理移除消息监听器方法调用
     */
    private void handleRemoveMessageListener(@NonNull MethodCall call, @NonNull Result result) {
        try {
            AliVCIMMessageInterface mi = getMessageInterface();
            if (mi != null) {
                mi.removeMessageListener(messageListener);
            }
            messageListener = null;
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    /**
     * 处理移除群组监听器方法调用
     */
    private void handleRemoveGroupListener(@NonNull MethodCall call, @NonNull Result result) {
        try {
            AliVCIMGroupInterface gi = getGroupInterface();
            if (gi != null) {
                gi.removeGroupListener(groupListener);
            }
            groupListener = null;
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", e.getMessage());
        }
    }

    // ========== onMethodCall ==========

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        try {
            switch (call.method) {
                case "getPlatformVersion":
                    handleGetPlatformVersion(call, result);
                    break;
                case "isInited":
                    handleIsInited(call, result);
                    break;
                case "isLogin":
                    handleIsLogin(call, result);
                    break;
                case "init":
                    handleInit(call, result);
                    break;
                case "unInit":
                    handleUnInit(call, result);
                    break;
                case "login":
                    handleLogin(call, result);
                    break;
                case "logout":
                    handleLogout(call, result);
                    break;
                case "queryGroupInfo":
                    handleQueryGroupInfo(call, result);
                    break;
                case "listGroupAllUser":
                    handleListGroupAllUser(call, result);
                    break;
                case "joinGroup":
                    handleJoinGroup(call, result);
                    break;
                case "leaveGroup":
                    handleLeaveGroup(call, result);
                    break;
                case "muteAll":
                    handleMuteAll(call, result);
                    break;
                case "cancelMuteAll":
                    handleCancelMuteAll(call, result);
                    break;
                case "muteUser":
                    handleMuteUser(call, result);
                    break;
                case "cancelMuteUser":
                    handleCancelMuteUser(call, result);
                    break;
                case "listMuteUsers":
                    handleListMuteUsers(call, result);
                    break;
                case "listRecentMessage":
                    handleListRecentMessage(call, result);
                    break;
                case "sendGroupMessage":
                    handleSendGroupMessage(call, result);
                    break;
                case "sendC2cMessage":
                    handleSendC2cMessage(call, result);
                    break;
                case "deleteMessage":
                    handleDeleteMessage(call, result);
                    break;
                case "addMessageListener":
                    handleAddMessageListener(call, result);
                    break;
                case "addGroupListener":
                    handleAddGroupListener(call, result);
                    break;
                case "removeMessageListener":
                    handleRemoveMessageListener(call, result);
                    break;
                case "removeGroupListener":
                    handleRemoveGroupListener(call, result);
                    break;
                default:
                    result.notImplemented();
                    break;
            }
        } catch (Exception e) {
            Log.e("AliVCIMGroupInterface", "Exception in onMethodCall: " + e.getMessage());
            result.error("500", "Unexpected error occurred", null);
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        eventSink.endOfStream();
        eventChannel.setStreamHandler(null);
        groupInterface = null;
        messageInterface = null;
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
