import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ali_vc_interaction_message_platform_interface.dart';

/// An implementation of [AliVcInteractionMessagePlatform] that uses method channels.
class MethodChannelAliVcInteractionMessage
    extends AliVcInteractionMessagePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ali_vc_interaction_message');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> isInited() async {
    final isInited = await methodChannel.invokeMethod<bool>('isInited');
    return isInited ?? false;
  }

  @override
  Future<bool> isLogin() async {
    final isLogin = await methodChannel.invokeMethod<bool>('isLogin');
    return isLogin ?? false;
  }

  Future<int> init(String deviceId, String appId, String appSign) async {
    final isLogin = await methodChannel.invokeMethod<int>('init', {
      'deviceId': deviceId,
      'appId': appId,
      'appSign': appSign,
    });
    return isLogin ?? -1;
  }

  @override
  Future<void> login(
    String userId,
    String nonce,
    String timestamp,
    String appToken,
  ) async {
    await methodChannel.invokeMethod<void>('login', {
      'userId': userId,
      'nonce': nonce,
      'timestamp': timestamp,
      'appToken': appToken,
    });
  }

  @override
  Future<void> logout() async {
    await methodChannel.invokeMethod<void>('logout');
  }

  @override
  Future<void> joinGroup(String groupId) async {
    await methodChannel.invokeMethod<void>('joinGroup', {
      'groupId': groupId,
    });
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    await methodChannel.invokeMethod<void>('leaveGroup', {
      'groupId': groupId,
    });
  }

  @override
  Future<int> unInit() async {
    return await methodChannel.invokeMethod<int>('unInit') ?? -1;
  }
}
