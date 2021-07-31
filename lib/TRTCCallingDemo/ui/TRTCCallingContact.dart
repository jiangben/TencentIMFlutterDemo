import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:listen/provider/conversion.dart';
import 'package:listen/provider/currentMessageList.dart';
import 'package:listen/provider/friend.dart';
import 'package:listen/provider/friendApplication.dart';
import 'package:listen/provider/groupApplication.dart';
import 'package:listen/provider/user.dart';
import 'package:listen/utils/toast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:listen/TRTCCallingDemo/model/TRTCCallingDelegate.dart';
import 'package:listen/utils/GenerateTestUserSig.dart';
import 'package:listen/utils/ProfileManager_Mock.dart';
import 'package:listen/utils/config.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimFriendshipListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimGroupListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSignalingListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import '../model/TRTCCalling.dart';
import 'base/CallTypes.dart';
import 'base/CallingScenes.dart';
import 'package:listen/utils/toast.dart' as toast;
import 'package:permission_handler/permission_handler.dart';

class TRTCCallingContact extends StatefulWidget {
  TRTCCallingContact(this.callingScenes, {Key? key}) : super(key: key);
  final CallingScenes callingScenes;

  @override
  _TRTCCallingContactState createState() => _TRTCCallingContactState();
}

class _TRTCCallingContactState extends State<TRTCCallingContact> {
  String searchText = '';
  String myLoginInfoId = '';
  List<UserInfo> userList = [];
  late ProfileManager _profileManager;
  late TRTCCalling sInstance;
  int _meetingNumber = 0;
  goIndex() {
    Navigator.pop(context);
    return true;
  }

  goLoginPage() {
    Navigator.pop(context);
    return true;
  }

  //搜索
  onSearchClick() async {
    List<UserInfo> ls =
        await ProfileManager.getInstance().queryUserInfo(searchText);

    setState(() {
      userList = ls;
    });
  }

  // bool verifyMeetingId(String _meetingNumber) {
  //   String meetId = _meetingNumber.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
  //   if (meetId == '' || meetId == '0') {
  //     return false;
  //   } else if (meetId.toString().length > 10) {
  //     return false;
  //   } else if (!new RegExp(r"[0-9]+$").hasMatch(meetId)) {
  //     return false;
  //   }
  //   return true;
  // }

  //发起通话
  onCallClick(UserInfo userInfo) async {
    if (userInfo.userId == myLoginInfoId) {
      toast.Utils.toastError('不能呼叫自己');
      return;
    }
    // _meetingNumber = Utils.getRandomNumber();
    // if (!verifyMeetingId(_meetingNumber.toString())) {
    //   toast.Utils.toastError('会议号错误');
    //   return;
    // }
    Navigator.pushNamed(
      context,
      "/calling/callingView",
      arguments: {
        "remoteUserInfo": userInfo,
        "callType": CallTypes.Type_Call_Someone,
        "callingScenes": widget.callingScenes
      },
    );
  }

  // 提示浮层
  showToast(text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }

  initUserInfo() async {
    if ((await Permission.camera.request().isGranted &&
        await Permission.microphone.request().isGranted)) {
    } else {
      toast.Utils.toastError('需要获取音视频权限才能进入');
      return;
    }
    _profileManager = await ProfileManager.getInstance();
    sInstance = await TRTCCalling.sharedInstance();

    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    String loginId = prefs.getString("flutter_userID")!;
    GenerateTestUserSig usersig = new GenerateTestUserSig(
      sdkappid: Config.sdkappid,
      key: Config.key,
    );
    String pwdStr = usersig.genSig(identifier: loginId, expire: 86400);
    var res = await sInstance.initSDK(Config.sdkappid);
    if (res.code != 0) {
      toast.Utils.toastError('SDK初始化失败');
      return;
    }

    initIMListener();

    await sInstance.login(loginId, pwdStr);
    sInstance.unRegisterListener(onTrtcListener);
    sInstance.registerListener(onTrtcListener);
    if (loginId == '') {
      toast.Utils.toastError("请先登录。");
      goLoginPage();
    } else {
      setState(() {
        myLoginInfoId = loginId;
      });
    }
  }

