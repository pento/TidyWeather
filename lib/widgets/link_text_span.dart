import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Generates a TextSpan that opens a URL when tapped.
class LinkTextSpan extends TextSpan {
  /// Constructor. Takes the same parameters as TextSpan, with the addition
  /// of a [url] parameter, which contains the URL to open when the text is
  /// tapped.
  LinkTextSpan(
      {String text,
      List<InlineSpan> children,
      TextStyle style,
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
