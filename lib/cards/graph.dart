import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/weather_model.dart';

class GraphCard extends StatefulWidget {

  @override
  _GraphCardState createState() => _GraphCardState();

}

class _GraphCardState extends State<GraphCard> {

  Color convertTempToColor( double temp ) {
    MaterialColor _color;

    if ( temp < 15 ) {
      _color = Colors.lightBlue;
    } else if ( temp < 25 ) {
      _color = Colors.lightGreen;
    } else if ( temp < 35 ) {
      _color = Colors.orange;
    } else if ( temp < 45 ) {
      _color = Colors.red;
    } else {
      _color = Colors.deepPurple;
    }

    return Color( r: _color.red, g: _color.green, b: _color.blue, a: _color.alpha );
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Consumer<WeatherModel>(
        builder: ( context, weather, child ) {
          List<WeatherForecastHourlyTemperature> _data = new List();

          for ( int i = 0; i < weather.today.forecast.temperature.hourlyTemperature.length; i += 3 ) {
            _data.add( weather.today.forecast.temperature.hourlyTemperature[ i ] );
          }

          List<Series<WeatherForecastHourlyTemperature, DateTime>> seriesList = [
            new Series<WeatherForecastHourlyTemperature, DateTime>(
                id: 'HourlyTemperature',
                data: _data,
                colorFn: ( WeatherForecastHourlyTemperature hour, _ ) => convertTempToColor( hour.temperature ),
                domainFn: ( WeatherForecastHourlyTemperature hour, _ ) => hour.dateTime,
                measureFn: ( WeatherForecastHourlyTemperature hour, _ ) => hour.temperature,
            )
          ];

          return SizedBox(
            height: 300,
            child: TimeSeriesChart(
              seriesList,
              animate: false,
              defaultRenderer: LineRendererConfig(
                includePoints: true,
              ),
            )
          );
        },
      ),
    );
  }
}
