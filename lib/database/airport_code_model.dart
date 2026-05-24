import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart'
    as parse;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'airport_code_model.g.dart';

/// Lightweight model for airport pickers/search.
/// Source: OurAirports airports.csv (id, type, ident, name, lat, lon, iso_country, iso_region, municipality)
class AirportLite {
  final int sourceId; // airports.csv: id
  final String type; // airports.csv: type
  final String ident; // airports.csv: ident (what user selects)
  final String name;
  final double latitude;
  final double longitude;
  final String country; // iso_country
  final String region; // iso_region
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

  /// Parse class: airports
  factory AirportLite.fromParse(parse.ParseObject obj) {
    final geo = obj.get<parse.ParseGeoPoint>('location');

    double lat = 0.0;
    double lon = 0.0;

    if (geo != null) {
      final double gLat = geo.latitude;
      final double gLon = geo.longitude;

      // Defensive validation: ParseGeoPoint asserts on invalid ranges
      if (gLat > -90.0 && gLat < 90.0 && gLon > -180.0 && gLon < 180.0) {
        lat = gLat;
        lon = gLon;
      } else {
        // Invalid geopoint on server — log & fallback
        // (We still keep the airport, just without usable coords)
        debugPrint('[Airports] Invalid GeoPoint for sourceId=${obj.get('sourceId')} lat=$gLat lon=$gLon');
      }
    }

    return AirportLite(
      sourceId: (obj.get<num>('sourceId') ?? 0).toInt(),
      type: (obj.get<String>('type') ?? '').trim(),
      ident: (obj.get<String>('ident') ?? '').trim(),
      name: (obj.get<String>('name') ?? '').trim(),
      latitude: lat,
      longitude: lon,
      country: (obj.get<String>('country') ?? '').trim(),
      region: (obj.get<String>('region') ?? '').trim(),
      municipality: (obj.get<String>('municipality') ?? '').trim(),
    );
  }

  /// Handy for local caching (Hive/Isar/SQLite/etc.)
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

/// Isar collection for offline airports.
/// Primary key = sourceId from airports.csv
@collection
class AirportLocal {
  Id sourceId;

  /// OurAirports airport type (for example: large_airport, medium_airport,
  /// small_airport, heliport). Used for result priority, not direct search.
  @Index(type: IndexType.hash)
  late String type;

  /// ident (code)
  @Index(type: IndexType.hash)
  late String ident;

  /// for case-insensitive search
  @Index()
  late String identUpper;

  /// Uppercased airport name for case-insensitive contains search.
  @Index()
  late String nameUpper;

  /// Uppercased municipality for case-insensitive contains search.
  @Index()
  late String municipalityUpper;

  /// Uppercased region for case-insensitive contains search.
  @Index()
  late String regionUpper;

  late String name;
  late double latitude;
  late double longitude;
  late String country;
  late String region;
  late String municipality;

  /// Same rowHash you store in Parse (from your import job)
  @Index(type: IndexType.hash)
  late String rowHash;

  @Index()
  late bool isActive;

  /// Parse updatedAt (UTC) in milliseconds since epoch
  @Index()
  late int updatedAtMs;

  AirportLocal({
    required this.sourceId,
    required this.type,
    required this.ident,
    required this.identUpper,
    required this.nameUpper,
    required this.municipalityUpper,
    required this.regionUpper,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.region,
    required this.municipality,
    required this.rowHash,
    required this.isActive,
    required this.updatedAtMs,
  });

  AirportLite toLite() => AirportLite(
        sourceId: sourceId,
        type: type,
        ident: ident,
        name: name,
        latitude: latitude,
        longitude: longitude,
        country: country,
        region: region,
        municipality: municipality,
      );
}

/// Single-row meta collection for sync state (id=0)
@collection
class AirportSyncMeta {
  Id id = 0;
  int lastSyncAtMs; // UTC ms

  AirportSyncMeta({this.lastSyncAtMs = 0});
}

/// Airport cache service:
/// - seed once from Parse if local is empty
/// - search locally for picker
/// - occasional delta sync using Parse updatedAt
class AirportCache {
  AirportCache._();
  static final AirportCache instance = AirportCache._();

