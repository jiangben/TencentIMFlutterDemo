import 'package:flutter/material.dart';
import 'package:listen/TRTCCallingDemo/ui/TRTCCallingContact.dart';
import 'package:listen/TRTCCallingDemo/ui/VideoCall/TRTCCallingVideo.dart';
import 'package:listen/TRTCCallingDemo/ui/base/CallingScenes.dart';
import 'package:listen/pages/login/listenerLogin.dart';
import 'package:listen/pages/login/login.dart';
import 'package:listen/pages/login/talkerLogin.dart';

final String initialRoute = "/";
final Map<String, WidgetBuilder> routes = {
  "/": (context) => LoginPage(),
  "/index": (context) => LoginPage(),
  "/login": (context) => LoginPage(),
  "/talkerLogin": (context) => TalkerLoginPage(),
  "/listenLogin": (context) => ListenerLoginPage(),
  "/calling/videoContact": (context) =>
      TRTCCallingContact(CallingScenes.VideoOneVOne),
  "/calling/audioContact": (context) =>
      TRTCCallingContact(CallingScenes.AudioOneVOne),
  "/calling/callingView": (context) => TRTCCallingVideo(),
};
