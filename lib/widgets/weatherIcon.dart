import '../data/weather_model.dart';

String weatherIcon(String iconCode, [WeatherForecastSun sun]) {
  Map iconCodes = new Map();

  iconCodes['chance-shower-cloud'] = 'weather_rainy';
  iconCodes['chance-shower-fine'] = 'weather_partly_rainy';
  iconCodes['chance-snow-cloud'] = 'weather_snowy';
  iconCodes['chance-snow-fine'] = 'weather_partly_snowy';
  iconCodes['chance-thunderstorm-cloud'] = 'weather_lightning';
  iconCodes['chance-thunderstorm-fine'] = 'weather_partly_lightning';
  iconCodes['chance-thunderstorm-showers'] = 'weather_lightning_rainy';
  iconCodes['cloudy'] = 'weather_cloudy';
  iconCodes['drizzle'] = 'weather_rainy';
  iconCodes['dust'] = 'weather_hazy';
  iconCodes['few-showers'] = 'weather_rainy';
  iconCodes['fine'] = 'weather_fine';
  iconCodes['fog'] = 'weather_fog';
  iconCodes['frost'] = 'weather_frost';
  iconCodes['hail'] = 'weather_hail';
  iconCodes['heavy-showers-rain'] = 'weather_pouring';
  iconCodes['heavy-snow'] = 'weather_snowy_heavy';
  iconCodes['high-cloud'] = 'weather_partly_cloudy';
  iconCodes['light-snow'] = 'weather_snowy';
  iconCodes['mostly-cloudy'] = 'weather_cloudy';
  iconCodes['mostly-fine'] = 'weather_partly_cloudy';
  iconCodes['overcast'] = 'weather_cloudy';
  iconCodes['partly-cloudy'] = 'weather_partly_cloudy';
  iconCodes['shower-or-two'] = 'weather_partly_rainy';
  iconCodes['showers-rain'] = 'weather_rainy';
  iconCodes['snow'] = 'weather_snowy';
  iconCodes['snow-and-rain'] = 'weather_snowy_rainy';
  iconCodes['thunderstorm'] = 'weather_lightning';
  iconCodes['wind'] = 'weather_windy';

  if (iconCodes.containsKey(iconCode)) {
    DateTime now = DateTime.now();

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
    print('Unknown icon code: $iconCode');
  }

  return '';
}
