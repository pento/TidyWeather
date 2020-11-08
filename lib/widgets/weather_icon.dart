import 'dart:developer' as developer;

import '../data/weather_model.dart';

/// Given an [iconCode], returns an appropriate icon file for the weather code.
/// The optional [sun] parameter should only be passed when retrieving an
/// icon for today, it will be used to determine if a day or night icon should
/// be returned.
String weatherIcon(String iconCode, [WeatherForecastSun sun]) {
  final Map<String, String> iconCodes = <String, String>{
    'chance-shower-cloud': 'weather_rainy',
    'chance-shower-fine': 'weather_partly_rainy',
    'chance-snow-cloud': 'weather_snowy',
    'chance-snow-fine': 'weather_partly_snowy',
    'chance-thunderstorm-cloud': 'weather_lightning',
    'chance-thunderstorm-fine': 'weather_partly_lightning',
    'chance-thunderstorm-showers': 'weather_lightning_rainy',
    'cloudy': 'weather_cloudy',
    'drizzle': 'weather_rainy',
    'dust': 'weather_hazy',
    'few-showers': 'weather_rainy',
    'fine': 'weather_fine',
    'fog': 'weather_fog',
    'frost': 'weather_frost',
    'hail': 'weather_hail',
    'heavy-showers-rain': 'weather_pouring',
    'heavy-snow': 'weather_snowy_heavy',
    'high-cloud': 'weather_partly_cloudy',
    'light-snow': 'weather_snowy',
    'mostly-cloudy': 'weather_cloudy',
    'mostly-fine': 'weather_partly_cloudy',
    'overcast': 'weather_cloudy',
    'partly-cloudy': 'weather_partly_cloudy',
    'shower-or-two': 'weather_partly_rainy',
    'showers-rain': 'weather_rainy',
    'snow': 'weather_snowy',
    'snow-and-rain': 'weather_snowy_rainy',
    'thunderstorm': 'weather_lightning',
    'wind': 'weather_windy',
  };

  if (iconCodes.containsKey(iconCode)) {
    final DateTime now = DateTime.now();

    if (sun != null &&
        (now.isBefore(sun.sunrise) || now.isAfter(sun.sunset)) &&
        (iconCode == 'fine' || iconCodes[iconCode].contains('partly'))) {
      return 'assets/icons/generated/${iconCodes[iconCode]}_night.svg';
    } else {
      return 'assets/icons/generated/${iconCodes[iconCode]}.svg';
    }
  }

  // A null icon code should be considered an intentional lookup failure.
  if (iconCode != null) {
    developer.log('Unknown icon code: $iconCode');
  }

  return '';
}
