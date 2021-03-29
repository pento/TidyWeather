import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pedantic/pedantic.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'location_model.dart';

/// Contains the weather data model.
class WeatherModel extends ChangeNotifier {
  Map<String, dynamic> _weather;
  static const MethodChannel _platform =
      MethodChannel('net.pento.tidyweather/widget');
  BuildContext _context;
  SharedPreferences _preferences;
  LocationModel _location;

  /// Construct a WeatherModel.
  WeatherModel(LocationModel location,
      {BuildContext context, SharedPreferences preferences}) {
    _preferences = preferences;
    final String weatherCache = _preferences.getString('cached_weather_data');
    if (weatherCache != null) {
      final Map<String, dynamic> data =
          // ignore: avoid_as
          jsonDecode(weatherCache) as Map<String, dynamic>;

      if (data.containsKey('location')) {
        _weather = data;
      }
    }

    _context = context;
    _location = location;

    loadData();
  }

  /// Find the index of today in _weather[ 'forecasts' ].
  /// Returns -1 if today couldn't be found.
  int todayIndex() {
    final DateTime now = DateTime.now();

    if (_weather == null || _weather.containsKey('error')) {
      return -1;
    }

    return _weather
        .cast<String, List<dynamic>>()['forecasts']
        .cast<Map<String, dynamic>>()
        .indexWhere((Map<String, dynamic> day) {
      final DateTime thisDay = DateTime.parse(day['dateTime'].toString());
      if (thisDay.day == now.day && thisDay.month == now.month) {
        return true;
      }

      return false;
    });
  }

  /// The weather for today.
  WeatherDay get today => WeatherDay.fromJson(_weather, todayIndex());

  /// Get the forecast for the coming week.
  WeatherWeek get week => WeatherWeek.fromJson(_weather, todayIndex());

  /// Load the data for the given location.
  Future<void> loadData() async {
    if (_location.town == '' ||
        _location.postCode == '' ||
        _location.uvStation == '') {
      return;
    }

    final Uri url = Uri.parse(
        'https://api.tidyweather.com/api/weather?town=${_location.town}&postcode=${_location.postCode}&uvstation=${_location.uvStation}');
    final http.Response weatherResponse = await http.get(url);
    final dynamic data = jsonDecode(weatherResponse.body);
    if (data is Map<String, dynamic>) {
      if (data.containsKey('error')) {
        developer.log('API error retrieving weather: ${data['error']}');
      }
      _weather = data;
    }

    await _preferences.setString('cached_weather_data', weatherResponse.body);

    if (_context != null && today.radar != null) {
      for (final WeatherRadarImage image in today.radar.overlays) {
        final Image theImage = Image.network(image.url);
        unawaited(precacheImage(theImage.image, _context));
      }
    }

    notifyListeners();

    if (Platform.isAndroid) {
      unawaited(_platform.invokeMethod('updateWeatherData', <String, String>{
        'current': today.observations.temperature.temperature.toString(),
        'min': today.forecast.weather.min.toString(),
        'max': today.forecast.weather.max.toString(),
        'code': today.forecast.weather.code,
        'sunrise': today.forecast.sun.sunrise.toIso8601String(),
        'sunset': today.forecast.sun.sunset.toIso8601String(),
      }));
    }
  }
}

/// Given a some API data that may be defined, or may be empty,
/// return double.nan if we couldn't handle the data.
double maybeParseDouble(dynamic data) {
  if (data == null) {
    return double.nan;
  }

  if (data.toString().isEmpty) {
    return double.nan;
  }

  try {
    return double.parse(data.toString());
  } on Exception {
    return double.nan;
  }
}

/// Data model for a week of weather.
class WeatherWeek {
  /// A list of the days in this week.
  List<WeatherDay> days;

  /// Constructor.
  WeatherWeek({this.days});

