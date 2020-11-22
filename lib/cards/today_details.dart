import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../data/weather_model.dart';
import '../widgets/weather_details_block.dart';

/// A card for detailed information for today.
class TodayDetailsCard extends StatefulWidget {
  /// Constructor.
  const TodayDetailsCard({Key key}) : super(key: key);

  @override
  _TodayDetailsCardState createState() => _TodayDetailsCardState();
}

class _TodayDetailsCardState extends State<TodayDetailsCard> {
  @override
  Widget build(BuildContext context) => Card(
        child: Selector<WeatherModel,
            Tuple2<WeatherForecast, WeatherObservations>>(
          selector: (BuildContext context, WeatherModel weather) =>
              Tuple2<WeatherForecast, WeatherObservations>(
                  weather.today.forecast, weather.today.observations),
          builder: (BuildContext context,
              Tuple2<WeatherForecast, WeatherObservations> data, Widget child) {
            final TextStyle textStyle = Theme.of(context).textTheme.bodyText2;
            final TextStyle lightTextStyle =
                Theme.of(context).textTheme.caption;

            final WeatherForecast forecast = data.item1;
            final WeatherObservations observations = data.item2;

            final String uvStartTime = Jiffy(forecast.uv.start).format('h:mm');
            final String uvEndTime = Jiffy(forecast.uv.end).format('h:mm');

            return Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: Color.fromARGB(0xFF, 0xCC, 0xCC, 0xCC)),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(Jiffy().format('EEEE do MMMM')),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    WeatherDetailsBlock(
                      icon: MdiIcons.beakerOutline,
                      iconColor: Colors.blue,
                      title: const Text('Rainfall since 9am'),
                      text: Text('${observations.rainfall.since9AMAmount}mm'),
                      subtext: const Text('Since 9am'),
                    ),
                    WeatherDetailsBlock(
                      icon: MdiIcons.water,
                      iconColor: Colors.blue,
                      title: const Text('Rain forecast'),
                      text: Text('${forecast.rainfall.rangeCode}mm'),
                      subtext: Text('${forecast.rainfall.probability}% chance'),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    WeatherDetailsBlock(
                      icon: MdiIcons.weatherSunny,
                      iconColor: Colors.deepPurple,
                      title: const Text('Current UV index'),
                      text: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              style: textStyle.copyWith(
                                  color:
                                      convertUVtoColor(observations.uv.index)),
                              text: observations.uv.description,
                            ),
                            TextSpan(
                              style: textStyle,
                              text: ' - ${observations.uv.index}',
                            ),
                          ],
                        ),
                      ),
                      subtext:
                          Text(Jiffy(observations.uv.utcDateTime).fromNow()),
                    ),
                    WeatherDetailsBlock(
                      icon: MdiIcons.weatherSunnyAlert,
                      iconColor: Colors.deepPurple,
                      title: const Text("Today's UV max"),
                      text: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              style: textStyle.copyWith(
                                  color: convertUVtoColor(forecast.uv.max)),
                              text: forecast.uv.description,
                            ),
                            TextSpan(
                              style: textStyle,
                              text: ' - ${forecast.uv.max}',
                            ),
                          ],
                        ),
                      ),
                      subtext: Text('$uvStartTime - $uvEndTime'),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    WeatherDetailsBlock(
                      icon: MdiIcons.fan,
                      iconColor: Colors.lightGreen,
                      title: const Text('Current wind speed'),
                      text: Text('${observations.wind.speed} km/h'),
                      subtext: Text(observations.wind.directionText),
                    ),
                    WeatherDetailsBlock(
                      icon: MdiIcons.weatherWindy,
                      iconColor: Colors.lightGreen,
                      title: const Text('Current wind gust'),
                      text: !observations.wind.gustSpeed.isNaN
                          ? Text('${observations.wind.gustSpeed} km/h')
                          : const Text('Unknown'),
                      subtext: const Text('Gust'),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    WeatherDetailsBlock(
                      icon: MdiIcons.weatherSunny,
                      iconColor: Colors.amber,
                      title: const Text('Sunrise/sunset'),
                      text: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                style: textStyle,
                                text: Jiffy(forecast.sun.sunrise)
                                    .format('H:mm ')),
                            TextSpan(
                                style: textStyle.copyWith(
                                    color: lightTextStyle.color),
                                text: Jiffy(forecast.sun.firstLight)
                                    .format('H:mm'))
                          ],
                        ),
                      ),
                      subtext: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                style: textStyle,
                                text:
                                    Jiffy(forecast.sun.sunset).format('H:mm ')),
                            TextSpan(
                                style: textStyle.copyWith(
                                    color: lightTextStyle.color),
                                text: Jiffy(forecast.sun.lastLight)
                                    .format('H:mm'))
                          ],
                        ),
                      ),
                    ),
                    WeatherDetailsBlock(
                      icon: MdiIcons.waterOutline,
                      iconColor: Colors.lightBlueAccent,
                      title: const Text('Relative humidity'),
                      text: Text('${observations.humidity.percentage}%'),
                      subtext: const Text('Humidity'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
}

/// Given a [uv] level, returns an appropriate colour.
Color convertUVtoColor(double uv) {
  if (uv <= 2) {
    return Colors.lightGreen;
  } else if (uv <= 5) {
    return Colors.yellow.shade800;
  } else if (uv <= 7) {
    return Colors.orange.shade800;
  } else if (uv <= 10) {
    return Colors.red.shade800;
  }

  return Colors.deepPurple.shade400;
}
