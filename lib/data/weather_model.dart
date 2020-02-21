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
      Map weatherData = jsonDecode( weatherCache );
      if ( weatherData.containsKey( 'location' ) ) {
        this._weather = weatherData;
      }
    }

    _self = this;
    this.background = background;
  }

  WeatherDay get today => new WeatherDay(
    _weather[ 'location' ],
    _weather[ 'forecasts' ],
    _weather[ 'observations' ],
    _weather[ 'radar' ],
  );

  WeatherWeek get week => new WeatherWeek( _weather );

  static void load( String town, String postcode, String uvStation ) {
    _self.loadData( town, postcode, uvStation );
  }

  void loadData( String town, String postcode, String uvStation ) async {
    final weatherResponse = await http.get( 'https://api.tidyweather.com/api/weather?town=$town&postcode=$postcode&uvstation=$uvStation' );
    _weather = jsonDecode( weatherResponse.body );

    PrefService.setString( 'cached_weather_data', weatherResponse.body );

    notifyListeners();

    if ( Platform.isAndroid ) {
      platform.invokeMethod(
        'updateWeatherData',
        {
          'current': _weather[ 'observations' ][ 'temperature' ][ 'temperature' ]?.toString(),
          'min': _weather[ 'forecasts' ][ 0 ][ 'weather' ][ 'min' ]?.toString(),
          'max': _weather[ 'forecasts' ][ 0 ][ 'weather' ][ 'max' ]?.toString(),
          'code': _weather[ 'forecasts' ][ 0 ][ 'weather' ][ 'code' ],
        }
      );
    }
  }
}

class WeatherWeek {
  List<WeatherDay> days;

  WeatherWeek( Map weather ) {
    this.days = weather[ 'forecasts' ].map<WeatherDay>( ( dayWeather ) => new WeatherDay( weather[ 'location' ], [ dayWeather ] ) ).toList();
  }
}

class WeatherDay {
  String locationName = 'Loading...';
  DateTime dateTime;
  WeatherForecast forecast;
  WeatherObservations observations;
  WeatherRadar radar;


  WeatherDay( Map location, List forecast, [ Map observations, Map radar ] ) {
    if ( location != null ) {
      this.locationName = location['name'];
    }

    if ( forecast != null ) {
      this.dateTime = DateTime.parse( forecast[ 0 ][ 'dateTime' ] );
      this.forecast = new WeatherForecast( forecast[ 0 ] );
    }

    if ( observations != null ) {
      this.observations = new WeatherObservations( observations );
    }

    if ( radar != null ) {
      this.radar = new WeatherRadar( radar );
    }
  }
}

class WeatherForecast {
  WeatherForecastWeather weather;
  List<WeatherForecastHourlyTemperature> temperature;
  WeatherForecastRainfall rainfall;
  List<WeatherForecastHourlyRainfall> hourlyRainfall;
  WeatherForecastUV uv;
  WeatherForecastWind windMax;
  WeatherForecastSun sun;
  WeatherForecastRegion region;

  WeatherForecast( Map forecast ) {
    this.weather = new WeatherForecastWeather( forecast[ 'weather' ] );
    this.temperature = forecast[ 'temperature' ].map<WeatherForecastHourlyTemperature>( ( hourTemperature ) => new WeatherForecastHourlyTemperature( hourTemperature ) ).toList();
    this.rainfall = new WeatherForecastRainfall( forecast[ 'rainfall' ] );
    if ( forecast.containsKey( 'rainfallProbability' ) ) {
      this.hourlyRainfall = forecast[ 'rainfallProbability' ]
          .map<WeatherForecastHourlyRainfall>( ( hourRainfall ) => new WeatherForecastHourlyRainfall( hourRainfall ) )
          .toList();
    }
    if ( forecast.containsKey( 'uv' ) ) {
      this.uv = new WeatherForecastUV( forecast[ 'uv' ] );
    }
    this.windMax = new WeatherForecastWind( forecast[ 'windMax' ] );
    this.sun = new WeatherForecastSun( forecast[ 'sun' ] );
    if ( forecast.containsKey( 'region' ) ) {
      this.region = new WeatherForecastRegion( forecast[ 'region' ] );
    }
  }
}

class WeatherForecastWeather {
  int min;
  int max;
  String code;
  String description;

  WeatherForecastWeather( Map weather ) {
    this.min = weather['min'];
    this.max = weather['max'];
    this.code = weather['code'];
    this.description = weather['description'];
  }
}

class WeatherForecastHourlyTemperature {
  double temperature;
  DateTime dateTime;

  WeatherForecastHourlyTemperature( Map hourTemperature ) {
    this.temperature = hourTemperature[ 'temperature' ]?.toDouble();
    this.dateTime = DateTime.parse( hourTemperature[ 'dateTime' ] );
  }

  WeatherForecastHourlyTemperature.fromValues( this.temperature, this.dateTime );
}

class WeatherForecastRainfall {
  String rangeCode;
  int probability;

  WeatherForecastRainfall( Map rainfall ) {
    this.rangeCode = rainfall[ 'rangeCode' ];
    this.probability = rainfall[ 'probability' ];
  }
}

class WeatherForecastHourlyRainfall {
  DateTime dateTime;
  int probability;

