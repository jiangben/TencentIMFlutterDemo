import 'package:flutter/material.dart';
import 'package:listen/TRTCCallingDemo/ui/TRTCCallingContact.dart';
import 'package:listen/TRTCCallingDemo/ui/VideoCall/TRTCCallingVideo.dart';
import 'package:listen/TRTCCallingDemo/ui/base/CallingScenes.dart';
import 'package:listen/pages/home/index.dart';
import 'package:listen/pages/login/listenerLogin.dart';
import 'package:listen/pages/login/talkerLogin.dart';

final String initialRoute = "/";
final Map<String, WidgetBuilder> routes = {
  "/": (context) => IndexPage(),
  "/index": (context) => IndexPage(),
  "/login": (context) => TalkerLoginPage(),
  "/talkerLogin": (context) => TalkerLoginPage(),
  "/listenerLogin": (context) => ListenerLoginPage(),
  "/calling/videoContact": (context) =>
      TRTCCallingContact(CallingScenes.VideoOneVOne),
  "/calling/audioContact": (context) =>
      TRTCCallingContact(CallingScenes.AudioOneVOne),
  "/calling/callingView": (context) => TRTCCallingVideo(),
};
