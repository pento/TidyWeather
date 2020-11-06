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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PrefService.init( prefix: 'pref_' );
  await Config().load( 'config.json' );

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider( create: ( context ) => LocationModel() ),
          ChangeNotifierProvider( create: ( context ) => WeatherModel( context: context ) ),
          ChangeNotifierProvider( create: ( context ) => PreferenceModel() ),
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
        requiredNetworkType: NetworkType.ANY,
    ), ( String taskId ) async {
      LocationModel.load().whenComplete( () { BackgroundFetch.finish( taskId ); } );
    } );
  }

  @override
  Widget build( BuildContext context ) {

    return Selector<PreferenceModel, Tuple2<ThemeData, ThemeData>>(
      selector: ( context, preferences ) => Tuple2( preferences.lightTheme( context ), preferences.darkTheme( context ) ),

      builder: ( context, themes, child ) {
        return MaterialApp(
          title: "Tidy Weather",
          theme: themes.item1,
          darkTheme: themes.item2,
          home: HomePage(),
          routes: <String, WidgetBuilder>{
            AboutPage.route: ( context ) => AboutPage(),
            SettingsPage.route: ( context ) => SettingsPage(),
            TodayPage.route: ( context ) => TodayPage(),
            WeekPage.route: ( context ) => WeekPage(),
          },
        );
      },
    );
  }
}

void backgroundFetchHeadlessTask( String taskId ) async {
  await PrefService.init( prefix: 'pref_' );

  LocationModel( background: true );
  WeatherModel();

  LocationModel.load().whenComplete( () { BackgroundFetch.finish( taskId ); } );
}
