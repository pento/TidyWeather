import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';

import '../data/weather_model.dart';
import '../pages/week.dart';
import '../widgets/weather_icon.dart';

class WeekCard extends StatefulWidget {

  @override
  _WeekCardState createState() => _WeekCardState();

}

class _WeekCardState extends State<WeekCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed( context, WeekPage.route );
      },

      child: Card(
        child: Consumer<WeatherModel>(
          builder: ( context, weather, child ) {
            if ( weather.week.days.length < 2 ) {
              return Container();
            }

            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              itemCount: weather.week.days.length,
              itemBuilder: ( BuildContext context, int index ) {
                if ( weather.week.days[ index ].dateTime.day == DateTime.now().day ) {
                  return Container();
                }

                String dayName;
                if ( weather.week.days[ index ].dateTime.day == DateTime.now().add( new Duration( days: 1 ) ).day ) {
                  dayName = 'Tomorrow';
                }
                else {
                  dayName = Jiffy( weather.week.days[ index ].dateTime ).format( 'EEEE' );
                }

                WeatherForecastWeather day = weather.week.days[ index ].forecast.weather;
                return Container(
                  margin: EdgeInsets.symmetric( vertical: 0, horizontal: 12 ),
                  padding: EdgeInsets.symmetric( vertical: 6, horizontal: 0 ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: index == weather.week.days.length - 1 ? BorderSide( width: 0 ) : BorderSide( color: Color.fromARGB( 0xFF, 0xCC, 0xCC, 0xCC )),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Text( dayName )
                      ),
                      SvgPicture.asset(
                        weatherIcon( day.code ),
                      ),
                      SizedBox(
                        width: 30,
                        child: Text(
                          day.min.toString(),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        child: Text(
                          day.max.toString(),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