  /// JSON Factory.
  factory WeatherWeek.fromJson(Map<String, dynamic> weather, int todayIndex) {
    final List<WeatherDay> _days = <WeatherDay>[];
    final List<dynamic> _forecasts =
        weather.cast<String, List<dynamic>>()['forecasts'];

    for (int day = todayIndex; day < _forecasts.length; day++) {
      _days.add(WeatherDay.fromJson(weather, day));
    }

    return WeatherWeek(days: _days);
  }
}

/// Data model for a single day of weather.
class WeatherDay {
  /// The name of the location where this weather is for.
  String locationName;

  /// The date of the forecast.
  DateTime dateTime;

  /// The forecast data.
  WeatherForecast forecast;

  /// The observational data.
  WeatherObservations observations;

  /// The relevant radar images.
  WeatherRadar radar;

  /// Constructor.
  WeatherDay(
      {this.locationName,
      this.dateTime,
      this.forecast,
      this.observations,
      this.radar});

  /// JSON factory.
  factory WeatherDay.fromJson(Map<String, dynamic> weather, int day) {
    if (weather == null ||
        weather['location'] == null ||
        weather['location']['name'] == null) {
      return WeatherDay(locationName: 'Loading...');
    }

    final String _locationName = weather['location']['name'].toString();
    DateTime _dateTime;
    WeatherForecast _forecast;
    WeatherObservations _observations;
    WeatherRadar _radar;

    final List<dynamic> _forecasts =
        weather.cast<String, List<dynamic>>()['forecasts'];

    if (_forecasts != null && _forecasts.elementAt(day) != null) {
      final Map<String, dynamic> _dayData =
          _forecasts.cast<Map<String, dynamic>>()[day];

      _dateTime = DateTime.parse(_dayData['dateTime']?.toString());

      _forecast = WeatherForecast.fromJson(_dayData);
    }

    if (weather['observations'] != null) {
      _observations = WeatherObservations.fromJson(
          weather.cast<String, Map<String, dynamic>>()['observations']);
    }

    if (weather['radar'] != null) {
      _radar = WeatherRadar.fromJson(
          weather.cast<String, Map<String, dynamic>>()['radar']);
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
  WeatherForecast({
    this.weather,
    this.temperature,
    this.rainfall,
    this.hourlyRainfall,
    this.hourlyWind,
    this.uv,
    this.windMax,
    this.sun,
    this.region,
  });

  /// JSON factory.
  factory WeatherForecast.fromJson(Map<String, dynamic> forecast) {
    final WeatherForecastWeather _weather = WeatherForecastWeather.fromJson(
        forecast.cast<String, Map<String, dynamic>>()['weather']);

    final List<WeatherForecastHourlyTemperature> _temperature = forecast
        .cast<String, List<dynamic>>()['temperature']
        .cast<Map<String, dynamic>>()
        .map<WeatherForecastHourlyTemperature>(
            (Map<String, dynamic> hourTemperature) =>
                WeatherForecastHourlyTemperature.fromJson(hourTemperature))
        .toList();

    WeatherForecastRainfall _rainfall;
    if (forecast.containsKey('rainfall')) {
      _rainfall = WeatherForecastRainfall.fromJson(
          forecast.cast<String, Map<String, dynamic>>()['rainfall']);
    }

    List<WeatherForecastHourlyRainfall> _hourlyRainfall;
    if (forecast.containsKey('rainfallProbability')) {
      _hourlyRainfall = forecast
          .cast<String, List<dynamic>>()['rainfallProbability']
          .cast<Map<String, dynamic>>()
          .map<WeatherForecastHourlyRainfall>(
              (Map<String, dynamic> hourRainfall) =>
                  WeatherForecastHourlyRainfall.fromJson(hourRainfall))
          .toList();
    }

    List<WeatherForecastHourlyWind> _hourlyWind;
    if (forecast.containsKey('wind')) {
      _hourlyWind = forecast
          .cast<String, List<dynamic>>()['wind']
          .cast<Map<String, dynamic>>()
          .map<WeatherForecastHourlyWind>((Map<String, dynamic> hourlyWind) =>
              WeatherForecastHourlyWind.fromJson(hourlyWind))
          .toList();
    }

    WeatherForecastUV _uv;
    if (forecast.containsKey('uv')) {
      _uv = WeatherForecastUV.fromJson(
          forecast.cast<String, Map<String, dynamic>>()['uv']);
    }

    final WeatherForecastWind _windMax = WeatherForecastWind.fromJson(
        forecast.cast<String, Map<String, dynamic>>()['windMax']);

    final WeatherForecastSun _sun = WeatherForecastSun.fromJson(
        forecast.cast<String, Map<String, dynamic>>()['sun']);

    WeatherForecastRegion _region;
    if (forecast.containsKey('region')) {
      _region = WeatherForecastRegion.fromJson(
          forecast.cast<String, Map<String, dynamic>>()['region']);
    }

    return WeatherForecast(
      weather: _weather,
      temperature: _temperature,
      rainfall: _rainfall,
      hourlyRainfall: _hourlyRainfall,
      hourlyWind: _hourlyWind,
      uv: _uv,
      windMax: _windMax,
      sun: _sun,
      region: _region,
    );
  }
}

class WeatherForecastWeather {
  int min;
  int max;
  String code;
  String description;

  /// Constructor.
  WeatherForecastWeather({this.min, this.max, this.code, this.description});

  /// JSON factory.
  factory WeatherForecastWeather.fromJson(Map<String, dynamic> weather) =>
      WeatherForecastWeather(
        min: int.parse(weather['min'].toString()),
        max: int.parse(weather['max'].toString()),
        code: weather['code'].toString(),
        description: weather['description'].toString(),
      );
}

class WeatherForecastHourlyTemperature {
  double temperature;
  DateTime dateTime;

  /// Constructor.
  WeatherForecastHourlyTemperature({this.temperature, this.dateTime});

  /// JSON factory.
  factory WeatherForecastHourlyTemperature.fromJson(
          Map<String, dynamic> hourTemperature) =>
      WeatherForecastHourlyTemperature(
        temperature: maybeParseDouble(hourTemperature['temperature']),
        dateTime: DateTime.parse(hourTemperature['dateTime'].toString()),
      );

  /// Values factory.
  WeatherForecastHourlyTemperature.fromValues({
    this.temperature,
    this.dateTime,
  });
}

class WeatherForecastRainfall {
  String rangeCode;
  int probability;

  /// Constructor.
  WeatherForecastRainfall({this.rangeCode, this.probability});

  /// JSON factory.
  factory WeatherForecastRainfall.fromJson(Map<String, dynamic> rainfall) =>
      WeatherForecastRainfall(
        rangeCode: rainfall['rangeCode'].toString(),
        probability: int.parse(rainfall['probability'].toString()),
      );
}

class WeatherForecastHourlyRainfall {
  DateTime dateTime;
  int probability;

  /// Constructor.
  WeatherForecastHourlyRainfall({this.dateTime, this.probability});

  /// JSON factory.
  factory WeatherForecastHourlyRainfall.fromJson(
          Map<String, dynamic> hourRainfall) =>
      WeatherForecastHourlyRainfall(
        dateTime: DateTime.parse(hourRainfall['dateTime'].toString()),
        probability: int.parse(hourRainfall['probability'].toString()),
      );
}

class WeatherForecastHourlyWind {
  DateTime dateTime;
  double speed;
  double direction;
  String directionText;

  /// Constructor.
  WeatherForecastHourlyWind(
      {this.dateTime, this.speed, this.direction, this.directionText});

  /// JSON factory.
  factory WeatherForecastHourlyWind.fromJson(
          Map<String, dynamic> hourRainfall) =>
      WeatherForecastHourlyWind(
        dateTime: DateTime.parse(hourRainfall['dateTime'].toString()),
        speed: maybeParseDouble(hourRainfall['speed']),
        direction: maybeParseDouble(hourRainfall['direction']),
        directionText: hourRainfall['directionText'].toString(),
      );
}

class WeatherForecastUV {
  double max;
  String description;
  DateTime start;
  DateTime end;

  /// Constructor.
  WeatherForecastUV({this.max, this.description, this.start, this.end});

  /// JSON factory.
  factory WeatherForecastUV.fromJson(Map<String, dynamic> uv) =>
      WeatherForecastUV(
        max: maybeParseDouble(uv['max']),
        description: uv['description'].toString(),
        start: DateTime.parse(uv['start'].toString()),
        end: DateTime.parse(uv['end'].toString()),
      );
}

class WeatherForecastWind {
  DateTime dateTime;
  double speed;
  int direction;
  String directionText;

  /// Constructor.
  WeatherForecastWind(
      {this.dateTime, this.speed, this.direction, this.directionText});

  /// JSON factory.
  factory WeatherForecastWind.fromJson(Map<String, dynamic> wind) =>
      WeatherForecastWind(
        dateTime: DateTime.parse(wind['dateTime'].toString()),
        speed: maybeParseDouble(wind['speed']),
        direction: int.parse(wind['direction'].toString()),
        directionText: wind['directionText'].toString(),
      );
}

class WeatherForecastSun {
  DateTime firstLight;
  DateTime sunrise;
  DateTime sunset;
  DateTime lastLight;

  /// Constructor.
  WeatherForecastSun(
      {this.firstLight, this.sunrise, this.sunset, this.lastLight});

  /// JSON factory.
  factory WeatherForecastSun.fromJson(Map<String, dynamic> sun) =>
      WeatherForecastSun(
        firstLight: DateTime.parse(sun['firstLight'].toString()),
        sunrise: DateTime.parse(sun['sunrise'].toString()),
        sunset: DateTime.parse(sun['sunset'].toString()),
        lastLight: DateTime.parse(sun['lastLight'].toString()),
      );
}

class WeatherForecastRegion {
  String name;
  String description;

  /// Constructor
  WeatherForecastRegion({this.name, this.description});

  /// JSON factory.
  factory WeatherForecastRegion.fromJson(Map<String, dynamic> region) =>
      WeatherForecastRegion(
        name: region['name'].toString(),
        description: region['description'].toString(),
      );
}

class WeatherObservations {
  WeatherObservationsTemperature temperature;
  WeatherObservationsRainfall rainfall;
  WeatherObservationsWind wind;
  WeatherObservationsUv uv;
  WeatherObservationsHumidity humidity;

  /// Constructor.
  WeatherObservations(
      {this.temperature, this.rainfall, this.wind, this.uv, this.humidity});

  /// JSON factory.
  factory WeatherObservations.fromJson(Map<String, dynamic> observations) =>
      WeatherObservations(
        temperature: WeatherObservationsTemperature.fromJson(
            observations.cast<String, Map<String, dynamic>>()['temperature']),
        rainfall: WeatherObservationsRainfall.fromJson(
            observations.cast<String, Map<String, dynamic>>()['rainfall']),
        wind: WeatherObservationsWind.fromJson(
            observations.cast<String, Map<String, dynamic>>()['wind']),
        uv: WeatherObservationsUv.fromJson(
            observations.cast<String, Map<String, dynamic>>()['uv']),
        humidity: WeatherObservationsHumidity.fromJson(
            observations.cast<String, Map<String, dynamic>>()['humidity']),
      );
}

class WeatherObservationsTemperature {
  double temperature;
  double apparentTemperature;

  /// Constructor.
  WeatherObservationsTemperature({this.temperature, this.apparentTemperature});

  /// JSON factory.
  factory WeatherObservationsTemperature.fromJson(
          Map<String, dynamic> temperature) =>
      WeatherObservationsTemperature(
        temperature: maybeParseDouble(temperature['temperature']),
        apparentTemperature:
            maybeParseDouble(temperature['apparentTemperature']),
      );
}

class WeatherObservationsWind {
  double speed;
  double gustSpeed;
  double direction;
  String directionText;

  /// Constructor.
  WeatherObservationsWind(
      {this.speed, this.gustSpeed, this.direction, this.directionText});

  /// JSON factory.
  factory WeatherObservationsWind.fromJson(Map<String, dynamic> wind) =>
      WeatherObservationsWind(
        speed: maybeParseDouble(wind['speed']),
        gustSpeed: maybeParseDouble(wind['gustSpeed']),
        direction: maybeParseDouble(wind['direction']),
        directionText: wind['directionText'].toString(),
      );
}

class WeatherObservationsRainfall {
  double since9AMAmount;

  /// Constructor.
  WeatherObservationsRainfall({this.since9AMAmount});

  /// JSON factory.
  factory WeatherObservationsRainfall.fromJson(Map<String, dynamic> rainfall) =>
      WeatherObservationsRainfall(
        since9AMAmount: maybeParseDouble(rainfall['since9AMAmount']),
      );
}

class WeatherObservationsUv {
  double index;
  String description;
  String name;
  DateTime utcDateTime;

  /// Constructor.
  WeatherObservationsUv(
      {this.index, this.description, this.name, this.utcDateTime});

  /// JSON factory.
  factory WeatherObservationsUv.fromJson(Map<String, dynamic> uv) =>
      WeatherObservationsUv(
        index: maybeParseDouble(uv['index']),
        description: uv['description'].toString(),
        name: uv['name'].toString(),
        utcDateTime: DateTime.parse(uv['utcDateTime'].toString()),
      );
}

class WeatherObservationsHumidity {
  double percentage;

  /// Constructor.
  WeatherObservationsHumidity({this.percentage});

  /// JSON factory.
  factory WeatherObservationsHumidity.fromJson(Map<String, dynamic> humidity) =>
      WeatherObservationsHumidity(
        percentage: maybeParseDouble(humidity['percentage']),
      );
}

class WeatherRadar {
  int interval;
  String name;
  WeatherRadarLocation mapMin;
  WeatherRadarLocation mapMax;
  WeatherRadarLocation location;
  List<WeatherRadarImage> overlays;

  /// Constructor.
  WeatherRadar(
      {this.interval,
      this.name,
      this.mapMin,
      this.mapMax,
      this.location,
      this.overlays});

  /// JSON factory.
  factory WeatherRadar.fromJson(Map<String, dynamic> radar) => WeatherRadar(
        interval: int.parse(radar['interval'].toString()),
        name: radar['name'].toString(),
        mapMin: WeatherRadarLocation(
            latitude: maybeParseDouble(radar['bounds']['minLat']),
            longitude: maybeParseDouble(radar['bounds']['minLng'])),
        mapMax: WeatherRadarLocation(
            latitude: maybeParseDouble(radar['bounds']['maxLat']),
            longitude: maybeParseDouble(radar['bounds']['maxLng'])),
        location: WeatherRadarLocation(
            latitude: maybeParseDouble(radar['lat']),
            longitude: maybeParseDouble(radar['lng'])),
        overlays: radar
            .cast<String, List<dynamic>>()['overlays']
            .cast<Map<String, dynamic>>()
            .map<WeatherRadarImage>((Map<String, dynamic> radarImage) =>
                WeatherRadarImage.fromJson(
                    radarImage, radar['overlayPath'].toString()))
            .toList(),
      );
}

class WeatherRadarLocation {
  double latitude;
  double longitude;

  /// Constructor.
  WeatherRadarLocation({this.latitude, this.longitude});
}

class WeatherRadarImage {
  DateTime dateTime;
  String url;

  /// Constructor.
  WeatherRadarImage({this.dateTime, this.url});

  /// JSON factory.
  factory WeatherRadarImage.fromJson(
          Map<String, dynamic> radarImage, String path) =>
      WeatherRadarImage(
        dateTime: DateTime.parse('${radarImage['dateTime']}Z'),
        url: '$path${radarImage['name']}',
      );
}
