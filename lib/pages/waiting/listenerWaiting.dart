import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listen/common/colors.dart';

class ListenerWaitingPage extends StatefulWidget {
  // const ListenerWaitingPage({Key? key}) : super(key: key);

  @override
  _ListenerWaitingPageState createState() => _ListenerWaitingPageState();
}

class _ListenerWaitingPageState extends State<ListenerWaitingPage> {
  int waitingLength = 0;
  bool isStanby = true;

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
                onPressed: () {
                  setState(() {
                    isStanby = !isStanby;
                  });
                },
              )),
          SizedBox(height: 20),
        ])));
  }
}
