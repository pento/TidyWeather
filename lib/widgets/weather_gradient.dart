import 'dart:developer' as developer;

import 'package:flutter/material.dart';

/// Given a weather code, returns a background gradient appropriate
/// for that weather.
LinearGradient weatherGradient(BuildContext context, String weatherCode,
        [double opacityFactor = 1.0]) =>
    LinearGradient(
      colors: _weatherColours(context, weatherCode, opacityFactor),
      end: const Alignment(0.5, 0),
    );

final Map<String, Color> _weatherGroupColours = <String, Color>{
  'fine': Colors.lightBlue,
  'rain-fine': Colors.lightGreen.shade800,
  'cloud-rain': Colors.blueGrey,
  'heavy-rain': Colors.blueGrey.shade800,
  'fog-snow': Colors.grey.shade600,
  'heavy-snow': Colors.grey.shade800,
  'hazy': Colors.brown.shade900,
};

final Map<String, Color> _weatherColoursMap = <String, Color>{
  'chance-shower-cloud': _weatherGroupColours['cloud-rain'],
  'chance-shower-fine': _weatherGroupColours['rain-fine'],
  'chance-snow-cloud': _weatherGroupColours['fog-snow'],
  'chance-snow-fine': _weatherGroupColours['rain-fine'],
  'chance-thunderstorm-cloud': _weatherGroupColours['heavy-rain'],
  'chance-thunderstorm-fine': _weatherGroupColours['heavy-rain'],
  'chance-thunderstorm-showers': _weatherGroupColours['heavy-rain'],
  'cloudy': _weatherGroupColours['cloud-rain'],
  'drizzle': _weatherGroupColours['cloud-rain'],
  'dust': _weatherGroupColours['hazy'],
  'few-showers': _weatherGroupColours['cloud-rain'],
  'fine': _weatherGroupColours['fine'],
  'fog': _weatherGroupColours['fog-snow'],
  'frost': _weatherGroupColours['fog-snow'],
  'hail': _weatherGroupColours['heavy-rain'],
  'heavy-showers-rain': _weatherGroupColours['heavy-rain'],
  'heavy-snow': _weatherGroupColours['heavy-snow'],
  'high-cloud': _weatherGroupColours['fine'],
  'light-snow': _weatherGroupColours['fog-snow'],
  'mostly-cloudy': _weatherGroupColours['cloud-rain'],
  'mostly-fine': _weatherGroupColours['fine'],
  'overcast': _weatherGroupColours['cloud-rain'],
  'partly-cloudy': _weatherGroupColours['fine'],
  'shower-or-two': _weatherGroupColours['rain-fine'],
  'showers-rain': _weatherGroupColours['cloud-rain'],
  'snow': _weatherGroupColours['fog-snow'],
  'snow-and-rain': _weatherGroupColours['heavy-rain'],
  'thunderstorm': _weatherGroupColours['heavy-rain'],
  'wind': _weatherGroupColours['fine'],
};

List<Color> _weatherColours(BuildContext context, String weatherCode,
    [double opacityFactor = 1.0]) {
  Color weatherColour;
  Color blendColour = Colors.white;
  double lightOpacity = 0.9;
  double darkOpacity;

  final ThemeData currentTheme = Theme.of(context);
  if (currentTheme.brightness == Brightness.dark) {
    weatherColour = currentTheme.splashColor;
    lightOpacity = 0.3;
    blendColour = Colors.black;
  } else if (_weatherColoursMap.containsKey(weatherCode)) {
    weatherColour = _weatherColoursMap[weatherCode];
  } else {
    // A null weather code should be considered an intentional lookup failure.
    if (weatherCode != null) {
      developer.log('Unknown weather code: $weatherCode');
    }

    weatherColour = currentTheme.splashColor;
  }

  darkOpacity = weatherColour.opacity;

  return <Color>[
    Color.lerp(
      Colors.transparent,
      Color.alphaBlend(weatherColour.withOpacity(lightOpacity), blendColour),
      opacityFactor,
    ),
    Color.lerp(
      Colors.transparent,
      Color.alphaBlend(weatherColour.withOpacity(darkOpacity), blendColour),
      opacityFactor,
    ),
  ];
}
