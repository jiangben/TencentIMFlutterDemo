import 'package:flutter/material.dart';
import 'package:listen/common/arrowRight.dart';
import 'package:listen/pages/profile/component/TextWithCommonStyle.dart';
import 'package:url_launcher/url_launcher.dart';

class Blog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        launch('https://cloud.tencent.com/product/im');
      },
      child: Container(
        height: 55,
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(int.parse('ededed', radix: 16)).withAlpha(255),
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
        ),
        child: Row(
          children: [
            TextWithCommonStyle(
              text: "进入开发中论坛",
            ),
            Expanded(
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  ArrowRight(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
