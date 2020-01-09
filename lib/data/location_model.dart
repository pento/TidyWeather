import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:preferences/preference_service.dart';

import './uv_model.dart';
import './weather_model.dart';

class LocationModel extends ChangeNotifier {
  Map _location = new Map();
  static LocationModel _self;

  WeatherLocation get location {
    WeatherLocation _currentLocation = new WeatherLocation();

    if ( _location.containsKey( 'location' ) ) {
      _currentLocation.id = _location[ 'location' ][ 'id' ];
      _currentLocation.name = _location[ 'location' ][ 'name' ];
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

    final weatherLocationResponse = await http.get( '$apiRoot/search.json?lat=${ position.latitude }&lng=${ position.longitude }&units=distance:km' );
    _location = jsonDecode( weatherLocationResponse.body );

    PrefService.setString( 'cached_location_data', weatherLocationResponse.body );

    WeatherModel.load( _location[ 'location' ][ 'id' ] );
    UVModel.load( _location[ 'location' ][ 'lat' ], _location[ 'location' ][ 'lng' ] );

    notifyListeners();
  }
}

class WeatherLocation {
  int id;
  String name = 'Searching...';
}