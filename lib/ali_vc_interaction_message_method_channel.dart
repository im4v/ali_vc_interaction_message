import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ali_vc_interaction_message_platform_interface.dart';

/// An implementation of [AliVcInteractionMessagePlatform] that uses method channels.
class MethodChannelAliVcInteractionMessage
    extends AliVcInteractionMessagePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ali_vc_interaction_message');

  /// 获取平台版本
  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  // ========== 检查 ==========

  /// 是否初始化
  @override
  Future<bool> isInited() async {
    final isInited = await methodChannel.invokeMethod<bool>('isInited');
    return isInited ?? false;
  }

  /// 是否登录
  @override
  Future<bool> isLogin() async {
    final isLogin = await methodChannel.invokeMethod<bool>('isLogin');
    return isLogin ?? false;
  }

  /// 初始化
  @override
  Future<int> init(
      {String? deviceId,
      required String appId,
      required String appSign}) async {
    final isLogin = await methodChannel.invokeMethod<int>('init', {
      'deviceId': deviceId,
      'appId': appId,
      'appSign': appSign,
    });
    return isLogin ?? -1;
  }

  /// 反初始化
  @override
  Future<int> unInit() async {
    return await methodChannel.invokeMethod<int>('unInit') ?? -1;
  }

  // ========== 登录 ==========

  /// 登录
  @override
  Future<void> login({
    required String userId,
    required String nonce,
    required String timestamp,
    String? role,
    required String nickName,
    required String avatar,
    required String appToken,
  }) async {
    await methodChannel.invokeMethod<void>('login', {
      'userId': userId,
      'nonce': nonce,
      'timestamp': timestamp,
      'nickName': nickName,
      'avatar': avatar,
      'role': role,
      'appToken': appToken,
    });
  }

  /// 注销登录
  @override
  Future<void> logout() async {
    await methodChannel.invokeMethod<void>('logout');
  }

  // ========== 群组 ==========

  /// 查询群组消息
  /// [groupId] 群组ID
  @override
  Future<void> queryGroupInfo({required String groupId}) {
    return methodChannel.invokeListMethod('queryGroupInfo', {
      'groupId': groupId,
    });
  }

  /// 查询群组所有用户
  /// [groupId] 群组ID
  @override
  Future<void> listGroupAllUser({required String groupId, int? nextPageToken}) {
    return methodChannel.invokeListMethod(
        'listGroupAllUser',
        {
          'groupId': groupId,
          'nextPageToken': nextPageToken,
        }..removeWhere((key, val) => val == null));
  }

  /// 加入群组
  @override
  Future<void> joinGroup({required String groupId}) async {
    await methodChannel.invokeMethod<void>('joinGroup', {
      'groupId': groupId,
    });
  }

  /// 退出群组
  @override
  Future<void> leaveGroup({required String groupId}) async {
    await methodChannel.invokeMethod<void>('leaveGroup', {
      'groupId': groupId,
    });
  }

  /// 群组全部禁言
  @override
  Future<void> muteAll({required String groupId}) async {
    await methodChannel.invokeMethod<void>('muteAll', {
      'groupId': groupId,
    });
  }

  /// 取消全体禁言
  @override
  Future<void> cancelMuteAll({required String groupId}) async {
    await methodChannel.invokeMethod<void>('cancelMuteAll', {
      'groupId': groupId,
    });
  }

  /// 禁言指定用户
  @override
  Future<void> muteUser(
      {required String groupId, required String userId}) async {
    await methodChannel.invokeMethod<void>('muteUser', {
      'groupId': groupId,
      'userId': userId,
    });
  }

  /// 取消禁言指定用户
  @override
  Future<void> cancelMuteUser(
      {required String groupId, required String userId}) async {
    await methodChannel.invokeMethod<void>('cancelMuteUser', {
      'groupId': groupId,
      'userId': userId,
    });
  }

  /// 查询禁言用户
  /// [groupId] 群组ID
  Future<void> listMuteUsers({required String groupId}) async {
    await methodChannel.invokeMethod<void>('listMuteUsers', {
      'groupId': groupId,
    });
  }

  // ========== 消息 ==========

  /// 获取最近消息
  @override
  Future<void> listRecentMessage({required String groupId}) async {
    await methodChannel.invokeMethod<void>('listRecentMessage', {
      'groupId': groupId,
    });
  }

  /// 发送群组消息
  @override
  Future<void> sendGroupMessage(
      {required String groupId,
      required String message,
      required int type}) async {
    await methodChannel.invokeMethod<void>('sendGroupMessage', {
      'groupId': groupId,
      'message': message,
      'type': type,
    });
  }

  /// 发送 单聊消息
  @override
  Future<void> sendC2cMessage(
      {required String userId,
      required String message,
      required int type}) async {
    await methodChannel.invokeMethod<void>('sendC2cMessage', {
      'userId': userId,
      'message': message,
      'type': type,
    });
  }

  /// 删除消息
  @override
  Future<void> deleteMessage(
      {required String groupId, required String messageId}) async {
    await methodChannel.invokeMethod<void>('deleteMessage', {
      'groupId': groupId,
      'messageId': messageId,
    });
  }

  // ========== 监听 ==========

  /// 添加消息监听器
  @override
  Future<void> addMessageListener() {
    return methodChannel.invokeListMethod<void>('addMessageListener');
  }

  /// 移除消息监听器
  @override
  Future<void> removeMessageListener() async {
    await methodChannel.invokeMethod<void>('removeMessageListener');
  }

  /// 添加群组监听器
  @override
  Future<void> addGroupListener() {
    return methodChannel.invokeListMethod<void>('addGroupListener');
  }

  /// 移除群组监听器
  @override
  Future<void> removeGroupListener() async {
    await methodChannel.invokeMethod<void>('removeGroupListener');
  }
}
