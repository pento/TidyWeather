import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../data/weather_model.dart';
import '../widgets/WeatherDetailsBlock.dart';

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
          final TextStyle textStyle = Theme.of( context ).textTheme.body1;
          final TextStyle lightTextStyle = Theme.of( context ).textTheme.caption;

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
                  WeatherDetailsBlock(
                    icon: MdiIcons.beakerOutline,
                    iconColor: Colors.blue,
                    title: Text( 'Rainfall since 9am' ),
                    text: Text( '${ weather.today.observations.rainfall.since9AMAmount }mm' ),
                    subtext: Text( 'Since 9am' ),
                  ),
                  WeatherDetailsBlock(
                    icon: MdiIcons.water,
                    iconColor: Colors.blue,
                    title: Text( "Rain forecast" ),
                    text: Text( '${ weather.today.forecast.rainfall.rangeCode }mm' ),
                    subtext: Text( '${ weather.today.forecast.rainfall.probability }% chance' ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  WeatherDetailsBlock(
                    icon: MdiIcons.weatherSunny,
                    iconColor: Colors.deepPurple,
                    title: Text( 'Current UV index' ),
                    text: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            style: textStyle.copyWith( color: convertUVtoColor( weather.today.observations.uv.index ) ),
                            text: weather.today.observations.uv.description,
                          ),
                          TextSpan(
                            style: textStyle,
                            text: ' - ${ weather.today.observations.uv.index }',
                          ),
                        ],
                      ),
                    ),
                    subtext: Text( Jiffy( weather.today.observations.uv.utcDateTime ).fromNow() ),
                  ),
                  WeatherDetailsBlock(
                    icon: MdiIcons.weatherSunnyAlert,
                    iconColor: Colors.deepPurple,
                    title: Text( "Today's UV max" ),
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
                  WeatherDetailsBlock(
                    icon: MdiIcons.fan,
                    iconColor: Colors.lightGreen,
                    title: Text( 'Current wind speed' ),
                    text: Text( '${ weather.today.observations.wind.speed } km/h' ),
                    subtext: Text( weather.today.observations.wind.directionText ),
                  ),
                  WeatherDetailsBlock(
                    icon: MdiIcons.weatherWindy,
                    iconColor: Colors.lightGreen,
                    title: Text( 'Current wind gust' ),
                    text: weather.today.observations.wind.gustSpeed != null ? Text( '${ weather.today.observations.wind.gustSpeed } km/h' ) : Text( 'Unknown' ),
                    subtext: Text( 'Gust' ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  WeatherDetailsBlock(
                    icon: MdiIcons.weatherSunny,
                    iconColor: Colors.amber,
                    title: Text( 'Sunrise/sunset' ),
                    text: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            style: textStyle,
                            text: Jiffy( weather.today.forecast.sun.sunrise ).format( 'H:mm ' )
                          ),
                          TextSpan(
                            style: textStyle.copyWith( color: lightTextStyle.color ),
                            text: Jiffy( weather.today.forecast.sun.firstLight ).format( 'H:mm' )
                          )
                        ],
                      ),
                    ),
                    subtext: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                              style: textStyle,
                              text: Jiffy( weather.today.forecast.sun.sunset ).format( 'H:mm ' )
                          ),
                          TextSpan(
                              style: textStyle.copyWith( color: lightTextStyle.color ),
                              text: Jiffy( weather.today.forecast.sun.lastLight ).format( 'H:mm' )
                          )
                        ],
                      ),
                    ),
                  ),
                  WeatherDetailsBlock(
                    icon: MdiIcons.waterOutline,
                    iconColor: Colors.lightBlueAccent,
                    title: Text( 'Relative humidity' ),
                    text: Text( '${ weather.today.observations.humidity.percentage }%' ),
                    subtext: Text( 'Humidity' ),
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

Color convertUVtoColor( double uv ) {
  if ( uv <= 2 ) {
    return Colors.lightGreen;
  } else if ( uv <= 5 ) {
    return Colors.yellow.shade800;
  } else if ( uv <= 7 ) {
    return Colors.orange.shade800;
  } else if ( uv <= 10 ) {
    return Colors.red.shade800;
  }

  return Colors.deepPurple;
}
