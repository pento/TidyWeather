import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jiffy/jiffy.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'package:tidyweather/data/config.dart';

import '../data/weather_model.dart';

class RadarCard extends StatefulWidget {

  @override
  _RadarCardState createState() => _RadarCardState();

}

class _RadarCardState extends State<RadarCard> {
  Timer _timer;
  int _mapTicks;

  @override
  void initState() {
    super.initState();

    setState(() => _mapTicks = 0 );

    _timer = new Timer.periodic(
      new Duration( milliseconds: 500 ),
      ( Timer timer ) => setState( () => _mapTicks++ ),
    );

  }

  @override
  void dispose() {
    super.dispose();

    _timer.cancel();
  }

  @override
  Widget build( BuildContext context ) {
    return Card(
      child: Consumer<WeatherModel>(
        builder: ( context, weather, child ) {
          if ( weather.today.radar.overlays.length == 0 ) {
            return Container();
          }

          // Pause for a second on the last image.
          int overlay = _mapTicks != null ? _mapTicks % ( weather.today.radar.overlays.length + 1 ) : 0;
          if ( overlay >= weather.today.radar.overlays.length ) {
            overlay = weather.today.radar.overlays.length - 1;
          }

          return Column(
              children: <Widget>[
                SizedBox(
                  height: 400,
                  child: new FlutterMap(
                    options: new MapOptions(
                      center: new LatLng( weather.today.radar.location.latitude, weather.today.radar.location.longitude ),
                      zoom: 8,
                      minZoom: 6,
                      maxZoom: 9,
                      interactive: false,
                    ),
                    layers: [
                      new TileLayerOptions(
                        urlTemplate: "https://api.mapbox.com/styles/v1/pento/ck6vbdjle0eai1isbmqf406r4/tiles/{z}/{x}/{y}?access_token={accessToken}",
                        additionalOptions: {
                          'accessToken': Config.item( 'mapbox_access_token' ),
                        },
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
