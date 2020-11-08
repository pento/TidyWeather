import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';
import 'package:provider/provider.dart';

import './weather_model.dart';

class PreferenceModel extends ChangeNotifier with WidgetsBindingObserver {
  static PreferenceModel _self;
  String _theme = 'system';

  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    splashColor: Colors.lightBlue,
    primaryColorLight: Colors.grey.shade300,
  );

  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColorLight: Colors.grey.shade400,
  );

  /// Constructor.
  PreferenceModel() {
    _theme = PrefService.getString('ui_theme');
    _self = this;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    notifyListeners();
  }

  ThemeData lightTheme(BuildContext context) {
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

  static void updateTheme(String theme) {
    _self._updateTheme(theme);
  }

  void _updateTheme(String theme) {
    _theme = theme;

    notifyListeners();
  }
}
