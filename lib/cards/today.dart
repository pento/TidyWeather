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
    return Container(
      color: Theme.of( context ).splashColor,
      padding: EdgeInsets.all( 8 ),
      child: Consumer<WeatherModel>(
        builder: ( context, weather, child ) {
          return Column(
            children: <Widget>[
              Row( // Big icon
                children: <Widget>[
                  Icon(
                    weatherIcon( weather.today.forecast.temperature.code ),
                    color: Colors.white,
                    size: 96,
                  )
                ],
              ),
              Row( // today's info
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${ weather.today.observations.temperature.temperature.toString() }°',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        textScaleFactor: 4,
                      ),
                      weather.today.observations.temperature.apparentTemperature != null?
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Feels like  ',
                                style: TextStyle(
                                  color: Color.fromARGB( 255, 0xDD, 0xDD, 0xDD ),
                                ),
                              ),
                              TextSpan(
                                text: weather.today.observations.temperature.apparentTemperature.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ):
                      Container(),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '${ weather.today.forecast.temperature.min.toString() } ',
                                style: TextStyle(
                                  color: Color.fromARGB( 255, 0xDD, 0xDD, 0xDD ),
                                ),
                              ),
                              TextSpan(
                                text: '${ weather.today.forecast.temperature.max.toString() }',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${ weather.today.forecast.temperature.description }',
                          style: TextStyle(
                            color: Color.fromARGB( 255, 0xDD, 0xDD, 0xDD ),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
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
