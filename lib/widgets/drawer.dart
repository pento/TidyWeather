import 'package:flutter/material.dart';

import '../pages/about.dart';
import '../pages/settings.dart';

/// Creates the main drawer for the app.
Drawer buildDrawer(BuildContext context, String currentRoute) => Drawer(
      child: ListView(
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
            selected: currentRoute == SettingsPage.route,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, SettingsPage.route);
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
    );
