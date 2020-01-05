import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tidyweather/widgets/SimpleWeatherGraph.dart';

import '../data/weather_model.dart';

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
          final List<WeatherForecastHourlyTemperature> data = weather.week.days[ 0 ].forecast.temperature.hourlyTemperature + weather.week.days[ 1 ].forecast.temperature.hourlyTemperature;
          return SizedBox(
            height: 250,
            child: SimpleWeatherGraph( weather.today.observations.temperature, data ),
          );
        },
      ),
    );
  }
}
