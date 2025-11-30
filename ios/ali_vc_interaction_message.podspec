#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ali_vc_interaction_message.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ali_vc_interaction_message'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for Aliyun live interaction message'
  s.description      = <<-DESC
Flutter plugin for Aliyun live interaction message
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
 # 添加你的公共头文件
  s.public_header_files = 'Classes/*.h'

  s.dependency 'Flutter'
#   添加你的公共 OC 依赖
  s.dependency 'AliVCInteractionMessage'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'


end
