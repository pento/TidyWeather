import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/weather_model.dart';
import '../widgets/simple_weather_graph.dart';

/// A card for showing the forecast temperature and wind over the next 24 hours.
class GraphCard extends StatefulWidget {
  /// Constructor.
  const GraphCard({Key key}) : super(key: key);

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
  Widget build(BuildContext context) => Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Consumer<WeatherModel>(
              builder:
                  (BuildContext context, WeatherModel weather, Widget child) {
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
                  child: SimpleWeatherGraph(
                      now: weather.today.observations,
                      forecast: temperatureData,
                      rainfall: rainfallData,
                      wind: windData,
                      display: _display),
                );
              },
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              layoutBehavior: ButtonBarLayoutBehavior.constrained,
              children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: _display == 'temperature'
                          ? Theme.of(context).backgroundColor.withOpacity(0.2)
                          : null),
                  onPressed: () => setState(() => _display = 'temperature'),
                  child: const Text('Temperature (℃)'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: _display == 'wind'
                          ? Theme.of(context).backgroundColor.withOpacity(0.2)
                          : null),
                  onPressed: () => setState(() => _display = 'wind'),
                  child: const Text('Wind (km/h)'),
                ),
              ],
            ),
          ],
        ),
      );
}
