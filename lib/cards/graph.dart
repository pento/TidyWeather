import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/weather_model.dart';
import '../widgets/SimpleWeatherGraph.dart';

class GraphCard extends StatefulWidget {

  @override
  _GraphCardState createState() => _GraphCardState();

}

class _GraphCardState extends State<GraphCard> {

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Consumer<WeatherModel>(
        builder: ( context, weather, child ) {
          final List<WeatherForecastHourlyTemperature> temperatureData = weather.week.days[ 0 ].forecast.temperature + weather.week.days[ 1 ].forecast.temperature;
          final List<WeatherForecastHourlyRainfall> rainfallData = weather.week.days[ 0 ].forecast.hourlyRainfall + weather.week.days[ 1 ].forecast.hourlyRainfall;
          List<WeatherForecastHourlyWind> windData;
          if ( weather.week.days[ 0 ].forecast.hourlyWind != null && weather.week.days[ 1 ].forecast.hourlyWind != null ) {
            windData = weather.week.days[ 0 ].forecast.hourlyWind + weather.week.days[ 1 ].forecast.hourlyWind;
          }
          return SizedBox(
            height: 250,
            child: SimpleWeatherGraph( weather.today.observations.temperature, temperatureData, rainfallData, windData ),
          );
        },
      ),
    );
  }
}
