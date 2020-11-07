import 'package:flutter/material.dart';

import '../pages/about.dart';
import '../pages/settings.dart';

Drawer buildDrawer(BuildContext context, String currentRoute) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: Text(
            "Tidy Weather",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          selected: currentRoute == SettingsPage.route,
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, SettingsPage.route);
          },
        ),
        Divider(),
        ListTile(
          title: Text('About Tidy Weather'),
          selected: currentRoute == AboutPage.route,
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, AboutPage.route);
          },
        ),
      ],
    ),
  );
}
