import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tidyweather/data/location_model.dart';

import '../data/weather_model.dart';
import '../widgets/Day.dart';

class TodayPage extends StatefulWidget {
  static const String route = '/today';

  @override
  _TodayPageState createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
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
              body: Day( weather.today ),
            );
          },
        );
      },
    );
  }
}
