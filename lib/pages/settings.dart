import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';

import '../data/preference_model.dart';

/// The settings page.
class SettingsPage extends StatefulWidget {
  /// The route for this page in the Navigator API.
  static const String route = '/settings';

  /// Constructor.
  const SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: PreferencePage(<Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              PreferenceTitle('Theme'),
              RadioPreference<String>(
                'System theme',
                'system',
                'ui_theme',
                isDefault: true,
                onSelect: () {
                  PreferenceModel.updateTheme('system');
                },
              ),
              RadioPreference<String>(
                'Dark theme after sunset',
                'sun',
                'ui_theme',
                onSelect: () {
                  PreferenceModel.updateTheme('sun');
                },
              ),
            ],
          ),
        ]),
      );
}
