import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:preferences/preference_service.dart';

import './weather_model.dart';

class LocationModel extends ChangeNotifier {
  bool _background;
  Placemark _place = Placemark();
  LocationPermission _permissionStatus;

  static LocationModel _self;

  WeatherPlace get place => WeatherPlace(_place);

  LocationPermission get permissionStatus => _permissionStatus;

  /// Constructor.
  LocationModel({bool background = false}) {
    _self = this;

    _background = background;

    loadData();
  }

  static Future<void> load() => Future<void>(_self.loadData);

  Future<void> loadData() async {
    _permissionStatus = await Geolocator.checkPermission();

    // If we don't have permission, there's nothing else we can do.
    if (_permissionStatus == LocationPermission.deniedForever ||
        _permissionStatus == LocationPermission.denied) {
      developer.log(
          "We don't have permission to get the location: $_permissionStatus");
      notifyListeners();
      return;
    }

    // We can't get the location if we only have foreground permission.
    if (_background && _permissionStatus != LocationPermission.always) {
      developer.log(
          "We don't have permission to get the location in the background.");
      notifyListeners();
      return;
    }

    Position currentPosition;

    final List<Placemark> place = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      currentPosition = position;
      developer.log('Location: ${position.latitude}, ${position.longitude}');
      return placemarkFromCoordinates(position.latitude, position.longitude);
    }).timeout(const Duration(seconds: 10), onTimeout: () {
      developer.log('Retrieving location timed out.');
      currentPosition = Position(
        longitude: PrefService.getDouble('_last_place_position_longitude'),
        latitude: PrefService.getDouble('_last_place_position_latitude'),
      );

      return <Placemark>[
        Placemark(
          locality: PrefService.getString('_last_place_locality'),
          postalCode: PrefService.getString('_last_place_postalCode'),
          isoCountryCode: PrefService.getString('_last_place_isoCountryCode'),
        ),
      ];
    });

    if (place[0].isoCountryCode == null) {
      developer.log('No position found.', error: place[0]);
      notifyListeners();
      return;
    }

    developer.log('Place:', error: place[0]);

    if (place[0].isoCountryCode != 'AU') {
      _place = place[0];
      storePlacemark(_place, currentPosition);
      notifyListeners();
      return;
    }

    if (_place.locality == null || place[0].locality != _place.locality) {
      _place = place[0];
      notifyListeners();
    }

    storePlacemark(_place, currentPosition);

    WeatherModel.load(_place.locality, _place.postalCode,
        uvLocation(currentPosition.latitude, currentPosition.longitude));
  }

  void storePlacemark(Placemark place, Position position) {
    PrefService.setString('_last_place_locality', place.locality);
    PrefService.setString('_last_place_postalCode', place.postalCode);
    PrefService.setString('_last_place_isoCountryCode', place.isoCountryCode);

    PrefService.setDouble('_last_place_position_longitude', position.longitude);
    PrefService.setDouble('_last_place_position_latitude', position.latitude);
  }

  String uvLocation(double latitude, double longitude) {
    // Source: https://api.willyweather.com.au/v2/{key}/search.json?query={location}&limit=1
    final Map<String, List<double>> locations = <String, List<double>>{
      'adl': <double>[-34.926, 138.6],
      'ali': <double>[-23.7, 133.881],
      'bri': <double>[-27.468, 153.028],
      'can': <double>[-35.282, 149.129],
      'dar': <double>[-12.461, 130.842],
      'emd': <double>[-23.527, 148.161],
      'gco': <double>[-28.005, 153.402],
      'kin': <double>[-42.977, 147.308],
      'mcq': <double>[-54.617, 158.9],
      'mel': <double>[-37.814, 144.963],
      'new': <double>[-32.924, 151.779],
      'per': <double>[-31.955, 115.859],
      'syd': <double>[-33.867, 151.207],
      'tow': <double>[-19.258, 146.818],
    };

    double shortestDistance = 0;
    String closestLocation = '';

    locations.forEach((String location, List<double> coordinates) {
      double latDiff = latitude - coordinates[0];
      latDiff = latDiff.abs();

      double longDiff = longitude - coordinates[1];
      longDiff = longDiff.abs();

      final double distance = sqrt(latDiff * latDiff + longDiff * longDiff);

      if (closestLocation == '' || distance < shortestDistance) {
        shortestDistance = distance;
        closestLocation = location;
      }
    });

    return closestLocation;
  }
}

class WeatherPlace {
  String countryCode;

  WeatherPlace(Placemark _place) {
    countryCode = _place.isoCountryCode;
  }
}
