import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:preferences/preference_service.dart';

import './uv_model.dart';
import './weather_model.dart';

class LocationModel extends ChangeNotifier {
  Map _location = new Map();
  Placemark _place = new Placemark();

  static LocationModel _self;

  WeatherLocation get location {
    WeatherLocation _currentLocation = new WeatherLocation();

    if ( _location.containsKey( 'id' ) ) {
      _currentLocation.id = _location[ 'id' ];
      _currentLocation.name = _location[ 'name' ];
      _currentLocation.countryCode = _place.isoCountryCode;
    }

    return _currentLocation;
  }

  LocationModel() {
    String locationCache = PrefService.getString( 'cached_location_data' );
    if ( locationCache != null ) {
      _location = jsonDecode( locationCache );
    }

    _self = this;

    String apiKey = PrefService.getString( 'api_key' );
    if ( apiKey != null || apiKey.isNotEmpty ) {
      loadData();
    }
  }

  static Future<void> load() {
    return new Future( _self.loadData );
  }

  void loadData() async {
    String apiKey = PrefService.getString( 'api_key' );
    if ( apiKey == null || apiKey == '' ) {
      return;
    }

    String apiRoot = 'https://api.willyweather.com.au/v2/$apiKey';

    Position position = await Geolocator().getCurrentPosition( desiredAccuracy: LocationAccuracy.high );

    List<Placemark> place = await Geolocator().placemarkFromPosition( position );

    if ( place[ 0 ].isoCountryCode != 'AU' ) {
      _place = place[ 0 ];
      notifyListeners();
      return;
    }

    if ( ! _location.containsKey( 'id' ) || _place.locality == null || place[ 0 ].locality != _place.locality ) {
      _place = place[ 0 ];

      final weatherLocationResponse = await http.get( '$apiRoot/search.json?query=${ _place.locality }+${ _place.postalCode }' );
      List locationData = jsonDecode( weatherLocationResponse.body );
      _location = locationData[ 0 ];

      PrefService.setString( 'cached_location_data', jsonEncode( _location ) );

      notifyListeners();
    }

    WeatherModel.load( _location[ 'id' ] );
    UVModel.load( _location[ 'lat' ], _location[ 'lng' ] );
  }
}

class WeatherLocation {
  int id;
  String name = 'Searching...';
  String countryCode;
}
