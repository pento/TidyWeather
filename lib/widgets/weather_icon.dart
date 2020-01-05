import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

IconData weatherIcon( String iconCode ) {
  Map iconCodes = new Map();

  iconCodes[ 'chance-shower-cloud' ] = MdiIcons.weatherRainy;
  iconCodes[ 'chance-shower-fine' ] = MdiIcons.weatherPartlyRainy;
  iconCodes[ 'chance-snow-cloud' ] = MdiIcons.weatherSnowy;
  iconCodes[ 'chance-snow-fine' ] = MdiIcons.weatherPartlySnowy;
  iconCodes[ 'chance-thunderstorm-cloud' ] = MdiIcons.weatherLightning;
  iconCodes[ 'chance-thunderstorm-fine' ] = MdiIcons.weatherPartlyLightning;
  iconCodes[ 'chance-thunderstorm-showers' ] = MdiIcons.weatherLightningRainy;
  iconCodes[ 'cloudy' ] = MdiIcons.weatherCloudy;
  iconCodes[ 'drizzle' ] = MdiIcons.weatherRainy;
  iconCodes[ 'dust' ] = MdiIcons.weatherHazy;
  iconCodes[ 'few-showers' ] = MdiIcons.weatherRainy;
  iconCodes[ 'fine' ] = MdiIcons.weatherSunny;
  iconCodes[ 'fog' ] = MdiIcons.weatherFog;
  iconCodes[ 'frost' ] = MdiIcons.snowflakeVariant;
  iconCodes[ 'hail' ] = MdiIcons.weatherHail;
  iconCodes[ 'heavy-showers-rain' ] = MdiIcons.weatherPouring;
  iconCodes[ 'heavt-snow' ] = MdiIcons.weatherSnowyHeavy;
  iconCodes[ 'high-cloud' ] = MdiIcons.weatherPartlyCloudy;
  iconCodes[ 'light-snow' ] = MdiIcons.weatherSnowy;
  iconCodes[ 'mostly-cloudy' ] = MdiIcons.weatherCloudy;
  iconCodes[ 'mostly-fine' ] = MdiIcons.weatherPartlyCloudy;
  iconCodes[ 'overcast' ] = MdiIcons.weatherCloudy;
  iconCodes[ 'partly-cloudy' ] = MdiIcons.weatherPartlyCloudy;
  iconCodes[ 'shower-or-two' ] = MdiIcons.weatherPartlyRainy;
  iconCodes[ 'showers-rain' ] = MdiIcons.weatherRainy;
  iconCodes[ 'snow' ] = MdiIcons.weatherSnowy;
  iconCodes[ 'snow-and-rain' ] = MdiIcons.weatherSnowyRainy;
  iconCodes[ 'thunderstorm' ] = MdiIcons.weatherLightning;
  iconCodes[ 'wind' ] = MdiIcons.weatherWindy;

  if ( iconCodes.containsKey( iconCode ) ) {
    return iconCodes[ iconCode ];
  }

  // A null icon code should be considered an intentional lookup failure.
  if ( iconCode != null ) {
    print( 'Unknown icon code: $iconCode' );
  }

  return Icons.texture;
}
