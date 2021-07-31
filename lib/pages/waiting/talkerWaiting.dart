import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listen/TRTCCallingDemo/model/TRTCCalling.dart';
import 'package:listen/TRTCCallingDemo/ui/base/CallTypes.dart';
import 'package:listen/TRTCCallingDemo/ui/base/CallingScenes.dart';
import 'package:listen/base/DemoSevice.dart';
import 'package:listen/common/colors.dart';
import 'package:listen/utils/ProfileManager_Mock.dart';
import 'package:listen/utils/config.dart';
import 'package:listen/utils/toast.dart' as toast;
import 'package:listen/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:listen/utils/globalDef.dart' as globalDef;
import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:listen/provider/conversion.dart';
import 'package:listen/provider/currentMessageList.dart';
import 'package:listen/provider/friend.dart';
import 'package:listen/provider/friendApplication.dart';
import 'package:listen/provider/groupApplication.dart';
import 'package:listen/provider/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:listen/TRTCCallingDemo/model/TRTCCallingDelegate.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimFriendshipListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimGroupListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSignalingListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';

class TalkerWaitingPage extends StatefulWidget {
  // const TalkerWaitingPage({Key? key}) : super(key: key);

  @override
  _TalkerWaitingPageState createState() => _TalkerWaitingPageState();
}

class _TalkerWaitingPageState extends State<TalkerWaitingPage> {
  int waitingLength = 0;
  int onlineListeners = 0;
  bool isWaiting = false;
  int timer = 0;
  late ProfileManager _profileManager;
  late TRTCCalling sInstance;

  Future<bool?>? showExitConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("提示"),
          content: Text("确定将退出倾听室吗?"),
          actions: <Widget>[
            ElevatedButton(
              child: Text("取消"),
              onPressed: () => Navigator.of(context).pop(false), // 关闭对话框
            ),
            ElevatedButton(
              child: Text("确定"),
              onPressed: () =>
                  //关闭对话框并返回true
                  Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  showWaitingOvertimeDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("提示"),
          content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("当前等待队列$waitingLength人"), Text("预计需要较长时间等待")]),
          actions: <Widget>[
            ElevatedButton(
              child: Text("确定"),
              onPressed: () =>
                  //关闭对话框并返回true
                  Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void apply2Talk() async {
    RepTalkInfo rep = await ProfileManager.getInstance().requestCall();
    if (rep.success) {
      UserInfo userInfo =
          await ProfileManager.getInstance().querySingleUserInfo(rep.userId);
      Navigator.pushNamed(
        context,
        "/calling/callingView",
        arguments: {
          "remoteUserInfo": userInfo,
          "callType": CallTypes.Type_Call_Someone,
          "callingScenes": CallingScenes.AudioOneVOne
        },
      );
      setState(() {
        isWaiting = false;
        timer = 0;
      });

      return;
    } else {
      setState(() {
        onlineListeners = rep.onlineListeners;
        waitingLength = rep.waitingLength;
      });
      new Future.delayed(const Duration(milliseconds: 1000), () async {
        setState(() {
          timer = ++timer;
        });
        if (!isWaiting) {
          return;
        }
        if (timer == 60) {
          showWaitingOvertimeDialog();
        }
        apply2Talk();
      });
    }
  }

  goLoginPage() {
    Navigator.pop(context);
    return true;
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

    var res = await sInstance.initSDK(Config.sdkappid);
    if (res.code != 0) {
      toast.Utils.toastError('SDK初始化失败');
      return;
    }

    initIMListener();

    String loginId = await Utils.getStorageByKey(globalDef.USERID_KEY);
    String userSig = await Utils.getStorageByKey(globalDef.USERSIG_KEY);

    await sInstance.login(loginId, userSig);
    sInstance.unRegisterListener(onTrtcListener);
    sInstance.registerListener(onTrtcListener);
    if (loginId == '') {
      toast.Utils.toastError("请先登录。");
      goLoginPage();
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
    toast.Utils.toast("你被踢下线了");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: CommonColors.getThemeColor(),
          title: Text("即时倾诉"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () async {
              bool isOk = (await this.showExitConfirmDialog())!;
              if (isOk) {
                Navigator.pop(
                  context,
                );
              }
            },
          ),
        ),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
              child: Image(
            image: AssetImage("images/care.png"),
            width: 120.0,
            height: 120.0,
          )),
          SizedBox(height: 20),
          Text("当前倾听者数量：$onlineListeners人空闲"),
          SizedBox(height: 20),
          Text("等待队列：$waitingLength人"),
          SizedBox(height: 20),
          Text(isWaiting ? "正在呼叫 $timer s" : "已停止呼叫"),
          SizedBox(height: 20),
          SizedBox(
              width: 200.0,
              height: 50.0,
              child: RaisedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // Replace with a Row for horizontal icon + text
                  children: <Widget>[
                    Icon(
                        isWaiting ? Icons.phone_disabled : Icons.phone_enabled),
                    SizedBox(width: 10),
                    Text(isWaiting ? "取消请求" : "发起请求")
                  ],
                ),
                color: CommonColors.getThemeColor(),
                textColor: Colors.white,
                onPressed: () {
                  setState(() {
                    isWaiting = !isWaiting;
                  });
                  if (isWaiting) {
                    timer = 0;
                    apply2Talk();
                  }
                },
              )),
          SizedBox(height: 20),
        ])));
  }
}
