import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jiffy/jiffy.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../data/weather_model.dart';
import '../widgets/weather_gradient.dart';
import '../widgets/weather_icon.dart';

/// A widget for showing the weather details of a given day.
class Day extends StatelessWidget {
  /// The day being shown.
  final WeatherDay day;

  /// Constructor.
  const Day({Key key, this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String dayName;
    EdgeInsets padding = const EdgeInsets.fromLTRB(8, 8, 8, 8);
    Color background = Theme.of(context).splashColor;
    BoxDecoration decoration;
    if (day.dateTime.day == DateTime.now().day) {
      dayName = 'Today';

      padding = const EdgeInsets.fromLTRB(8, 88, 8, 8);
      background = null;
      decoration = BoxDecoration(
        gradient: weatherGradient(context, day.forecast.weather.code),
      );
    } else if (day.dateTime.day ==
        DateTime.now().add(const Duration(days: 1)).day) {
      dayName = 'Tomorrow';
    } else {
      dayName = Jiffy(day.dateTime).format('EEEE');
    }

    return Column(
      children: <Widget>[
        Container(
          color: background,
          decoration: decoration,
          padding: padding,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  SvgPicture.asset(
                    weatherIcon(day.forecast.weather.code),
                    width: 32,
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
                        dayName,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        textScaleFactor: 2,
                      ),
                      Text(
                        Jiffy(day.dateTime).format('do MMMM'),
                        style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                        ),
                      ),
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
                                text: '${day.forecast.weather.min.toString()} ',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                ),
                              ),
                              TextSpan(
                                text: day.forecast.weather.max.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          day.forecast.weather.description,
                          style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                day.forecast.region.name,
                style: Theme.of(context).textTheme.subtitle2,
              ),
              Container(
                height: 10,
              ),
              Text(day.forecast.region.description),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            children: <Widget>[
              if (day.forecast.rainfall != null)
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                            color: Color.fromARGB(0xFF, 0xCC, 0xCC, 0xCC)),
                        bottom: BorderSide(
                            color: Color.fromARGB(0xFF, 0xCC, 0xCC, 0xCC)),
                        right: BorderSide(
                            color: Color.fromARGB(0xFF, 0xCC, 0xCC, 0xCC)),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          MdiIcons.water,
                          color: Colors.blue,
                          size: 32,
                        ),
                        Text('${day.forecast.rainfall.rangeCode} mm'),
                        Text(
                          '${day.forecast.rainfall.probability}% chance',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          color: Color.fromARGB(0xFF, 0xCC, 0xCC, 0xCC)),
                      bottom: BorderSide(
                          color: Color.fromARGB(0xFF, 0xCC, 0xCC, 0xCC)),
                      right: BorderSide(
                          color: Color.fromARGB(0xFF, 0xCC, 0xCC, 0xCC)),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        MdiIcons.fan,
                        color: Colors.lightGreen,
                        size: 32,
                      ),
                      Text('${day.forecast.windMax.speed} km/h'),
                      Text(
                        'Max wind speed',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          color: Color.fromARGB(0xFF, 0xCC, 0xCC, 0xCC)),
                      bottom: BorderSide(
                          color: Color.fromARGB(0xFF, 0xCC, 0xCC, 0xCC)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(
                              MdiIcons.weatherSunsetUp,
                              color: Colors.amber,
                            ),
                            Container(height: 10),
                            Text(
                                Jiffy(day.forecast.sun.sunrise).format('h:mm')),
                            Text(
                              Jiffy(day.forecast.sun.sunrise).format('a'),
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(
                              MdiIcons.weatherSunsetDown,
                              color: Colors.amber,
                            ),
                            Container(height: 10),
                            Text(Jiffy(day.forecast.sun.sunset).format('h:mm')),
                            Text(
                              Jiffy(day.forecast.sun.sunset).format('a'),
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<WeatherDay>('day', day));
  }
}
