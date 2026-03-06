import 'dart:async';

import 'package:flutter/services.dart';

import 'ali_vc_interaction_message_platform_interface.dart';

// class ReceiveData {
//   final int code;
//   final String method;
//   final String msg;
//   final String? data;
//
//   ReceiveData({
//     required this.code,
//     required this.method,
//     required this.msg,
//     this.data,
//   });
// }

// 类型定义 - 接收函数
// typedef TypeOnRecvData = void Function(ReceiveData data);

class AliVcInteractionMessage {
  // event channel 定义
  static const eventChannel = EventChannel('ali_vc_interaction_message_event');

  // 创建单例构造函数
  factory AliVcInteractionMessage() => _instance;
  static final AliVcInteractionMessage _instance =
      AliVcInteractionMessage._internal();
  AliVcInteractionMessage._internal();

  // 订阅
  StreamSubscription? _streamSubscription;
  // 接收函数
  // TypeOnRecvData? _onRecvData;
  final _subscriptions = <StreamSubscription>[];
  Stream? _broadcastStream;

  /// 监听事件
  /// [listener] 接收函数
  StreamSubscription addHandlerListen() {
    // 如果广播流还没有创建，就创建一个
    _broadcastStream ??=
        eventChannel.receiveBroadcastStream().asBroadcastStream();

    StreamSubscription subscription = _broadcastStream!.listen(null);
    _subscriptions.add(subscription);
    return subscription;
  }

  /// 移除指定监听事件
  void removeHandlerListen(StreamSubscription? subscription) {
    if (subscription != null && _subscriptions.contains(subscription)) {
      subscription.cancel();
      _subscriptions.remove(subscription);
      // return true;
    }
    // return false;
  }

  /// 清空监听事件
  void clearHandlerListen() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// 获取系统和版本
  Future<String?> getPlatformVersion() {
    return AliVcInteractionMessagePlatform.instance.getPlatformVersion();
  }

  // ========== 检查 ==========

  /// 是否初始化
  Future<bool> isInited() {
    return AliVcInteractionMessagePlatform.instance.isInited();
  }

  /// 是否登录
  Future<bool> isLogin() {
    return AliVcInteractionMessagePlatform.instance.isLogin();
  }

  /// 初始化
  /// [deviceId] 设备ID
  /// [appId] 应用ID
  /// [appSign] 应用签名
  /// 初始化返回非0，表示初始化失败，其中1001:重复初始化、1002:创建底层引擎失败、-1:底层重复初始化、-2:初始化配置信息有误
  Future<int> init(
      {String? deviceId = '', required String appId, required String appSign}) {
    return AliVcInteractionMessagePlatform.instance
        .init(deviceId: deviceId, appId: appId, appSign: appSign);
  }

  /// 反初始化
  Future<int> unInit() {
    return AliVcInteractionMessagePlatform.instance.unInit();
  }

  // ========== 登录 ==========

  /// 登录
  /// [userId] 用户ID
  /// [nonce] 随机数
  /// [timestamp] 时间戳
  /// [appToken] 应用token
  /// [role] 角色，为admin时，表示该用户可以调用管控接口,可为空
  Future<void> login({
    required String userId,
    required String nonce,
    required String timestamp,
    String? role,
    required String nickName,
    required String avatar,
    required String appToken,
  }) {
    return AliVcInteractionMessagePlatform.instance.login(
        userId: userId,
        nonce: nonce,
        nickName: nickName,
        avatar: avatar,
        timestamp: timestamp,
        role: role,
        appToken: appToken);
  }

  /// 登出
  Future<void> logout() {
    return AliVcInteractionMessagePlatform.instance.logout();
  }

  // ========== 群组 ==========

  /// 查询群组消息
  /// [groupId] 群组ID
  Future<void> queryGroupInfo({required String groupId}) {
    return AliVcInteractionMessagePlatform.instance
        .queryGroupInfo(groupId: groupId);
  }

  /// 查询群组所有用户
  /// [groupId] 群组ID
  Future<void> listGroupAllUser({required String groupId, int? nextPageToken}) {
    return AliVcInteractionMessagePlatform.instance
        .listGroupAllUser(groupId: groupId, nextPageToken: nextPageToken);
  }

