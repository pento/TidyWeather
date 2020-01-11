import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';
import 'package:provider/provider.dart';

import './data/location_model.dart';
import './data/uv_model.dart';
import './data/weather_model.dart';
import './pages/home.dart';
import './pages/settings.dart';
import './pages/today.dart';
import './pages/week.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PrefService.init( prefix: 'pref_' );

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider( create: ( context ) => LocationModel() ),
          ChangeNotifierProvider( create: ( context ) => UVModel() ),
          ChangeNotifierProvider( create: ( context ) => WeatherModel() ),
        ],
        child: MyApp(),
      )
  );

  BackgroundFetch.registerHeadlessTask( backgroundFetchHeadlessTask );
}

class MyApp extends StatelessWidget {

  MyApp() {
    BackgroundFetch.configure( BackgroundFetchConfig(
        minimumFetchInterval: 30,
        stopOnTerminate: false,
        enableHeadless: true,
        startOnBoot: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: BackgroundFetchConfig.NETWORK_TYPE_ANY
    ), () async {
      LocationModel.load().whenComplete( () { BackgroundFetch.finish(); } );
    } );
  }

  @override
  Widget build( BuildContext context ) {
    return MaterialApp(
      title: "Tidy Weather",
      theme: ThemeData(
        brightness: Brightness.light,
        splashColor: Colors.lightBlue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: HomePage(),
      routes: <String, WidgetBuilder>{
        SettingsPage.route: ( context ) => SettingsPage(),
        TodayPage.route: ( context ) => TodayPage(),
        WeekPage.route: ( context ) => WeekPage(),
      },
    );
  }
}

void backgroundFetchHeadlessTask() async {
  await PrefService.init( prefix: 'pref_' );

  LocationModel();
  UVModel();
  WeatherModel( background: true );

  LocationModel.load().whenComplete( () { BackgroundFetch.finish(); } );
}
