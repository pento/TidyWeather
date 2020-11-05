
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
import '../widgets/FadingAppBarScaffold.dart';

class HomePage extends StatefulWidget {
  static const String route = '/';

  @override
  AppState createState() => AppState();
}

class AppState extends State<HomePage> {
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

  }

  @override
  Widget build( BuildContext context ) {
    return Selector2<LocationModel, WeatherModel, Tuple4<LocationPermission, String, String, WeatherDay>>(
      selector: ( context, location, weather ) => Tuple4(
        location.permissionStatus,
        location.place.countryCode,
        weather.today.locationName,
        weather.today,
      ),
      builder: ( context, data, child ) {
        // We don't yet have permission, let's request that.
        if ( data.item1 == LocationPermission.denied || data.item1 == LocationPermission.deniedForever ) {
          List<Widget> _text = [
            Text(
              'Welcome to Tidy Weather!',
              style: TextStyle( fontWeight: FontWeight.bold ),
            ),
            SizedBox( height: 24 ),
          ];
          if ( data.item1 == LocationPermission.denied ) {
            _text.add( Text( "In order to display your weather, we need permission to check your location. Allowing location access all of the time will ensure your weather is always up to date, even when the app isn't open." ) );
          } else {
            _text.add( Text( "In order to display your weather, we need permission to check your location. You'll need to allow location access in the device settings." ) );
          }
          return Scaffold(
            appBar: AppBar(
              title: Text( 'Tidy Weather' ),
            ),
            drawer: buildDrawer( context, HomePage.route ),
            body: Padding(
              padding: const EdgeInsets.symmetric( horizontal: 40.0, vertical: 12.0 ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ..._text,
                  SizedBox( height: 16 ),
                  ElevatedButton(
                    child: Text( 'Grant Location Permission' ),
                    onPressed: () async {
                      if ( data.item1 == LocationPermission.denied ) {
                        await Geolocator.requestPermission();
                        await LocationModel.load();
                      } else {
                        Geolocator.openAppSettings();
                      }
                    },
                  )
                ]
              )
            ),
          );
        }

        if ( data.item2 != null && data.item2 != 'AU' ) {
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

        if ( data.item4.observations == null || data.item4.forecast == null ) {
          return Scaffold(
            appBar: AppBar(
              title: Text( data.item3 ),
            ),
            drawer: buildDrawer( context, HomePage.route ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        ThemeData _modifiedTheme = Theme.of( context ).copyWith( appBarTheme: AppBarTheme( color: Colors.transparent ) );

        return Theme(
          data: _modifiedTheme,
          child: FadingAppBarScaffold(
            controller: _scrollController,
            title: data.item3,
            weatherCode: data.item4.forecast.weather.code,
            body: RefreshIndicator(
              onRefresh: LocationModel.load,
              child: ListView(
                padding: EdgeInsets.zero,
                controller: _scrollController,
                children: <Widget>[
                  TodayCard(),
                  WeekCard(),
                  GraphCard(),
                  TodayDetailsCard(),
                  RadarCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