  WeatherForecastHourlyRainfall( Map hourRainfall ) {
    this.dateTime = DateTime.parse( hourRainfall[ 'dateTime' ] );
    this.probability = hourRainfall[ 'probability' ];
  }
}

class WeatherForecastUV {
  double max;
  String description;
  DateTime start;
  DateTime end;

  WeatherForecastUV( Map uv ) {
    this.max = uv[ 'max' ]?.toDouble();
    this.description = uv[ 'description' ];
    this.start = DateTime.parse( uv[ 'start' ] );
    this.end = DateTime.parse( uv[ 'end' ] );
  }
}

class WeatherForecastWind {
  DateTime dateTime;
  double speed;
  int direction;
  String directionText;

  WeatherForecastWind( Map wind ) {
    this.dateTime = DateTime.parse( wind[ 'dateTime' ] );
    this.speed = wind[ 'speed' ]?.toDouble();
    this.direction = wind[ 'direction' ];
    this.directionText = wind[ 'directionText' ];
  }
}

class WeatherForecastSun {
  DateTime firstLight;
  DateTime sunrise;
  DateTime sunset;
  DateTime lastLight;

  WeatherForecastSun( Map sun ) {
    this.firstLight = DateTime.parse( sun[ 'firstLight' ] );
    this.sunrise = DateTime.parse( sun[ 'sunrise' ] );
    this.sunset = DateTime.parse( sun[ 'sunset' ] );
    this.lastLight = DateTime.parse( sun[ 'lastLight' ] );
  }
}

class WeatherForecastRegion {
  String name;
  String description;

  WeatherForecastRegion( Map region ) {
    this.name = region[ 'name' ];
    this.description = region[ 'description' ];
  }
}

class WeatherObservations {
  WeatherObservationsTemperature temperature;
  WeatherObservationsRainfall rainfall;
  WeatherObservationsWind wind;
  WeatherObservationsUv uv;
  WeatherObservationsHumidity humidity;

  WeatherObservations( Map observations ) {
    this.temperature = new WeatherObservationsTemperature( observations[ 'temperature' ] );
    this.rainfall = new WeatherObservationsRainfall( observations[ 'rainfall' ] );
    this.wind = new WeatherObservationsWind( observations[ 'wind' ] );
    this.uv = new WeatherObservationsUv( observations[ 'uv' ] );
    this.humidity = new WeatherObservationsHumidity( observations[ 'humidity' ] );
  }
}

class WeatherObservationsTemperature {
  double temperature;
  double apparentTemperature;

  WeatherObservationsTemperature( Map temperature ) {
    this.temperature = temperature[ 'temperature' ]?.toDouble();
    this.apparentTemperature = temperature[ 'apparentTemperature' ]?.toDouble();
  }
}

class WeatherObservationsWind {
  double speed;
  double gustSpeed;
  String directionText;

  WeatherObservationsWind( Map wind ) {
    this.speed = wind[ 'speed' ]?.toDouble();
    this.gustSpeed = wind[ 'gustSpeed' ]?.toDouble();
    this.directionText = wind[ 'directionText' ];
  }
}

class WeatherObservationsRainfall {
  double since9AMAmount;

  WeatherObservationsRainfall( Map rainfall ) {
    this.since9AMAmount = rainfall[ 'since9AMAmount' ]?.toDouble();
  }
}

class WeatherObservationsUv {
  double index;
  String description;
  String name;
  DateTime utcDateTime;

  WeatherObservationsUv( Map uv ) {
    this.index = double.parse( uv[ 'index' ] );
    this.description = uv[ 'description' ];
    this.name = uv[ 'name' ];
    this.utcDateTime = DateTime.parse( uv[ 'utcDateTime' ] );
  }
}

class WeatherObservationsHumidity {
  double percentage;

  WeatherObservationsHumidity( Map humidity ) {
    this.percentage = humidity[ 'percentage' ]?.toDouble();
  }
}

class WeatherRadar {
  int interval;
  String name;
  WeatherRadarLocation mapMin;
  WeatherRadarLocation mapMax;
  WeatherRadarLocation location;
  List<WeatherRadarImage> overlays;

  WeatherRadar( Map radar ) {
    this.interval = radar[ 'interval' ];
    this.name = radar[ 'name' ];
    this.mapMin = WeatherRadarLocation( radar[ 'bounds' ][ 'minLat' ], radar[ 'bounds' ][ 'minLng' ] );
    this.mapMax = WeatherRadarLocation( radar[ 'bounds' ][ 'maxLat' ], radar[ 'bounds' ][ 'maxLng' ] );
    this.location = WeatherRadarLocation( radar[ 'lat' ], radar['lng'] );

    this.overlays = radar[ 'overlays' ]
        .map<WeatherRadarImage>( ( radarImage ) => new WeatherRadarImage( radarImage, radar[ 'overlayPath' ] ) )
        .toList();
  }
}

class WeatherRadarLocation {
  double latitude;
  double longitude;

  WeatherRadarLocation( latitude, longitude ) {
    this.latitude = latitude.toDouble();
    this.longitude = longitude.toDouble();
  }
}

class WeatherRadarImage {
  DateTime dateTime;
  String url;

  WeatherRadarImage( Map radarImage, path ) {
    this.dateTime = DateTime.parse( radarImage[ 'dateTime' ] + 'Z' );
    this.url = '$path${ radarImage[ 'name' ] }';
  }
}
