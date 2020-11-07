import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    return Consumer<WeatherModel>(
      builder: (context, weather, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(weather.today.locationName),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          extendBodyBehindAppBar: true,
          body: Day(weather.today),
        );
      },
    );
  }
}
