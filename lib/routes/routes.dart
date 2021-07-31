import 'package:flutter/material.dart';
import 'package:listen/TRTCCallingDemo/ui/TRTCCallingContact.dart';
import 'package:listen/TRTCCallingDemo/ui/VideoCall/TRTCCallingVideo.dart';
import 'package:listen/TRTCCallingDemo/ui/base/CallingScenes.dart';
import 'package:listen/pages/home/index.dart';
import 'package:listen/pages/login/listenerLogin.dart';
import 'package:listen/pages/login/login.dart';
import 'package:listen/pages/login/talkerLogin.dart';
import 'package:listen/pages/waiting/listenerWaiting.dart';
import 'package:listen/pages/waiting/talkerWaiting.dart';

final String initialRoute = "/";
final Map<String, WidgetBuilder> routes = {
  "/": (context) => IndexPage(),
  "/index": (context) => IndexPage(),
  "/login": (context) => TalkerLoginPage(),
  "/talker/login": (context) => TalkerLoginPage(),
  "/listener/login": (context) => ListenerLoginPage(),
  "/talker/waiting": (context) => TalkerWaitingPage(),
  "/listener/waiting": (context) => ListenerWaitingPage(),
  "/calling/videoContact": (context) =>
      TRTCCallingContact(CallingScenes.VideoOneVOne),
  "/calling/audioContact": (context) =>
      TRTCCallingContact(CallingScenes.AudioOneVOne),
  "/calling/callingView": (context) => TRTCCallingVideo(),
};
