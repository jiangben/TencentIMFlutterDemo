import 'dart:ui';

import 'package:listen/pages/login/policyDialog.dart';
import 'package:listen/utils/ProfileManager_Mock.dart';
import 'package:flutter/material.dart';
import 'package:listen/common/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:listen/utils/toast.dart' as toast;

class TalkerLoginPage extends StatefulWidget {
  @override
  _TalkerLoginPageState createState() => _TalkerLoginPageState();
}

class _TalkerLoginPageState extends State<TalkerLoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(int.parse('006fff', radix: 16)).withAlpha(255),
        title: Text("即刻倾听"),
        centerTitle: true,
        actions: <Widget>[LoginPopUpMenu()],
      ),
      body: Container(
          child: Column(
        children: [
          AppLogo(),
          LoginBtn(),
        ],
      )),
    );
  }
}

class AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 400,
        width: 400,
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image(
            image: AssetImage("images/waiting.png"),
            width: 120.0,
            height: 120.0,
          ),
        ]));
  }
}

class LoginBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
              width: 200.0,
              height: 50.0,
              child: RaisedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // Replace with a Row for horizontal icon + text
                    children: <Widget>[
                      Icon(Icons.phone_android),
                      Text("成年人登录")
                    ],
                  ),
                  color: CommonColors.getThemeColor(),
                  textColor: Colors.white,
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return PolicyDialog(
                          needCode: false,
                          mdFileName: 'privacy_policy.md',
                        );
                      },
                    );
                  })),
          SizedBox(height: 10),
          SizedBox(
              width: 200.0,
              height: 50.0,
              child: RaisedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // Replace with a Row for horizontal icon + text
                  children: <Widget>[Icon(Icons.phone_android), Text("未成年人登录")],
                ),
                color: CommonColors.getThemeColor(),
                textColor: Colors.white,
                onPressed: () async {
                  var success =
                      await ProfileManager.getInstance().talkerLogin();
                  if (success) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return PolicyDialog(
                          needCode: true,
                          mdFileName: 'privacy_policy.md',
                        );
                      },
                    );
                  } else {
                    toast.Utils.toastError("登录失败");
                  }
                },
              )),
        ],
      ),
    );
  }
}

class LoginPopUpMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.add),
      padding: EdgeInsets.all(0),
      offset: Offset(0, 32),
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem<String>>[
          PopupMenuItem<String>(
            height: 30,
            textStyle: TextStyle(
              height: 1,
              color: CommonColors.getTextBasicColor(),
            ),
            child: MenuItem("倾听者登录"),
            value: "manager",
          ),
        ];
      },
      onSelected: (String action) {
        switch (action) {
          case "manager":
            Navigator.pushNamed(context, "/listenerLogin");
            break;
        }
      },
      onCanceled: () {
        print("onCanceled");
      },
    );
  }
}

class MenuItem extends StatelessWidget {
  final String name;
  MenuItem(this.name);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: CommonColors.getBorderColor(),
            style: BorderStyle.solid,
          ),
        ),
      ),
      padding: EdgeInsets.only(top: 6, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Image(
              image: AssetImage('images/person.png'),
              width: 18,
            ),
          ),
          Text(
            name,
            textAlign: TextAlign.start,
            style: TextStyle(
              textBaseline: TextBaseline.alphabetic,
            ),
          ),
        ],
      ),
    );
  }
}