  /// 加入群组
  /// [groupId] 群组ID
  Future<void> joinGroup({required String groupId}) {
    return AliVcInteractionMessagePlatform.instance.joinGroup(groupId: groupId);
  }

  /// 离开群组
  /// [groupId] 群组ID
  Future<void> leaveGroup({required String groupId}) {
    return AliVcInteractionMessagePlatform.instance
        .leaveGroup(groupId: groupId);
  }

  /// 群组全部禁言
  /// [groupId] 群组ID
  Future<void> muteAll({required String groupId}) {
    return AliVcInteractionMessagePlatform.instance.muteAll(groupId: groupId);
  }

  /// 取消全体禁言
  /// [groupId] 群组ID
  Future<void> cancelMuteAll({required String groupId}) {
    return AliVcInteractionMessagePlatform.instance
        .cancelMuteAll(groupId: groupId);
  }

  /// 禁言指定用户
  /// [groupId] 群组ID
  /// [userId] 用户ID
  Future<void> muteUser({required String groupId, required String userId}) {
    return AliVcInteractionMessagePlatform.instance
        .muteUser(groupId: groupId, userId: userId);
  }

  /// 取消禁言指定用户
  /// [groupId] 群组ID
  /// [userId] 用户ID
  Future<void> cancelMuteUser(
      {required String groupId, required String userId}) {
    return AliVcInteractionMessagePlatform.instance
        .cancelMuteUser(groupId: groupId, userId: userId);
  }

  /// 查询禁言用户
  /// [groupId] 群组ID
  Future<void> listMuteUsers({required String groupId}) {
    return AliVcInteractionMessagePlatform.instance
        .listMuteUsers(groupId: groupId);
  }

  // ========== 消息 ==========

  /// 查询最近消息
  /// [groupId] 群组ID
  Future<void> listRecentMessage({required String groupId}) {
    return AliVcInteractionMessagePlatform.instance
        .listRecentMessage(groupId: groupId);
  }

  /// 发送群组消息
  /// [groupId] 群组ID
  /// [message] 消息内容
  Future<void> sendGroupMessage(
      {required String groupId, required String message, required int type}) {
    return AliVcInteractionMessagePlatform.instance
        .sendGroupMessage(groupId: groupId, message: message, type: type);
  }

  /// 发送 单聊消息
  /// [userId] 用户ID
  /// [message] 消息内容
  Future<void> sendC2cMessage(
      {required String userId, required String message, required int type}) {
    return AliVcInteractionMessagePlatform.instance
        .sendC2cMessage(userId: userId, message: message, type: type);
  }

  /// 删除消息
  /// [messageId] 消息ID
  Future<void> deleteMessage(
      {required String groupId, required String messageId}) {
    return AliVcInteractionMessagePlatform.instance
        .deleteMessage(groupId: groupId, messageId: messageId);
  }

  /// 卸载插件
  Future<void> dispose() async {
    clearHandlerListen();
    await unInit();
    // _streamSubscription?.cancel();
    // _streamSubscription = null;
    // _onRecvData = null;
  }

  /// 接收函数
  // void _listenStream(value) {
  //   debugPrint("Received From Native:  $value\n");
  //   _onRecvData?.call(ReceiveData(
  //       code: value['code'] ?? '',
  //       method: value['method'] ?? '',
  //       msg: value['msg'] ?? '',
  //       data: value['data']));
  // }

  // ========== 监听 ==========

  /// 添加消息监听器
  Future<void> addMessageListener() {
    return AliVcInteractionMessagePlatform.instance.addMessageListener();
  }

  /// 移除消息监听器
  Future<void> removeMessageListener() {
    return AliVcInteractionMessagePlatform.instance.removeMessageListener();
  }

  /// 添加群组监听器
  Future<void> addGroupListener() {
    return AliVcInteractionMessagePlatform.instance.addGroupListener();
  }

  /// 移除群组监听器
  Future<void> removeGroupListener() {
    return AliVcInteractionMessagePlatform.instance.removeGroupListener();
  }
}
