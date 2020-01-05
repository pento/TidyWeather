import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';

import '../data/weather_model.dart';
import '../widgets/weather_icon.dart';

class WeekCard extends StatefulWidget {

  @override
  _WeekCardState createState() => _WeekCardState();

}

class _WeekCardState extends State<WeekCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Consumer<WeatherModel>(
        builder: ( context, weather, child ) {
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: weather.week.days.length,
            itemBuilder: ( BuildContext context, int index ) {
              WeatherForecastTemperature day = weather.week.days[ index ].forecast.temperature;
              return Container(
                margin: EdgeInsets.symmetric( vertical: 0, horizontal: 12 ),
                padding: EdgeInsets.symmetric( vertical: 6, horizontal: 0 ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: index == weather.week.days.length - 1 ? BorderSide( width: 0 ) : BorderSide( color: Color.fromARGB( 0xFF, 0xCC, 0xCC, 0xCC )),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Text( index == 0 ? 'Tomorrow' : Jiffy( weather.week.days[ index ].dateTime ).format( 'EEEE' ) )
                    ),
                    Icon( weatherIcon( day.code ) ),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '    ${ day.min.toString() }    ',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          TextSpan(
                            text: day.max.toString(),
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
