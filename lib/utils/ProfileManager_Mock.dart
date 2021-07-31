import 'package:dio/dio.dart';
import 'package:listen/utils/GenerateTestUserSig.dart';
import 'package:listen/utils/http.dart';

import 'utils.dart';
import 'globalDef.dart' as globalDef;

class UserInfo {
  String phone;
  String name;
  String avatar;
  String userId;
  UserInfo(
      {this.phone = '', this.name = '', this.avatar = '', this.userId = ''});
}

class RepTalkInfo {
  bool success;
  String userId;
  int waitingLength;
  int onlineListeners;
  RepTalkInfo(
      {this.success = false,
      this.userId = "",
      this.waitingLength = 0,
      this.onlineListeners = 0});
}

class ProfileManager {
  static ProfileManager? _instance;

  static getInstance() {
    if (_instance == null) {
      _instance = new ProfileManager();
    }
    return _instance;
  }

  Future<List<UserInfo>> queryUserInfo(String userId) {
    return Future.value([
      UserInfo(
          phone: userId,
          name: userId,
          avatar: Utils.getDefaltAvatarUrl(),
          userId: userId)
    ]);
  }

  Future<UserInfo> querySingleUserInfo(String userId) {
    return Future.value(UserInfo(
        phone: userId,
        name: userId,
        avatar: Utils.getDefaltAvatarUrl(),
        userId: userId));
  }

  Future<bool> listenerLogin(String name, String pwd) async {
    if (Utils.isDebug()) {
      var userId = "2222";
      var userSig =
          GenerateTestUserSig.getInstance().genSig(identifier: userId);
      Utils.setStorageByKey(globalDef.USERID_KEY, userId);
      Utils.setStorageByKey(globalDef.USERSIG_KEY, userSig);
      Utils.setStorageByKey(globalDef.USERROLE_KEY, "listeners");
      return Future.value(true);
    } else {
      try {
        Response response = await dio
            .post('/base/login', data: {'username': name, 'password': pwd});
        print(response);
        if (response.data['code'] == 0) {
          var userId = response.data['data']['user']['ID'].toString();
          var userSig = response.data['data']['userSig'];
          Utils.setStorageByKey(globalDef.USERID_KEY, userId);
          Utils.setStorageByKey(globalDef.USERSIG_KEY, userSig);
          Utils.setStorageByKey(globalDef.USERROLE_KEY, "999");
          return Future.value(true);
        } else {
          return Future.value(false);
        }
      } on DioError catch (e) {
        print(e.message);
        print("获取appId失败");
        return Future.value(false);
      }
    }
  }

  Future<bool> talkerLogin() async {
    if (Utils.isDebug()) {
      var userId = "1111";
      var userSig =
          GenerateTestUserSig.getInstance().genSig(identifier: userId);
      Utils.setStorageByKey(globalDef.USERID_KEY, userId);
      Utils.setStorageByKey(globalDef.USERSIG_KEY, userSig);
      Utils.setStorageByKey(globalDef.USERROLE_KEY, "666");
      return true;
    } else {
      try {
        String udid = Utils.getStorageByKey(globalDef.UDID_KEY) as String;
        if (udid.isEmpty) {
          udid = Utils.getRandomNumber();
          print("首次生成udid: $udid");
          Utils.setStorageByKey(globalDef.UDID_KEY, udid);
        }
        Response response =
            await dio.post('/talker/login', data: {'udid': udid});
        print(response);
        if (response.data['code'] == 0) {
          var userId = response.data['data']['user']['ID'].toString();
          var userSig = response.data['data']['userSig'];
          Utils.setStorageByKey(globalDef.USERID_KEY, userId);
          Utils.setStorageByKey(globalDef.USERSIG_KEY, userSig);
          Utils.setStorageByKey(globalDef.USERROLE_KEY, "talker");
          return true;
        } else {
          return false;
        }
      } on DioError catch (e) {
        print(e.message);
        print("登录失败");
        return false;
      }
    }
  }

  Future<bool> autoCode(String code) async {
    if (Utils.isDebug()) {
      return true;
    } else {
      try {
        Response response =
            await dio.post('/talker/authCode', data: {'code': code});
        if (response.data['code'] == 0) {
          return true;
        }
      } on DioError catch (e) {
        print(e.message);
        print("获取appId失败");
      }
      return false;
    }
  }

  Future<bool> getReady(bool ready) async {
    if (Utils.isDebug()) {
      return true;
    } else {
      try {
        Response response =
            await dio.post('/listener/getReady', data: {'ready': ready});
        if (response.data['code'] == 0) {
          return true;
        }
      } on DioError catch (e) {
        print(e.message);
        print("设置状态失败");
      }
      return false;
    }
  }

  Future<RepTalkInfo> requestCall() async {
    if (Utils.isDebug()) {
      return RepTalkInfo(
          success: true, userId: "2222", waitingLength: 1, onlineListeners: 1);
    } else {
      try {
        Response response = await dio.post('/talker/requestCall');
        if (response.data['code'] == 0) {
          bool success = response.data['data']['success'];
          String userId = response.data['data']['userId'];
          int waitingLength = response.data['data']['waitingLength'];
          int onlineListeners = response.data['data']['onlineListeners'];
          return RepTalkInfo(
              success: success,
              userId: userId,
              waitingLength: waitingLength,
              onlineListeners: onlineListeners);
        }
      } on DioError catch (e) {
        print(e.message);
        print("请求通话失败");
      }
      return RepTalkInfo(
          success: false, userId: "", waitingLength: 0, onlineListeners: 0);
    }
  }
}
