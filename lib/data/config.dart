import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class Config {
  static Map<String, dynamic> config;

  static load( configPath ) async {
    rootBundle.loadStructuredData(
      configPath,
      ( jsonStr ) async {
        config = jsonDecode( jsonStr );
      },
    );
  }

  static item( String key ) {
    if ( config.containsKey( key ) ) {
      return config[ key ];
    }

    return false;
  }
}