  void onRecvNewMessage(V2TimMessage message) {
    try {
      List<V2TimMessage> messageList = List.empty(growable: true);

      messageList.add(message);

      print("c2c_${message.sender}");
      String key;
      if (message.groupID == null) {
        key = "c2c_${message.sender}";
      } else {
        key = "group_${message.groupID}";
      }
      print("conterkey_$key");
      Provider.of<CurrentMessageListModel>(context, listen: false)
          .addMessage(key, messageList);
    } catch (err) {
      print(err);
    }
  }

  void onRecvC2CReadReceipt(List<V2TimMessageReceipt> list) {
    print('收到了新消息 已读回执');
    list.forEach((element) {
      print("已读回执${element.userID} ${element.timestamp}");
      Provider.of<CurrentMessageListModel>(context, listen: false)
          .updateC2CMessageByUserId(element.userID);
    });
  }

  void onSendMessageProgress(V2TimMessage message, int progress) {
// 消息进度
    String key;
    if (message.groupID == null) {
      key = "c2c_${message.userID}";
    } else {
      key = "group_${message.groupID}";
    }
    try {
      Provider.of<CurrentMessageListModel>(
        context,
        listen: false,
      ).addOneMessageIfNotExits(
        key,
        message,
      );
    } catch (err) {
      print("error $err");
    }
    print(
        "消息发送进度 $progress ${message.timestamp} ${message.msgID} ${message.timestamp} ${message.status}");
  }

  void
      onFriendListAddedonFriendListDeletedonFriendInfoChangedonBlackListDeleted() async {
    V2TimValueCallback<List<V2TimFriendInfo>> friendRes =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendList();
    if (friendRes.code == 0) {
      List<V2TimFriendInfo>? newList = friendRes.data;
      if (newList != null && newList.length > 0) {
        Provider.of<FriendListModel>(context, listen: false)
            .setFriendList(newList);
      } else {
        Provider.of<FriendListModel>(context, listen: false)
            .setFriendList(List.empty(growable: true));
      }
    }
  }

  void onFriendApplicationListAdded(List<V2TimFriendApplication> list) {
    // 收到加好友申请,添加双向好友时双方都会周到这个回调，这时要过滤掉type=2的不显示
    print("收到加好友申请");
    List<V2TimFriendApplication> newlist = List.empty(growable: true);
    list.forEach((element) {
      if (element.type != 2) {
        newlist.add(element);
      }
    });
    if (newlist.isNotEmpty) {
      Provider.of<FriendApplicationModel>(context, listen: false)
          .setFriendApplicationResult(newlist);
    }
  }

  Map<String, V2TimConversation> conversationlistToMap(
      List<V2TimConversation> list) {
    Map<int, V2TimConversation> convsersationMap = list.asMap();
    Map<String, V2TimConversation> newConversation = new Map();
    convsersationMap.forEach((key, value) {
      newConversation[value.conversationID] = value;
    });
    return newConversation;
  }

  void onReceiveJoinApplicationonMemberEnter() async {
    V2TimValueCallback<V2TimGroupApplicationResult> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupApplicationList();
    if (res.code == 0) {
      if (res.code == 0) {
        if (res.data!.groupApplicationList!.length > 0) {
          Provider.of<GroupApplicationModel>(context, listen: false)
              .setGroupApplicationResult(res.data!.groupApplicationList);
        }
      }
    } else {
      print("获取加群申请失败${res.desc}");
    }
  }

