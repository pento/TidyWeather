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
          return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text( Jiffy().format( 'EEEE do MMMM' ) ),
                ],
              ),
              Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon( MdiIcons.beakerOutline ),
                          Column(
                            children: <Widget>[
                              Text( '${ weather.today.observations.rainfall.since9AMAmount }mm' ),
                              Text( 'Since 9am' ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon( MdiIcons.water ),
                          Column(
                            children: <Widget>[
                              Text( '${ weather.today.forecast.rainfall.rangeCode }mm' ),
                              Text( '${ weather.today.forecast.rainfall.probability }% chance' ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon( MdiIcons.weatherSunny ),
                          Consumer<UVModel>(
                            builder: ( context, uv, child ) {
                              return Column(
                                children: <Widget>[
                                  Text( '${ uv.data.description } - ${ uv.data.index }' ),
                                  Text( Jiffy( uv.data.utcDateTime ).fromNow() ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon( MdiIcons.weatherSunnyAlert ),
                          Column(
                            children: <Widget>[
                              Text( '${ weather.today.forecast.uv.description } - ${ weather.today.forecast.uv.max }' ),
                              Text( Jiffy( weather.today.forecast.uv.start ).format( 'h:mm' ) + ' - ' + Jiffy( weather.today.forecast.uv.end ).format( 'h:mm' ) ),
                            ],
                          ),
                        ],
                      ),
                    ],
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
