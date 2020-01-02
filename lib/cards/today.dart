import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/weather_model.dart';
import '../widgets/weather_icon.dart';

class TodayCard extends StatefulWidget {

  @override
  _TodayCardState createState() => _TodayCardState();

}

class _TodayCardState extends State<TodayCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Consumer<WeatherModel>(
        builder: ( context, weather, child ) {
          return Column(
            children: <Widget>[
              Row( // Big icon
                children: <Widget>[
                  Icon(
                    weatherIcon( weather.today.forecast.temperature.code ),
                    size: 96,
                  )
                ],
              ),
              Row( // today's info
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        '${ weather.today.observations.temperature.temperature.toString() }°',
                        textScaleFactor: 4,
                      ),
                      Text(
                        'Feels like ${ weather.today.observations.temperature.apparentTemperature.toString() }°',
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        '${ weather.today.forecast.temperature.min.toString() } ${ weather.today.forecast.temperature.max.toString() }',
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        '${ weather.today.forecast.temperature.description }',
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
