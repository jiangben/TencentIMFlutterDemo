import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:listen/common/colors.dart';
import 'package:listen/provider/currentMessageList.dart';
import 'package:listen/provider/keybooadshow.dart';
import 'package:listen/utils/toast.dart';

class TextMsg extends StatefulWidget {
  final String toUser;
  final int type;

  TextMsg(this.toUser, this.type);

  @override
  State<StatefulWidget> createState() => TextMsgState();
}

class TextMsgState extends State<TextMsg> {
  bool isRecording = false;
  bool isSend = true;
  TextEditingController inputController = new TextEditingController();
  FlutterPluginRecord recordPlugin = new FlutterPluginRecord();
  OverlayEntry? overlayEntry;
  String voiceIco = "images/voice_volume_1.png";
  void initState() {
    print("widget.toUser${widget.toUser}");

    recordPlugin.responseFromInit.listen((data) {
      if (data) {
      } else {
        Utils.toast("初始化失败");
      }
    });
    recordPlugin.response.listen((data) {
      if (data.msg == "onStop") {
        ///结束录制时会返回录制文件的地址方便上传服务器
        if (isSend) {
          TencentImSDKPlugin.v2TIMManager
              .getMessageManager()
              .sendSoundMessage(
                soundPath: data.path!,
                receiver: (widget.type == 1 ? widget.toUser : ""),
                groupID: (widget.type == 2 ? widget.toUser : ""),
                duration: data.audioTimeLength!.toInt(),
              )
              .then((sendRes) {
            // 发送成功
            if (sendRes.code == 0) {
              String key = (widget.type == 1
                  ? "c2c_${widget.toUser}"
                  : "group_${widget.toUser}");
              List<V2TimMessage> list = new List.empty(growable: true);
              list.add(sendRes.data!);
              Provider.of<CurrentMessageListModel>(context, listen: false)
                  .addMessage(key, list);
              print('发送成功');
            }
          });
        }
      } else if (data.msg == "onStart") {}
    });
    recordPlugin.responseFromAmplitude.listen((data) {
      var voiceData = double.parse(data.msg!);
      setState(() {
        if (voiceData > 0 && voiceData < 0.1) {
          voiceIco = "images/voice_volume_2.png";
        } else if (voiceData > 0.2 && voiceData < 0.3) {
          voiceIco = "images/voice_volume_3.png";
        } else if (voiceData > 0.3 && voiceData < 0.4) {
          voiceIco = "images/voice_volume_4.png";
        } else if (voiceData > 0.4 && voiceData < 0.5) {
          voiceIco = "images/voice_volume_5.png";
        } else if (voiceData > 0.5 && voiceData < 0.6) {
          voiceIco = "images/voice_volume_6.png";
        } else if (voiceData > 0.6 && voiceData < 0.7) {
          voiceIco = "images/voice_volume_7.png";
        } else if (voiceData > 0.7 && voiceData < 1) {
          voiceIco = "images/voice_volume_7.png";
        } else {
          voiceIco = "images/voice_volume_1.png";
        }
        if (overlayEntry != null) {
          overlayEntry!.markNeedsBuild();
        }
      });

      print("振幅大小   " + voiceData.toString() + "  " + voiceIco);
    });
    recordPlugin.initRecordMp3();
    super.initState();
  }

  buildOverLayView(BuildContext context) {
    if (overlayEntry == null) {
      overlayEntry = new OverlayEntry(builder: (content) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.5 - 80,
          left: MediaQuery.of(context).size.width * 0.5 - 80,
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: Opacity(
                opacity: 0.8,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Color(0xff77797A),
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: new Image.asset(
                          voiceIco,
                          width: 100,
                          height: 100,
                          package: 'flutter_plugin_record',
                        ),
                      ),
                      Container(
//                      padding: EdgeInsets.only(right: 20, left: 20, top: 0),
                        child: Text(
                          "手指上滑,取消发送",
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
      Overlay.of(context)!.insert(overlayEntry!);
    }
  }

  onSubmitted(String? s, context) async {
    if (s == '' || s == null) {
      return;
    }
    V2TimValueCallback<V2TimMessage> sendRes;
    if (widget.type == 1) {
      sendRes = await TencentImSDKPlugin.v2TIMManager
          .sendC2CTextMessage(text: s, userID: widget.toUser);
      print("发送信息简介$sendRes");
      inspect(widget);
    } else {
      sendRes = await TencentImSDKPlugin.v2TIMManager
          .sendGroupTextMessage(text: s, groupID: widget.toUser, priority: 1);
    }

    if (sendRes.code == 0) {
      print('发送成功');
      String key = (widget.type == 1
          ? "c2c_${widget.toUser}"
          : "group_${widget.toUser}");
      List<V2TimMessage> list = List.empty(growable: true);
      list.add(sendRes.data!);
      Provider.of<CurrentMessageListModel>(context, listen: false)
          .addMessage(key, list);
      inputController.clear();
    } else {
      print(sendRes.desc);
      Utils.toast("发送失败 ${sendRes.code} ${sendRes.desc}");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboradshow = Provider.of<KeyBoradModel>(context).show;
    return Expanded(
      child: isKeyboradshow
          ? PhysicalModel(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              clipBehavior: Clip.antiAlias,
              child: Container(
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (event) {
                      print("key input");
                      print(event.data.logicalKey.keyId);
                      if (event.runtimeType == RawKeyDownEvent &&
                          (event.logicalKey.keyId == 4295426088)) {
                        onSubmitted(this.inputController.text, context);
                      }
                    },
                    child: TextFormField(
                      controller: inputController,
                      onFieldSubmitted: (inputController) {
                        onSubmitted(this.inputController.text, context);
                      },
                      autocorrect: false,
                      textAlign: TextAlign.left,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.send,
                      cursorColor: CommonColors.getThemeColor(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                          top: 9,
                          bottom: 0,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      minLines: 1,
                    )),
              ),
            )
          : GestureDetector(
              onLongPressStart: (e) async {
                setState(() {
                  isRecording = true;
                  isSend = true;
                });
                buildOverLayView(context);
                await recordPlugin.start();
              },
              onLongPressEnd: (e) async {
                bool isSendLocal = true;
                Utils.toast("${e.localPosition.dx} ${e.localPosition.dy}");
                if (e.localPosition.dx < 0 ||
                    e.localPosition.dy < 0 ||
                    e.localPosition.dy > 40) {
                  // 取消了发送
                  isSendLocal = false;
                  print("取消了");
                }
                try {
                  if (overlayEntry != null) {
                    overlayEntry!.remove();
                    overlayEntry = null;
                  }
                } catch (err) {}
                setState(() {
                  isRecording = false;
                  isSend = isSendLocal;
                });
                await recordPlugin.stop();
              },
              child: Container(
                height: 34,
                color: isRecording
                    ? CommonColors.getGapColor()
                    : CommonColors.getWitheColor(),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '按住说话',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