  initIMListener() {
    V2TIMManager timManager = TencentImSDKPlugin.v2TIMManager;
    //简单监听
    timManager.addSimpleMsgListener(
      listener: new V2TimSimpleMsgListener(
        onRecvC2CCustomMessage: (msgID, sender, customData) {},
        onRecvC2CTextMessage: (msgID, userInfo, text) {},
        onRecvGroupCustomMessage: (msgID, groupID, sender, customData) {},
        onRecvGroupTextMessage: (msgID, groupID, sender, customData) {},
      ),
    );

    //群组监听
    timManager.setGroupListener(
      listener: new V2TimGroupListener(
        onApplicationProcessed: (groupID, opUser, isAgreeJoin, opReason) {},
        onGrantAdministrator: (groupID, opUser, memberList) {},
        onGroupAttributeChanged: (groupID, groupAttributeMap) {},
        onGroupCreated: (groupID) {},
        onGroupDismissed: (groupID, opUser) {},
        onGroupInfoChanged: (groupID, changeInfos) {},
        onGroupRecycled: (groupID, opUser) {},
        onMemberEnter: (groupID, memberList) {
          onReceiveJoinApplicationonMemberEnter();
        },
        onMemberInfoChanged: (groupID, v2TIMGroupMemberChangeInfoList) {},
        onMemberInvited: (groupID, opUser, memberList) {},
        onMemberKicked: (groupID, opUser, memberList) {},
        onMemberLeave: (groupID, member) {},
        onQuitFromGroup: (groupID) {},
        onReceiveJoinApplication: (groupID, member, opReason) {
          onReceiveJoinApplicationonMemberEnter();
        },
        onReceiveRESTCustomData: (groupID, customData) {},
        onRevokeAdministrator: (groupID, opUser, memberList) {},
      ),
    );
    //高级消息监听
    timManager.getMessageManager().addAdvancedMsgListener(
          listener: new V2TimAdvancedMsgListener(
            onRecvC2CReadReceipt: (receiptList) {
              onRecvC2CReadReceipt(receiptList);
            },
            onRecvMessageRevoked: (msgID) {},
            onRecvNewMessage: (msg) {
              onRecvNewMessage(msg);
            },
            onSendMessageProgress: (message, progress) {
              onSendMessageProgress(message, progress);
            },
          ),
        );

    timManager.getFriendshipManager().setFriendListener(
          listener: new V2TimFriendshipListener(
            onBlackListAdd: (infoList) {},
            onBlackListDeleted: (userList) {
              onFriendListAddedonFriendListDeletedonFriendInfoChangedonBlackListDeleted();
            },
            onFriendApplicationListAdded: (applicationList) {
              onFriendApplicationListAdded(applicationList);
            },
            onFriendApplicationListDeleted: (userIDList) {},
            onFriendApplicationListRead: () {},
            onFriendInfoChanged: (infoList) {
              onFriendListAddedonFriendListDeletedonFriendInfoChangedonBlackListDeleted();
            },
            onFriendListAdded: (users) {
              onFriendListAddedonFriendListDeletedonFriendInfoChangedonBlackListDeleted();
            },
            onFriendListDeleted: (userList) {
              onFriendListAddedonFriendListDeletedonFriendInfoChangedonBlackListDeleted();
            },
          ),
        );
    //会话监听
    timManager.getConversationManager().setConversationListener(
          listener: new V2TimConversationListener(
            onConversationChanged: (conversationList) {
              try {
                Provider.of<ConversionModel>(context, listen: false)
                    .setConversionList(conversationList);
                //如果当前会话在使用中，也更新一下

              } catch (e) {}
            },
            onNewConversation: (conversationList) {
              try {
                Provider.of<ConversionModel>(context, listen: false)
                    .setConversionList(conversationList);
                //如果当前会话在使用中，也更新一下

              } catch (e) {}
            },
            onSyncServerFailed: () {},
            onSyncServerFinish: () {},
            onSyncServerStart: () {},
          ),
        );
    timManager.getSignalingManager().addSignalingListener(
          listener: new V2TimSignalingListener(
            onInvitationCancelled: (inviteID, inviter, data) {},
            onInvitationTimeout: (inviteID, inviteeList) {},
            onInviteeAccepted: (inviteID, invitee, data) {},
            onInviteeRejected: (inviteID, invitee, data) {},
            onReceiveNewInvitation:
                (inviteID, inviter, groupID, inviteeList, data) {},
          ),
        );
    print("初始化完成了");
  }

  onTrtcListener(type, params) async {
    switch (type) {
      case TRTCCallingDelegate.onInvited:
        {
          UserInfo userInfo = await _profileManager
              .querySingleUserInfo(params["sponsor"].toString());
          Navigator.pushNamed(context, "/calling/callingView", arguments: {
            "remoteUserInfo": userInfo,
            "callType": CallTypes.Type_Being_Called,
            "callingScenes": params['type'] == TRTCCalling.typeVideoCall
                ? CallingScenes.VideoOneVOne
                : CallingScenes.AudioOneVOne
          });
        }
        break;
      case TRTCCallingDelegate.onKickedOffline:
        onKickedOffline();
        break;
      case TRTCCallingDelegate.onSelfInfoUpdated:
        onSelfInfoUpdated();
        break;
    }
  }

