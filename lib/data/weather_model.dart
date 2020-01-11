import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:preferences/preference_service.dart';

class WeatherModel extends ChangeNotifier {
  Map _weather = new Map();
  static WeatherModel _self;
  static const platform = const MethodChannel( 'net.pento.tidyweather/widget' );
  bool background;

  WeatherModel( { bool background = false } ) {
    String weatherCache = PrefService.getString( 'cached_weather_data' );
    if ( weatherCache != null ) {
      _weather = jsonDecode( weatherCache );
    }

    _self = this;
    this.background = background;
  }

  WeatherDay get today {
    WeatherDay _weatherToday = new WeatherDay();

    if ( _weather.containsKey( 'forecasts' ) ) {
      _weatherToday = new WeatherDay(
          _weather[ 'forecasts' ][ 'weather' ][ 'days' ][ 0 ][ 'entries' ][ 0 ],
          _weather[ 'forecasts' ][ 'temperature' ][ 'days' ][ 0 ][ 'entries' ],
          _weather[ 'forecasts' ][ 'rainfall' ][ 'days' ][ 0 ][ 'entries' ][ 0 ],
          _weather[ 'forecasts' ][ 'uv' ][ 'days' ][ 0 ],
          _weather['forecasts'].containsKey( 'wind' ) ? _weather[ 'forecasts' ][ 'wind' ][ 'days' ][ 0 ] : null,
          _weather['forecasts'].containsKey( 'sunrisesunset' ) ? _weather[ 'forecasts' ][ 'sunrisesunset' ][ 'days' ][ 0 ][ 'entries' ][ 0 ] : null,
          _weather.containsKey( 'regionPrecis' ) ? _weather[ 'regionPrecis' ][ 'days' ][ 0 ][ 'entries' ][ 0 ] : null,
          _weather.containsKey( 'regionPrecis' ) ? _weather[ 'regionPrecis' ][ 'name' ] : null,
          _weather[ 'observational' ][ 'observations' ],
      );
    }

    return _weatherToday;
  }

  WeatherWeek get week {
    WeatherWeek _week = new WeatherWeek();

    if ( _weather.containsKey( 'forecasts' ) ) {
      for ( var i  = 0; i < _weather[ 'forecasts' ][ 'weather' ][ 'days' ].length; i++ ) {
        WeatherDay _day = new WeatherDay(
          _weather[ 'forecasts' ][ 'weather' ][ 'days' ][ i ][ 'entries' ][ 0 ],
          _weather[ 'forecasts' ][ 'temperature' ][ 'days' ][ i ][ 'entries' ],
          _weather[ 'forecasts' ][ 'rainfall' ][ 'days' ][ i ][ 'entries' ][ 0 ],
          i < _weather[ 'forecasts' ][ 'uv' ][ 'days' ].length ? _weather[ 'forecasts' ][ 'uv' ][ 'days' ][ i ] : null,
          _weather['forecasts'].containsKey( 'wind' ) ? _weather[ 'forecasts' ][ 'wind' ][ 'days' ][ i ] : null,
          _weather['forecasts'].containsKey( 'sunrisesunset' ) ? _weather[ 'forecasts' ][ 'sunrisesunset' ][ 'days' ][ i ][ 'entries' ][ 0 ] : null,
          _weather.containsKey( 'regionPrecis' ) ? _weather[ 'regionPrecis' ][ 'days' ][ i ][ 'entries' ][ 0 ] : null,
          _weather.containsKey( 'regionPrecis' ) ? _weather[ 'regionPrecis' ][ 'name' ] : null,
        );
        _week.days.add( _day );
      }
    }

    return _week;
  }

  static void load( int id ) {
    _self.loadData( id );
  }

  void loadData( int id ) async {
    String apiKey = PrefService.getString( 'api_key' );
    if ( apiKey == null || apiKey == '' ) {
      return;
    }

    String apiRoot = 'https://api.willyweather.com.au/v2/$apiKey';

    final weatherResponse = await http.get( '$apiRoot/locations/$id/weather.json?forecasts=weather,rainfall,uv,temperature,wind,sunrisesunset&observational=true&regionPrecis=true' );
    _weather = jsonDecode( weatherResponse.body );

    PrefService.setString( 'cached_weather_data', weatherResponse.body );

    notifyListeners();

    if ( Platform.isAndroid && ! background ) {
      platform.invokeMethod(
        'updateWeatherData',
        {
          'current': _weather[ 'observational' ][ 'observations' ][ 'temperature' ][ 'temperature' ].toString(),
          'min': _weather[ 'forecasts' ][ 'weather' ][ 'days' ][ 0 ][ 'entries' ][ 0 ][ 'min' ].toString(),
          'max': _weather[ 'forecasts' ][ 'weather' ][ 'days' ][ 0 ][ 'entries' ][ 0 ][ 'max' ].toString(),
          'code': _weather[ 'forecasts' ][ 'weather' ][ 'days' ][ 0 ][ 'entries' ][ 0 ][ 'precisCode' ]
        }
      );
    }
  }
}

class WeatherWeek {
  List<WeatherDay> days = new List();
}

class WeatherDay {
  WeatherForecast forecast = new WeatherForecast();
  WeatherObservations observations = new WeatherObservations();
  DateTime dateTime;

