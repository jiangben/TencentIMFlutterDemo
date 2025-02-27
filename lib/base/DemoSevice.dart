import 'package:flutter/material.dart';
import 'package:listen/TRTCCallingDemo/model/TRTCCalling.dart';
import 'package:listen/TRTCCallingDemo/model/TRTCCallingDelegate.dart';
import 'package:listen/TRTCCallingDemo/ui/base/CallTypes.dart';
import 'package:listen/TRTCCallingDemo/ui/base/CallingScenes.dart';
import 'package:listen/provider/user.dart';
import 'package:listen/utils/ProfileManager_Mock.dart';
import 'package:listen/utils/config.dart';

class DemoSevice {
  static DemoSevice? _instance;

  late TRTCCalling _tRTCCallingService;
  late ProfileManager _profileManager;
  late GlobalKey<NavigatorState> _navigatorKey;
  bool _isRegisterListener = false;
  bool _isSDKInit = false;
  DemoSevice() {
    initTrtc();
  }
  initTrtc() async {
    _tRTCCallingService = await TRTCCalling.sharedInstance();
    _profileManager = await ProfileManager.getInstance();
  }

  static sharedInstance() {
    if (_instance == null) {
      _instance = new DemoSevice();
    }
    return _instance;
  }

  setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  start() async {
    if (_isRegisterListener) {
      _tRTCCallingService.unRegisterListener(onTrtcListener);
    }

    var res = await _tRTCCallingService.initSDK(Config.sdkappid);
    if (res.code == 0) {
      _isSDKInit = true;
    }
  }

  onTrtcListener(type, params) async {
    switch (type) {
      case TRTCCallingDelegate.onInvited:
        {
          BuildContext context = _navigatorKey.currentState!.overlay!.context;
          UserModel userInfo = (await _profileManager
              .querySingleUserInfo(params["sponsor"].toString())) as UserModel;
          Navigator.pushReplacementNamed(
            context,
            "/calling/callingView",
            arguments: {
              "remoteUserInfo": userInfo,
              "callType": CallTypes.Type_Being_Called,
              "callingScenes": params['type'] == TRTCCalling.typeVideoCall
                  ? CallingScenes.VideoOneVOne
                  : CallingScenes.AudioOneVOne
            },
          );
        }
        break;
    }
  }
}