  /// --------------------------
  /// Pinned airports configuration
  /// --------------------------
  /// These airports will appear at the top of the list when search query is empty.
  /// Maintain order here to control display priority.
  static const List<String> kPinnedAirportIdents = [
    // Add preferred airport idents here in desired order
    'KMIA', // Miami Intl
    'KLAS', // Las Vegas McCarran
    'KLAX', // Los Angeles Intl
    'KBOS', // Boston Logan
    'KHOU', // Houston George Bush
    'KIAD', // Washington Dulles
    'KTEB', // Teterboro
    'KSEA', // Seattle Tacoma
    'KDAL', // Dallas/Fort Worth Intl
    'KORD', // Chicago O'Hare Intl
    'KSDL', // Sand Diego Intl
    'KPHX', // Phoenix Sky Harbor
    'KBZN', // Bozeman Yellowstone Intl
    'KHPN', // Westchester County
    'KASE', // Aspen Pitkin County
    'KDEN', // Denver Intl
    'KFLL', // Fort Lauderdale
    'KBNA', // Nashville Intl
    'KSAN', // San Diego Intl
    'KSFO', // San Francisco Intl
  ];

  /// Cached uppercase set for fast lookup
  static final Set<String> _pinnedIdentSet =
      kPinnedAirportIdents.map((e) => e.toUpperCase()).toSet();

  /// Map to preserve ordering of pinned airports
  static final Map<String, int> _pinnedOrder = {
    for (int i = 0; i < kPinnedAirportIdents.length; i++)
      kPinnedAirportIdents[i].toUpperCase(): i,
  };

  /// Higher-priority airport types should appear earlier within each result
  /// bucket. Unknown types fall back to the lowest priority.
  static const Map<String, int> _airportTypePriority = {
    'large_airport': 0,
    'medium_airport': 1,
    'small_airport': 2,
    'seaplane_base': 3,
    'heliport': 4,
    'balloonport': 5,
    'closed': 6,
  };

  static int _typePriority(String type) {
    return _airportTypePriority[type.trim().toLowerCase()] ?? 999;
  }

  static int _compareAirportPriority(AirportLocal a, AirportLocal b) {
    final typeCompare = _typePriority(a.type).compareTo(_typePriority(b.type));
    if (typeCompare != 0) return typeCompare;

    final identCompare = a.identUpper.compareTo(b.identUpper);
    if (identCompare != 0) return identCompare;

    return a.sourceId.compareTo(b.sourceId);
  }

  /// Bump this whenever the local airport cache schema/derived search fields
  /// change in a way that makes previously cached rows incompatible.
  static const int kCacheSchemaVersion = 3;

