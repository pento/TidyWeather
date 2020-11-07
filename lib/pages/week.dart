import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/weather_model.dart';
import '../widgets/day.dart';

/// A page for showing the weather forecast details for the coming week.
class WeekPage extends StatefulWidget {
  /// The route for this page in the Navigator API.
  static const String route = '/week';

  /// Constructor.
  const WeekPage({Key key}) : super(key: key);

  @override
  _WeekPageState createState() => _WeekPageState();
}

class _WeekPageState extends State<WeekPage> {
  @override
  Widget build(BuildContext context) => Consumer<WeatherModel>(
        builder: (BuildContext context, WeatherModel weather, Widget child) =>
            Scaffold(
          appBar: AppBar(
            title: Text(weather.today.locationName),
          ),
          body: ListView.builder(
            shrinkWrap: true,
            itemCount: weather.week.days.length,
            itemBuilder: (BuildContext context, int index) {
              if (weather.week.days[index].dateTime.day == DateTime.now().day) {
                return Container();
              }

              return Card(
                child: Day(day: weather.week.days[index]),
              );
            },
          ),
        ),
      );
}
