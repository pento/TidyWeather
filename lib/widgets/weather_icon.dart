
String weatherIcon( String iconCode ) {
  Map iconCodes = new Map();

  iconCodes[ 'chance-shower-cloud' ] = 'weather-rainy';
  iconCodes[ 'chance-shower-fine' ] = 'weather-partly-rainy';
  iconCodes[ 'chance-snow-cloud' ] = 'weather-snowy';
  iconCodes[ 'chance-snow-fine' ] = 'weather-partly-snowy';
  iconCodes[ 'chance-thunderstorm-cloud' ] = 'weather-lightning';
  iconCodes[ 'chance-thunderstorm-fine' ] = 'weather-partly-lightning';
  iconCodes[ 'chance-thunderstorm-showers' ] = 'weather-lightning-rainy';
  iconCodes[ 'cloudy' ] = 'weather-cloudy';
  iconCodes[ 'drizzle' ] = 'weather-rainy';
  iconCodes[ 'dust' ] = 'weather-hazy';
  iconCodes[ 'few-showers' ] = 'weather-rainy';
  iconCodes[ 'fine' ] = 'weather-sunny';
  iconCodes[ 'fog' ] = 'weather-fog';
  iconCodes[ 'frost' ] = 'snowflake-variant';
  iconCodes[ 'hail' ] = 'weather-hail';
  iconCodes[ 'heavy-showers-rain' ] = 'weather-pouring';
  iconCodes[ 'heavt-snow' ] = 'weather-snowy-heavy';
  iconCodes[ 'high-cloud' ] = 'weather-partly-cloudy';
  iconCodes[ 'light-snow' ] = 'weather-snowy';
  iconCodes[ 'mostly-cloudy' ] = 'weather-cloudy';
  iconCodes[ 'mostly-fine' ] = 'weather-partly-cloudy';
  iconCodes[ 'overcast' ] = 'weather-cloudy';
  iconCodes[ 'partly-cloudy' ] = 'weather-partly-cloudy';
  iconCodes[ 'shower-or-two' ] = 'weather-partly-rainy';
  iconCodes[ 'showers-rain' ] = 'weather-rainy';
  iconCodes[ 'snow' ] = 'weather-snowy';
  iconCodes[ 'snow-and-rain' ] = 'weather-snowy-rainy';
  iconCodes[ 'thunderstorm' ] = 'weather-lightning';
  iconCodes[ 'wind' ] = 'weather-windy';

  if ( iconCodes.containsKey( iconCode ) ) {
    return 'assets/icons/${ iconCodes[ iconCode ] }.svg';
  }

  // A null icon code should be considered an intentional lookup failure.
  if ( iconCode != null ) {
    print( 'Unknown icon code: $iconCode' );
  }

  return '';
}
