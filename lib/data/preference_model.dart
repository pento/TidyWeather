import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';
import 'package:provider/provider.dart';

import './weather_model.dart';

class PreferenceModel extends ChangeNotifier with WidgetsBindingObserver {
  static PreferenceModel _self;
  String _theme = 'system';

  ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    splashColor: Colors.lightBlue,
  );

  ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
  );

  PreferenceModel() {
    _theme = PrefService.getString( 'ui_theme' );
    _self = this;
    WidgetsBinding.instance.addObserver( this );
  }

  @override
  void didChangeAppLifecycleState( AppLifecycleState state ) {
    notifyListeners();
  }

  ThemeData lightTheme( BuildContext context ) {
    if ( _theme == 'sun' ) {
      WeatherForecastSun sun = Provider.of<WeatherModel>( context, listen: false ).today.forecast.sun;

      if ( sun.sunrise == null ) {
        return _lightTheme;
      }

      DateTime now = DateTime.now();

      if ( now.isBefore( sun.sunrise ) || now.isAfter( sun.sunset ) ) {
        return _darkTheme;
      }
    }
    return _lightTheme;
  }

  ThemeData darkTheme( BuildContext context ) {
    if ( _theme == 'sun' ) {
      WeatherForecastSun sun = Provider.of<WeatherModel>( context, listen: false ).today.forecast.sun;

      if ( sun.sunrise == null ) {
        return _darkTheme;
      }

      DateTime now = DateTime.now();

      if ( now.isAfter( sun.sunrise ) && now.isBefore( sun.sunset ) ) {
        return _lightTheme;
      }
    }
    return _darkTheme;
  }

  static void updateTheme( String theme ) {
    _self._updateTheme( theme );
  }

  void _updateTheme( String theme ) {
    _theme = theme;

    notifyListeners();
  }
}
