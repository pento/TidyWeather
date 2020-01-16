import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/location_model.dart';
import '../data/weather_model.dart';
import '../widgets/Day.dart';

class WeekPage extends StatefulWidget {
  static const String route = '/week';

  @override
  _WeekPageState createState() => _WeekPageState();
}

class _WeekPageState extends State<WeekPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocationModel>(
      builder: ( context, location, child ) {
        return Consumer<WeatherModel>(
          builder: ( context, weather, child ) {
            return Scaffold(
              appBar: AppBar(
                title: Text( location.location.name ),
              ),
              body: ListView.builder(
                shrinkWrap: true,
                itemCount: weather.week.days.length,
                itemBuilder: ( BuildContext context, int index ) {
                  if ( weather.week.days[ index ].dateTime.day == DateTime.now().day ) {
                    return Container();
                  }

                  return Card(
                    child: Day( weather.week.days[ index ] ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
