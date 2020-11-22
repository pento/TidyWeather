import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../data/location_model.dart';
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
  Widget build(BuildContext context) => Selector2<PreferenceModel,
          LocationModel, Tuple3<bool, LocationPermission, Color>>(
        selector: (BuildContext context, PreferenceModel preferences,
                LocationModel location) =>
            Tuple3<bool, LocationPermission, Color>(
          preferences.seenPermissionExplanation,
          location.permissionStatus,
          Theme.of(context).iconTheme.color,
        ),
        builder: (BuildContext context,
            Tuple3<bool, LocationPermission, Color> data, Widget child) {
          Container permissionMessage;
          Text permissionButton;
          bool highlightPermission = !data.item1;
          switch (data.item2) {
            case LocationPermission.denied:
            case LocationPermission.deniedForever:
              permissionMessage = Container(
                margin: const EdgeInsets.all(16),
                child: const Text(
                    'In order to provide accurate weather data, Tidy '
                    'Weather requires permission to access to your location. '
                    'Your exact location never leaves your device, and your '
                    'approximate location is only used for gathering accurate '
                    'weather data.'),
              );
              permissionButton = const Text('Grant Location Permission');
              break;
            case LocationPermission.whileInUse:
              permissionMessage = Container(
                margin: const EdgeInsets.all(16),
                child: const Text(
                    "Tidy Weather does work if it's only able to check your "
                    "location while it's open. However, it works best when it "
                    'has permission to check your location in the background, '
                    'too.'),
              );
              permissionButton = const Text('Grant Location Permission');
              break;
            case LocationPermission.always:
              // No need to display a message when we have all permissions.
              permissionButton = const Text('Open Location Permissions');
              highlightPermission = false;
              break;
          }
          return Scaffold(
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
                  Container(
                    color: highlightPermission
                        ? Theme.of(context).highlightColor
                        : null,
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            if (highlightPermission)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, top: 20),
                                child: Icon(
                                  Icons.warning,
                                  color: data.item3,
                                  size: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .fontSize,
                                ),
                              ),
                            PreferenceTitle('Permissions'),
                          ],
                        ),
                        if (permissionMessage != null) permissionMessage,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              ElevatedButton(
                                onPressed: () async {
                                  await LocationModel.requestPermission(
                                    forceOpen: true,
                                  );
                                },
                                child: permissionButton,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ]),
          );
        },
      );
}
