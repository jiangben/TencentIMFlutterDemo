import 'dart:ui';
// import 'package:device_info/device_info.dart';

import 'package:flutter/material.dart';
import 'package:listen/common/colors.dart';
import 'package:listen/utils/ProfileManager_Mock.dart';
import 'package:listen/pages/waiting/listenerWaiting.dart';
import 'package:listen/utils/toast.dart';
// import 'package:tencent_tpns_oppo_push_plugin/enum/importance.dart';
// import 'package:tencent_tpns_oppo_push_plugin/tencent_tpns_oppo_push_plugin.dart';
// import 'package:tencent_tpns_vivo_push_plugin/tencent_tpns_vivo_push_plugin.dart';
// import 'package:tencent_tpns_xiaomi_push_plugin/tencent_tpns_xiaomi_push_plugin.dart';

var timLogo = AssetImage("images/logo.png");

class ListenerLoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListenerLoginPage();
}

class _ListenerLoginPage extends State<ListenerLoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: new AppLayout(),
    );
  }
}

class AppLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppLogo(),
        Expanded(
          child: LoginForm(),
        )
      ],
    );
  }
}

class AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 192.0,
      color: CommonColors.getThemeColor(),
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(
        top: 108.0,
      ),
      child: Row(
        children: <Widget>[
          Container(
            height: 90,
            width: 90,
            child: Image(
              image: timLogo,
              width: 90.0,
              height: 90.0,
            ),
          ),
          Container(
            height: 90.0,
            padding: EdgeInsets.only(
              top: 10,
            ),
            child: Column(
              children: <Widget>[
                Text(
                  '倾听者登录',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 28,
                  ),
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          )
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  void initState() {
    super.initState();
  }

  String name = '';
  String pwd = '';
  bool isGeted = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 40, 16, 0),
      child: Form(
        child: Column(
          children: [
            TextField(
              autofocus: false,
              decoration: InputDecoration(
                labelText: "用户名",
                hintText: "请输入用户名",
                icon: Icon(Icons.person),
              ),
              keyboardType: TextInputType.name,
              onChanged: (v) {
                setState(() {
                  name = v;
                });
              },
            ),
            TextField(
              autofocus: false,
              decoration: InputDecoration(
                labelText: "密码",
                hintText: "请输入密码",
                icon: Icon(Icons.password),
              ),
              keyboardType: TextInputType.text,
              onChanged: (v) {
                setState(() {
                  pwd = v;
                });
              },
            ),
            Container(
              margin: EdgeInsets.only(
                top: 28,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RaisedButton(
                      padding: EdgeInsets.only(
                        top: 15,
                        bottom: 15,
                      ),
                      child: Text("登录"),
                      color: CommonColors.getThemeColor(),
                      textColor: Colors.white,
                      onPressed: () async {
                        var success = await ProfileManager.getInstance()
                            .listenerLogin(name, pwd);
                        if (success) {
                          Navigator.pushNamed(context, "/listener/waiting");
                        } else {
                          Utils.toastError("登录失败,请重试");
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(),
            )
          ],
        ),
      ),
    );
  }
}
