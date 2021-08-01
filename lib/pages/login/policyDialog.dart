import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:listen/utils/ProfileManager_Mock.dart';
import 'package:listen/utils/toast.dart';

class PolicyDialog extends StatefulWidget {
  PolicyDialog({
    this.radius = 8,
    this.code = "",
    this.needCode = false,
    required this.mdFileName,
  })  : assert(mdFileName.contains('.md'),
            'The file must contain the .md extension'),
        super();

  final double radius;
  final String mdFileName;
  final bool needCode;
  final String code;
  @override
  _PolicyDialogState createState() =>
      _PolicyDialogState(this.radius, this.mdFileName, this.needCode);
}

class _PolicyDialogState extends State<PolicyDialog> {
  double radius;
  String mdFileName;
  bool needCode;
  String code = "";
  _PolicyDialogState(this.radius, this.mdFileName, this.needCode);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: Future.delayed(Duration(milliseconds: 150)).then((value) {
                return rootBundle.loadString('assets/$mdFileName');
              }),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Markdown(
                    data: snapshot.data as String,
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          Visibility(
            visible: needCode,
            child: SizedBox(
                height: 40,
                child: TextField(
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: "请输入授权码",
                  ),
                  keyboardType: TextInputType.name,
                  onChanged: (v) {
                    setState(() {
                      code = v;
                    });
                  },
                )),
          ),
          Row(
            children: [
              Expanded(
                  child: SizedBox(
                      height: 50,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        color: Theme.of(context).buttonColor,
                        onPressed: () async {
                          if (needCode) {
                            if (code.isEmpty) {
                              return Utils.toastError("请输入授权码");
                            }
                            var success = await ProfileManager.getInstance()
                                .autoCode(code);
                            if (!success) {
                              return Utils.toastError("授权码错误");
                            }
                          }
                          Navigator.of(context).pop(true);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(radius),
                          ),
                        ),
                        child: Text(
                          "确认",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.button!.color,
                          ),
                        ),
                      ))),
              Expanded(
                  child: SizedBox(
                      height: 50,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        color: Theme.of(context).buttonColor,
                        onPressed: () => Navigator.of(context).pop(false),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(radius),
                          ),
                        ),
                        child: Text(
                          "取消",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.button!.color,
                          ),
                        ),
                      )))
            ],
          )
        ],
      ),
    );
  }
}
