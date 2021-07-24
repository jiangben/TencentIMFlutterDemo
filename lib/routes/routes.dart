import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin_example/TRTCCallingDemo/ui/TRTCCallingContact.dart';
import 'package:tencent_im_sdk_plugin_example/TRTCCallingDemo/ui/VideoCall/TRTCCallingVideo.dart';
import 'package:tencent_im_sdk_plugin_example/TRTCCallingDemo/ui/base/CallingScenes.dart';
import 'package:tencent_im_sdk_plugin_example/pages/home/home.dart';
import 'package:tencent_im_sdk_plugin_example/pages/login/login.dart';

final String initialRoute = "/";
final Map<String, WidgetBuilder> routes = {
  "/": (context) => LoginPage(),
  "/index": (context) => LoginPage(),
  "/login": (context) => LoginPage(),
  "/calling/videoContact": (context) =>
      TRTCCallingContact(CallingScenes.VideoOneVOne),
  "/calling/audioContact": (context) =>
      TRTCCallingContact(CallingScenes.AudioOneVOne),
  "/calling/callingView": (context) => TRTCCallingVideo(),
};
