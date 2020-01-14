import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/LinkTextSpan.dart';

class AboutPage extends StatefulWidget {
  static const String route = '/about';

  @override
  _AboutPageState createState() => _AboutPageState();

}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of( context );
    final TextStyle textStyle = themeData.textTheme.body2;
    final TextStyle linkStyle = themeData.textTheme.body2.copyWith( color: themeData.accentColor );

    return Scaffold(
      appBar: AppBar(
        title: Text( 'About Tidy Weather' ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric( horizontal: 16.0, vertical: 12.0 ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichText(
              text: TextSpan(
                style: textStyle,
                children: <TextSpan>[
                  TextSpan(
                    text: 'Tidy Weather is lovingly crafted by ',
                  ),
                  LinkTextSpan(
                    style: linkStyle,
                    text: 'Gary',
                    url: 'https://pento.net',
                  ),
                  TextSpan(
                    text: '.',
                  ),
                ],
              ),
            ),
            Container(
              height: 20,
            ),
            RichText(
              text: TextSpan(
                style: textStyle,
                children: <TextSpan>[
                  TextSpan(
                    text: 'This is an Open Source application, you can view the source code, report bugs, and contribute fixes in the ',
                  ),
                  LinkTextSpan(
                    style: linkStyle,
                    text: 'Tidy Weather repository',
                    url: 'https://github.com/pento/TidyWeather/',
                  ),
                  TextSpan(
                    text: '.',
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(),
            ),
            RichText(
              text: TextSpan(
                style: textStyle,
                children: <TextSpan>[
                  TextSpan(
                    text: 'Some data in this app is sourced from the ',
                  ),
                  LinkTextSpan(
                    style: linkStyle,
                    text: 'Bureau of Meteorology',
                    url: 'http://www.bom.gov.au/data-access/3rd-party-attribution.shtml',
                  ),
                  TextSpan(
                    text: ', via ',
                  ),
                  LinkTextSpan(
                    style: linkStyle,
                    text: 'the WillyWeather API',
                    url: 'https://www.willyweather.com.au/info/api.html',
                  ),
                  TextSpan(
                    text: '.',
                  ),
                ],
              ),
            ),
            Container(
              height: 20,
            ),
            RichText(
              text: TextSpan(
                style: textStyle,
                children: <TextSpan>[
                  TextSpan(
                    text: 'UV observations courtesy of ARPANSA. ',
                  ),
                  LinkTextSpan(
                    style: linkStyle,
                    text: 'Disclaimer',
                    url: 'https://www.arpansa.gov.au/our-services/monitoring/ultraviolet-radiation-monitoring/ultraviolet-radation-data-information',
                  ),
                  TextSpan(
                    text: '.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
