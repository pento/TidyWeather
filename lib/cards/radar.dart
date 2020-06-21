import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jiffy/jiffy.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

import '../data/config.dart';
import '../data/weather_model.dart';

class RadarCard extends StatefulWidget {

  @override
  _RadarCardState createState() => _RadarCardState();

}

class _RadarCardState extends State<RadarCard> {
  Timer _timer;
  int _mapTicks;
  MapController _mapController;

  @override
  void initState() {
    super.initState();

    _mapController = new MapController();

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
          if ( weather.today.radar == null || weather.today.radar.overlays.length == 0 ) {
            return Container();
          }

          // Pause for a second on the last image.
          int overlay = _mapTicks != null ? _mapTicks % ( weather.today.radar.overlays.length + 1 ) : 0;
          if ( overlay >= weather.today.radar.overlays.length ) {
            overlay = weather.today.radar.overlays.length - 1;
          }

          LatLng center = new LatLng( weather.today.radar.location.latitude, weather.today.radar.location.longitude );

          return Column(
              children: <Widget>[
                SizedBox(
                  height: 400,
                  child: new FlutterMap(
                    mapController: _mapController,
                    options: new MapOptions(
                      center: center,
                      zoom: 8,
                      minZoom: 7,
                      maxZoom: 9,
                      interactive: false,
                    ),
                    layers: [
                      new TileLayerOptions(
                        urlTemplate: "https://api.mapbox.com/styles/v1/pento/ck8ljtx870q8z1iphvwes27kc/tiles/{z}/{x}/{y}?access_token={accessToken}",
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
                            imageProvider: NetworkImage( weather.today.radar.overlays[ overlay ].url ),
                            gaplessPlayback: true,
                          ),
                        ],
                      ),
                      new TileLayerOptions(
                        urlTemplate: "https://api.mapbox.com/styles/v1/pento/ck8mdbur70gb61ipjxtbqmbcp/tiles/{z}/{x}/{y}?access_token={accessToken}",
                        backgroundColor: Colors.transparent,
                        additionalOptions: {
                          'accessToken': Config.item( 'mapbox_access_token' ),
                        },
                      ),
                    ],
                  ),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  buttonPadding: EdgeInsets.all( 0 ),
                  children: <Widget>[
                    FlatButton(
                      child: Text( '50km' ),
                      color: _mapController.ready && _mapController.zoom == 9 ? Theme.of( context ).backgroundColor.withOpacity( 0.2 ) : null,
                      onPressed: () => _mapController.move( center, 9 ),
                    ),
                    FlatButton(
                      child: Text( '100km' ),
                      color: _mapController.ready && _mapController.zoom == 8 ? Theme.of( context ).backgroundColor.withOpacity( 0.2 ) : null,
                      onPressed: () => _mapController.move( center, 8 ),
                    ),
                    FlatButton(
                      child: Text( '200km' ),
                      color: _mapController.ready && _mapController.zoom == 7 ? Theme.of( context ).backgroundColor.withOpacity( 0.2 ) : null,
                      onPressed: () => _mapController.move( center, 7 ),
                    ),
                  ],
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