  /// SharedPreferences key used to remember which airport cache schema
  /// version has already been prepared on this device.
  static const String kCacheSchemaVersionPrefKey = 'airport_cache_schema_version';
  /// Prepares the local airport cache for use in production.
  ///
  /// If the stored cache schema version is older than the current version,
  /// we wipe the local airport DB once so stale rows do not break newer search
  /// logic that depends on newly added derived fields such as uppercase search
  /// columns.
  ///
  /// After the optional wipe, we seed when empty and then run the usual delta
  /// sync. We only persist the new schema version after this preparation has
  /// completed successfully.
  Future<void> prepareCache({
    Duration minDeltaSyncInterval = const Duration(days: 30),
    int pageSize = 1000,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int storedVersion = prefs.getInt(kCacheSchemaVersionPrefKey) ?? 0;

      debugPrint(
        '[Airports] prepareCache START storedVersion=$storedVersion currentVersion=$kCacheSchemaVersion',
      );

      if (storedVersion < kCacheSchemaVersion) {
        debugPrint(
          '[Airports] cache schema changed; wiping local airport DB '
          '(stored=$storedVersion current=$kCacheSchemaVersion)',
        );
        await deleteLocalAirportsDb();
      }

      final int beforeCount = await localCount();
      debugPrint('[Airports] prepareCache localCount(before)=$beforeCount');

      if (beforeCount == 0) {
        final t0 = DateTime.now();
        debugPrint('[Airports] prepareCache seeding from Parse...');
        await ensureSeeded(pageSize: pageSize);
        final afterSeed = await localCount();
        debugPrint(
          '[Airports] prepareCache seeding DONE in '
          '${DateTime.now().difference(t0).inSeconds}s, localCount(afterSeed)=$afterSeed',
        );
      } else {
        debugPrint('[Airports] prepareCache seed skipped (already have local data)');
      }

      final t1 = DateTime.now();
      debugPrint('[Airports] prepareCache delta sync check...');
      await syncDeltasIfNeeded(
        minInterval: minDeltaSyncInterval,
        pageSize: pageSize,
      );
      debugPrint(
        '[Airports] prepareCache delta sync DONE in '
        '${DateTime.now().difference(t1).inMilliseconds}ms',
      );

      await prefs.setInt(kCacheSchemaVersionPrefKey, kCacheSchemaVersion);

      final sample = await searchByIdent('', limit: 5);
      final finalCount = await localCount();
      debugPrint('[Airports] prepareCache sample=${sample.map((e) => e.ident).toList()}');
      debugPrint('[Airports] prepareCache END localCount(final)=$finalCount');
    } catch (e) {
      debugPrint('[Airports] prepareCache ERROR: $e');

      if (!_isRecoverableOpenError(e)) {
        rethrow;
      }

      await _resetCorruptDbAndPrefs(e);
      _isar = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(kCacheSchemaVersionPrefKey, 0);

      debugPrint('[Airports] prepareCache RETRY after DB reset');

      final int beforeCount = await localCount();
      debugPrint('[Airports] prepareCache retry localCount(before)=$beforeCount');

      if (beforeCount == 0) {
        await ensureSeeded(pageSize: pageSize);
      }

      await syncDeltasIfNeeded(
        minInterval: minDeltaSyncInterval,
        pageSize: pageSize,
      );

      await prefs.setInt(kCacheSchemaVersionPrefKey, kCacheSchemaVersion);

      final sample = await searchByIdent('', limit: 5);
      final finalCount = await localCount();
      debugPrint('[Airports] prepareCache RETRY END sample=${sample.map((e) => e.ident).toList()} localCount=$finalCount');
    }
  }

  Isar? _isar;

  Future<void> _resetCorruptDbAndPrefs(Object error) async {
    debugPrint('[Airports] Resetting local airport DB after open failure: $error');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(kCacheSchemaVersionPrefKey);
    } catch (prefsError) {
      debugPrint('[Airports] Failed to clear cache schema version pref: $prefsError');
    }

    try {
      await deleteLocalAirportsDb();
    } catch (deleteError) {
      debugPrint('[Airports] Failed to delete local airport DB during recovery: $deleteError');
    }
  }

  bool _isRecoverableOpenError(Object error) {
    final String message = error.toString().toLowerCase();
    return message.contains('schema') ||
        message.contains('collection') ||
        message.contains('database') ||
        message.contains('invalid') ||
        message.contains('corrupt');
  }

  Future<Isar> _open() async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationDocumentsDirectory();

    Future<Isar> openFresh() {
      return Isar.open(
        [AirportLocalSchema, AirportSyncMetaSchema],
        directory: dir.path,
        name: 'airports_db',
      );
    }

