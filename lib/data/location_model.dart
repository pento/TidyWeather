import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import './weather_model.dart';

class LocationModel extends ChangeNotifier {
  Placemark _place = new Placemark();

  static LocationModel _self;

  WeatherPlace get place  => new WeatherPlace( _place );

  LocationModel( { background: false } ) {
    _self = this;

    if ( ! background ) {
      this.loadData();
    }
  }

  static Future<void> load() {
    return new Future( _self.loadData );
  }

  void loadData() async {
    List<Placemark> place = await Geolocator()
      .getCurrentPosition( desiredAccuracy: LocationAccuracy.high )
      .then( ( Position position ) async {
        print( 'Location: ${position.latitude}, ${position.longitude}' );
        return await Geolocator().placemarkFromPosition( position );
      } )
      .timeout( new Duration( seconds: 10 ), onTimeout: () {
        print( 'Retrieving location timed out.' );
        return [ _place ];
      } );

    print( 'Place: ${place[ 0 ].locality} ${place[ 0 ].postalCode} ${place[ 0 ].isoCountryCode}' );

    if ( place[ 0 ].isoCountryCode != 'AU' ) {
      _place = place[ 0 ];
      notifyListeners();
      return;
    }

    if ( _place.locality == null || place[ 0 ].locality != _place.locality ) {
      _place = place[ 0 ];
      notifyListeners();
    }

    WeatherModel.load( _place.locality, _place.postalCode, uvLocation( _place.position.latitude, _place.position.longitude ) );
  }

  String uvLocation( double latitude, double longitude ) {
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

    return closestLocation;
  }
}

class WeatherPlace {
  String countryCode;

  WeatherPlace( Placemark _place ) {
    countryCode = _place.isoCountryCode;
  }
}
