import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../data/weather_model.dart';
import '../pages/today.dart';
import '../widgets/weather_gradient.dart';
import '../widgets/weather_icon.dart';

/// A card for showing a summary of today's weather.
class TodayCard extends StatefulWidget {
  /// Constructor.
  const TodayCard({Key key}) : super(key: key);

  @override
  _TodayCardState createState() => _TodayCardState();
}

class _TodayCardState extends State<TodayCard> {
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, TodayPage.route);
        },
        child: Selector<WeatherModel,
                Tuple2<WeatherForecast, WeatherObservations>>(
            selector: (BuildContext context, WeatherModel weather) =>
                Tuple2<WeatherForecast, WeatherObservations>(
                    weather.today.forecast, weather.today.observations),
            builder: (BuildContext context,
                Tuple2<WeatherForecast, WeatherObservations> data,
                Widget child) {
              final WeatherForecast forecast = data.item1;
              final WeatherObservations observations = data.item2;

              return Container(
                decoration: BoxDecoration(
                  gradient: weatherGradient(context, forecast.weather.code),
                ),
                padding: const EdgeInsets.fromLTRB(8, 88, 8, 8),
                child: Column(
                  children: <Widget>[
                    Row(
                      // Big icon
                      children: <Widget>[
                        SvgPicture.asset(
                          weatherIcon(forecast.weather.code, forecast.sun),
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
                              '${observations.temperature.temperature}°',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              textScaleFactor: 4,
                            ),
                            if (observations.temperature.apparentTemperature !=
                                null)
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
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
                                      text: observations
                                          .temperature.apparentTemperature
                                          .toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          '${forecast.weather.min.toString()} ',
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                      ),
                                    ),
                                    TextSpan(
                                      text: forecast.weather.max.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                forecast.weather.description,
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
            }),
      );
}
