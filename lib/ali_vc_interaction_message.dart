import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ali_vc_interaction_message_platform_interface.dart';

// 类型定义 - 接收函数
typedef TypeOnRecvData = void Function(Map<Object?, Object?> value);

class AliVcInteractionMessage {
  // event channel 定义
  static const eventChannel = EventChannel('ali_vc_interaction_message_event');
  // 订阅
  StreamSubscription? _streamSubscription;
  // 接收函数
  TypeOnRecvData? _onRecvData;

  void listen(TypeOnRecvData? listener) {
    _onRecvData = listener;
    _streamSubscription =
        eventChannel.receiveBroadcastStream().listen(_listenStream);
  }

  Future<String?> getPlatformVersion() {
    return AliVcInteractionMessagePlatform.instance.getPlatformVersion();
  }

  Future<bool> isInited() {
    return AliVcInteractionMessagePlatform.instance.isInited();
  }

  Future<int> init(String deviceId, String appId, String appSign) {
    return AliVcInteractionMessagePlatform.instance
        .init(deviceId, appId, appSign);
  }

  /// 登录
  Future<void> login(
    String userId,
    String nonce,
    String timestamp,
    String appToken,
  ) {
    return AliVcInteractionMessagePlatform.instance
        .login(userId, nonce, timestamp, appToken);
  }

  /// 登出
  Future<void> logout() {
    return AliVcInteractionMessagePlatform.instance.logout();
  }

  /// 加入群组
  Future<void> joinGroup(String groupId) {
    return AliVcInteractionMessagePlatform.instance.joinGroup(groupId);
  }

  /// 离开群组
  Future<void> leaveGroup(String groupId) {
    return AliVcInteractionMessagePlatform.instance.leaveGroup(groupId);
  }

  /// 反初始化
  Future<int> unInit() {
    return AliVcInteractionMessagePlatform.instance.unInit();
  }

  /// 卸载插件
  Future<void> dispose() async {
    await unInit();
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _onRecvData = null;
  }

  /// 接收函数
  void _listenStream(value) {
    debugPrint("Received From Native:  $value\n");
    _onRecvData?.call(value);
  }
}
