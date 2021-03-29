import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../data/location_model.dart';
import '../data/preference_model.dart';
import '../pages/about.dart';
import '../pages/settings.dart';

/// Creates the main drawer for the app.
Drawer buildDrawer(BuildContext context, String currentRoute) => Drawer(
      child: Selector2<PreferenceModel, LocationModel, bool>(
        selector: (BuildContext context, PreferenceModel preferences,
                LocationModel location) =>
            !preferences.seenPermissionExplanation() &&
            location.permissionStatus != LocationPermission.always,
        builder:
            (BuildContext context, bool showPermissionWarning, Widget child) =>
                ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Tidy Weather',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              trailing:
                  showPermissionWarning ? const Icon(Icons.warning) : null,
              selected: currentRoute == SettingsPage.route,
              onTap: () async {
                Navigator.pop(context);
                await Navigator.pushNamed(context, SettingsPage.route);
                PreferenceModel.sawPermissionExplanation();
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('About Tidy Weather'),
              selected: currentRoute == AboutPage.route,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AboutPage.route);
              },
            ),
          ],
        ),
      ),
    );
