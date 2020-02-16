import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jiffy/jiffy.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

import '../data/weather_model.dart';

class RadarCard extends StatefulWidget {

  @override
  _RadarCardState createState() => _RadarCardState();

}

class _RadarCardState extends State<RadarCard> {
  Timer _timer;
  int _seconds;

  @override
  void initState() {
    super.initState();

    setState(() => _seconds = 0 );

    _timer = new Timer.periodic(
      new Duration( seconds: 1 ),
      ( Timer timer ) => setState( () => _seconds++ ),
    );

  }

  @override
  Widget build( BuildContext context ) {
    return Card(
      child: Consumer<WeatherModel>(
        builder: ( context, weather, child ) {
          if ( weather.today.radar.overlays.length == 0 ) {
            return Container();
          }

          int overlay = _seconds != null ? _seconds % weather.today.radar.overlays.length : 0;

          return Column(
              children: <Widget>[
                SizedBox(
                  height: 400,
                  child: new FlutterMap(
                    options: new MapOptions(
                      center: new LatLng( weather.today.radar.location.latitude, weather.today.radar.location.longitude ),
                      zoom: 7,
                      minZoom: 7,
                      maxZoom: 7,
                    ),
                    layers: [
                      new TileLayerOptions(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: [ 'a', 'b', 'c' ],
                      ),
                      new OverlayImageLayerOptions(
                        overlayImages: [
                          new OverlayImage(
                            bounds: new LatLngBounds(
                              new LatLng( weather.today.radar.mapMin.latitude, weather.today.radar.mapMin.longitude ),
                              new LatLng( weather.today.radar.mapMax.latitude, weather.today.radar.mapMax.longitude ),
                            ),
                            imageProvider: Image.network( weather.today.radar.overlays[ overlay ].url ).image,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  padding: EdgeInsets.all( 8 ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Text( weather.today.radar.name ),
                      ),
                      Text( Jiffy( weather.today.radar.overlays[ overlay ].dateTime ).fromNow() ),
                    ],
                  ),
                ),
              ],
          );
        },
      ),
    );
  }
}
