import 'package:flutter/material.dart';

import '../widgets/link_text_span.dart';

/// The about page.
class AboutPage extends StatefulWidget {
  /// The route for this page in the Navigator API.
  static const String route = '/about';

  /// Constructor.
  const AboutPage({Key key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextStyle textStyle = themeData.textTheme.bodyText1;
    final TextStyle linkStyle =
        themeData.textTheme.bodyText1.copyWith(color: themeData.accentColor);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Tidy Weather'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichText(
              text: TextSpan(
                style: textStyle,
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Tidy Weather is lovingly crafted by ',
                  ),
                  LinkTextSpan(
                    style: linkStyle,
                    text: 'Gary',
                    url: 'https://pento.net',
                  ),
                  const TextSpan(
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
                  const TextSpan(
                    text: 'This is an Open Source application, you can view '
                        'the source code, report bugs, and contribute '
                        'fixes in the ',
                  ),
                  LinkTextSpan(
                    style: linkStyle,
                    text: 'Tidy Weather repository',
                    url: 'https://github.com/pento/TidyWeather/',
                  ),
                  const TextSpan(
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
                  const TextSpan(
                    text: 'Some data in this app is sourced from the ',
                  ),
                  LinkTextSpan(
                    style: linkStyle,
                    text: 'Bureau of Meteorology',
                    url:
                        'http://www.bom.gov.au/data-access/3rd-party-attribution.shtml',
                  ),
                  const TextSpan(
                    text: ', via ',
                  ),
                  LinkTextSpan(
                    style: linkStyle,
                    text: 'the WillyWeather API',
                    url: 'https://www.willyweather.com.au/info/api.html',
                  ),
                  const TextSpan(
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
                  const TextSpan(
                    text: 'UV observations courtesy of ARPANSA. ',
                  ),
                  LinkTextSpan(
                    style: linkStyle,
                    text: 'Disclaimer',
                    url:
                        'https://www.arpansa.gov.au/our-services/monitoring/ultraviolet-radiation-monitoring/ultraviolet-radation-data-information',
                  ),
                  const TextSpan(
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
                  const TextSpan(
                    text: 'Maps are © ',
                  ),
                  LinkTextSpan(
                    style: linkStyle,
                    text: 'OpenStreetMap',
                    url: 'https://www.openstreetmap.org/',
                  ),
                  const TextSpan(
                    text: ' contributors.',
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
