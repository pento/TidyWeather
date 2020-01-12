import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import './home.dart';
import '../data/location_model.dart';
import '../data/preference_model.dart';
import '../data/uv_model.dart';
import '../data/weather_model.dart';

class SettingsPage extends StatefulWidget {
  static const String route = '/settings';

  @override
  _SettingsPageState createState() => _SettingsPageState();

}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of( context );
    final TextStyle textStyle = themeData.textTheme.body2;
    final TextStyle linkStyle = themeData.textTheme.body2.copyWith( color: themeData.accentColor );

    final firstLoad = ! Navigator.canPop( context );

    return Scaffold(
      appBar: AppBar(
        title: Text( 'Settings' ),
      ),
      body: PreferencePage( [
        firstLoad ? Container() : Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              PreferenceTitle( 'Theme' ),
              RadioPreference(
                'System theme',
                'system',
                'ui_theme',
                isDefault: true,
                onSelect: () {
                  PreferenceModel.updateTheme( 'system' );
                },
              ),
              RadioPreference(
                'Dark theme after sunset',
                'sun',
                'ui_theme',
                onSelect: () {
                  PreferenceModel.updateTheme( 'sun' );
                },
              ),
            ],
          ),
        ),
        PreferenceTitle( 'API Settings' ),
        Padding(
          padding: const EdgeInsets.symmetric( horizontal: 16.0, vertical: 12.0 ),
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  style: textStyle,
                  text: 'Please ',
                ),
                TextSpan(
                  style: linkStyle,
                  text: 'signup for a WillyWeather API account',
                    recognizer: TapGestureRecognizer()..onTap = () {
                      launch( 'https://www.willyweather.com.au/api/register.html', forceSafariVC: false );
                    }
                ),
                TextSpan(
                  style: textStyle,
                  text: ', and enter your API Key here.',
                ),
              ],
            ),
          ),
        ),
        TextFieldPreference( 'API Key', 'api_key' ),

        firstLoad ?
          RaisedButton(
            onPressed: () {
              LocationModel();
              UVModel();
              WeatherModel();

              LocationModel.load();

              Navigator.pushNamed( context, HomePage.route );
            },
            child: Text( 'Close Settings' ),
          ) :
          Container(),
      ] ),
    );
  }
}
