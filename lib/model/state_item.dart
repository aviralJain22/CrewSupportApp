import 'package:flutter/cupertino.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Model representing one row from Back4App `state` class.
/// Matches Cloud Code return: { "name": "...", "code": "..." }
class StateItem {
  final String name;
  final String? code; // can be null for rows like "Washington DC", "Los Angeles", "Not Assigned"

  StateItem({
    required this.name,
    required this.code,
  });

  /// Create from JSON map (one element from `states` array in Cloud Function result)
  factory StateItem.fromJson(Map<String, dynamic> json) {
    return StateItem(
      name: (json['name'] ?? '') as String,
      code: json['code'] == null ? null : json['code'] as String,
    );
  }

  /// Optional: helpful for debugging
  @override
  String toString() => 'AppState(name: $name, code: $code)';
}

/// Fetch all states from Back4App via Cloud Function `getAllStates`.
///
/// Cloud function response shape:
/// {
///   "result": {
///     "success": true,
///     "count": 54,
///     "states": [ { "name": "...", "code": "..." }, ... ]
///   }
/// }
Future<List<StateItem>> fetchAllStates() async {
  final ParseCloudFunction function = ParseCloudFunction('getAllStates');

  try {
    // Execute cloud function without parameters
    final ParseResponse response = await function.execute();

    // Basic transport / server error check
    if (!response.success || response.result == null) {
      // You may want to log response.error as well
      throw Exception('getAllStates failed: ${response.error?.message ?? 'Unknown error'}');
    }

    // We expect `response.result` to be a Map:
    // { success: true, count: N, states: [ ... ] }
    final dynamic rawResult = response.result;

    if (rawResult is! Map<String, dynamic>) {
      throw Exception('Unexpected result format from getAllStates (not a Map).');
    }

    // Optional: check success flag inside result as well
    final bool innerSuccess = (rawResult['success'] ?? false) as bool;
    if (!innerSuccess) {
      throw Exception('getAllStates returned success=false from Cloud Code.');
    }

    // Extract "states" array
    final dynamic rawStates = rawResult['states'];
    if (rawStates is! List) {
      throw Exception('Unexpected result format: `states` is not a List.');
    }

    // Map each element to AppState model
    final List<StateItem> states = rawStates
        .where((element) => element != null) // safety filter
        .map<StateItem>((element) {
      // Each element should be a Map<String, dynamic>
      final Map<String, dynamic> map = Map<String, dynamic>.from(element as Map);
      return StateItem.fromJson(map);
    }).toList();

    return states;
  } catch (e) {
    // Re-throw or handle as needed in your app
    // e.g., show error dialog, fallback to empty list, etc.
    debugPrint('Error in fetchAllStates: $e');
    rethrow;
  }
}