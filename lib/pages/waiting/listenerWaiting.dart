import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listen/common/colors.dart';
import 'package:listen/utils/ProfileManager_Mock.dart';
import 'package:listen/utils/toast.dart';

class ListenerWaitingPage extends StatefulWidget {
  // const ListenerWaitingPage({Key? key}) : super(key: key);

  @override
  _ListenerWaitingPageState createState() => _ListenerWaitingPageState();
}

class _ListenerWaitingPageState extends State<ListenerWaitingPage> {
  int waitingLength = 0;
  bool isStanby = false;

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
                onPressed: () {
                  Navigator.of(context).pop(true);
                }),
          ],
        );
      },
    );
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
            image: AssetImage("images/listener.png"),
            width: 120.0,
            height: 120.0,
          )),
          SizedBox(height: 20),
          Text("当前倾诉者排队数量：$waitingLength"),
          SizedBox(height: 20),
          Text(isStanby ? "已上线" : "已离线"),
          SizedBox(height: 20),
          SizedBox(
              width: 200.0,
              height: 50.0,
              child: RaisedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // Replace with a Row for horizontal icon + text
                  children: <Widget>[
                    Icon(isStanby ? Icons.pause : Icons.play_arrow),
                    SizedBox(width: 10),
                    Text(isStanby ? "离开一下" : "开始倾听")
                  ],
                ),
                color: CommonColors.getThemeColor(),
                textColor: Colors.white,
                onPressed: () async {
                  var success =
                      await ProfileManager.getInstance().getReady(!isStanby);
                  if (!success) {
                    return Utils.toastError("网络错误");
                  }
                  setState(() {
                    isStanby = !isStanby;
                  });
                },
              )),
          SizedBox(height: 20),
        ])));
  }
}
