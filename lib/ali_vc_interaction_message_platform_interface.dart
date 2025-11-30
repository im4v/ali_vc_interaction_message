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

  /// 判断插件是否初始化
  Future<bool> isInited() {
    throw UnimplementedError('isInited() has not been implemented.');
  }

  /// 判断是否登录成功
  Future<bool> isLogin() {
    throw UnimplementedError('isLoginSuccess() has not been implemented.');
  }

  /// 初始化插件
  Future<int> init(String deviceId, String appId, String appSign) {
    throw UnimplementedError('init() has not been implemented.');
  }

  /// 登录
  Future<void> login(
    String userId,
    String nonce,
    String timestamp,
    String appToken,
  ) {
    throw UnimplementedError('login() has not been implemented.');
  }

  /// 登出
  Future<void> logout() {
    throw UnimplementedError('logout() has not been implemented.');
  }

  /// 加入群组
  Future<void> joinGroup(String groupId) {
    throw UnimplementedError('joinGroup() has not been implemented.');
  }

  /// 离开群组
  Future<void> leaveGroup(String groupId) {
    throw UnimplementedError('leaveGroup() has not been implemented.');
  }

  /// 反初始化
  Future<int> unInit() {
    throw UnimplementedError("unInit() has not been implemented.");
  }
}