  void onKickedOffline() async {
// 被踢下线
    // 清除本地缓存，回到登录页TODO
    try {
      Provider.of<ConversionModel>(context, listen: false).clear();
      Provider.of<UserModel>(context, listen: false).clear();
      Provider.of<CurrentMessageListModel>(context, listen: false).clear();
      Provider.of<FriendListModel>(context, listen: false).clear();
      Provider.of<FriendApplicationModel>(context, listen: false).clear();
      Provider.of<GroupApplicationModel>(context, listen: false).clear();
      // 去掉存的一些数据
      Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
      SharedPreferences prefs = await _prefs;
      prefs.remove('token');
      prefs.remove('sessionId');
      prefs.remove('phone');
      prefs.remove('code');
    } catch (err) {
      print("someError");
      print(err);
    }
    print("被踢下线了");
    Utils.toast("你被踢下线了");
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pushNamedAndRemoveUntil(
        "/",
        ModalRoute.withName('/'),
      );
    });
  }

  void onSelfInfoUpdated() async {
    //自己信息更新，从新获取自己的信息；
    V2TimValueCallback<String> usercallback =
        await TencentImSDKPlugin.v2TIMManager.getLoginUser();
    V2TimValueCallback<List<V2TimUserFullInfo>> infos = await TencentImSDKPlugin
        .v2TIMManager
        .getUsersInfo(userIDList: [usercallback.data!]);
    if (infos.code == 0) {
      Provider.of<UserModel>(context, listen: false).setInfo(infos.data![0]);
    }
  }

  @override
  void initState() {
    super.initState();
    initUserInfo();
  }

  @override
  void dispose() {
    super.dispose();
    sInstance.unRegisterListener(onTrtcListener);
  }

  getGuideSearchWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Center(
          child: Image.asset(
            'images/callingDemo/search.png',
            height: 97,
          ),
        ),
        Center(
          child: Text('搜索添加已注册用户'),
        ),
        Center(
          child: Text('以发起通话'),
        ),
      ],
    );
  }

  getSearchResult() {
    return CustomScrollView(
      slivers: [
        SliverFixedExtentList(
          itemExtent: 55.0,
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              var userInfo = userList[index];
              return Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(44),
                        child: Image.network(
                          userInfo.avatar,
                          height: 44,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                        child: Text(
                          userInfo.name,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      // ignore: deprecated_member_use
                      child: RaisedButton(
                        color: Colors.green,
                        onPressed: () {
                          onCallClick(userInfo);
                        },
                        child: Text(
                          '呼叫',
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                        shape: RoundedRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
            childCount: userList.length,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var searchBtn = Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(19.0),
              ),
              color: Color.fromRGBO(244, 245, 249, 1.000),
            ),
            child: TextField(
                style: TextStyle(color: Colors.black),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "搜索用户ID",
                  hintStyle:
                      TextStyle(color: Color.fromRGBO(187, 187, 187, 1.000)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => this.searchText = value),
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 20),
          // ignore: deprecated_member_use
          child: RaisedButton(
            color: Color.fromRGBO(0, 110, 255, 1.000),
            shape: RoundedRectangleBorder(
              side: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            onPressed: () {
              onSearchClick();
            },
            child: Text(
              '搜索',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
    var myInfo = Row(
      children: [
        Container(
          constraints: BoxConstraints(minHeight: 12, minWidth: 3),
          margin: EdgeInsets.only(left: 20, right: 10),
          color: Color.fromRGBO(153, 153, 153, 1.000),
        ),
        Text('您的用户ID是 $myLoginInfoId'),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: widget.callingScenes == CallingScenes.VideoOneVOne
            ? Text('视频通话')
            : Text('语音通话'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () async {
            goIndex();
          },
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: WillPopScope(
        onWillPop: () async {
          return goIndex();
        },
        child: Column(
          children: [
            searchBtn,
            myInfo,
            Expanded(
              flex: 1,
              child: getSearchResult(), //getGuideSearchWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