    try {
      _isar = await openFresh();
      return _isar!;
    } catch (e) {
      final bool isRecoverable = _isRecoverableOpenError(e);

      debugPrint('[Airports] Initial Isar open failed: $e');

      if (!isRecoverable) rethrow;
      
      await _resetCorruptDbAndPrefs(e);

      _isar = await openFresh();
      debugPrint('[Airports] Isar open succeeded after DB reset.');
      return _isar!;
    }
  }

  Future<int> localCount() async {
    final isar = await _open();
    return isar.airportLocals.count();
  }

  /// Lookup a single airport by its sourceId from the local Isar cache.
  Future<AirportLite?> getBySourceId(int sourceId) async {
    if (sourceId <= 0) return null;
    final isar = await _open();
    final local = await isar.airportLocals.get(sourceId);
    return local?.toLite();
  }

  /// Fetch a page of airports from Cloud Code.
  ///
  /// IMPORTANT: We use Cloud Code so the server can sanitize invalid GeoPoints
  /// and return lat/lon as plain numbers (avoids ParseGeoPoint assertion in SDK).
  Future<({
    List<Map<String, dynamic>> items,
    int nextAfterSourceId,
    bool hasMore,
  })> _fetchAirportsPageFromCloud({
    required int afterSourceId,
    required int limit,
  }) async {
    final fn = parse.ParseCloudFunction('getAirportsPage');
    final resp = await fn.execute(parameters: {
      'afterSourceId': afterSourceId,
      'limit': limit,
    });

    if (!resp.success || resp.result == null) {
      throw Exception(resp.error?.message ?? 'getAirportsPage failed');
    }

    final result = resp.result;
    if (result is! Map) {
      throw Exception('getAirportsPage unexpected result');
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(result);
    if (map['success'] != true) {
      throw Exception(map['message']?.toString() ?? 'getAirportsPage success=false');
    }

    final List<dynamic> rawItems = (map['items'] as List<dynamic>? ?? const <dynamic>[]);
    final items = rawItems.map((e) => Map<String, dynamic>.from(e as Map)).toList();

    final int nextAfterSourceId = (map['nextAfterSourceId'] as num? ?? afterSourceId).toInt();
    final bool hasMore = (map['hasMore'] as bool?) ?? false;

    return (items: items, nextAfterSourceId: nextAfterSourceId, hasMore: hasMore);
  }

  /// Fetch airport deltas from Cloud Code (updated after the given UTC millis).
  Future<({
    List<Map<String, dynamic>> items,
    bool hasMore,
    int nextCursorUpdatedAtMs,
    int nextAfterSourceId,
  })> _fetchAirportsDeltaFromCloud({
    required int updatedAfterMs,
    required int afterSourceId,
    required int limit,
  }) async {
    final fn = parse.ParseCloudFunction('getAirportsDelta');
    final resp = await fn.execute(parameters: {
      'updatedAfterMs': updatedAfterMs,
      'afterSourceId': afterSourceId,
      'limit': limit,
    });

    if (!resp.success || resp.result == null) {
      throw Exception(resp.error?.message ?? 'getAirportsDelta failed');
    }

    final result = resp.result;
    if (result is! Map) {
      throw Exception('getAirportsDelta unexpected result');
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(result);
    if (map['success'] != true) {
      throw Exception(map['message']?.toString() ?? 'getAirportsDelta success=false');
    }

    final List<dynamic> rawItems = (map['items'] as List<dynamic>? ?? const <dynamic>[]);
    final items = rawItems.map((e) => Map<String, dynamic>.from(e as Map)).toList();

    final bool hasMore = (map['hasMore'] as bool?) ?? false;
    final int nextCursorUpdatedAtMs = (map['nextCursorUpdatedAtMs'] as num? ?? updatedAfterMs).toInt();
    final int nextAfterSourceId = (map['nextAfterSourceId'] as num? ?? afterSourceId).toInt();

    return (
      items: items,
      hasMore: hasMore,
      nextCursorUpdatedAtMs: nextCursorUpdatedAtMs,
      nextAfterSourceId: nextAfterSourceId,
    );
  }

  /// One-time seed from Parse if local DB is empty.
  /// Uses paging by sourceId (fast, no huge skip values).
  Future<void> ensureSeeded({int pageSize = 1000}) async {
    final isar = await _open();
    if (await isar.airportLocals.count() > 0) return;

    final swTotal = Stopwatch()..start();
    int pageNo = 0;
    int fetchedTotal = 0;
    int insertedTotal = 0;
    int skippedInvalidGeoTotal = 0;
    int skippedMissingGeoTotal = 0;

    debugPrint('[Airports][Seed] START pageSize=$pageSize');

    int lastSourceId = 0;
    bool hasMore = true;

    while (hasMore) {
      pageNo++;
      final swPage = Stopwatch()..start();
      debugPrint('[Airports][Seed] Page $pageNo requesting sourceId > $lastSourceId');

      final swQuery = Stopwatch()..start();
      final page = await _fetchAirportsPageFromCloud(afterSourceId: lastSourceId, limit: pageSize);
      final items = page.items;
      swQuery.stop();

      fetchedTotal += items.length;
      debugPrint('[Airports][Seed] Page $pageNo fetched=${items.length} (totalFetched=$fetchedTotal) queryMs=${swQuery.elapsedMilliseconds} hasMore=${page.hasMore} nextAfterSourceId=${page.nextAfterSourceId}');
      // If server says there are no more raw rows, we are done.
      if (!page.hasMore && items.isEmpty) break;

      final locals = <AirportLocal>[];
      for (final m in items) {
        final int sourceId = (m['sourceId'] as num? ?? 0).toInt();
        final String ident = (m['ident'] as String? ?? '').trim();
        final String type = (m['type'] as String? ?? '').trim();
        if (sourceId <= 0 || ident.isEmpty) continue;

        // Lat/Lon are returned as plain numbers from Cloud Code.
        final double? lat = (m['latitude'] as num?)?.toDouble();
        final double? lon = (m['longitude'] as num?)?.toDouble();

        if (lat == null || lon == null) {
          skippedMissingGeoTotal++;
          continue;
        }

        // Validate ranges (Cloud should already sanitize, but keep defense)
        if (!(lat > -90.0 && lat < 90.0 && lon > -180.0 && lon < 180.0)) {
          skippedInvalidGeoTotal++;
          debugPrint('[Airports] Skipping invalid coords sourceId=$sourceId lat=$lat lon=$lon');
          continue;
        }

        final String name = (m['name'] as String? ?? '').trim();
        final String country = (m['country'] as String? ?? '').trim();
        final String region = (m['region'] as String? ?? '').trim();
        final String municipality = (m['municipality'] as String? ?? '').trim();
        final String rowHash = (m['rowHash'] as String? ?? '').trim();
        final bool isActive = (m['isActive'] as bool?) ?? true;
        final int updatedAtMs = (m['updatedAtMs'] as num? ?? 0).toInt();

        locals.add(
          AirportLocal(
            sourceId: sourceId,
            type: type,
            ident: ident,
            identUpper: ident.toUpperCase(),
            nameUpper: name.toUpperCase(),
            municipalityUpper: municipality.toUpperCase(),
            regionUpper: region.toUpperCase(),
            name: name,
            latitude: lat,
            longitude: lon,
            country: country,
            region: region,
            municipality: municipality,
            rowHash: rowHash,
            isActive: isActive,
            updatedAtMs: updatedAtMs,
          ),
        );
      }

      // Advance cursor based on RAW server page, not filtered items.
      // This prevents premature termination when server filters invalid rows.
      lastSourceId = page.nextAfterSourceId;

      final swWrite = Stopwatch()..start();
      await isar.writeTxn(() async {
        await isar.airportLocals.putAll(locals);
      });
      swWrite.stop();
      insertedTotal += locals.length;
      swPage.stop();

      debugPrint(
        '[Airports][Seed] Page $pageNo inserted=${locals.length} (totalInserted=$insertedTotal) writeMs=${swWrite.elapsedMilliseconds} pageMs=${swPage.elapsedMilliseconds} cursor(lastSourceId)=$lastSourceId hasMore=${page.hasMore} nextAfterSourceId=${page.nextAfterSourceId} skippedMissingGeo=$skippedMissingGeoTotal skippedInvalidGeo=$skippedInvalidGeoTotal',
      );

      hasMore = page.hasMore;
    }

    swTotal.stop();
    debugPrint(
      '[Airports][Seed] END totalFetched=$fetchedTotal totalInserted=$insertedTotal skippedMissingGeo=$skippedMissingGeoTotal skippedInvalidGeo=$skippedInvalidGeoTotal totalMs=${swTotal.elapsedMilliseconds}',
    );

    // Initialize sync meta row
    await isar.writeTxn(() async {
      await isar.airportSyncMetas.put(
        AirportSyncMeta(lastSyncAtMs: DateTime.now().toUtc().millisecondsSinceEpoch),
      );
    });
  }

  /// Local search by ident, airport name, municipality, or region
  /// (case-insensitive).
  ///
  /// Ranking priority:
  /// 1. ident prefix matches
  /// 2. airport name contains matches
  /// 3. municipality contains matches
  /// 4. region contains matches
  ///
  /// Within each bucket, airport type priority is applied so large/medium
  /// airports rank ahead of smaller or more specialized airport types.
  ///
  /// We fetch each bucket separately and then merge them while de-duplicating by
  /// sourceId, so the UI gets a stable relevance order instead of a plain
  /// alphabetical order across mixed match types.
  Future<List<AirportLite>> searchByIdent(String query, {int limit = 200}) async {
    Isar isar;
    try {
      isar = await _open();
    } catch (e) {
      debugPrint('[Airports] searchByIdent open failed: $e');

      if (!_isRecoverableOpenError(e)) {
        rethrow;
      }

      await _resetCorruptDbAndPrefs(e);
      _isar = null;
      isar = await _open();
    }

    final q = query.trim().toUpperCase();

    if (q.isEmpty) {
      // --------------------------
      // EMPTY QUERY BEHAVIOR
      // --------------------------
      // With ~80k airports, fetching a slightly larger alphabetical slice is
      // not enough to reliably include pinned airports, because some pinned
      // idents may be far away alphabetically.
      //
      // So instead we:
      // 1) fetch pinned airports directly by ident
      // 2) fetch the normal default alphabetical list
      // 3) merge them with pinned airports first
      // 4) de-duplicate by sourceId

      final List<AirportLocal> pinned = [];

      // Fetch pinned airports one-by-one by exact identUpper match so they are
      // guaranteed to appear regardless of their position in the full dataset.
      for (final identUpper in _pinnedIdentSet) {
        final match = await isar.airportLocals
            .filter()
            .isActiveEqualTo(true)
            .identUpperEqualTo(identUpper)
            .findFirst();

        if (match != null) {
          pinned.add(match);
        }
      }

      // Preserve the exact custom order defined in kPinnedAirportIdents.
      pinned.sort((a, b) {
        final ai = _pinnedOrder[a.identUpper] ?? 999999;
        final bi = _pinnedOrder[b.identUpper] ?? 999999;
        final pinnedCompare = ai.compareTo(bi);
        if (pinnedCompare != 0) return pinnedCompare;
        return _compareAirportPriority(a, b);
      });

      // Fetch the normal default alphabetical list separately.
      final normal = await isar.airportLocals
          .filter()
          .isActiveEqualTo(true)
          .sortByIdentUpper()
          .limit(limit)
          .findAll();

      // Re-rank the default list locally so larger airport types appear first.
      normal.sort(_compareAirportPriority);

      // Merge pinned first, then normal list, while removing duplicates.
      final List<AirportLocal> combined = [];
      final Set<int> seen = <int>{};

      void addBucket(List<AirportLocal> bucket) {
        for (final item in bucket) {
          if (seen.add(item.sourceId)) {
            combined.add(item);
            if (combined.length >= limit) return;
          }
        }
      }

      addBucket(pinned);
      if (combined.length < limit) addBucket(normal);

      return combined.take(limit).map((e) => e.toLite()).toList();
    }

    final identMatches = await isar.airportLocals
        .filter()
        .isActiveEqualTo(true)
        .identUpperStartsWith(q)
        .sortByIdentUpper()
        .limit(limit)
        .findAll();

    identMatches.sort(_compareAirportPriority);

    // final nameMatches = await isar.airportLocals
    //     .filter()
    //     .isActiveEqualTo(true)
    //     .nameUpperContains(q)
    //     .sortByNameUpper()
    //     .limit(limit)
    //     .findAll();

    final municipalityMatches = await isar.airportLocals
        .filter()
        .isActiveEqualTo(true)
        .municipalityUpperContains(q)
        .sortByMunicipalityUpper()
        .limit(limit)
        .findAll();

    municipalityMatches.sort(_compareAirportPriority);

    final regionMatches = await isar.airportLocals
        .filter()
        .isActiveEqualTo(true)
        .regionUpperContains(q)
        .sortByRegionUpper()
        .limit(limit)
        .findAll();

    regionMatches.sort(_compareAirportPriority);

    final ordered = <AirportLocal>[];
    final seen = <int>{};

    void addBucket(List<AirportLocal> bucket) {
      for (final item in bucket) {
        if (seen.add(item.sourceId)) {
          ordered.add(item);
          if (ordered.length >= limit) return;
        }
      }
    }

    addBucket(identMatches);
    // if (ordered.length < limit) addBucket(nameMatches);
    if (ordered.length < limit) addBucket(municipalityMatches);
    if (ordered.length < limit) addBucket(regionMatches);

    return ordered.take(limit).map((e) => e.toLite()).toList();
  }

  /// Occasional delta sync using Parse updatedAt.
  /// Throttled by [minInterval] (default 30 days).
  Future<void> syncDeltasIfNeeded({
    Duration minInterval = const Duration(days: 30),
    int pageSize = 1000,
  }) async {
    final isar = await _open();
    final meta = await isar.airportSyncMetas.get(0) ?? AirportSyncMeta(lastSyncAtMs: 0);

    final now = DateTime.now().toUtc();
    final lastSync = DateTime.fromMillisecondsSinceEpoch(meta.lastSyncAtMs, isUtc: true);

    if (meta.lastSyncAtMs != 0 && now.difference(lastSync) < minInterval) {
      return; // throttled
    }

    int cursorUpdatedAtMs = lastSync.millisecondsSinceEpoch;
    int cursorSourceId = 0; // tie-breaker
    bool hasMore = true;

    while (hasMore) {
      final page = await _fetchAirportsDeltaFromCloud(
        updatedAfterMs: cursorUpdatedAtMs,
        afterSourceId: cursorSourceId,
        limit: pageSize,
      );
      final items = page.items;

      // Done when server says no more raw rows AND nothing returned
      if (!page.hasMore && items.isEmpty) break;

      final locals = <AirportLocal>[];

      for (final m in items) {
        final int sourceId = (m['sourceId'] as num? ?? 0).toInt();
        final String ident = (m['ident'] as String? ?? '').trim();
        final String type = (m['type'] as String? ?? '').trim();
        if (sourceId <= 0 || ident.isEmpty) continue;

        final double? lat = (m['latitude'] as num?)?.toDouble();
        final double? lon = (m['longitude'] as num?)?.toDouble();
        if (lat == null || lon == null) continue;

        if (!(lat > -90.0 && lat < 90.0 && lon > -180.0 && lon < 180.0)) continue;

        final String name = (m['name'] as String? ?? '').trim();
        final String country = (m['country'] as String? ?? '').trim();
        final String region = (m['region'] as String? ?? '').trim();
        final String municipality = (m['municipality'] as String? ?? '').trim();
        final String rowHash = (m['rowHash'] as String? ?? '').trim();
        final bool isActive = (m['isActive'] as bool?) ?? true;
        final int updatedAtMs = (m['updatedAtMs'] as num? ?? 0).toInt();

        locals.add(
          AirportLocal(
            sourceId: sourceId,
            type: type,
            ident: ident,
            identUpper: ident.toUpperCase(),
            nameUpper: name.toUpperCase(),
            municipalityUpper: municipality.toUpperCase(),
            regionUpper: region.toUpperCase(),
            name: name,
            latitude: lat,
            longitude: lon,
            country: country,
            region: region,
            municipality: municipality,
            rowHash: rowHash,
            isActive: isActive,
            updatedAtMs: updatedAtMs,
          ),
        );
      }

      await isar.writeTxn(() async {
        await isar.airportLocals.putAll(locals);
      });

      // Advance cursor based on RAW server page
      cursorUpdatedAtMs = page.nextCursorUpdatedAtMs;
      cursorSourceId = page.nextAfterSourceId;
      hasMore = page.hasMore;

      debugPrint(
        '[Airports][Delta] fetched=${items.length} upserted=${locals.length} '
        'cursorUpdatedAtMs=$cursorUpdatedAtMs cursorSourceId=$cursorSourceId hasMore=$hasMore',
      );
    }

    await isar.writeTxn(() async {
      meta.lastSyncAtMs = now.millisecondsSinceEpoch;
      await isar.airportSyncMetas.put(meta);
    });
  }

  // For testing/debugging purposes.
  // This wipes only the Isar database named airports_db and nothing else.
  Future<void> deleteLocalAirportsDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = dir.path;

    debugPrint('[Airports] deleteLocalAirportsDb START path=$path');

    try {
      // 1) If an instance is already open (even if our field is null), grab it.
      _isar ??= Isar.getInstance('airports_db');

      // 2) If still null, open it briefly so we can delete from disk.
      //    (Isar can only delete from disk when it has an instance to close.)
      _isar ??= await Isar.open(
        [AirportLocalSchema, AirportSyncMetaSchema],
        directory: path,
        name: 'airports_db',
      );

      // 3) Close and delete.
      await _isar!.close(deleteFromDisk: true);
      _isar = null;

      debugPrint('[Airports] deleteLocalAirportsDb DONE (deleted from disk)');
    } catch (e) {
      debugPrint('[Airports] deleteLocalAirportsDb ERROR: $e');
    }
  }
}