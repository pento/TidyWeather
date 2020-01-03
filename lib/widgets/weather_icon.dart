import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

IconData weatherIcon( String iconCode ) {
  Map iconCodes = new Map();
  iconCodes[ 'chance-shower-fine' ] = MdiIcons.weatherPartlyRainy;
  iconCodes[ 'chance-thunderstorm-fine' ] = MdiIcons.weatherPartlyLightning;
  iconCodes[ 'cloudy' ] = MdiIcons.weatherCloudy;
  iconCodes[ 'dust' ] = MdiIcons.weatherHazy;
  iconCodes[ 'fine' ] = MdiIcons.weatherSunny;
  iconCodes[ 'mostly-fine' ] = MdiIcons.weatherPartlyCloudy;
  iconCodes[ 'partly-cloudy' ] = MdiIcons.weatherPartlyCloudy;
  iconCodes[ 'shower-or-two' ] = MdiIcons.weatherPartlyRainy;

  if ( iconCodes.containsKey( iconCode ) ) {
    return iconCodes[ iconCode ];
  }

  // A null icon code should be considered an intentional lookup failure.
  if ( iconCode != null ) {
    print( 'Unknown icon code: $iconCode' );
  }

  return Icons.texture;
}
