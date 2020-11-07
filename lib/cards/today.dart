import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../data/weather_model.dart';
import '../pages/today.dart';
import '../widgets/weatherGradient.dart';
import '../widgets/weatherIcon.dart';

class TodayCard extends StatefulWidget {
  @override
  _TodayCardState createState() => _TodayCardState();
}

class _TodayCardState extends State<TodayCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, TodayPage.route);
      },
      child: Consumer<WeatherModel>(
        builder: (context, weather, child) {
          return Container(
            decoration: BoxDecoration(
              gradient:
                  weatherGradient(context, weather.today.forecast.weather.code),
            ),
            padding: EdgeInsets.fromLTRB(8, 88, 8, 8),
            child: Column(
              children: <Widget>[
                Row(
                  // Big icon
                  children: <Widget>[
                    SvgPicture.asset(
                      weatherIcon(weather.today.forecast.weather.code,
                          weather.today.forecast.sun),
                      width: 96,
                    )
                  ],
                ),
                Row(
                  // today's info
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${weather.today.observations.temperature.temperature}°',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          textScaleFactor: 4,
                        ),
                        weather.today.observations.temperature
                                    .apparentTemperature !=
                                null
                            ? RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Feels like  ',
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                      ),
                                    ),
                                    TextSpan(
                                      text: weather.today.observations
                                          .temperature.apparentTemperature
                                          .toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
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
                                  text:
                                      '${weather.today.forecast.weather.min.toString()} ',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                ),
                                TextSpan(
                                  text: weather.today.forecast.weather.max
                                      .toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            weather.today.forecast.weather.description,
                            style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
