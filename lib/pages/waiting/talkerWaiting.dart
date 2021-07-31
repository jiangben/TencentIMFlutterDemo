import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listen/TRTCCallingDemo/ui/base/CallTypes.dart';
import 'package:listen/TRTCCallingDemo/ui/base/CallingScenes.dart';
import 'package:listen/common/colors.dart';
import 'package:listen/utils/ProfileManager_Mock.dart';

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
      return;
    } else {
      setState(() {
        onlineListeners = rep.onlineListeners;
        waitingLength = rep.waitingLength;
      });
      new Future.delayed(const Duration(milliseconds: 1000), () async {
        timer = ++timer;
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: CommonColors.getThemeColor(),
          title: Text("即时倾诉"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios), //color: Colors.black
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
          Text(isWaiting ? "正在呼叫" : "已停止呼叫"),
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
