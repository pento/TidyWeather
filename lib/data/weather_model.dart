import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pedantic/pedantic.dart';
import 'package:preferences/preference_service.dart';

/// Contains the weather data model.
class WeatherModel extends ChangeNotifier {
  Map<String, dynamic> _weather;
  static WeatherModel _self;
  static const MethodChannel _platform = MethodChannel( 'net.pento.tidyweather/widget' );
  BuildContext _context;

  /// Construct a WeatherModel.
  WeatherModel( { BuildContext context } ) {
    final String weatherCache = PrefService.getString( 'cached_weather_data' );
    if ( weatherCache != null ) {
      final Map<String, dynamic> data =
        // ignore: avoid_as
        jsonDecode( weatherCache ) as Map<String, dynamic>;

      if ( data.containsKey( 'location' ) ) {
        _weather = data;
      }
    }

    _self = this;
    _context = context;
  }

  /// Find the index of today in _weather[ 'forecasts' ].
  /// Returns -1 if today couldn't be found.
  int todayIndex() {
    final DateTime now = DateTime.now();

    return _weather
      .cast<String, List<dynamic>>()[ 'forecasts' ]
      .cast<Map<String, dynamic>>()
      .indexWhere( ( Map<String, dynamic> day ) {
        final DateTime thisDay = DateTime.parse( day[ 'dateTime' ].toString() );
        if ( thisDay.day == now.day && thisDay.month == now.month ) {
          return true;
        }

        return false;
      } );
  }

  /// The weather for today.
  WeatherDay get today => WeatherDay.fromJson( _weather, todayIndex() );

  /// Get the forecast for the coming week.
  WeatherWeek get week => WeatherWeek.fromJson( _weather, todayIndex() );

  /// Provide a static method for loading the data for the given location.
  static void load( String town, String postcode, String uvStation ) {
    _self.loadData( town, postcode, uvStation );
  }

  /// Load the data for the given location.
  Future<void> loadData(
      String town,
      String postcode,
      String uvStation
  ) async {
    final http.Response weatherResponse = await http.get( 'https://api.tidyweather.com/api/weather?town=$town&postcode=$postcode&uvstation=$uvStation' );
    final dynamic data = jsonDecode( weatherResponse.body );
    if ( data is Map<String, dynamic> ) {
      _weather = data;
    }

    PrefService.setString( 'cached_weather_data', weatherResponse.body );

    if ( _context != null && today.radar != null ) {
      for( final WeatherRadarImage image in today.radar.overlays ) {
        final Image theImage = Image.network( image.url );
        unawaited( precacheImage( theImage.image, _context ) );
      }
    }

    notifyListeners();

    if ( Platform.isAndroid ) {
      unawaited(
        _platform.invokeMethod(
          'updateWeatherData',
          <String, String>{
            'current': today.observations.temperature.temperature.toString(),
            'min': today.forecast.weather.min.toString(),
            'max': today.forecast.weather.max.toString(),
            'code': today.forecast.weather.code,
            'sunrise': today.forecast.sun.sunrise.toIso8601String(),
            'sunset': today.forecast.sun.sunset.toIso8601String(),
          }
        )
      );
    }
  }
}

/// Data model for a week of weather.
class WeatherWeek {
  /// A list of the days in this week.
  List<WeatherDay> days;

  /// Constructor.
  WeatherWeek( { this.days } );

  /// JSON Factory.
  factory WeatherWeek.fromJson( Map<String, dynamic> weather, int todayIndex ) {
    final List<WeatherDay> _days = <WeatherDay>[];
    final List<dynamic> _forecasts = weather
      .cast<String, List<dynamic>>()[ 'forecasts' ];

    for( int day = todayIndex; day < _forecasts.length; day++ ) {
      _days.add( WeatherDay.fromJson( weather, day ) );
    }

    return WeatherWeek( days: _days );
  }
}

/// Data model for a single day of weather.
class WeatherDay {
  /// The name of the location where this weather is for.
  String locationName = 'Loading...';
  /// The date of the forecast.
  DateTime dateTime;
  /// The forecast data.
  WeatherForecast forecast;
  /// The observational data.
  WeatherObservations observations;
  /// The relevant radar images.
  WeatherRadar radar;

  /// Constructor.
  WeatherDay( {
    this.locationName,
    this.dateTime,
    this.forecast,
    this.observations,
    this.radar
  } );

