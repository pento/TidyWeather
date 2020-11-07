import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkTextSpan extends TextSpan {
  LinkTextSpan(
      {String text,
      List<InlineSpan> children,
      TextStyle style,
      GestureRecognizer recognizer,
      String semanticsLabel,
      String url})
      : super(
          text: text,
          children: children,
          style: style,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              launch(url, forceSafariVC: false);
            },
          semanticsLabel: semanticsLabel,
        );
}
