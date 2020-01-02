import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';
import 'package:provider/provider.dart';

import './data/location_model.dart';
import './data/uv_model.dart';
import './data/weather_model.dart';
import './pages/home.dart';
import './pages/settings.dart';

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
}

class MyApp extends StatelessWidget {
  @override
  Widget build( BuildContext context ) {
    return MaterialApp(
      title: "Tidy Weather",
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
      routes: <String, WidgetBuilder>{
        SettingsPage.route: ( context ) => SettingsPage(),
      },
    );
  }
}
