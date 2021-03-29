import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

import './data/config.dart';
import './data/location_model.dart';
import './data/preference_model.dart';
import './data/weather_model.dart';
import './pages/about.dart';
import './pages/home.dart';
import './pages/settings.dart';
import './pages/today.dart';
import './pages/week.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences _preferences = await SharedPreferences.getInstance();

  await Config().load('config.json');

  runApp(MultiProvider(
    providers: <InheritedProvider<dynamic>>[
      ChangeNotifierProvider<PreferenceModel>(
        create: (BuildContext context) =>
            PreferenceModel(preferences: _preferences),
      ),
      ChangeNotifierProvider<LocationModel>(
        create: (BuildContext context) =>
            LocationModel(preferences: _preferences),
      ),
      ChangeNotifierProxyProvider<LocationModel, WeatherModel>(
          create: (BuildContext context) => WeatherModel(
              Provider.of<LocationModel>(context, listen: false),
              preferences: _preferences),
          update: (BuildContext context, LocationModel location,
                  WeatherModel weather) =>
              WeatherModel(location,
                  context: context, preferences: _preferences)),
    ],
    child: MyApp(),
  ));

  await BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

/// The main app class.
class MyApp extends StatelessWidget {
  /// Constructor.
  MyApp({Key key}) : super(key: key) {
    BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 30,
          stopOnTerminate: false,
          enableHeadless: true,
          startOnBoot: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          requiredNetworkType: NetworkType.ANY,
        ), (String taskId) async {
      await LocationModel.load().whenComplete(() {
        BackgroundFetch.finish(taskId);
      });
    });
  }

  @override
  Widget build(BuildContext context) =>
      Selector<PreferenceModel, Tuple2<ThemeData, ThemeData>>(
        selector: (BuildContext context, PreferenceModel preferences) =>
            Tuple2<ThemeData, ThemeData>(preferences.lightTheme(context),
                preferences.darkTheme(context)),
        builder: (BuildContext context, Tuple2<ThemeData, ThemeData> themes,
                Widget child) =>
            MaterialApp(
          title: 'Tidy Weather',
          theme: themes.item1,
          darkTheme: themes.item2,
          home: const HomePage(),
          routes: <String, WidgetBuilder>{
            AboutPage.route: (BuildContext context) => const AboutPage(),
            SettingsPage.route: (BuildContext context) => const SettingsPage(),
            TodayPage.route: (BuildContext context) => const TodayPage(),
            WeekPage.route: (BuildContext context) => const WeekPage(),
          },
        ),
      );
}

/// This function is used by the BackgroundFetch library, which allows it to
/// check for weather updates even if the app has been killed by the OS.
Future<void> backgroundFetchHeadlessTask(HeadlessTask task) async {
  final LocationModel _location = LocationModel(background: true);

  await LocationModel.load().then((void data) {
    final WeatherModel _weather = WeatherModel(_location);
    return _weather.loadData();
  }).whenComplete(() {
    BackgroundFetch.finish(task.taskId);
  });
}
