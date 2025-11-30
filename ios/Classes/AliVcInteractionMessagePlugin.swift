import Flutter
import UIKit
import AliVCInteractionMessage


public class AliVcInteractionMessagePlugin: NSObject, FlutterPlugin,FlutterStreamHandler {
    var eventSink : FlutterEventSink?

    
 
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = AliVcInteractionMessagePlugin()

    let channel = FlutterMethodChannel(name: "ali_vc_interaction_message", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "ali_vc_interaction_message_event", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)
    registrar.addMethodCallDelegate(instance, channel: channel)
      
  }

    
    /// FlutterStreamHandler
    ///
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
        case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
        case "init":
            if let args = call.arguments as? [String:Any] {
                let config = AliVCIMEngineConfig();
                config.deviceId = args["deviceId"] as! String;
                config.appId = args["appId"] as! String;
                config.appSign = args["appSign"] as! String;
                config.logLevel = AliVCIMLogLevel.debug;
                let code = AliVCIMEngine.shared().setup(config)
                // 初始化返回非0，表示初始化失败，其中1001:重复初始化、1002:创建底层引擎失败、-1:底层重复初始化、-2:初始化配置信息有误

                if code==0 || code==1001 {
                    eventSink?(["code":200,"method":"init","msg":"成功"])
    //                result(["code":200,"method":"init","msg":"success"])
                }else{
                    eventSink?(["code":500,"method":"init","msg":"初始化失败"])

                }
                  
            }else{
                eventSink?(["code":500,"method":"init","msg":"无效参数"])
            }
       
        case "login":
                if let args = call.arguments as? [String:Any] {
                    let req = AliVCIMLoginReq()
                    let user = AliVCIMUser()
                    user.userId = args["userId"] as! String
                    let authToken = AliVCIMAuthToken()
                    authToken.token = args["appToken"] as! String
                    authToken.timestamp =  Int(args["timestamp"] as! String)!
                    authToken.nonce = (args["nonce"] as! String)
                    req.currentUser = user
                    req.authToken = authToken
                    AliVCIMEngine.shared().login(req){ (error) in
                        if error==nil {
                            self.eventSink?(["code":200,"method":"login","msg":"成功"])
                        }else{
                            self.eventSink?(["code":500,"method":"login","msg":error!.localizedDescription])
                            
                        }
                    }
                }else{
                    self.eventSink?(["code":500,"method":"login","msg":"无效参数"])

                }
            
            case "isInited":
                result(AliVCIMEngine.shared().isInited())
            case "isLogin":
                result((AliVCIMEngine.shared().isLogin()))
            case "isLogout":
                result(AliVCIMEngine.shared().isLogout())
            case "logout":
                AliVCIMEngine.shared().logout(){(error) in if error==nil {
                    self.eventSink?(["code":200,"method":"logout","msg":"成功"])
                }else{
                    self.eventSink?(["code":500,"method":"logout","msg":error!.localizedDescription])

                }}

            case "joinGroup":
                if let args = call.arguments as? [String:Any] {
                    let req = AliVCIMJoinGroupReq();
                    req.groupId = args["groupId"] as! String;
                    let manager = AliVCIMEngine.shared().getGroupManager();
                    manager?.joinGroup(req) { req, error in
                        if error==nil {
                            self.eventSink?(["code":200,"method":"joinGroup","msg":"成功"])
                        }else{
                            self.eventSink?(["code":500,"method":"joinGroup","msg":error!.localizedDescription])

                        }
                    };
                }else{
                    self.eventSink?(["code":500,"method":"joinGroup","msg":"无效参数"])

                }
                    
            case "leaveGroup":
                if let args = call.arguments as? [String:Any] {
                let req = AliVCIMLeaveGroupReq();
                req.groupId = args["groupId"] as! String;
                let manager = AliVCIMEngine.shared().getGroupManager();
                manager?.leaveGroup(req) { error in
                    if error==nil {
                        self.eventSink?(["code":200,"method":"leaveGroup","msg":"成功"])
                    }else{
                        self.eventSink?(["code":500,"method":"leaveGroup","msg":error!.localizedDescription])

                    }
                }
        }else{
            self.eventSink?(["code":500,"method":"leaveGroup","msg":"无效参数"])

        }
           

    default:
        result(FlutterMethodNotImplemented)
    }
  }
}
