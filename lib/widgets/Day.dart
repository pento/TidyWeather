import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jiffy/jiffy.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../data/weather_model.dart';
import '../widgets/weatherGradient.dart';
import '../widgets/weatherIcon.dart';

class Day extends StatelessWidget {
  final WeatherDay _day;

  Day(this._day);

  @override
  Widget build(BuildContext context) {
    String dayName;
    EdgeInsets padding = EdgeInsets.fromLTRB(8, 8, 8, 8);
    Color background = Theme.of(context).splashColor;
    BoxDecoration decoration;
    if (_day.dateTime.day == DateTime.now().day) {
      dayName = 'Today';

      padding = EdgeInsets.fromLTRB(8, 88, 8, 8);
      background = null;
      decoration = BoxDecoration(
        gradient: weatherGradient(context, _day.forecast.weather.code),
      );
    } else if (_day.dateTime.day ==
        DateTime.now().add(new Duration(days: 1)).day) {
      dayName = 'Tomorrow';
    } else {
      dayName = Jiffy(_day.dateTime).format('EEEE');
    }

    return Container(
      child: Column(
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
                      weatherIcon(_day.forecast.weather.code),
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
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          textScaleFactor: 2,
                        ),
                        Text(
                          Jiffy(_day.dateTime).format('do MMMM'),
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
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      '${_day.forecast.weather.min.toString()} ',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                ),
                                TextSpan(
                                  text: _day.forecast.weather.max.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _day.forecast.weather.description,
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
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _day.forecast.region.name,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                Container(
                  height: 10,
                ),
                Text(_day.forecast.region.description),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              children: <Widget>[
                _day.forecast.rainfall != null
                    ? Expanded(
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                  color:
                                      Color.fromARGB(0xFF, 0xCC, 0xCC, 0xCC)),
                              bottom: BorderSide(
                                  color:
                                      Color.fromARGB(0xFF, 0xCC, 0xCC, 0xCC)),
                              right: BorderSide(
                                  color:
                                      Color.fromARGB(0xFF, 0xCC, 0xCC, 0xCC)),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                MdiIcons.water,
                                color: Colors.blue,
                                size: 32,
                              ),
                              Text('${_day.forecast.rainfall.rangeCode} mm'),
                              Text(
                                '${_day.forecast.rainfall.probability}% chance',
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
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
                        Icon(
                          MdiIcons.fan,
                          color: Colors.lightGreen,
                          size: 32,
                        ),
                        Text('${_day.forecast.windMax.speed} km/h'),
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
                    decoration: BoxDecoration(
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
                              Icon(
                                MdiIcons.weatherSunsetUp,
                                color: Colors.amber,
                              ),
                              Container(height: 10),
                              Text(Jiffy(_day.forecast.sun.sunrise)
                                  .format('h:mm')),
                              Text(
                                Jiffy(_day.forecast.sun.sunrise).format('a'),
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                MdiIcons.weatherSunsetDown,
                                color: Colors.amber,
                              ),
                              Container(height: 10),
                              Text(Jiffy(_day.forecast.sun.sunset)
                                  .format('h:mm')),
                              Text(
                                Jiffy(_day.forecast.sun.sunset).format('a'),
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
      ),
    );
  }
}