  WeatherDay( [ Map temperatureForecastData, List hourlyTemperatureForecastData, Map rainfallForecastData, Map uvForecastData, Map windForecastData, Map sunForecastData, Map regionForecastData, String regionForecastName, Map observationalData ] ) {
    if ( temperatureForecastData != null ) {
      dateTime = DateTime.parse( temperatureForecastData[ 'dateTime' ] );

      forecast.temperature.min = temperatureForecastData[ 'min' ];
      forecast.temperature.max = temperatureForecastData[ 'max' ];
      forecast.temperature.code = temperatureForecastData[ 'precisCode' ];
      forecast.temperature.description = temperatureForecastData[ 'precis' ] + '.';
    }

    if ( hourlyTemperatureForecastData != null ) {
      hourlyTemperatureForecastData.forEach( ( hourlyTemperatureData ) {
        WeatherForecastHourlyTemperature _hourlyTemperature = new WeatherForecastHourlyTemperature(
          hourlyTemperatureData[ 'temperature' ].toDouble(),
          DateTime.parse( hourlyTemperatureData[ 'dateTime' ] ),
        );

        forecast.temperature.hourlyTemperature.add( _hourlyTemperature );
      } );
    }

    if ( rainfallForecastData != null ) {
      forecast.rainfall.rangeCode = rainfallForecastData[ 'rangeCode' ];
      forecast.rainfall.probability = rainfallForecastData[ 'probability' ];
    }

    if ( uvForecastData != null ) {
      forecast.uv.max = uvForecastData[ 'alert' ][ 'maxIndex' ].toDouble();

      if ( forecast.uv.max < 3.0 ) {
        forecast.uv.description = 'Low';
      } else if ( forecast.uv.max < 6.0 ) {
        forecast.uv.description = 'Moderate';
      } else if ( forecast.uv.max < 8.0 ) {
        forecast.uv.description = 'High';
      } else if ( forecast.uv.max < 11.0 ) {
        forecast.uv.description = 'Very High';
      } else {
        forecast.uv.description = 'Extreme';
      }

      forecast.uv.start = DateTime.parse( uvForecastData[ 'alert' ][ 'startDateTime' ] );
      forecast.uv.end = DateTime.parse( uvForecastData[ 'alert' ][ 'endDateTime' ] );
    }

    if ( windForecastData != null ) {
      int maxIndex;
      double maxSpeed = -1;
      for ( int i = 0; i < windForecastData[ 'entries' ].length; i++ ) {
        if ( windForecastData[ 'entries' ][ i ][ 'speed' ] > maxSpeed ) {
          maxSpeed = windForecastData[ 'entries' ][ i ][ 'speed' ].toDouble();
          maxIndex = i;
        }
      }

      forecast.windMax.dateTime = DateTime.parse( windForecastData[ 'entries' ][ maxIndex ][ 'dateTime' ] );
      forecast.windMax.speed = windForecastData[ 'entries' ][ maxIndex ][ 'speed' ].toDouble();
      forecast.windMax.direction = windForecastData[ 'entries' ][ maxIndex ][ 'direction' ];
      forecast.windMax.directionText = windForecastData[ 'entries' ][ maxIndex ][ 'directionText' ];
    }

    if ( sunForecastData != null ) {
      forecast.sun.sunrise = DateTime.parse( sunForecastData[ 'riseDateTime' ] );
      forecast.sun.sunset = DateTime.parse( sunForecastData[ 'setDateTime' ] );
    }

    if ( regionForecastData != null && regionForecastName != null ) {
      forecast.region.name = regionForecastName;
      forecast.region.description = regionForecastData[ 'precis' ];
    }

    if ( observationalData != null ) {
      observations.temperature.temperature = observationalData[ 'temperature' ][ 'temperature' ].toDouble();
      observations.temperature.apparentTemperature = observationalData[ 'temperature' ][ 'apparentTemperature' ]?.toDouble();

      observations.rainfall.since9AMAmount = observationalData[ 'rainfall' ][ 'since9AMAmount' ].toDouble();
    }
  }
}

class WeatherForecast {
  WeatherForecastTemperature temperature = new WeatherForecastTemperature();
  WeatherForecastRainfall rainfall = new WeatherForecastRainfall();
  WeatherForecastUV uv = new WeatherForecastUV();
  WeatherForecastWind windMax = new WeatherForecastWind();
  WeatherForecastSun sun = new WeatherForecastSun();
  WeatherForecastRegion region = new WeatherForecastRegion();
}

class WeatherForecastTemperature {
  int min;
  int max;
  String code;
  String description;
  List<WeatherForecastHourlyTemperature> hourlyTemperature = new List();
}

class WeatherForecastHourlyTemperature {
  double temperature;
  DateTime dateTime;

  WeatherForecastHourlyTemperature( this.temperature, this.dateTime );
}

class WeatherForecastRainfall {
  String rangeCode;
  int probability;
}

class WeatherForecastUV {
  double max;
  String description;
  DateTime start;
  DateTime end;
}

class WeatherForecastWind {
  DateTime dateTime;
  double speed;
  int direction;
  String directionText;
}

class WeatherForecastSun {
  DateTime sunrise;
  DateTime sunset;
}

class WeatherForecastRegion {
  String name;
  String description;
}


class WeatherObservations {
  WeatherObservationsTemperature temperature = new WeatherObservationsTemperature();
  WeatherObservationsRainfall rainfall = new WeatherObservationsRainfall();
}

class WeatherObservationsTemperature {
  double temperature;
  double apparentTemperature;
}

class WeatherObservationsRainfall {
  double since9AMAmount;
}

