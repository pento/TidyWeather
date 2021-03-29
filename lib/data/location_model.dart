import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedantic/pedantic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationModel extends ChangeNotifier with WidgetsBindingObserver {
  bool _background;
  bool _requestingPermission = false;
  bool _disposed = false;
  Position _currentPosition;
  Placemark _place = Placemark();
  LocationPermission _permissionStatus;
  SharedPreferences _preferences;

  static LocationModel _self;

  WeatherPlace get place => WeatherPlace(_place);

  LocationPermission get permissionStatus => _permissionStatus;

  /// Constructor.
  LocationModel(
      {bool background = false,
      bool loadDataImmediately = true,
      SharedPreferences preferences}) {
    WidgetsBinding.instance.addObserver(this);

    _self = this;

    _background = background;

    _preferences = preferences;

    if (loadDataImmediately) {
      loadData();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  /// If we need to request additional permission, open the appropriate dialog.
  static Future<void> requestPermission({bool forceOpen = false}) async {
    if (_self._background) {
      // We can't open a permission dialog if we're in the background.
      return;
    }

    if (forceOpen) {
      _self._requestingPermission = true;
      unawaited(Geolocator.openAppSettings());
      return;
    }

    _self._permissionStatus = await Geolocator.checkPermission();

    switch (_self._permissionStatus) {
      case LocationPermission.always:
        // No need to do anything if we have full permissions.
        break;
      case LocationPermission.denied:
        // We could technically wait here, but it's better to just rely
        // on the AppLifecycleState updating, indicating we regained focus.
        _self._requestingPermission = true;
        unawaited(Geolocator.requestPermission());
        break;
      case LocationPermission.whileInUse:
      case LocationPermission.deniedForever:
        // We need to open the system dialog, add background check
        // for permission changing, since there's no nice way for us to wait.
        _self._requestingPermission = true;
        unawaited(Geolocator.openAppSettings());
        break;
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    // If we've just re-gained focus, check if permissions have changed.
    if (state == AppLifecycleState.resumed) {
      _self._requestingPermission = false;
      final LocationPermission newStatus = await Geolocator.checkPermission();
      if (newStatus != _permissionStatus) {
        _permissionStatus = newStatus;
        notifyListeners();
      }

      if (_permissionStatus == LocationPermission.always ||
          _permissionStatus == LocationPermission.whileInUse) {
        await loadData();
      }
    }
  }

  static Future<void> load() => Future<void>(_self.loadData);

  Future<void> loadData() async {
    if (_requestingPermission) {
      // Can't do anything if we're currently requesting permission.
      return;
    }

    _permissionStatus ??= await Geolocator.checkPermission();

    if (_permissionStatus == LocationPermission.denied) {
      await requestPermission();
      return;
    }

    // If we don't have permission, there's nothing else we can do.
    if (_permissionStatus == LocationPermission.deniedForever) {
      developer.log(
          "We don't have permission to get the location: $_permissionStatus");
      return;
    }

    List<Placemark> place;
    try {
      place = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((Position position) async {
        _currentPosition = position;
        developer.log('Location: ${position.latitude}, ${position.longitude}');
        return placemarkFromCoordinates(position.latitude, position.longitude);
      }).timeout(const Duration(seconds: 10), onTimeout: () {
        developer.log('Retrieving location timed out.');
        _currentPosition = Position(
          longitude: _preferences.getDouble('_last_place_position_longitude'),
          latitude: _preferences.getDouble('_last_place_position_latitude'),
          timestamp: DateTime.now(),
          speed: 0,
          heading: 0,
          accuracy: 0,
          altitude: 0,
          speedAccuracy: 0,
        );

        return <Placemark>[
          Placemark(
            locality: _preferences.getString('_last_place_locality'),
            postalCode: _preferences.getString('_last_place_postalCode'),
            isoCountryCode:
                _preferences.getString('_last_place_isoCountryCode'),
          ),
        ];
      });
    } on Exception catch (error) {
      developer.log('Failed to get the location: $error');
      // We possibly failed because permission was denied. Check permission
      // status again, so we can update the info message, if necessary.
      _permissionStatus = await Geolocator.checkPermission();
      notifyListeners();
      return;
    }

    if (place[0].isoCountryCode == null) {
      developer.log('No position found.', error: place[0]);
      return;
    }

    developer.log('Place:', error: place[0]);

    if (place[0].isoCountryCode != 'AU') {
      _place = place[0];
      await storePlacemark(_place, _currentPosition);
      notifyListeners();
      return;
    }

    if (_place.locality == null || place[0].locality != _place.locality) {
      _place = place[0];
      notifyListeners();
    }

    await storePlacemark(_place, _currentPosition);
  }

  String get town => _place.locality;
  String get postCode => _place.postalCode;
  String get uvStation =>
      uvLocation(_currentPosition?.latitude, _currentPosition?.longitude);

  Future<void> storePlacemark(Placemark place, Position position) async {
    await _preferences.setString('_last_place_locality', place.locality);
    await _preferences.setString('_last_place_postalCode', place.postalCode);
    await _preferences.setString(
        '_last_place_isoCountryCode', place.isoCountryCode);

    await _preferences.setDouble(
        '_last_place_position_longitude', position.longitude);
    await _preferences.setDouble(
        '_last_place_position_latitude', position.latitude);
  }

  String uvLocation(double latitude, double longitude) {
    if (latitude == null || longitude == null) {
      return '';
    }
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
