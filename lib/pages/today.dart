import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/weather_model.dart';
import '../widgets/day.dart';

/// A page for showing the detailed weather information for today.
class TodayPage extends StatefulWidget {
  /// The route for this page in the Navigator API.
  static const String route = '/today';

  /// Constructor.
  const TodayPage({Key key}) : super(key: key);

  @override
  _TodayPageState createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  @override
  Widget build(BuildContext context) => Consumer<WeatherModel>(
        builder: (BuildContext context, WeatherModel weather, Widget child) =>
            Scaffold(
          appBar: AppBar(
            title: Text(weather.today.locationName),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          extendBodyBehindAppBar: true,
          body: Day(day: weather.today),
        ),
      );
}
