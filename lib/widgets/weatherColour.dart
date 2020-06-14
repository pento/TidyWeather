import 'package:flutter/material.dart';

Color weatherColor( BuildContext context, String weatherCode ) {
  ThemeData currentTheme = Theme.of( context );
  if ( currentTheme.brightness == Brightness.dark ) {
    return currentTheme.splashColor;
  }

  Map weatherCodes = new Map();

  weatherCodes[ 'chance-shower-cloud' ] = Colors.blueGrey;
  weatherCodes[ 'chance-shower-fine' ] = Colors.green;
//  weatherCodes[ 'chance-snow-cloud' ] = 'weather_snowy';
//  weatherCodes[ 'chance-snow-fine' ] = 'weather_partly_snowy';
//  weatherCodes[ 'chance-thunderstorm-cloud' ] = 'weather_lightning';
//  weatherCodes[ 'chance-thunderstorm-fine' ] = 'weather_partly_lightning';
//  weatherCodes[ 'chance-thunderstorm-showers' ] = 'weather_lightning_rainy';
//  weatherCodes[ 'cloudy' ] = 'weather_cloudy';
  weatherCodes[ 'drizzle' ] = Colors.blueGrey;
//  weatherCodes[ 'dust' ] = 'weather_hazy';
  weatherCodes[ 'few-showers' ] = Colors.blueGrey;
  weatherCodes[ 'fine' ] = Colors.lightBlue;
//  weatherCodes[ 'fog' ] = 'weather_fog';
//  weatherCodes[ 'frost' ] = 'weather_frost';
//  weatherCodes[ 'hail' ] = 'weather_hail';
//  weatherCodes[ 'heavy-showers-rain' ] = 'weather_pouring';
//  weatherCodes[ 'heavy-snow' ] = 'weather_snowy_heavy';
//  weatherCodes[ 'high-cloud' ] = 'weather_partly_cloudy';
//  weatherCodes[ 'light-snow' ] = 'weather_snowy';
//  weatherCodes[ 'mostly-cloudy' ] = 'weather_cloudy';
  weatherCodes[ 'mostly-fine' ] = Colors.green;
//  weatherCodes[ 'overcast' ] = 'weather_cloudy';
  weatherCodes[ 'partly-cloudy' ] = Colors.lightBlue;
  weatherCodes[ 'shower-or-two' ] = Colors.green;
  weatherCodes[ 'showers-rain' ] = Colors.blueGrey;
//  weatherCodes[ 'snow' ] = 'weather_snowy';
//  weatherCodes[ 'snow-and-rain' ] = 'weather_snowy_rainy';
//  weatherCodes[ 'thunderstorm' ] = 'weather_lightning';
//  weatherCodes[ 'wind' ] = 'weather_windy';

  if ( weatherCodes.containsKey( weatherCode ) ) {
    return weatherCodes[ weatherCode ];
  }

  // A null weather code should be considered an intentional lookup failure.
  if ( weatherCode != null ) {
    print( 'Unknown weather code: $weatherCode' );
  }

  return currentTheme.splashColor;
}
