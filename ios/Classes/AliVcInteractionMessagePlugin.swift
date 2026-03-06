import Flutter
import UIKit
import AliVCInteractionMessage
import YYModel


public class AliVcInteractionMessagePlugin: NSObject, FlutterPlugin,FlutterStreamHandler,AliVCIMGroupListenerProtocol,AliVCIMMessageListenerProtocol {
    var eventSink : FlutterEventSink?
    var currentMethod:String?


  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = AliVcInteractionMessagePlugin()

    let channel = FlutterMethodChannel(name: "ali_vc_interaction_message", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "ali_vc_interaction_message_event", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)
    registrar.addMethodCallDelegate(instance, channel: channel)

  }


    fileprivate func queryGroupInfo(_ call: FlutterMethodCall) {
        if let args = call.arguments as? [String:Any] {
            let req = AliVCIMQueryGroupReq();
            req.groupId = args["groupId"] as! String;
            let manager = AliVCIMEngine.shared().getGroupManager();

            manager?.queryGroup(req) { res, error in
                if error==nil {
                    self.handleEventSinkData(method: call.method, data: self.encodeData2String(info: res))
                }else{
                    self.handleEventSinkData(code: 500,method: call.method, msg: error!.localizedDescription)
                }
            };
        }else{
            handleEventSinkData(code: 500,method: call.method, msg: "无效参数")
        }
    }

    fileprivate func listGroupAllUser(_ call: FlutterMethodCall) {
        if let args = call.arguments as? [String:Any],let groupId = args["groupId"] {
            let req = AliVCIMListGroupUserReq();
            req.groupId = groupId as! String;
            if(args["nextPageToken"] != nil){
                req.nextPageToken = Int(args["nextPageToken"] as! String)!
            }
            req.pageSize = 10
            let manager = AliVCIMEngine.shared().getGroupManager();
            manager?.listGroupUser(req) { res, error in
                if error==nil {
                    self.handleEventSinkData(method: call.method, data: self.encodeData2String(info: res ))
                }else{
                    self.handleEventSinkData(code: 500,method: call.method, msg: error!.localizedDescription)

                }
            };
        }else{
            handleEventSinkData(code: 500,method: call.method, msg: "无效参数")

        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        currentMethod = call.method
        switch call.method {
            case "getPlatformVersion":
                result("iOS " + UIDevice.current.systemVersion)
            case "init":
                initEngine(call)
            case "login":
                login(call)
            case "isInited":
                result(AliVCIMEngine.shared().isInited())
            case "isLogin":
                result((AliVCIMEngine.shared().isLogin()))
            case "isLogout":
                result(AliVCIMEngine.shared().isLogout())
            case "logout":
                logout(call)
            case "queryGroupInfo":
                queryGroupInfo(call)
            case "listGroupAllUser":
                listGroupAllUser(call)

            case "joinGroup":
                joinGroup(call)
            case "leaveGroup":
                leaveGroup(call)
            case "addMessageListener":

                addMessageListener(call)
            case "removeMessageListener":

                removeMessageListener(call)
            case "addGroupListener":
                addGroupListener(call)
            case "removeGroupListener":
                removeGroupListener(call)
            case "muteAll":
                muteAll(call)
            case "cancelMuteAll":
                cancelMuteAll(call)
            case "muteUser":
                muteUser(call)
            case "cancelMuteUser":
                cancelMuteUser(call)
            case "sendC2CMessage":
                sendC2CMessage(call)
            case "sendGroupMessage":
                sendGroupMessage(call)
            case "deleteMessage":
                deleteMessage(call)
            case "listRecentMessage":
                listRecentMessage(call)

            default:
                result(FlutterMethodNotImplemented)
    }
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

    /// AliVCIMGroupListenerProtocol
    public func im(onGroupMemberChanged info: AliVCImGroupMemberChangeInfo) {
        handleEventSinkData(code: 200,method: "onMemberChange",msg: "成功",data: encodeData2String(info: info))

    }

    public func imGroup(_ groupId: String, onExited reason: Int32) {
        handleEventSinkData(code: 200,method: "onExit",msg: "成功",data: reason.description)

    }

    public func imGroup(_ groupId: String, onMuteChanged status: AliVCIMGroupMuteStatus) {
        handleEventSinkData(code: 200,method: "onMuteChange",msg: "成功",data: encodeData2String(info: status))

    }

    public func imGroup(_ groupId: String, onInfoChanged status: AliVCIMGroupInfoStatus) {
        handleEventSinkData(code: 200,method: "onInfoChange",msg: "成功",data: encodeData2String(info: status))

    }


    /// AliVCIMMessageListenerProtocol
    public func onIMReceivedC2CMessage(_ message: AliVCIMMessage) {
        handleEventSinkData(code: 200,method: "onRecvC2cMessage",msg: "成功",data: encodeData2String(info: message))

    }

    public func onIMReceivedGroupMessage(_ message: AliVCIMMessage) {
        handleEventSinkData(code: 200,method: "onRecvGroupMessage",msg: "成功",data: encodeData2String(info: message))
    }

    public func onIMDeleteMessage(_ messageId: String, groupId: String) {
//        收到消息撤回
        handleEventSinkData(code: 200,method: "onDeleteGroupMessage",msg: "成功",data: "")

    }

    public func onIMReceivedStreamMessage(_ message: AliVCIMStreamMessage) {
        handleEventSinkData(code: 200,method: "onIMReceivedStreamMessage",data: "")

    }

    public func onIMStreamMessage(_ messageId: String, receivedEnd endCode: Int32, subCode: Int32, endMsg: String) {
        handleEventSinkData(code: 200,method: "onIMStreamMessage",data: "")

    }


    /// 通过eventSink传回相关方法的返回结果
    private func handleEventSinkData(code:Int = 200,method:String?=nil,msg:String="成功",data:String? = nil){
        self.eventSink?(["code":code,"method":method ?? currentMethod ?? "","msg":msg,"data":data ?? ""])

    }

    private func encodeData2String(info:NSObject?) -> String{
        guard let json = info?.yy_modelToJSONString() else { return "" }
        return json

    }


    fileprivate func cancelMuteAll(_ call: FlutterMethodCall) {
        if let args = call.arguments as? [String:Any] {
            if let groupManager = AliVCIMEngine.shared().getGroupManager() {
                let req = AliVCIMCancelMuteAllReq()
                req.groupId = args["groupId"] as! String;
                groupManager.cancelMuteAll(req) { error in
                    if error==nil {
                        self.handleEventSinkData(method: call.method, )
                    }else{
                        self.handleEventSinkData(code: 500,method: call.method, msg: error!.localizedDescription)

                    }
                }
            }else{
                handleEventSinkData(code: 500,method: call.method, msg: "groupManager为空")

            }
        }else{
            handleEventSinkData(code: 500,method: call.method, msg: "无效参数")

        }
    }

    fileprivate func muteAll(_ call: FlutterMethodCall) {
        if let args = call.arguments as? [String:Any] {
            if let groupManager = AliVCIMEngine.shared().getGroupManager() {
                let req = AliVCIMMuteAllReq()
                req.groupId = args["groupId"] as! String;
                groupManager.muteAll(req) { error in
                    if error==nil {
                        self.handleEventSinkData(method: call.method, )
                    }else{
                        self.handleEventSinkData(code: 500,method: call.method, msg: error!.localizedDescription)

                    }
                }
            }else{
                self.handleEventSinkData(code: 500,method: call.method, msg: "groupManager为空")

            }
        }else{
            handleEventSinkData(code: 500,method: call.method, msg: "无效参数")

        }
    }

    fileprivate func joinGroup(_ call: FlutterMethodCall) {
        if let args = call.arguments as? [String:Any] {
            let req = AliVCIMJoinGroupReq();
            req.groupId = args["groupId"] as! String;

            if let manager = AliVCIMEngine.shared().getGroupManager(){
                manager.joinGroup(req) { res, error in
                    if error==nil {
                        self.handleEventSinkData(method: call.method, data:self.encodeData2String(info: res))
                    }else{
                        self.handleEventSinkData(code: 500,method: call.method, msg: error!.localizedDescription)
                    }
                };
            }else{
                handleEventSinkData(code: 500,method: call.method, msg: "getGroupManager出错")

            };

        }else{
            handleEventSinkData(code: 500,method: call.method, msg: "无效参数")

        }
    }

    fileprivate func leaveGroup(_ call: FlutterMethodCall) {
        if let args = call.arguments as? [String:Any] {
            let req = AliVCIMLeaveGroupReq();
            req.groupId = args["groupId"] as! String;
            if let manager = AliVCIMEngine.shared().getGroupManager() {
                manager.leaveGroup(req) { error in
                    if error==nil {
                        self.handleEventSinkData(method: call.method, )
                    }else{
                        self.handleEventSinkData(code: 500,method: call.method, msg: error!.localizedDescription)

                    }
                }
            }else{
                handleEventSinkData(code: 500,method: call.method, msg: "getGroupManager出错")

            }

        }else{
            handleEventSinkData(code: 500,method: call.method, msg: "无效参数")

        }
    }

    fileprivate func login(_ call: FlutterMethodCall) {
        if let args = call.arguments as? [String:Any] ,let appToken = args["appToken"] ,let timestamp = args["timestamp"],let userId = args["userId"],let nickName = args["nickName"],let avatar = args["avatar"]{
            let req = AliVCIMLoginReq()
            let user = AliVCIMUser()
            let userEx = ["nickName":nickName as! String,"avatar":avatar as! String]

//            user.userExtension = userEx.description

            let userExData = try! JSONSerialization.data(withJSONObject: userEx,options: .prettyPrinted)

            if let exStr = String(data: userExData, encoding: .utf8) {
                user.userExtension = exStr
            }

            user.userId = userId as! String
            let authToken = AliVCIMAuthToken()
            authToken.token = appToken as! String
            authToken.role = args["role"] as? String
            authToken.timestamp =  Int(timestamp as! String)!
            authToken.nonce = args["nonce"] as? String

            req.currentUser = user
            req.authToken = authToken
            AliVCIMEngine.shared().login(req){ (error) in
                if error==nil {
                    self.handleEventSinkData(method: call.method, )
                }else{
                    self.handleEventSinkData(code: 500,method: call.method, msg: error!.localizedDescription)
                }
            }
        }else{
            handleEventSinkData(code: 500,method: call.method, msg: "无效参数")

        }
    }

    fileprivate func initEngine(_ call: FlutterMethodCall) {
        if let args = call.arguments as? [String:Any] {
            let config = AliVCIMEngineConfig();
            config.deviceId = args["deviceId"] as! String;
            config.appId = args["appId"] as! String;
            config.appSign = args["appSign"] as! String;
            config.logLevel = AliVCIMLogLevel.error;
            let code = AliVCIMEngine.shared().setup(config)
            // 初始化返回非0，表示初始化失败，其中1001:重复初始化、1002:创建底层引擎失败、-1:底层重复初始化、-2:初始化配置信息有误
            handleEventSinkData(method: call.method, data:  code.description)
//            if code==0 || code==1001 {
//                handleEventSinkData(data: encodeData2String(info: code))
//            }else{
//                handleEventSinkData(code: 500,msg: "初始化失败")
//            }

        }else{
            handleEventSinkData(code: 500,method: call.method, msg: "无效参数")
        }
    }

    fileprivate func logout(_ call: FlutterMethodCall) {
        AliVCIMEngine.shared().logout(){(error) in if error==nil {
            self.handleEventSinkData(method: call.method, )
        }else{
            self.handleEventSinkData(code: 500,method: call.method, msg: error!.localizedDescription)
        }}
    }

    fileprivate func cancelMuteUser(_ call: FlutterMethodCall) {
        if let args = call.arguments as? [String:Any],let groupId = args["groupId"], let userId = args["userId"] {
            if let groupManager = AliVCIMEngine.shared().getGroupManager() {
                let req = AliVCIMCancelMuteUserReq()
                req.groupId = groupId as! String;
                req.userList = [userId as! String];
                groupManager.cancelMuteUser(req) { error in
                    if error==nil {
                        self.handleEventSinkData(method: call.method, )
                    }else{
                        self.handleEventSinkData(code:500,method: call.method, msg:error!.localizedDescription)
                    }
                }
            }else{
                handleEventSinkData(code:500,method: call.method, msg:"groupManager为空",)
            }
        }else{
            handleEventSinkData(code:500,method: call.method, msg:"无效参数",)
        }
    }

    fileprivate func sendGroupMessage(_ call: FlutterMethodCall) {
        if let args = call.arguments as? [String:Any],let groupId = args["groupId"], let message = args["message"], let type = args["type"] {
            if let msgManager = AliVCIMEngine.shared().getMessageManager() {
                let req = AliVCIMSendMessageToGroupReq()
                req.data = message as! String
                req.type = type as! Int32
                req.groupId = groupId as! String
                msgManager.sendGroupMessage(req) { res, error in
                    if error==nil {
                        self.handleEventSinkData(method: call.method, data: self.encodeData2String(info: res))
                    }else{
                        self.handleEventSinkData(code:500,method: call.method, msg:error!.localizedDescription)
                    }
                }

            }else{
                self.handleEventSinkData(code:500,method: call.method, msg:"groupManager为空",)
            }
        }else{
            self.handleEventSinkData(code:500,method: call.method, msg:"无效参数",)
        }
    }

    fileprivate func sendC2CMessage(_ call: FlutterMethodCall) {
        if let args = call.arguments as? [String:Any],let groupId = args["groupId"], let message = args["message"], let type = args["type"], let userId = args["userId"] {
            if let msgManager = AliVCIMEngine.shared().getMessageManager() {
                let req = AliVCIMSendMessageToUserReq()
                req.data = message as! String
                req.type = type as! Int32
                req.reveiverId = userId as! String
                msgManager.sendC2CMessage(req) { res, error in
                    if error==nil {
                        self.handleEventSinkData(method: call.method, data: self.encodeData2String(info: res))
                    }else{
                        self.handleEventSinkData(code:500,method: call.method, msg:error!.localizedDescription)
                    }
                }

            }else{
                self.handleEventSinkData(code:500,method: call.method, msg:"groupManager为空",)
            }
        }else{
            self.handleEventSinkData(code:500,method: call.method, msg:"无效参数",)
        }
    }

    fileprivate func deleteMessage(_ call: FlutterMethodCall) {
        if let args = call.arguments as? [String:Any],let messageId = args["messageId"] ,let groupId = args["groupId"] {
            if let msgManager = AliVCIMEngine.shared().getMessageManager() {
                let req = AliVCIMDeleteMessageReq()
                req.groupId = groupId as! String
                req.messageId = messageId as! String
                msgManager.deleteMessage(req) { error in
                    if error==nil {
                        self.handleEventSinkData(method: call.method, )
                    }else{
                        self.handleEventSinkData(code:500,method: call.method, msg:error!.localizedDescription,)
                    }
                }

            }else{
                self.handleEventSinkData(code:500,method: call.method, msg:"msgManager为空",)
            }
        }else{
            self.handleEventSinkData(code:500,method: call.method, msg:"无效参数",)
        }
    }

    fileprivate func listRecentMessage(_ call: FlutterMethodCall) {
        if let args = call.arguments as? [String:Any],let groupId = args["groupId"] {
            if let msgManager = AliVCIMEngine.shared().getMessageManager() {
                let req = AliVCIMListRecentMessageReq()
                req.groupId = groupId as! String
                msgManager.listRecentMessage(req) {response, error in
                    if error==nil {
                        self.handleEventSinkData(method: call.method, data: self.encodeData2String(info: response))
                    }else{
                        self.handleEventSinkData(code:500,method: call.method, msg:error!.localizedDescription)
                    }
                }
            }else{
                self.handleEventSinkData(code:500,method: call.method, msg:"groupManager为空")
            }
        }else{
            self.handleEventSinkData(code:500,method: call.method, msg:"无效参数")
        }
    }

    fileprivate func muteUser(_ call: FlutterMethodCall) {
        if let args = call.arguments as? [String:Any],let groupId = args["groupId"], let userId = args["userId"] {
            if let groupManager = AliVCIMEngine.shared().getGroupManager() {
                let req = AliVCIMMuteUserReq()
                req.groupId = groupId as! String;
                req.userList = [userId as! String];
                groupManager.muteUser(req) { error in
                    if error==nil {
                        self.handleEventSinkData(method: call.method, )
                    }else{
                        self.handleEventSinkData(code:500,method: call.method, msg:error!.localizedDescription)
                    }
                }
            }else{
                self.handleEventSinkData(code:500,method: call.method, msg:"groupManager为空")
            }
        }else{
            self.handleEventSinkData(code:500,method: call.method, msg:"无效参数")
        }
    }

    fileprivate func removeGroupListener(_ call: FlutterMethodCall) {
        if let groupManager = AliVCIMEngine.shared().getGroupManager() {
            groupManager.removeListener(self)

            self.handleEventSinkData(method: call.method, )

        }else{
            self.handleEventSinkData(code: 500,method: call.method, msg: "groupManager为空")
        }
    }

    fileprivate func removeMessageListener(_ call: FlutterMethodCall) {
        if let msgManager = AliVCIMEngine.shared().getMessageManager() {
            msgManager.removeListener(self)
            self.handleEventSinkData()
        }else{
            self.handleEventSinkData(code: 500,method: call.method, msg: "msgManager为空")
        }
    }

    fileprivate func addMessageListener(_ call: FlutterMethodCall) {
        if let msgManager = AliVCIMEngine.shared().getMessageManager() {
            msgManager.addListener(self)
            self.handleEventSinkData()

        }else{
            self.handleEventSinkData(code: 500,method: call.method, msg: "msgManager为空")

        }
    }

    fileprivate func addGroupListener(_ call: FlutterMethodCall) {
        if let groupManager = AliVCIMEngine.shared().getGroupManager() {
            groupManager.addListener(self)
            self.handleEventSinkData()
        }else{
            self.handleEventSinkData(code: 500,method: call.method, msg: "groupManager为空")
        }
    }

}
