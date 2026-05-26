// Web stub — Isar doesn't support Flutter Web.
// All AirportCache methods are no-ops that return empty data.
// The real implementation in airport_code_model.dart is never
// compiled for web because airport_platform.dart conditionally
// exports this file instead.

import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart' as parse;

class AirportLite {
  final int sourceId;
  final String type;
  final String ident;
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String region;
  final String municipality;

  const AirportLite({
    required this.sourceId,
    required this.type,
    required this.ident,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.region,
    required this.municipality,
  });

  factory AirportLite.fromParse(parse.ParseObject obj) => AirportLite(
        sourceId: (obj.get<num>('sourceId') ?? 0).toInt(),
        type: (obj.get<String>('type') ?? '').trim(),
        ident: (obj.get<String>('ident') ?? '').trim(),
        name: (obj.get<String>('name') ?? '').trim(),
        latitude: 0.0,
        longitude: 0.0,
        country: (obj.get<String>('country') ?? '').trim(),
        region: (obj.get<String>('region') ?? '').trim(),
        municipality: (obj.get<String>('municipality') ?? '').trim(),
      );

  Map<String, dynamic> toJson() => {
        'sourceId': sourceId,
        'type': type,
        'ident': ident,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'country': country,
        'region': region,
        'municipality': municipality,
      };

  factory AirportLite.fromJson(Map<String, dynamic> json) => AirportLite(
        sourceId: (json['sourceId'] as num).toInt(),
        type: (json['type'] as String?)?.trim() ?? '',
        ident: (json['ident'] as String?)?.trim() ?? '',
        name: (json['name'] as String?)?.trim() ?? '',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        country: (json['country'] as String?)?.trim() ?? '',
        region: (json['region'] as String?)?.trim() ?? '',
        municipality: (json['municipality'] as String?)?.trim() ?? '',
      );

  bool matchesIdent(String qUpper) => ident.toUpperCase().contains(qUpper);

  @override
  String toString() => ident;
}

class AirportCache {
  AirportCache._();
  static final AirportCache instance = AirportCache._();

  static const List<String> kPinnedAirportIdents = [];

  Future<void> prepareCache({
    Duration minDeltaSyncInterval = const Duration(days: 30),
    int pageSize = 1000,
  }) async {
    debugPrint('[Airports] AirportCache.prepareCache: no-op on web');
  }

  Future<List<AirportLite>> searchByIdent(String query,
          {int limit = 200}) async =>
      const [];

  Future<AirportLite?> getBySourceId(int sourceId) async => null;

  Future<int> localCount() async => 0;

  Future<void> deleteLocalAirportsDb() async {}

  Future<void> ensureSeeded({int pageSize = 1000}) async {}

  Future<void> syncDeltasIfNeeded({
    Duration minInterval = const Duration(days: 30),
    int pageSize = 1000,
  }) async {}
}
