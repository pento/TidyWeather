import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../data/weather_model.dart';

class RadarCard extends StatefulWidget {

  @override
  _RadarCardState createState() => _RadarCardState();

}

class _RadarCardState extends State<RadarCard> {
  DrawableRoot _map;

  @override
  void initState() {
    super.initState();
    _loadMap();
  }

  _loadMap() async {
    String svgString = await rootBundle.loadString( 'assets/images/map-australia.svg' );
    DrawableRoot map = await svg.fromSvgString( svgString, svgString );

    setState( () => _map = map );
  }

  @override
  Widget build( BuildContext context ) {
    return Card(
      child: Consumer<WeatherModel>(
        builder: ( context, weather, child ) {
          if ( weather.today.radar.overlays.length == 0 ) {
            return Container();
          }
          return SizedBox(
            height: 400,
            child: Stack(
              fit: StackFit.passthrough,
              children: <Widget>[
                new CustomPaint(
                  painter: new RadarPainter( context, weather, _map ),
                ),
                Image.network( weather.today.radar.overlays.last.url ),
                Text( weather.today.radar.overlays.last.dateTime.toIso8601String() )
              ],
            ),
          );
        },
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final BuildContext context;
  final WeatherModel weather;
  final DrawableRoot map;


  RadarPainter( this.context, this.weather, this.map ) : super();

  void paint( Canvas canvas, Size size ) async {
    if ( map == null ) {
      return;
    }

    // Ensure nothing paints outside of the canvas.
    canvas.clipRect( Rect.fromLTWH( 0, 0, size.width, size.height ) );

    canvas.transform( Transform.scale(scale: 1.5 ).transform.storage );

    // Map is 111 to 156°E, and 2000 units wide.
    // Map is 9 to 45°S, and 1842 units tall. It uses the Mercator projection.
    double mapWidth = 2000;
    double mapHeight = 1842;

    double mapLngLeft = 112;
    double mapLngRight = 157.4;
    double mapLngDelta = mapLngRight - mapLngLeft;

    double mapLatBottom = -45.5;
    double mapLatBottomDegree = mapLatBottom * pi / 180;

    double translateX = -1 * ( weather.today.radar.mapMin.longitude - mapLngLeft ) * ( mapWidth / mapLngDelta );

    double lat = weather.today.radar.mapMax.latitude * pi / 180;
    double worldMapWidth = ( ( mapWidth / mapLngDelta ) * 360 ) / ( 2 * pi );
    double mapOffsetY = ( worldMapWidth / 2 * log( ( 1 + sin( mapLatBottomDegree ) ) / ( 1 - sin( mapLatBottomDegree ) ) ) );
    double translateY = -1 * ( mapHeight - ( ( worldMapWidth / 2 * log( ( 1 + sin( lat ) ) / ( 1 - sin( lat ) ) ) ) - mapOffsetY ) );

    canvas.translate( translateX, translateY );

    map.draw( canvas, Rect.fromLTWH( 0, 0, size.width, size.height ) );
  }

  @override
  bool shouldRepaint( RadarPainter old ) => true;
}
