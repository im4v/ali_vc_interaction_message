import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ali_vc_interaction_message/ali_vc_interaction_message.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _aliVcInteractionMessagePlugin = AliVcInteractionMessage();

  @override
  void initState() {
    super.initState();
    _aliVcInteractionMessagePlugin.listen((map) {
      if (map['code'] == 200) {
        if (map['method'] == 'joinGroup') {
          print('加入群组成功');
        } else if (map['method'] == 'leaveGroup') {
          print('退出群组成功');
        }
      }
    });
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _aliVcInteractionMessagePlugin.getPlatformVersion() ??
              'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Center(
              child: Text('Running on: $_platformVersion\n'),
            ),
            ElevatedButton(
                onPressed: () async {
                  try {
                    var result =
                        await _aliVcInteractionMessagePlugin.isInited();
                    if (result) {
                      // 弹出消息
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('已注册'),
                          duration: Duration(seconds: 2), // 显示时长
                        ),
                      );
                    } else {
                      // 弹出消息
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('未注册'),
                          duration: Duration(seconds: 2), // 显示时长
                        ),
                      );
                    }
                  } on PlatformException {
                    // 弹出消息
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('操作失败'),
                        duration: Duration(seconds: 2), // 显示时长
                      ),
                    );
                  }
                },
                child: const Text("查看是否初始化")),
            ElevatedButton(
                onPressed: () {
                  // _aliVcInteractionMessagePlugin.init('0', '', '');
                },
                child: Text("初始化Ali引擎"))
          ],
        ),
      ),
    );
  }
}
