import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:listen/pages/conversion/component/addAdvanceMsg.dart';
import 'package:listen/pages/conversion/component/addFaceMsg.dart';
import 'package:listen/pages/conversion/component/addTextMsg.dart';
import 'package:listen/pages/conversion/component/addVoiceMsg.dart';

class MsgInput extends StatelessWidget {
  MsgInput(this.toUser, this.type);
  final String toUser;
  final int type;
  @override
  Widget build(BuildContext context) {
    print("toUser$toUser $type ***** MsgInput");

    return Container(
      height: 55,
      child: Row(
        children: [
          FaceMsg(toUser, type),
          // VoiceMsg(toUser, type),
          TextMsg(toUser, type),
          AdvanceMsg(toUser, type),
        ],
      ),
    );
  }
}
