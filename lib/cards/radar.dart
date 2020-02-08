import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/weather_model.dart';

class RadarCard extends StatefulWidget {

  @override
  _RadarCardState createState() => _RadarCardState();

}

class _RadarCardState extends State<RadarCard> {

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Consumer<WeatherModel>(
        builder: ( context, weather, child ) {
          return SizedBox(
            height: 250,
            child: Text( 'lol' ),
          );
        },
      ),
    );
  }
}
