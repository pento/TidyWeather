import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/weather_model.dart';
import '../widgets/simple_weather_graph.dart';

class GraphCard extends StatefulWidget {
  @override
  _GraphCardState createState() => _GraphCardState();
}

class _GraphCardState extends State<GraphCard> {
  String _display;

  @override
  void initState() {
    super.initState();

    _display = 'temperature';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Consumer<WeatherModel>(
            builder: (context, weather, child) {
              final List<WeatherForecastHourlyTemperature> temperatureData =
                  weather.week.days[0].forecast.temperature +
                      weather.week.days[1]?.forecast?.temperature;
              final List<WeatherForecastHourlyRainfall> rainfallData =
                  weather.week.days[0].forecast.hourlyRainfall +
                      weather.week.days[1]?.forecast?.hourlyRainfall;
              List<WeatherForecastHourlyWind> windData;
              if (weather.week.days[0].forecast.hourlyWind != null &&
                  weather.week.days[1]?.forecast?.hourlyWind != null) {
                windData = weather.week.days[0].forecast.hourlyWind +
                    weather.week.days[1]?.forecast?.hourlyWind;
              }
              return SizedBox(
                height: 250,
                child: SimpleWeatherGraph(weather.today.observations,
                    temperatureData, rainfallData, windData, _display),
              );
            },
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            layoutBehavior: ButtonBarLayoutBehavior.constrained,
            children: <Widget>[
              TextButton(
                child: Text('Temperature (℃)'),
                style: TextButton.styleFrom(
                    backgroundColor: _display == 'temperature'
                        ? Theme.of(context).backgroundColor.withOpacity(0.2)
                        : null),
                onPressed: () => setState(() => _display = 'temperature'),
              ),
              TextButton(
                child: Text('Wind (km/h)'),
                style: TextButton.styleFrom(
                    backgroundColor: _display == 'wind'
                        ? Theme.of(context).backgroundColor.withOpacity(0.2)
                        : null),
                onPressed: () => setState(() => _display = 'wind'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
