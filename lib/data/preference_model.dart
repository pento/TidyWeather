import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './weather_model.dart';

class PreferenceModel extends ChangeNotifier with WidgetsBindingObserver {
  static PreferenceModel _self;

  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    splashColor: Colors.lightBlue,
    primaryColorLight: Colors.grey.shade300,
  );

  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColorLight: Colors.grey.shade400,
  );

  SharedPreferences _preferences;

  /// Constructor.
  PreferenceModel({SharedPreferences preferences}) {
    _self = this;
    _preferences = preferences;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    notifyListeners();
  }

  ThemeData lightTheme(BuildContext context) {
    final String _theme = _preferences.getString('ui_theme');
    if (_theme == 'sun') {
      final WeatherForecast forecast =
          Provider.of<WeatherModel>(context, listen: false).today.forecast;

      if (forecast == null) {
        return _lightTheme;
      }

      final DateTime now = DateTime.now();

      if (now.isBefore(forecast.sun.sunrise) ||
          now.isAfter(forecast.sun.sunset)) {
        return _darkTheme;
      }
    }
    return _lightTheme;
  }

  ThemeData darkTheme(BuildContext context) {
    final String _theme = _preferences.getString('ui_theme');
    if (_theme == 'sun') {
      final WeatherForecast forecast =
          Provider.of<WeatherModel>(context, listen: false).today.forecast;

      if (forecast == null) {
        return _darkTheme;
      }

      final DateTime now = DateTime.now();

      if (now.isAfter(forecast.sun.sunrise) &&
          now.isBefore(forecast.sun.sunset)) {
        return _lightTheme;
      }
    }
    return _darkTheme;
  }

  bool seenPermissionExplanation() {
    final bool seen = _preferences.getBool('seen_permission_explanation');
    if (seen == null) {
      return false;
    }
    return seen;
  }

  static void sawPermissionExplanation() {
    _self._sawPermissionExplanation();
  }

  void _sawPermissionExplanation() {
    _preferences
        .setBool('seen_permission_explanation', true)
        .then((bool success) => notifyListeners());
  }

  String theme() {
    final String theme = _preferences.getString('ui_theme');

    if (theme == null) {
      return 'system';
    }

    return theme;
  }

  static void updateTheme({String theme}) {
    _self._updateTheme(theme: theme);
  }

  void _updateTheme({String theme}) {
    _preferences
        .setString('ui_theme', theme)
        .then((bool success) => notifyListeners());
  }
}
