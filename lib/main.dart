import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:listen/custom_animation.dart';

import 'package:listen/pages/login/login.dart';
import 'package:listen/provider/conversion.dart';
import 'package:listen/provider/currentMessageList.dart';
import 'package:listen/provider/friend.dart';
import 'package:listen/provider/friendApplication.dart';
import 'package:listen/provider/groupApplication.dart';
import 'package:listen/provider/keybooadshow.dart';
import 'package:listen/provider/user.dart';
import './routes/routes.dart' as router;

// 应用初始化时就加在登录页

void main() {
  // 先设置状态栏样式
  SystemUiOverlayStyle style = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  );
  SystemChrome.setSystemUIOverlayStyle(style);
  // 看看有没有sessionID和token;如果有，直接登录了
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConversionModel()),
        ChangeNotifierProvider(create: (_) => UserModel()),
        ChangeNotifierProvider(create: (_) => CurrentMessageListModel()),
        ChangeNotifierProvider(create: (_) => FriendListModel()),
        ChangeNotifierProvider(create: (_) => FriendApplicationModel()),
        ChangeNotifierProvider(create: (_) => GroupApplicationModel()),
        ChangeNotifierProvider(create: (_) => KeyBoradModel()),
      ],
      child: MaterialApp(
        builder: EasyLoading.init(),
        initialRoute: router.initialRoute,
        routes: router.routes,
      ),
    ),
  );
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false
    ..customAnimation = CustomAnimation();
}
