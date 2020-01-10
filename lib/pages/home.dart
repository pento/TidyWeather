
import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';
import 'package:provider/provider.dart';

import './settings.dart';
import '../cards/graph.dart';
import '../cards/today.dart';
import '../cards/today_details.dart';
import '../cards/week.dart';
import '../data/location_model.dart';
import '../data/weather_model.dart';
import '../widgets/drawer.dart';

class HomePage extends StatefulWidget {
  static const String route = '/';

  @override
  AppState createState() => AppState();
}

class AppState extends State<HomePage> {

  @override
  Widget build( BuildContext context ) {
    String apiKey = PrefService.getString( 'api_key' );
    if ( apiKey == null || apiKey == '' ) {
      return SettingsPage();
    }

    return Consumer<LocationModel>(
      builder: ( context, location, child ) {
        return Consumer<WeatherModel>(
          builder: ( context, weather, child ) {
            if ( location.location.countryCode != null && location.location.countryCode != 'AU' ) {
              return Scaffold(
                appBar: AppBar(
                  title: Text( 'Outside Australia' ),
                ),
                drawer: buildDrawer( context, HomePage.route ),
                body: Padding(
                  padding: const EdgeInsets.symmetric( horizontal: 16.0, vertical: 12.0 ),
                  child: Text( "Thanks for trying out Tidy Weather! We're currently only available in Australia, but will be expanding to other locations soon!" ),
                ),
              );

            }

            if ( weather.today.observations.temperature.temperature == null ) {
              return Scaffold(
                appBar: AppBar(
                  title: Text( location.location.name ),
                ),
                drawer: buildDrawer( context, HomePage.route ),
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: Text( location.location.name ),
              ),
              drawer: buildDrawer( context, HomePage.route ),
              body: RefreshIndicator(
                onRefresh: LocationModel.load,
                child: ListView(
                  children: <Widget>[
                    TodayCard(),
                    WeekCard(),
                    GraphCard(),
                    TodayDetailsCard(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

