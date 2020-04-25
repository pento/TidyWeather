
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../cards/graph.dart';
import '../cards/radar.dart';
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
    return Selector2<LocationModel, WeatherModel, Tuple3<String, String, bool>>(
      selector: ( context, location, weather ) => Tuple3(
        location.place.countryCode,
        weather.today.locationName,
        weather.today.observations == null || weather.today.forecast == null
      ),
      builder: ( context, data, child ) {
        if ( data.item1 != null && data.item1 != 'AU' ) {
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

        if ( data.item3 ) {
          return Scaffold(
            appBar: AppBar(
              title: Text( data.item2 ),
            ),
            drawer: buildDrawer( context, HomePage.route ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text( data.item2 ),
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
                RadarCard(),
              ],
            ),
          ),
        );
      },
    );
  }
}

