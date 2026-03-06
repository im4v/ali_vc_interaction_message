import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ali_vc_interaction_message_method_channel.dart';

abstract class AliVcInteractionMessagePlatform extends PlatformInterface {
  /// Constructs a AliVcInteractionMessagePlatform.
  AliVcInteractionMessagePlatform() : super(token: _token);

  static final Object _token = Object();

  static AliVcInteractionMessagePlatform _instance =
      MethodChannelAliVcInteractionMessage();

  /// The default instance of [AliVcInteractionMessagePlatform] to use.
  ///
  /// Defaults to [MethodChannelAliVcInteractionMessage].
  static AliVcInteractionMessagePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AliVcInteractionMessagePlatform] when
  /// they register themselves.
  static set instance(AliVcInteractionMessagePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// 获取系统和版本
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  // ========== 检查 ==========

  /// 判断插件是否初始化
  Future<bool> isInited() {
    throw UnimplementedError('isInited() has not been implemented.');
  }

  /// 判断是否登录成功
  Future<bool> isLogin() {
    throw UnimplementedError('isLoginSuccess() has not been implemented.');
  }

  /// 初始化插件
  Future<int> init(
      {String? deviceId, required String appId, required String appSign}) {
    throw UnimplementedError('init() has not been implemented.');
  }

  /// 反初始化
  Future<int> unInit() {
    throw UnimplementedError("unInit() has not been implemented.");
  }

  // ========== 登录 ==========

  /// 登录
  /// [userId] 用户ID
  /// [nonce] 随机数
  /// [timestamp] 时间戳
  /// [role] 角色
  /// [appToken] 应用token
  Future<void> login({
    required String userId,
    required String nonce,
    required String timestamp,
    required String nickName,
    required String avatar,
    String? role,
    required String appToken,
  }) {
    throw UnimplementedError('login() has not been implemented.');
  }

  /// 登出
  Future<void> logout() {
    throw UnimplementedError('logout() has not been implemented.');
  }

  // ========== 群组 ==========

  /// 查询群组消息
  /// [groupId] 群组ID
  Future<void> queryGroupInfo({required String groupId}) {
    throw UnimplementedError('queryGroupInfo() has not been implemented.');
  }

  /// 查询群组所有用户
  /// [groupId] 群组ID
  Future<void> listGroupAllUser({required String groupId, int? nextPageToken}) {
    throw UnimplementedError('listGroupAllUser() has not been implemented.');
  }

  /// 加入群组
  /// [groupId] 群组ID
  Future<void> joinGroup({required String groupId}) {
    throw UnimplementedError('joinGroup() has not been implemented.');
  }

  /// 离开群组
  /// [groupId] 群组ID
  Future<void> leaveGroup({required String groupId}) {
    throw UnimplementedError('leaveGroup() has not been implemented.');
  }

  /// 群组全部禁言
  /// [groupId] 群组ID
  Future<void> muteAll({required String groupId}) {
    throw UnimplementedError("muteAll() has not been implemented.");
  }

  /// 取消群组全部禁言
  /// [groupId] 群组ID
  Future<void> cancelMuteAll({required String groupId}) {
    throw UnimplementedError("cancelMuteAll() has not been implemented.");
  }

  /// 禁言指定用户
  /// [groupId] 群组ID
  /// [userId] 用户ID
  Future<void> muteUser({required String groupId, required String userId}) {
    throw UnimplementedError("muteUser() has not been implemented.");
  }

  /// 取消禁言指定用户
  /// [groupId] 群组ID
  /// [userId] 用户ID
  Future<void> cancelMuteUser(
      {required String groupId, required String userId}) {
    throw UnimplementedError("cancelMuteUser() has not been implemented.");
  }

  /// 查询禁言用户
  /// [groupId] 群组ID
  Future<void> listMuteUsers({required String groupId}) {
    throw UnimplementedError("listMuteUsers() has not been implemented.");
  }

  // ========== 消息 ==========

  /// 获取最近消息
  /// [groupId] 群组ID
  Future<void> listRecentMessage({required String groupId}) {
    throw UnimplementedError("listRecentMessage() has not been implemented.");
  }

  /// 发送群组消息
  /// [groupId] 群组ID
  /// [message] 消息内容
  /// [type] 消息类型
  Future<void> sendGroupMessage(
      {required String groupId, required String message, required int type}) {
    throw UnimplementedError("sendGroupMessage() has not been implemented.");
  }

  /// 发送单聊消息
  /// [groupId] 群组ID
  /// [userId] 用户ID
  /// [message] 消息内容
  /// [type] 消息类型
  Future<void> sendC2cMessage(
      {required String userId, required String message, required int type}) {
    throw UnimplementedError("sendC2cMessage() has not been implemented.");
  }

  /// 删除消息
  /// [groupId] 群组ID
  /// [messageId] 消息ID
  Future<void> deleteMessage(
      {required String groupId, required String messageId}) {
    throw UnimplementedError("deleteMessage() has not been implemented.");
  }

  // ========== 监听 ==========

  /// 添加监听器
  Future<void> addMessageListener() {
    throw UnimplementedError("addMessageListener() has not been implemented.");
  }

  /// 添加群组监听器
  Future<void> addGroupListener() {
    throw UnimplementedError("addGroupListener() has not been implemented.");
  }

  /// 移除消息监听器
  Future<void> removeMessageListener() {
    throw UnimplementedError(
        "removeMessageListener() has not been implemented.");
  }

  /// 移除群组监听器
  Future<void> removeGroupListener() {
    throw UnimplementedError("removeGroupListener() has not been implemented.");
  }
}
