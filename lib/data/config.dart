import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// The config loader data model.
class Config {
  static final Config _instance = Config._internal();
  static Map<String, dynamic> _config;

  /// Constructor.
  factory Config() => _instance;

  Config._internal();

  /// Loads the config values found in [configPath].
  Future<void> load(String configPath) async => rootBundle.loadStructuredData(
        configPath,
        (String jsonStr) async {
          // ignore: avoid_as
          _config = json.decode(jsonStr) as Map<String, dynamic>;
        },
      );

  /// Grab the value for a given config [key].
  String item(String key) {
    if (_config != null && _config.containsKey(key)) {
      return _config[key].toString();
    }

    return '';
  }
}
