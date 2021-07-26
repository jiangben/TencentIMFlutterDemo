import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listen/common/colors.dart';

class TalkerWaitingPage extends StatefulWidget {
  // const TalkerWaitingPage({Key? key}) : super(key: key);

  @override
  _TalkerWaitingPageState createState() => _TalkerWaitingPageState();
}

class _TalkerWaitingPageState extends State<TalkerWaitingPage> {
  int waitingLength = 0;
  int onlineListeners = 0;
  bool isWating = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: CommonColors.getThemeColor(),
          title: Text(""),
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
          Text(isWating ? "正在呼叫" : "已停止呼叫"),
          SizedBox(height: 20),
          SizedBox(
              width: 200.0,
              height: 50.0,
              child: RaisedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // Replace with a Row for horizontal icon + text
                  children: <Widget>[
                    Icon(isWating ? Icons.phone_disabled : Icons.phone_enabled),
                    SizedBox(width: 10),
                    Text(isWating ? "取消请求" : "发起请求")
                  ],
                ),
                color: CommonColors.getThemeColor(),
                textColor: Colors.white,
                onPressed: () {
                  setState(() {
                    isWating = !isWating;
                  });
                },
              )),
          SizedBox(height: 20),
        ])));
  }
}