  /// JSON factory.
  factory WeatherDay.fromJson( Map<String, dynamic> weather, int day ) {
    if ( weather['location']['name'] == null ) {
      return WeatherDay();
    }

    final String _locationName = weather['location']['name'].toString();
    DateTime _dateTime;
    WeatherForecast _forecast;
    WeatherObservations _observations;
    WeatherRadar _radar;

    final List<dynamic> _forecasts = weather
        .cast<String, List<dynamic>>()[ 'forecasts' ];

    if (  _forecasts != null && _forecasts.elementAt( day ) != null ) {
      final Map<String, dynamic> _dayData =
        _forecasts.cast<Map<String, dynamic>>()[ day ];

      _dateTime = DateTime.parse( _dayData[ 'dateTime' ]?.toString() );

      _forecast = WeatherForecast( _dayData );
    }

    if ( weather['observations'] != null ) {
      _observations = WeatherObservations(
        weather.cast<String, Map<String, dynamic>>()['observations']
      );
    }

    if ( weather['radar'] != null ) {
      _radar = WeatherRadar(
        weather.cast<String, Map<String, dynamic>>()['radar']
      );
    }

    return WeatherDay(
      locationName: _locationName,
      dateTime: _dateTime,
      forecast: _forecast,
      observations: _observations,
      radar: _radar,
    );
  }
}

/// Data model for a day of weather forecasting.
class WeatherForecast {
  WeatherForecastWeather weather;
  List<WeatherForecastHourlyTemperature> temperature;
  WeatherForecastRainfall rainfall;
  List<WeatherForecastHourlyRainfall> hourlyRainfall;
  List<WeatherForecastHourlyWind> hourlyWind;
  WeatherForecastUV uv;
  WeatherForecastWind windMax;
  WeatherForecastSun sun;
  WeatherForecastRegion region;

  /// Constructor.
  WeatherForecast( Map<String, dynamic> forecast ) {
    weather = WeatherForecastWeather(
      forecast.cast<String, Map<String, dynamic>>()[ 'weather' ]
    );

    temperature = forecast[ 'temperature' ].map<WeatherForecastHourlyTemperature>(
            ( hourTemperature ) => WeatherForecastHourlyTemperature( hourTemperature ) ).toList();
    if ( forecast.containsKey( 'rainfall' ) ) {
      rainfall = WeatherForecastRainfall( forecast[ 'rainfall' ] );
    }
    if ( forecast.containsKey( 'rainfallProbability' ) ) {
      hourlyRainfall = forecast[ 'rainfallProbability' ]
          .map<WeatherForecastHourlyRainfall>( ( hourRainfall ) => WeatherForecastHourlyRainfall( hourRainfall ) )
          .toList();
    }
    if ( forecast.containsKey( 'wind' ) ) {
      hourlyWind = forecast[ 'wind' ]
          .map<WeatherForecastHourlyWind>( ( hourlyWind ) => WeatherForecastHourlyWind( hourlyWind ) )
          .toList();
    }
    if ( forecast.containsKey( 'uv' ) ) {
      uv = WeatherForecastUV( forecast[ 'uv' ] );
    }
    windMax = WeatherForecastWind( forecast[ 'windMax' ] );
    sun = WeatherForecastSun( forecast[ 'sun' ] );
    if ( forecast.containsKey( 'region' ) ) {
      region = WeatherForecastRegion( forecast[ 'region' ] );
    }
  }
}

class WeatherForecastWeather {
  int min;
  int max;
  String code;
  String description;

  WeatherForecastWeather( Map<String, dynamic> weather ) {
    min = int.parse( weather[ 'min' ].toString() );
    max = int.parse( weather[ 'max' ].toString() );
    code = weather[ 'code' ].toString();
    description = weather[ 'description' ].toString();
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

class WeatherForecastHourlyWind {
  DateTime dateTime;
  double speed;
  double direction;
  String directionText;

  WeatherForecastHourlyWind( Map hourRainfall ) {
    this.dateTime = DateTime.parse( hourRainfall[ 'dateTime' ] );
    this.speed = hourRainfall[ 'speed' ].toDouble();
    this.direction = hourRainfall[ 'direction' ].toDouble();
    this.directionText = hourRainfall[ 'directionText' ];
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
  double direction;
  String directionText;

  WeatherObservationsWind( Map wind ) {
    this.speed = wind[ 'speed' ]?.toDouble();
    this.gustSpeed = wind[ 'gustSpeed' ]?.toDouble();
    this.direction = wind[ 'direction' ]?.toDouble();
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
