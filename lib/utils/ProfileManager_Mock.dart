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
      var userSig = GenerateTestUserSig.getInstance().genTestSig(userId);
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
          Utils.setStorageByKey(globalDef.USERROLE_KEY, "listeners");
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
      var userSig = GenerateTestUserSig.getInstance().genTestSig(userId);
      Utils.setStorageByKey(globalDef.USERID_KEY, userId);
      Utils.setStorageByKey(globalDef.USERSIG_KEY, userSig);
      Utils.setStorageByKey(globalDef.USERROLE_KEY, "talker");
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
}
