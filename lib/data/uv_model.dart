import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:preferences/preference_service.dart';
import 'package:xml2json/xml2json.dart';

class UVModel extends ChangeNotifier {
  Map _station = new Map();
  static UVModel _self;

  UVStation get data {
    UVStation _data = new UVStation();

    if ( _station.containsKey( 'index' ) ) {
      _data.index = double.parse( _station[ 'index' ] );
      _data.name = _station[ 'name' ];

      if ( _data.index < 3.0 ) {
        _data.description = 'Low';
      } else if ( _data.index < 6.0 ) {
        _data.description = 'Moderate';
      } else if ( _data.index < 8.0 ) {
        _data.description = 'High';
      } else if ( _data.index < 11.0 ) {
        _data.description = 'Very High';
      } else {
        _data.description = 'Extreme';
      }

      _data.utcDateTime = DateTime.parse( _station[ 'utcdatetime' ].replaceAll( '/', '-' ) + 'Z' );
    }

    return _data;
  }

  UVModel() {
    String uvCache = PrefService.getString( 'cached_uv_data' );
    if ( uvCache != null ) {
      _station = jsonDecode( uvCache );
    }

    _self = this;
  }

  static void load( double latitude, double longitude ) {
    _self.loadData( latitude, longitude );
  }

  void loadData( double latitude, double longitude ) async {
    final Xml2Json xmlJsonTransformer = Xml2Json();
    final locations = new Map();

    // Source: https://api.willyweather.com.au/v2/{key}/search.json?query={location}&limit=1
    locations[ 'adl' ] = [ -34.926, 138.6 ];
    locations[ 'ali' ] = [ -23.7, 133.881 ];
    locations[ 'bri' ] = [ -27.468, 153.028 ];
    locations[ 'can' ] = [ -35.282, 149.129 ];
    locations[ 'dar' ] = [ -12.461, 130.842 ];
    locations[ 'emd' ] = [ -23.527, 148.161 ];
    locations[ 'gco' ] = [ -28.005, 153.402 ];
    locations[ 'kin' ] = [ -42.977, 147.308 ];
    locations[ 'mcq' ] = [ -54.617, 158.9 ];
    locations[ 'mel' ] = [ -37.814, 144.963 ];
    locations[ 'new' ] = [ -32.924, 151.779 ];
    locations[ 'per' ] = [ -31.955, 115.859 ];
    locations[ 'syd' ] = [ -33.867, 151.207 ];
    locations[ 'tow' ] = [ -19.258, 146.818 ];

    double shortestDistance = 0;
    String closestLocation = '';

    locations.forEach( ( location, coordinates ) {
      double latDiff = latitude - coordinates[ 0 ];
      latDiff = latDiff.abs();

      double longDiff = longitude - coordinates[ 1 ];
      longDiff = longDiff.abs();

      double distance = sqrt( latDiff * latDiff + longDiff * longDiff );

      if ( closestLocation == '' || distance < shortestDistance ) {
        shortestDistance = distance;
        closestLocation = location;
      }
    } );

    final uvResponse = await http.get( 'https://uvdata.arpansa.gov.au/xml/uvvalues.xml' );

    xmlJsonTransformer.parse( utf8.decode( uvResponse.bodyBytes ) );
    final allUV = jsonDecode( xmlJsonTransformer.toParker() );

    Map closestStation = new Map();
    allUV[ 'stations' ][ 'location' ].forEach( ( location ) {
      if ( location[ 'name' ] == closestLocation ) {
        closestStation = location;
      }
    } );

    _station = closestStation;

    PrefService.setString( 'cached_uv_data', jsonEncode( _station ) );

    notifyListeners();
  }
}

class UVStation {
  double index;
  String description;
  String name;
  DateTime utcDateTime = new DateTime.fromMicrosecondsSinceEpoch( 0, isUtc: true );
}