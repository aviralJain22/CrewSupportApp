import 'package:crew_support/utils/pref_keys.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared location sync service used by both foreground UI flows and future
/// background/app-lifecycle entry points.
///
/// IMPORTANT:
/// - This service only handles reading the current device location and saving it
///   to the logged-in Parse `_User` row.
/// - Controller/UI code should decide *when* to call this service.
/// - Throttle state is kept here so all callers share the same write policy.
class LocationSyncService {
  LocationSyncService._();

  static final LocationSyncService instance = LocationSyncService._();
  static const String sourceForeground = 'foreground';
  static const String sourceBackground = 'background';

  /// Singleton-friendly top-level access point for app lifecycle / background
  /// entry points that should respect the persisted selected-profile flag.
  static Future<bool> runBestEffortSyncIfEnabled({
    double minDistanceM = 300,
    Duration minInterval = const Duration(minutes: 5),
  }) {
    return instance.syncCurrentUserLocationIfEnabled(
      minDistanceM: minDistanceM,
      minInterval: minInterval,
      allowTimeOnlyFallback: true,
      locationSource: sourceBackground,
    );
  }

  /// Returns the persisted key used to remember whether location sync is enabled
  /// for a specific membership type.
  String locationEnabledKeyForMembershipType(int membershipType) {
    return 'locationEnabled_$membershipType';
  }

  /// Reads the currently selected membership type from SharedPreferences.
  Future<int> getPersistedSelectedProfileType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PrefKeys.selectedProfileType) ?? 0;
  }

  /// Returns whether location sync is enabled for the currently selected
  /// membership type, based on the value previously persisted by the dashboard.
  Future<bool> isLocationEnabledForPersistedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedProfileType = prefs.getInt(PrefKeys.selectedProfileType) ?? 0;

    if (selectedProfileType == 0) {
      return false;
    }

    return prefs.getBool(locationEnabledKeyForMembershipType(selectedProfileType)) ?? false;
  }

  // --- throttle state ---
  DateTime? _lastLocationSaveAt;
  ParseGeoPoint? _lastSavedGeoPoint;

  /// Clears in-memory throttle state.
  ///
  /// Useful on logout so a new session/account is not affected by the previous
  /// user's last successful save time/location.
  void resetThrottle() {
    _lastLocationSaveAt = null;
    _lastSavedGeoPoint = null;
  }

  /// Best-effort sync helper for non-UI entry points such as app resume or
  /// future background fetch callbacks.
  ///
  /// This reads the persisted selected profile + enabled flag and skips the
  /// location read entirely when sync is not allowed for the active profile.
  Future<bool> syncCurrentUserLocationIfEnabled({
    double minDistanceM = 300,
    Duration minInterval = const Duration(minutes: 5),
    bool allowTimeOnlyFallback = false,
    String locationSource = sourceForeground,
  }) async {
    final enabled = await isLocationEnabledForPersistedProfile();
    if (!enabled) {
      debugPrint('[Location] Persisted profile has location sync disabled.');
      return false;
    }

    return syncCurrentUserLocation(
      minDistanceM: minDistanceM,
      minInterval: minInterval,
      allowTimeOnlyFallback: allowTimeOnlyFallback,
      locationSource: locationSource,
    );
  }

  /// Push the latest device location to the current Parse `_User` row.
  ///
  /// Returns `true` only when a save actually succeeded.
  /// Returns `false` when the update was skipped, denied, failed, or the user
  /// was not logged in.
  Future<bool> syncCurrentUserLocation({
    // Minimum distance moved before saving again (in metres)
    double minDistanceM = 100,
    // Minimum time gap before saving again
    Duration minInterval = const Duration(seconds: 30),
    // When true, a save is allowed once [minInterval] has elapsed even if the
    // distance moved is still below [minDistanceM].
    bool allowTimeOnlyFallback = true,
    String locationSource = sourceForeground,
  }) async {
    try {
      // 1) Ensure permissions & services
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[Location][$locationSource] GPS service disabled.');
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('[Location][$locationSource] Permission denied.');
        return false;
      }

      // 2) Read current position
      final Position pos = await Geolocator.getCurrentPosition();

      final nowUtc = DateTime.now().toUtc();
      final newPoint = ParseGeoPoint(
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

      // 3) Throttle by time
      if (_lastLocationSaveAt != null) {
        final elapsed = nowUtc.difference(_lastLocationSaveAt!);
        if (elapsed < minInterval) {
          debugPrint('[Location][$locationSource] Skipping save (minInterval not reached).');
          return false;
        }
      }

      // 4) Throttle by distance
      if (_lastSavedGeoPoint != null) {
        final distM = Geolocator.distanceBetween(
          _lastSavedGeoPoint!.latitude,
          _lastSavedGeoPoint!.longitude,
          newPoint.latitude,
          newPoint.longitude,
        );

        if (distM < minDistanceM) {
          if (!allowTimeOnlyFallback) {
            debugPrint(
              '[Location][$locationSource] Skipping save (moved only ${distM.toStringAsFixed(1)} m).',
            );
            return false;
          }

          debugPrint(
            '[Location][$locationSource] Distance below threshold (${distM.toStringAsFixed(1)} m), '
            'but saving because minInterval has elapsed.',
          );
        }
      }

      // Optional: ignore very poor accuracy (in metres)
      // if (pos.accuracy > 50) return false;

      // 5) Save to Parse _User
      final ParseUser? user = await ParseUser.currentUser() as ParseUser?;
      if (user == null) {
        debugPrint('[Location][$locationSource] Not logged in.');
        return false;
      }

      user.set<ParseGeoPoint>('location', newPoint);
      user.set<DateTime>('locationUpdatedAt', nowUtc);
      user.set<String>('locationSource', locationSource);

      // Optional extra metadata (if you add these columns)
      // user.set<double>('locationAccuracyM', pos.accuracy);
      // user.set<double>('locationSpeedMps', pos.speed);
      // user.set<double>('locationHeadingDeg', pos.heading);

      final res = await user.save();
      if (!res.success) {
        debugPrint('[Location][$locationSource] Save failed: ${res.error?.message}');
        return false;
      }

      // 6) Update local throttle state only after successful save
      _lastLocationSaveAt = nowUtc;
      _lastSavedGeoPoint = newPoint;

      debugPrint('[Location][$locationSource] Saved (${pos.latitude}, ${pos.longitude}) at $nowUtc');
      return true;
    } catch (e) {
      debugPrint('[Location][$locationSource] Exception: $e');
      return false;
    }
  }
}