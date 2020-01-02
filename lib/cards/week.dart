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
            itemCount: weather.week.days.length,
            itemBuilder: ( BuildContext context, int index ) {
              WeatherForecastTemperature day = weather.week.days[ index ].forecast.temperature;
              return Container(
                height: 24,
                child: Row(
                  children: <Widget>[
                    Text( index == 0 ? 'Tomorrow' : Jiffy( weather.week.days[ index ].dateTime ).format( 'EEEE' ) ),
                    Icon( weatherIcon( day.code ) ),
                    Text( '${ day.min } ${ day.max }' )
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
