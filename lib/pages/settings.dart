import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';

import '../data/preference_model.dart';

class SettingsPage extends StatefulWidget {
  static const String route = '/settings';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: PreferencePage([
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              PreferenceTitle('Theme'),
              RadioPreference(
                'System theme',
                'system',
                'ui_theme',
                isDefault: true,
                onSelect: () {
                  PreferenceModel.updateTheme('system');
                },
              ),
              RadioPreference(
                'Dark theme after sunset',
                'sun',
                'ui_theme',
                onSelect: () {
                  PreferenceModel.updateTheme('sun');
                },
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
