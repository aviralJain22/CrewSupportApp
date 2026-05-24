import 'dart:developer';

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Simple data model representing one row from the `city` class in Back4App.
/// Matches columns:
///   - name      (CityName)
///   - stateName (StateName)
class CityItem {
  final String name;
  final String stateName;
  final String? objectId; // optional, may be useful later

  CityItem({
    required this.name,
    required this.stateName,
    this.objectId,
  });

  /// Build a City from a JSON map returned by the Cloud Function.
  /// Expected keys: { "name": "...", "stateName": "...", "objectId": "..." }
  factory CityItem.fromJson(Map<String, dynamic> json) {
    return CityItem(
      name: (json['name'] ?? '') as String,
      stateName: (json['stateName'] ?? '') as String,
      objectId: json['objectId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'stateName': stateName,
      if (objectId != null) 'objectId': objectId,
    };
  }

  @override
  String toString() => 'City(name: $name, stateName: $stateName)';
}

class CityService {
  CityService._(); // private ctor – use static methods

  /// Calls the `getCitiesByState` Cloud Function on Back4App.
  ///
  /// Cloud Function (JS) returns a payload like:
  /// {
  ///   "stateName": "Alabama",
  ///   "count": 123,
  ///   "results": [ { "objectId": "...", "name": "...", "stateName": "..." }, ... ]
  /// }
  ///
  /// This method converts `results` into a `List<City>`.
  static Future<List<CityItem>> getCitiesByState(String stateName) async {
    // Basic guard: don't make a useless network call
    if (stateName.trim().isEmpty) {
      return [];
    }

    try {
      final function = ParseCloudFunction('getCitiesByState');

      final response = await function.execute(
        parameters: <String, dynamic>{
          'stateName': stateName,
        },
      );

      if (!response.success) {
        // Log the error for debug purposes
        log(
          'getCitiesByState failed: ${response.error?.code} '
          '- ${response.error?.message}',
          name: 'CityService',
        );
        throw Exception(
          'Failed to load cities for $stateName: '
          '${response.error?.message ?? 'Unknown error'}',
        );
      }

      // Parse the raw result
      final data = response.result;
      if (data == null || data is! Map) {
        // Unexpected shape – defensive fallback
        log(
          'getCitiesByState returned unexpected data: $data',
          name: 'CityService',
        );
        return [];
      }

      final results = data['results'];
      if (results == null || results is! List) {
        return [];
      }

      // Map each map to a City instance
      final List<CityItem> cities = results
          .whereType<Map>() // only keep Map entries
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .map<CityItem>((json) => CityItem.fromJson(json))
          .toList();

      return cities;
    } catch (e, stack) {
      // You can replace `log` with your logger or GetX logger
      log(
        'Exception in getCitiesByState($stateName): $e',
        name: 'CityService',
        stackTrace: stack,
      );
      rethrow; // Let caller decide how to show error
    }
  }
}