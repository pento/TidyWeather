import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';
import 'package:provider/provider.dart';
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

  await PrefService.init(prefix: 'pref_');
  await Config().load('config.json');

  runApp(MultiProvider(
    providers: <ChangeNotifierProvider<dynamic>>[
      ChangeNotifierProvider<LocationModel>(
          create: (BuildContext context) =>
              LocationModel(loadDataImmediately: false)),
      ChangeNotifierProvider<WeatherModel>(
          create: (BuildContext context) => WeatherModel(context: context)),
      ChangeNotifierProvider<PreferenceModel>(
          create: (BuildContext context) => PreferenceModel()),
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
Future<void> backgroundFetchHeadlessTask(String taskId) async {
  await PrefService.init(prefix: 'pref_');

  LocationModel(background: true);
  WeatherModel();

  await LocationModel.load().whenComplete(() {
    BackgroundFetch.finish(taskId);
  });
}
