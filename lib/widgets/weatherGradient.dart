import 'package:flutter/material.dart';

LinearGradient weatherGradient( BuildContext context, String weatherCode, [ double opacityFactor = 1.0 ] ) {
  return LinearGradient(
    colors: weatherColours( context, weatherCode, opacityFactor ),
    begin: Alignment.centerLeft,
    end: Alignment( 0.5, 0 ),
  );
}

final Map<String, Color> _weatherGroupColours = {
  'fine': Colors.lightBlue,
  'rain-fine': Colors.lightGreen.shade800,
  'cloud-rain': Colors.blueGrey,
  'heavy-rain': Colors.blueGrey.shade800,
  'fog-snow': Colors.grey.shade600,
  'heavy-snow': Colors.grey.shade800,
  'hazy': Colors.brown.shade900,

};

final Map<String, Color> _weatherColoursMap = {
  'chance-shower-cloud': _weatherGroupColours[ 'cloud-rain' ],
  'chance-shower-fine': _weatherGroupColours[ 'rain-fine' ],
  'chance-snow-cloud': _weatherGroupColours[ 'rain-fine' ],
  'chance-snow-fine': _weatherGroupColours[ 'rain-fine' ],
  'chance-thunderstorm-cloud': _weatherGroupColours[ 'heavy-rain' ],
  'chance-thunderstorm-fine': _weatherGroupColours[ 'heavy-rain' ],
  'chance-thunderstorm-showers': _weatherGroupColours[ 'heavy-rain' ],
  'cloudy': _weatherGroupColours[ 'cloud-rain' ],
  'drizzle': _weatherGroupColours[ 'cloud-rain' ],
  'dust': _weatherGroupColours[ 'hazy' ],
  'few-showers': _weatherGroupColours[ 'cloud-rain' ],
  'fine': _weatherGroupColours[ 'fine' ],
  'fog': _weatherGroupColours[ 'rain-fine' ],
  'frost': _weatherGroupColours[ 'rain-fine' ],
  'hail': _weatherGroupColours[ 'heavy-rain' ],
  'heavy-showers-rain': _weatherGroupColours[ 'heavy-rain' ],
  'heavy-snow': _weatherGroupColours[ 'heavy-snow' ],
  'high-cloud': _weatherGroupColours[ 'fine' ],
  'light-snow': _weatherGroupColours[ 'rain-fine' ],
  'mostly-cloudy': _weatherGroupColours[ 'cloud-rain' ],
  'mostly-fine': _weatherGroupColours[ 'rain-fine' ],
  'overcast': _weatherGroupColours[ 'cloud-rain' ],
  'partly-cloudy': _weatherGroupColours[ 'fine' ],
  'shower-or-two': _weatherGroupColours[ 'rain-fine' ],
  'showers-rain': _weatherGroupColours[ 'cloud-rain' ],
  'snow': _weatherGroupColours[ 'rain-fine' ],
  'snow-and-rain': _weatherGroupColours[ 'heavy-rain' ],
  'thunderstorm': _weatherGroupColours[ 'heavy-rain' ],
  'wind': _weatherGroupColours[ 'fine' ],
};

List<Color> weatherColours( BuildContext context, String weatherCode, [ double opacityFactor = 1.0 ] ) {
  Color weatherColour;
  Color blendColour = Colors.white;
  double lightOpacity = 0.9;
  double darkOpacity;

  ThemeData currentTheme = Theme.of( context );
  if ( currentTheme.brightness == Brightness.dark ) {
    weatherColour = currentTheme.splashColor;
    lightOpacity = 0.3;
    blendColour = Colors.black;
  } else if ( _weatherColoursMap.containsKey( weatherCode ) ) {
    weatherColour = _weatherColoursMap[ weatherCode ];
  } else {
    // A null weather code should be considered an intentional lookup failure.
    if ( weatherCode != null ) {
      print( 'Unknown weather code: $weatherCode' );
    }

    weatherColour = currentTheme.splashColor;
  }

  darkOpacity = weatherColour.opacity;

  return [
    Color.lerp(
      Colors.transparent,
      Color.alphaBlend( weatherColour.withOpacity( lightOpacity ), blendColour ),
      opacityFactor,
    ),
    Color.lerp(
      Colors.transparent,
      Color.alphaBlend( weatherColour.withOpacity( darkOpacity ), blendColour ),
      opacityFactor,
    ),
  ];
}
