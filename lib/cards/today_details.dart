import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../data/weather_model.dart';
import '../data/uv_model.dart';

class TodayDetailsCard extends StatefulWidget {

  @override
  _TodayDetailsCardState createState() => _TodayDetailsCardState();

}

class _TodayDetailsCardState extends State<TodayDetailsCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Consumer<WeatherModel>(
        builder: ( context, weather, child ) {
          final TextStyle textStyle = Theme.of( context ).textTheme.body2;

          return Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all( 12 ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide( color: Color.fromARGB( 0xFF, 0xCC, 0xCC, 0xCC )),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Text( Jiffy().format( 'EEEE do MMMM' ) ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  buildDetails(
                    icon: MdiIcons.beakerOutline,
                    iconColor: Colors.blue,
                    text: Text( '${ weather.today.observations.rainfall.since9AMAmount }mm' ),
                    subtext: Text( 'Since 9am' ),
                  ),
                  buildDetails(
                    icon: MdiIcons.water,
                    iconColor: Colors.blue,
                    text: Text( '${ weather.today.forecast.rainfall.rangeCode }mm' ),
                    subtext: Text( '${ weather.today.forecast.rainfall.probability }% chance' ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Consumer<UVModel>(
                    builder: ( context, uv, child ) {
                      return buildDetails(
                        icon: MdiIcons.weatherSunny,
                        iconColor: Colors.deepPurple,
                        text: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                style: textStyle.copyWith( color: convertUVtoColor( uv.data.index ) ),
                                text: uv.data.description,
                              ),
                              TextSpan(
                                style: textStyle,
                                text: ' - ${ uv.data.index }',
                              ),
                            ],
                          ),
                        ),
                        subtext: Text( Jiffy( uv.data.utcDateTime ).fromNow() ),
                      );
                    }
                  ),
                  buildDetails(
                    icon: MdiIcons.weatherSunnyAlert,
                    iconColor: Colors.deepPurple,
                    text: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            style: textStyle.copyWith( color: convertUVtoColor( weather.today.forecast.uv.max ) ),
                            text: weather.today.forecast.uv.description,
                          ),
                          TextSpan(
                            style: textStyle,
                            text: ' - ${ weather.today.forecast.uv.max }',
                          ),
                        ],
                      ),
                    ),
                    subtext: Text( Jiffy( weather.today.forecast.uv.start ).format( 'h:mm' ) + ' - ' + Jiffy( weather.today.forecast.uv.end ).format( 'h:mm' ) ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  buildDetails(
                    icon: MdiIcons.fan,
                    iconColor: Colors.lightGreen,
                    text: Text( '${ weather.today.observations.wind.speed } km/h' ),
                    subtext: Text( weather.today.observations.wind.directionText ),
                  ),
                  buildDetails(
                    icon: MdiIcons.weatherWindy,
                    iconColor: Colors.lightGreen,
                    text: Text( '${ weather.today.observations.wind.gustSpeed } km/h' ),
                    subtext: Text( 'Gust' ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

Expanded buildDetails( { icon, iconColor, text, subtext } ) {
  return Expanded(
    child: Container(
      padding: EdgeInsets.symmetric( vertical: 5, horizontal: 12 ),
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all( 6 ),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular( 20 ),
                ),

                child: Icon(
                  icon,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only( left: 10 ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                text,
                subtext,
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Color convertUVtoColor( double uv ) {
  if ( uv <= 2 ) {
    return Colors.lightGreen;
  } else if ( uv <= 5 ) {
    return Colors.yellow;
  } else if ( uv <= 7 ) {
    return Colors.orange;
  } else if ( uv <= 10 ) {
    return Colors.red;
  }

  return Colors.deepPurple;
}
