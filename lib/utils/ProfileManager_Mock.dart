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
  int userId;
  // int waitingLength;
  // int onlineListeners;
  RepTalkInfo({this.success = false, this.userId = 0});
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
      var userId = "7";
      var userSig =
          GenerateTestUserSig.getInstance().genSig(identifier: userId);
      Utils.setStorageByKey(globalDef.USERID_KEY, userId);
      Utils.setStorageByKey(globalDef.USERSIG_KEY, userSig);
      Utils.setStorageByKey(globalDef.USERROLE_KEY, "listeners");
      return true;
    } else {
      try {
        Response response = await dio
            .post('/base/login', data: {'username': name, 'password': pwd});
        print(response);
        if (response.data['code'] == 0) {
          var token = response.data['data']['token'];
          dio.options.headers['x-token'] = token;
          var userId = response.data['data']['user']['ID'].toString();
          var userSig = response.data['data']['user']['userSig'];
          Utils.setStorageByKey(globalDef.USERID_KEY, userId);
          Utils.setStorageByKey(globalDef.USERSIG_KEY, userSig);
          Utils.setStorageByKey(globalDef.USERROLE_KEY, "999");
          return true;
        } else {
          return false;
        }
      } on DioError catch (e) {
        print(e.message);
        print("获取appId失败");
        return false;
      }
    }
  }

  Future<bool> talkerLogin() async {
    if (Utils.isDebug()) {
      var userId = "6";
      var userSig =
          GenerateTestUserSig.getInstance().genSig(identifier: userId);
      Utils.setStorageByKey(globalDef.USERID_KEY, userId);
      Utils.setStorageByKey(globalDef.USERSIG_KEY, userSig);
      Utils.setStorageByKey(globalDef.USERROLE_KEY, "666");
      return true;
    } else {
      try {
        String udid = await Utils.getStorageByKey(globalDef.UDID_KEY);
        if (udid.isEmpty) {
          udid = Utils.getRandomNumber();
          print("首次生成udid: $udid");
          Utils.setStorageByKey(globalDef.UDID_KEY, udid);
        }
        Response response =
            await dio.post('/talker/login', data: {'udid': udid});
        print(response);
        if (response.data['code'] == 0) {
          var token = response.data['data']['token'];
          dio.options.headers['x-token'] = token;
          var userId = response.data['data']['user']['ID'].toString();
          var userSig = response.data['data']['user']['userSig'];
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
        return false;
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
        return false;
      }
      return false;
    }
  }

  Future<RepTalkInfo> requestCall() async {
    if (Utils.isDebug()) {
      return RepTalkInfo(success: true, userId: 7);
    } else {
      try {
        String userId = await Utils.getStorageByKey(globalDef.USERID_KEY);
        Response response = await dio
            .post('/talker/requestCall', data: {'userId': int.parse(userId)});
        print(response);
        if (response.data['code'] == 0) {
          int listenerId = response.data['data']['userId'];
          // int waitingLength = response.data['data']['waitingLength'];
          // int onlineListeners = response.data['data']['onlineListeners'];
          return RepTalkInfo(success: true, userId: listenerId);
        }
      } on DioError catch (e) {
        print(e.message);
        print("请求通话失败");
      }
      return RepTalkInfo(success: false, userId: 0);
    }
  }

  Future<int> getOnlineListenersSum() async {
    if (Utils.isDebug()) {
      return 1;
    } else {
      try {
        Response response = await dio.post('/talker/onlineListeners');
        if (response.data['code'] == 0) {
          int onlineListeners = response.data['data'];
          return onlineListeners;
        }
      } on DioError catch (e) {
        print(e.message);
        print("获取亲听着数量失败");
      }
    }
    return 0;
  }
}
