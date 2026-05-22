import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:background_fetch/background_fetch.dart';
import 'package:crew_support/app/routes.dart';
import 'package:crew_support/database/airport_code_model.dart';
import 'package:crew_support/features/trip/trip_draft_flow_service.dart';
import 'package:crew_support/model/profile_summary.dart';
import 'package:crew_support/model/trip_model.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/local_notification_service.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:crew_support/utils/pref_keys.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:crew_support/features/home/home_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crew_support/services/location_sync_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class DashboardController extends GetxController with WidgetsBindingObserver {
  static const bool useMock = true; // Set to false when backend is ready

  /// Search field controller (same as legacy)
  final TextEditingController searchController = TextEditingController();

  /// Avatar/photo url pulled from backend
  final RxString photoUrl = ''.obs;
  /// Whether the current profile is disabled (used for faded avatar)
  final RxBool isCurrentProfileDisabled = false.obs;

  /// Minimum characters required to trigger search (legacy = 2)
  final int minSearchChars = 3;

  /// Bottom navigation state (0: Home, 1: Profile, 2: Connection, 3: Notification, 4: Messages, 5: Search)
  final RxInt currentPage = 0.obs;

  // ===== Airport code logic (migrated from legacy getCode()) =====
  /// Loading flag for airport code seeding/refresh
  final RxBool isLoadingCode = false.obs;

  // Controls loading indicator inside login dialog
  final RxBool isDialogLoading = false.obs;

  // Reactive selected profile type
  final RxInt selectedProfileType = 0.obs;

  String? selectedProfileId;

  // ===== Switch account dialog state (ported from legacy showLoginDilog) =====

  /// Profiles returned from `getAllProfilesForCurrentUser`.
  /// We reuse `ProfileSummary` model (membershipType, firstName, lastName, photoPath).
  final RxList<ProfileSummary> switchList = <ProfileSummary>[].obs;

  /// Currently selected radio index in the dialog (equivalent to legacy `selectedRadio`).
  final RxInt selectedRadio = 0.obs;

  /// Convenience getters to check which profiles exist for the current user.
  bool get hasOwnerProfile =>
      switchList.any((p) => p.membershipType == 1);
  bool get hasInstructorProfile =>
      switchList.any((p) => p.membershipType == 2);
  bool get hasPilotProfile =>
      switchList.any((p) => p.membershipType == 3);
  bool get hasFlightAttendantProfile =>
      switchList.any((p) => p.membershipType == 4);

  /// True when user already has all 4 profile types; used to hide "Add Account".
  bool get hasAllProfiles =>
      hasOwnerProfile &&
      // hasInstructorProfile && //Removed temporarily
      hasPilotProfile &&
      hasFlightAttendantProfile;

  /// trips grouped by category from getOwnerTrips, getPilotTrips etc...
  final RxList<TripModel> currentTrips = <TripModel>[].obs;
  final RxList<TripModel> futureTrips = <TripModel>[].obs;
  final RxList<TripModel> historyTrips = <TripModel>[].obs;
  final RxList<TripModel> pendingTrips = <TripModel>[].obs;
  final RxList<TripModel> draftTrips = <TripModel>[].obs;
  final RxList<TripModel> uncrewedTrips = <TripModel>[].obs;

  /// Badge counts (unread = isRead == false) for each category
  final RxInt currentBadgeCount = 0.obs;
  final RxInt futureBadgeCount = 0.obs;
  final RxInt historyBadgeCount = 0.obs;
  final RxInt pendingBadgeCount = 0.obs;
  final RxInt draftBadgeCount = 0.obs;

  /// Loading + error state for loadingTrips
  final RxBool isLoadingTrips = false.obs;
  final RxnString loadTripsError = RxnString();

  /// When true, the normal top-bar heart icon is replaced with a warning icon.
  ///
  /// This warning is only relevant when the currently selected profile has
  /// Current Location enabled. It is used to surface configuration problems
  /// that would prevent the app from reliably updating the user's location,
  /// especially for nearby-trip visibility.
  final RxBool showLocationWarningButton = false.obs;

  /// Why the warning icon is being shown.
  ///
  /// Possible values:
  /// - permission_not_always:
  ///   App has location permission, but not the required `always` level.
  /// - device_location_off:
  ///   Device-wide Location Services are turned off.
  /// - background_fetch_disabled:
  ///   Background refresh/fetch is unavailable on iOS, so background location
  ///   sync may not run reliably.
  final RxnString locationWarningReason = RxnString();

  /// Helper flag used only for warning-icon presentation.
  ///
  /// When the only problem is that permission is `whileInUse` instead of
  /// `always`, the UI uses a softer warning color than it does for more severe
  /// states such as device Location Services being off.
  final RxBool isWhileInUseOnly = false.obs;

  /// Holds airport code rows read from local DB (use your concrete model instead of dynamic if desired)
  // final RxList<dynamic> airportCode = <dynamic>[].obs;

  // Token to force a rebuild of the dashboard body
  // final RxInt bodyReloadToken = 0.obs;

  /// Call this whenever you want the Expanded section to rebuild.
  // void reloadBody() {
  //   bodyReloadToken.value++;
  // }

  /// Whether location updates are enabled for the currently selected profile.
  /// Driven by ProfileSummary.currentLocation returned by fetchBasicProfileForCurrentRole().
  final RxBool isLocationEnabledForProfile = false.obs;

  /// Replicates legacy getCode() with safe reseed logic:
  /// - Ask server for current TotalCount
  /// - If local count != server count, clear table then insert fresh
  /// - Otherwise, just read from local
  Future<void> getCode() async {
    debugPrint("inside getCode");
    try {
      isLoadingCode.value = true;

      // 2) Get current local count
      // final localCount = (await AirportCodeDB.instance.getTotalLength()) ?? 0;
      // debugPrint("localCount = $localCount");
      
      // 3) Decide reseed vs read
      // final needsReseed = (apiListCount > 0 && localCount != apiListCount) || localCount == 0;
      // final needsReseed = (localCount < 60000) || localCount == 0;

      // if (needsReseed) {
      //   // 1) Hit the API first; use its TotalCount as the source of truth
      //   final result = await getAllAirportCode();
      //   final apiCount = result?.totalCount ?? 0;
      //   final apiListCount = result?.data?.airportCode?.length ?? 0;

      //   debugPrint("AirportCode localCount=$localCount, apiCount=$apiCount, apiListCount=$apiListCount");

      //   debugPrint("Reseeding airport codes (local=$localCount, api=$apiCount)...");
      //   // Clear first to avoid duplicates/stale data
      //   await AirportCodeDB.instance.clearAll();

      //   // Insert only if API returned rows
      //   final rows = result?.data?.airportCode ?? const <AirportCode>[];
      //   if (rows.isNotEmpty) {
      //     // Keep only rows that actually have a non-empty AirportCode
      //     final valid = rows.where((e) => (e.airportCode?.trim().isNotEmpty ?? false)).toList();
      //     debugPrint("API rows: ${rows.length}, valid(with AirportCode): ${valid.length}");
      //     if (valid.isEmpty) {
      //       debugPrint("Warning: API rows missing AirportCode field; verify Cloud Function maps { AirportCode: <code> } per row.");
      //       if (rows.isNotEmpty) {
      //         debugPrint('Sample raw row: ' + rows.first.toJson().toString());
      //       }
      //     } else {
      //       final sample = valid.take(5).map((e) => e.airportCode).toList();
      //       debugPrint("inserting ${valid.length} rows; sample=${sample}");
      //       await AirportCodeDB.instance.batchInsert(valid);
      //       final post = (await AirportCodeDB.instance.getTotalLength()) ?? 0;
      //       debugPrint('post-insert local count=$post');
      //     }
      //   } else {
      //     debugPrint("Warning: API returned zero rows; skipping insert.");
      //   }
      // }

      // debugPrint("loading local DB into memory");
      // 4) Load from local DB into memory
      // final list = await AirportCodeDB.instance.readAllAirportCode();
      // debugPrint("loading into memory complete. Loaded ${list.length} items.");
      // airportCode.assignAll(list as Iterable<AirportCodeDBModel>);
    } catch (e) {
      debugPrint('getCode() error: $e');
    } finally {
      // debugPrint("airportCode length: ${airportCode.length}");
      isLoadingCode.value = false;
    }
  }

  /// Flags that mirror the old booleans; we keep derived getters for convenience.
  bool get isHome => currentPage.value == 0;
  bool get isProfile => currentPage.value == 1;
  bool get isConn => currentPage.value == 2;
  bool get isNotification => currentPage.value == 3;
  bool get isMsg => currentPage.value == 4;
  bool get isSearch => currentPage.value == 5;

  /// Debounce for search (matches the old "call on each change" without spamming network)
  Timer? _debounce;
  final RxBool isSearching = false.obs;

  /// Search results coming back from the cloud function
  final RxList<Map<String, dynamic>> searchResults = <Map<String, dynamic>>[].obs;

  /// When true, the user has typed but the query is too short (mirrors legacy `_searchValidation`)
  final RxBool searchValidationError = false.obs;

  /// Public: call this when search text changes. Provide your async search function via [onPerformSearch].
  void onSearchChanged(
    String text, {
    required Future<List<Map<String, dynamic>>> Function(String q) onPerformSearch,
    Duration debounce = const Duration(milliseconds: 350),
  }) {
    debugPrint("text: $text");
    _debounce?.cancel();

    final trimmed = text.trim();

    // Always show the Search tab while interacting with the box
    currentPage.value = 5;

    if (trimmed.isEmpty) {
      // Reset everything when field is cleared
      isSearching.value = false;
      searchValidationError.value = false;
      searchResults.clear();
      return;
    }

    if (trimmed.length < minSearchChars) {
      // Mirror legacy behaviour: show validation + no results
      isSearching.value = false;
      searchValidationError.value = true;
      searchResults.clear();
      return;
    }

    // Valid query – clear previous error and debounce the API call
    searchValidationError.value = false;
    isSearching.value = true;

    _debounce = Timer(debounce, () async {
      try {
        final results = await onPerformSearch(trimmed);
        searchResults
          ..clear()
          ..addAll(results);
      } finally {
        isSearching.value = false;
      }
    });
  }

  /// Wrapper used by the UI: performs the cloud search and returns the raw rows.
  Future<List<Map<String, dynamic>>> performSearch(String q) async {
    final results = await searchUsersByName(q);
    return results;
  }

  Future<List<Map<String, dynamic>>> searchUsersByName(String searchText) async {
    // Ensure the user is logged in before calling this
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) {
      throw Exception('User must be logged in to search.');
    }

    // Prepare cloud function
    final function = ParseCloudFunction('searchUsersByName');

    // Call with the search text
    final ParseResponse response =
        await function.execute(parameters: {'searchText': searchText});

        debugPrint("response: $response");

    if (!response.success || response.result == null) {
      // Either error or no results
      return [];
    }

    // result is a List<dynamic> of Map<String, dynamic>
    final List<dynamic> raw = response.result as List<dynamic>;

    return raw.cast<Map<String, dynamic>>();
  }

  /// Handle tap on a search result row.
  /// For now we only log; routing to detail screens can be wired later.
  void onSearchResultTap(Map<String, dynamic> row) {
    final id = row['id']?.toString();
    final membershipType = (row['membershipType'] as num?)?.toInt() ?? 0;

    debugPrint('Search result tapped: id=$id, membershipType=$membershipType');

    if (membershipType == MembershipType.pilot) {
      Get.toNamed(AppRoutes.pilotViewProfile, arguments: {
        'profileId': id,
        'userId': row['userId']?.toString(),
      });
    // } else if (membershipType == MembershipType.ownerOperator) {
    // } else if (membershipType == MembershipType.instructor) {
    } else if (membershipType == MembershipType.flightAttendant) {
      Get.toNamed(AppRoutes.fAViewProfile, arguments: {
        'profileId': id,
        'userId': row['userId']?.toString(),
      });
    } else {
      debugPrint('Unknown membershipType: $membershipType');
      return;
    }
    // TODO: Route to the appropriate profile detail screen once
    // those GetX routes are wired up (Owner/Instructor/Pilot/FA).
  
  }

  /// Navigation helpers (kept tiny so UI stays declarative)
  ///
  /// NOTE: By default we unfocus to dismiss the keyboard on tab switches.
  /// But when selecting the Search tab via a TextField tap, unfocusing will
  /// immediately remove focus and prevent the keyboard from showing.
  void selectTab(int index, {bool unfocus = true}) {
    currentPage.value = index;

    // Clear keyboard focus on tab switch (optional)
    if (unfocus) {
      Get.focusScope?.unfocus();
    }
  }

  /// Convenience helper for selecting a tab while keeping the current focus.
  void selectTabKeepFocus(int index) {
    selectTab(index, unfocus: false);
  }

  /// Simulated avatar tap action (open a full-screen image viewer in future)
  void onAvatarTap() {
    // Intentionally left blank for now. Hook to image viewer route if available.
  }

  /// Help Center tap
  void onHelpCenterTap() {
    Get.toNamed('/help');
  }

  /// Manage Availability tap - route when screen exists
  void onManageAvailabilityTap() {
    Get.toNamed(AppRoutes.manageAvailability);
  }

  /// Show a confirmation dialog before logging the user out.
  /// Uses GetX's default dialog to keep UI consistent and simple.
  void askLogoutConfirm() {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Are you sure you want to log out?',
      textCancel: 'Cancel',
      textConfirm: 'Logout',
      barrierDismissible: false,
      onCancel: () {
        // User cancelled; do nothing.
      },
      onConfirm: () {
        // Close the dialog then perform logout.
        Get.back();
        doUserLogout();
      },
    );
  }

  /// Logout using Parse. Uses a gentle UI-first strategy:
  /// - Logs out on Parse
  /// - If successful, takes user to Login
  /// - If failed, logs the error (replace with showMyDialog/snackbar in future)
  Future<void> doUserLogout() async {
     // Prevent stale UI state when logging into another account.
    _clearLocalDashboardState();
    try {
      final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        await Get.deleteAll(force: true);
        Get.offAllNamed('/login');
        return;
      }
      final response = await currentUser.logout();
      if (response.success) {
        // Hard reset the dependency tree so the next session gets fresh controllers.
        // This fixes the issue where Dashboard/Home show previous account data after relogin.
        await Get.deleteAll(force: true);
        Get.offAllNamed('/login');
      } else {
        // Replace with showMyDialog(...) if your project uses that consistently
        debugPrint('Error logging out: ${response.error?.message}');
      }
    } catch (e) {
      debugPrint('Logout exception: $e');
    }
  }

  /// Clears any locally cached/reactive state so the next login cannot show stale data.
  ///
  /// IMPORTANT: This does not log out; it only resets in-memory controller state.
  void _clearLocalDashboardState() {
    try {
      // Header
      photoUrl.value = '';
      isCurrentProfileDisabled.value = false;

      // Role selection
      selectedProfileType.value = 0;
      selectedRadio.value = 0;
      switchList.clear();

      // Trips
      currentTrips.clear();
      futureTrips.clear();
      historyTrips.clear();
      pendingTrips.clear();
      draftTrips.clear();

      currentBadgeCount.value = 0;
      futureBadgeCount.value = 0;
      historyBadgeCount.value = 0;
      pendingBadgeCount.value = 0;
      draftBadgeCount.value = 0;

      loadTripsError.value = null;
      isLoadingTrips.value = false;

      // Search
      _debounce?.cancel();
      isSearching.value = false;
      searchValidationError.value = false;
      searchResults.clear();
      searchController.clear();

      // Tabs
      currentPage.value = 0;

      showLocationWarningButton.value = false;
      locationWarningReason.value = null;

      // Reset shared location throttle so a future session/profile starts clean.
      LocationSyncService.instance.resetThrottle();
    } catch (e) {
      debugPrint('_clearLocalDashboardState error: $e');
    }
  }

  /// Allow external code to update the known photo url and membership id
  // void hydrateUserHeader({String? photo, String? membershipId}) {
  //   if (photo != null) photoUrl.value = photo;
  //   if (membershipId != null) fkMembershipId.value = membershipId;
  // }

  late SharedPreferences prefs;

  Timer? _locationTimer;

  void _stopLocationTimer({String reason = 'unspecified'}) {
    if (_locationTimer != null) {
      debugPrint('[Location][foreground] Stopping timer ($reason).');
    }
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  /// Restarts the foreground timer that periodically pushes location updates.
  ///
  /// Important behavior:
  /// - Always stops any previous timer first so profile switches cannot leave
  ///   stale timers running.
  /// - Never triggers a permission popup from the dashboard flow.
  /// - Starts the timer only when the selected profile has Current Location ON
  ///   and usable permission is already available.
  Future<void> _restartLocationUpdatesIfNeeded() async {
    // Always cancel first so switching profiles cannot leave an old timer running.
    _stopLocationTimer(reason: 'restart requested');

    if (!isLocationEnabledForProfile.value) {
      debugPrint('[Location][foreground] Disabled for this profile; timer not started.');
      return;
    }

    // Do not request permission from Dashboard flow.
    // The permission prompt should only originate from the explicit profile toggle flow.
    final bool hasPermission = await _hasUsableLocationPermissionForCurrentLocationFeature();
    if (!hasPermission) {
      debugPrint('[Location][foreground] Current Location is ON for this profile, but usable permission is not available; timer not started.');
      return;
    }

    // Foreground heartbeat:
    // - timer fires every 45s
    // - service itself enforces movement/time throttling
    // - `allowTimeOnlyFallback` lets us still sync after enough time passes,
    //   even if movement is below the distance threshold
    _locationTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      updateMyLocationToParse(
        minDistanceM: 100,
        minInterval: const Duration(seconds: 30),
        allowTimeOnlyFallback: true,
        locationSource: LocationSyncService.sourceForeground,
      );
    });

    debugPrint('[Location][foreground] Enabled for this profile and permission is ready; timer started.');
  }

  /// Silent permission gate used by dashboard/background-adjacent flows.
  ///
  /// Important:
  /// - This method must NEVER trigger the iOS permission popup.
  /// - The popup should only appear when the user explicitly turns
  ///   Current Location ON from the profile screen.
  /// - Since this feature is intended to keep location usable beyond the
  ///   visible profile screen flow, we treat `always` as the usable state.
  Future<bool> _hasUsableLocationPermissionForCurrentLocationFeature() async {
    final bool servicesEnabled = await Geolocator.isLocationServiceEnabled();
    if (!servicesEnabled) {
      return false;
    }

    final LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always;
  }

  /// Best-effort sync performed when the app returns to the foreground.
  ///
  /// This complements the periodic timer by attempting one immediate sync on
  /// resume, using a looser time-based fallback so the server can be refreshed
  /// even when the user has not moved much.
  Future<void> _syncLocationOnAppResumeIfNeeded() async {
    if (!isLocationEnabledForProfile.value) {
      debugPrint('[Location][foreground] App resume sync skipped because Current Location is OFF for this profile.');
      return;
    }

    final bool hasPermission = await _hasUsableLocationPermissionForCurrentLocationFeature();
    if (!hasPermission) {
      debugPrint('[Location][foreground] App resume sync skipped because usable location permission is not available.');
      return;
    }

    await LocationSyncService.instance.syncCurrentUserLocationIfEnabled(
      minDistanceM: 300,
      minInterval: const Duration(minutes: 5),
      locationSource: LocationSyncService.sourceForeground,
    );
  }

  Future<void> refreshTopBarLocationWarningState() async {
    try {
      // If Current Location is OFF for this profile, keep the normal heart icon.
      if (!isLocationEnabledForProfile.value) {
        showLocationWarningButton.value = false;
        locationWarningReason.value = null;
        isWhileInUseOnly.value = false;
        return;
      }

      // 1) Device location services must be ON.
      // This should take priority over permission-state messaging because when
      // Location Services are OFF at the device level, sending the user to app
      // permission settings is not the right guidance.
      final bool servicesEnabled = await Geolocator.isLocationServiceEnabled();
      if (!servicesEnabled) {
        showLocationWarningButton.value = true;
        locationWarningReason.value = 'device_location_off';
        isWhileInUseOnly.value = false;
        debugPrint('[Location][warning] device_location_off');
        return;
      }

      // 2) Permission must be Always.
      final LocationPermission permission = await Geolocator.checkPermission();

      // Keep a separate UI hint so the icon color can distinguish the milder
      // while-in-use-only case from more serious warning states.
      isWhileInUseOnly.value = permission == LocationPermission.whileInUse;

      if (permission != LocationPermission.always) {
        showLocationWarningButton.value = true;
        locationWarningReason.value = 'permission_not_always';
        debugPrint('[Location][warning] permission_not_always: $permission');
        return;
      }

      // 3) Background refresh / fetch warning is iOS-specific.
      if (Platform.isIOS) {
        final int bgStatus = await BackgroundFetch.status;
        if (bgStatus == BackgroundFetch.STATUS_DENIED ||
            bgStatus == BackgroundFetch.STATUS_RESTRICTED) {
          showLocationWarningButton.value = true;
          locationWarningReason.value = 'background_fetch_disabled';
          isWhileInUseOnly.value = false;
          debugPrint('[Location][warning] background_fetch_disabled: $bgStatus');
          return;
        }
      }

      // Everything is OK.
      showLocationWarningButton.value = false;
      locationWarningReason.value = null;
      isWhileInUseOnly.value = false;
      debugPrint('[Location][warning] all requirements satisfied');
    } catch (e) {
      debugPrint('[Location][warning] refreshTopBarLocationWarningState error: $e');
      showLocationWarningButton.value = false;
      locationWarningReason.value = null;
      isWhileInUseOnly.value = false;
    }
  }

  Future<void> onTopBarLocationWarningTap() async {
    try {
      if (!isLocationEnabledForProfile.value) {
        return;
      }

      // Device-level Location Services OFF should be handled before permission
      // checks, otherwise the user may see the wrong dialog (for example a
      // permission dialog when the real issue is that phone-wide location is OFF).
      final bool servicesEnabled = await Geolocator.isLocationServiceEnabled();
      if (!servicesEnabled) {
        await refreshTopBarLocationWarningState();
        _showDeviceLocationOffDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      // Give this button the opportunity to trigger the system permission popup
      // when permission is still in a requestable state.
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('[Location][warning] requestPermission result: $permission');
      }

      // If still not Always, explain what to do next.
      if (permission != LocationPermission.always) {
        await refreshTopBarLocationWarningState();
        _showLocationPermissionWarningDialog(permission);
        return;
      }

      if (Platform.isIOS) {
        final int bgStatus = await BackgroundFetch.status;
        if (bgStatus == BackgroundFetch.STATUS_DENIED ||
            bgStatus == BackgroundFetch.STATUS_RESTRICTED) {
          await refreshTopBarLocationWarningState();
          _showBackgroundFetchWarningDialog();
          return;
        }
      }

      // If user fixed everything, refresh UI and resume location flow.
      await refreshTopBarLocationWarningState();
      await _restartLocationUpdatesIfNeeded();
      await _syncLocationOnAppResumeIfNeeded();
    } catch (e) {
      debugPrint('[Location][warning] onTopBarLocationWarningTap error: $e');
    }
  }

  void _showLocationPermissionWarningDialog(LocationPermission permission) {
    final bool permanentlyDenied = permission == LocationPermission.deniedForever;
    final bool whileInUseOnly = permission == LocationPermission.whileInUse;

    String message;

    if (Platform.isAndroid) {
      message =
          'Enable full location access to improve nearby trip matching. Crew Support needs Location set to "Allow all the time" for optimal functioning.';

      if (permanentlyDenied) {
        message =
            'Location access is permanently denied for Crew Support. Please open Settings, allow location access, and set Location to "Allow all the time" so you can remain visible for nearby trips even when the app is closed.';
      } else if (whileInUseOnly) {
        message =
            'Location access is currently allowed only while using the app. To stay visible for nearby trips even when the app is closed, please open Settings and change Location to "Allow all the time" for Crew Support.';
      }
    } else {
      // LocationPermission.denied can mean:
      // 1. User selected “Ask Next Time”
      // 2. User tapped “Don’t Allow” (but not permanently denied)
      // 3. App has never asked for permission yet
      // All of these collapse into the same state: denied but still requestable.
      message =
          'Enable full location access to improve nearby trip matching. Crew Support needs location access set to "Always" for optimal functioning.';

      if (permanentlyDenied) {
        message =
            'Location access is permanently denied for Crew Support. Enable full location access to improve nearby trip matching. Crew Support only uses your location to match you with trips — never for continuous tracking. Please open Settings and change Location access to "Always" for Crew Support.';
      } else if (whileInUseOnly) {
        message =
            'Location access is currently allowed only while using the app. Enable full location access to stay visible for nearby trips even when the app is closed. Please open Settings and change Location access to "Always" for Crew Support.';
      }
    }

    Get.defaultDialog(
      title: 'Location Access Needed',
      titleStyle: TextStyle(color: Colors.white),
      middleText: message,
      middleTextStyle: TextStyle(color: Colors.white),
      backgroundColor: AppColor.backgroundColor1,
      textCancel: 'Cancel',
      textConfirm: 'Open Settings',
      cancelTextColor: Colors.white,
      confirmTextColor: Colors.white,
      barrierDismissible: false,
      onCancel: () {},
      onConfirm: () async {
        Get.back();
        await Geolocator.openAppSettings();
      },
    );
  }

  void _showDeviceLocationOffDialog() {
    final String message = Platform.isAndroid
        ? 'Location is turned off on this device. Please turn it on to stay visible for nearby trip opportunities. Open device Location settings and enable Location.'
        : 'Location Services are turned off on this device. Please turn them on to stay visible for nearby trip opportunities. Open Settings, then go to Privacy & Security > Location Services and turn them on.';

    Get.defaultDialog(
      title: 'Turn On Location Services',
      titleStyle: TextStyle(color: Colors.white),
      middleText: message,
      middleTextStyle: TextStyle(color: Colors.white),
      backgroundColor: AppColor.backgroundColor1,
      textCancel: 'Cancel',
      textConfirm: 'Open Settings',
      cancelTextColor: Colors.white,
      confirmTextColor: Colors.white,
      barrierDismissible: false,
      onCancel: () {},
      onConfirm: () async {
        Get.back();
        await Geolocator.openLocationSettings();
      },
    );
  }

  void _showBackgroundFetchWarningDialog() {
    final String message = Platform.isAndroid
        ? 'Background location updates may be limited by this device. Please review battery optimization and background activity settings for Crew Support if location freshness is unreliable.'
        : 'Background App Refresh / Background Fetch is disabled for Crew Support. Please enable it in Settings to stay visible for nearby trip opportunities.';

    Get.defaultDialog(
      title: 'Background Refresh Needed',
      titleStyle: TextStyle(color: Colors.white),
      middleText: message,
      middleTextStyle: TextStyle(color: Colors.white),
      backgroundColor: AppColor.backgroundColor1,
      textCancel: 'Cancel',
      textConfirm: 'Open Settings',
      cancelTextColor: Colors.white,
      confirmTextColor: Colors.white,
      barrierDismissible: false,
      onCancel: () {},
      onConfirm: () async {
        Get.back();
        await Geolocator.openAppSettings();
      },
    );
  }

  //onReady() runs after navigation & UI mount — perfect timing.
  // So ensure loadTrips runs when Dashboard is shown again:
  @override
  void onReady() {
    super.onReady();
    loadTrips();

    unawaited(_restartLocationUpdatesIfNeeded());
  }

  String targetTutorialPrefKey = ""; // This will be set in onInit when we have the user ID and profile type
  final int currentTutorialVersion = 1; // Increment this when tutorial content changes to show it again

  @override
  Future<void> onInit() async {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);

    // Preload airports into local Isar cache (offline picker/search).
    // This is intentionally done at app start so CreateTrip pickers are instant.
    unawaited(_preloadAirports());

    // If you want to auto-seed after login (matching old initState condition),
    // call getCode() from wherever you know `fkMembershipId` and flags.
    // Example:
    // if ((Get.arguments?['fromSign'] == true || Get.arguments?['fromotp'] == true) && fkMembershipId.value == '1') {
    //   getCode();
    // }
    prefs = await SharedPreferences.getInstance();
    selectedProfileType.value = prefs.getInt(PrefKeys.selectedProfileType) ?? 0;

    // Central refresh: profile header + trips
    await refreshForSelectedProfile();

    registerNotification();

    // final basicProfile = await fetchBasicProfileForCurrentRole();
    //   photoUrl.value = basicProfile?.photoPath ?? '';
    //   isCurrentProfileDisabled.value = basicProfile?.isDisabled ?? false;
    // await _refreshForSelectedProfile();

    getCode();
  }

  Future<void> computeTutorialPrefKeyAndShowTutorial() async {
    // Get current logged-in user
    final currentUser = await ParseUser.currentUser() as ParseUser?;

    if (currentUser != null) {

      // Get _User class objectId
      String? userId = currentUser.objectId;

      debugPrint('DashboardController: User with email ${currentUser.emailAddress} and ID $userId is logged in');

      if (userId != null){
        targetTutorialPrefKey = "${userId}_${selectedProfileType.value}${PrefKeys.tutorialVersion}";

        debugPrint('DashboardController: Computed tutorial pref key: $targetTutorialPrefKey');

        //check if latest tutorial version is already seen
        if ((prefs.getInt(targetTutorialPrefKey) ?? 0) < currentTutorialVersion){
          //showTutorial
          show();
        } else { 
          debugPrint('DashboardController: Tutorial already shown for pref key $targetTutorialPrefKey.');
        }
      } else {
        debugPrint('DashboardController: Current user has no objectId; cannot determine tutorial state.');
      }

    } else {
      debugPrint('DashboardController: No user logged in');
    }
  }

  /// Preload airports into local Isar cache (offline picker/search).
  /// This is intentionally done at app start so CreateTrip pickers are instant.
  ///
  /// The AirportCache service itself handles one-time schema-version resets,
  /// seeding when empty, and throttled delta sync. Keeping that logic in the
  /// service avoids manual/commented-out wipes in controller code.
  Future<void> _preloadAirports() async {
    try {
      debugPrint('[Airports] preload START');

      const PAGE_SIZE = 50000;

      await AirportCache.instance.prepareCache(
        pageSize: PAGE_SIZE,
        minDeltaSyncInterval: const Duration(days: 30),
      );

      debugPrint('[Airports] preload END');
    } catch (e) {
      debugPrint('[Airports] preload ERROR: $e');
    }
  }
  
  /// Updates the top-left avatar URL shown in the dashboard header.
  ///
  /// This is used after profile refresh/switch flows so the header image stays
  /// in sync with the currently selected profile.
  void updatePhoto(String url) {
    photoUrl.value = url;
  }

  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  Map<String, dynamic> payload = <String, dynamic>{};

  void registerNotification() async {

    // iOS permission prompt (safe on Android too; it will just no-op)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
      return;
    }

    await messaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);

    messaging.getToken().then((value) async {
      if (value == null) return;
      try {
        final installation = await ParseInstallation.currentInstallation();
        installation.deviceToken = value;
        await installation.save();
        debugPrint("this is the device token: $value");
      } catch (e) {
        debugPrint("Failed to save Parse installation: $e");
      }
    });

    messaging.onTokenRefresh.listen((value) async {
      try {
        final installation = await ParseInstallation.currentInstallation();
        installation.deviceToken = value;
        await installation.save();
      } catch (e) {
        debugPrint("Failed to refresh Parse token: $e");
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      if (message.notification != null &&
          message.notification?.android != null) {
        LocalNotificationService().showNotifications(
            code: message.hashCode,
            title: message.notification!.title!,
            body: message.notification!.body!,
            payload: jsonEncode(message.data));
      }
    });

    //TODO:

    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   setState(() {
    //     payload = message.data;
    //   });
    // });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // LocalNotificationService().streamPayload.listen((data) {
    //   setState(() {
    //     payload = data;
    //   });
    // });
  }

  Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint("Handling a background message");

    //Todo:
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );

    if (message.notification != null) {
      LocalNotificationService().showNotifications(
          code: message.hashCode,
          title: message.notification!.title!,
          body: message.notification!.body!,
          payload: jsonEncode(message.data));
    }
  }

  Future<ProfileSummary?> fetchBasicProfileForCurrentRole() async {
    if (useMock) {
      return ProfileSummary(
        membershipType: selectedProfileType.value,
        firstName: "John",
        lastName: "Doe",
        photoPath: "https://i.pravatar.cc/150?u=${selectedProfileType.value}",
        isDisabled: false,
        currentLocation: selectedProfileType.value == 3,
        objectId: "mock_id_${selectedProfileType.value}",
      );
    }

    // If no role is selected (0), we cannot call the function meaningfully
    if (selectedProfileType.value == 0) {
      // You can choose to throw, return null, or handle differently
      return null;
    }

    // Prepare the Parse Cloud Function
    final function = ParseCloudFunction('getBasicProfileByMembershipType');

    // Execute with parameters
    final ParseResponse response = await function.execute(
      parameters: <String, dynamic>{
        'membershipType': selectedProfileType.value,
      },
    );

    if (!response.success || response.result == null) {
      // Log or handle failure
      // response.error?.message may contain server-side message
      return null;
    }

    // Expected result shape:
    // {
    //   "success": true,
    //   "message": "Profile fetched successfully.",
    //   "data": { membershipType, firstName, lastName, photoPath }
    // }

    final Map<String, dynamic> resultMap =
        Map<String, dynamic>.from(response.result as Map);

    final bool success = resultMap['success'] == true;
    if (!success) {
      // For example when "Profile not found for this membership type."
      return null;
    }

    final dynamic dataRaw = resultMap['data'];
    if (dataRaw == null) {
      return null;
    }

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(dataRaw as Map);

    // Build and return a ProfileSummary object
    return ProfileSummary.fromJson(data);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('[Location][foreground] AppLifecycleState changed: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_restartLocationUpdatesIfNeeded());
        unawaited(refreshTopBarLocationWarningState());
        debugPrint('[Location][foreground] App resumed; attempting best-effort location sync.');
        unawaited(_syncLocationOnAppResumeIfNeeded());
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _stopLocationTimer(reason: 'app moved out of foreground: $state');
        break;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    searchController.dispose();
    _stopLocationTimer(reason: 'controller disposed');
    super.onClose();
  }

  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = <TargetFocus>[];
  TutorialCoachMark? tutorialCoachMark2;
  List<TargetFocus> targets2 = <TargetFocus>[];
  // These are just references; actual keys are created in DashboardScreen
  GlobalKey? key1; // used for Profile tab target
  GlobalKey? key2; // used for Manage Availability target

  showtutorial() {
    debugPrint("inside showtutorial");
    initTarget();
    // initTargetOwner();
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.transparent,
      opacityShadow: 0.8,
      textSkip: "SKIP",
      textStyleSkip: TextStyle(color: AppColor.secondaryColor1),
      paddingFocus: 10,
      onFinish: () {
        debugPrint('tutorial1 finished');
        showtutorial2();
      },
      onSkip: () {
        debugPrint('on press skip of tutorial 1');
        showtutorial2();
        return true;
      },
    )..show(context: Get.context!);
    // initDynamicLinks();
  }

  showtutorial2() {

    //store the tutorial seen version
    prefs.setInt(targetTutorialPrefKey, 1);

    initTarget2();
    // initTargetOwner();
    tutorialCoachMark2 = TutorialCoachMark(
      targets: targets2,
      colorShadow: Colors.transparent,
      opacityShadow: 0.8,
      textSkip: "SKIP",
      textStyleSkip: TextStyle(color: AppColor.secondaryColor1),
      paddingFocus: 10,
      onFinish: () {
        debugPrint('tutorial2 finished');
        // initDynamicLinks();
      },
      onSkip: () {
        debugPrint('on press skip of tutorial 2');
        return true;
        // initDynamicLinks();
      },
    )..show(context: Get.context!);
    // initDynamicLinks();
  }

  initTarget() {
    targets.add(TargetFocus(
      identify: "Target 1",
      keyTarget: key1,
      contents: [
        TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Profile",
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.secondaryColor1, fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Go to Profile and fill in the requested information." /*\nYou will need to select if you are an Pilot, or flight attendant\n(This selection cannot be changed once saved)"*/,
                    style: TextStyle(color: AppColor.textColor1),
                  ),
                )
              ],
            ))
      ],
      shape: ShapeLightFocus.Circle,
      enableTargetTab: true,
    ));
  }

  initTarget2() {
    targets2.add(TargetFocus(
        identify: "Target 2",
        keyTarget: key2,
        contents: [
          
          TargetContent(
              align: ContentAlign.bottom,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Manage Availability",
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.secondaryColor1, fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "\nAfter your profile is complete, make sure to manage your availability.\nThis will allow you to populate in all searches you are available for.",
                      /*so you will populate in all searches you are available for*/
                      style: TextStyle(color: AppColor.textColor1),
                    ),
                  )
                ],
              ))
        ],
        enableTargetTab: true));
  }

  show(){
    debugPrint("inside show");
    Future.delayed(Duration(seconds: 1), showtutorial);
    // kIsFirstLoginTime ? Future.delayed(Duration(seconds: 2), showtutorial) : null;
  }


    /// Load all profiles for the current user from the cloud function
    /// `getAllProfilesForCurrentUser` and update [switchList].
    ///
    /// Also sets [selectedRadio] so that the currently selected item is the one
    /// whose `membershipType` equals [selectedProfileType].
    Future<void> loadProfilesForCurrentUser() async {
      if (useMock) {
        switchList.assignAll([
          ProfileSummary(
            membershipType: 1,
            firstName: "John",
            lastName: "Doe (Owner)",
            photoPath: "https://i.pravatar.cc/150?u=owner",
            isDisabled: false,
            currentLocation: false,
            objectId: "mock_owner_id",
          ),
          ProfileSummary(
            membershipType: 3,
            firstName: "John",
            lastName: "Doe (Pilot)",
            photoPath: "https://i.pravatar.cc/150?u=pilot",
            isDisabled: false,
            currentLocation: true,
            objectId: "mock_pilot_id",
          ),
          ProfileSummary(
            membershipType: 4,
            firstName: "John",
            lastName: "Doe (Attendant)",
            photoPath: "https://i.pravatar.cc/150?u=attendant",
            isDisabled: false,
            currentLocation: true,
            objectId: "mock_fa_id",
          ),
        ]);
        final int idx = switchList.indexWhere(
          (p) => p.membershipType == selectedProfileType.value,
        );
        selectedRadio.value = idx != -1 ? idx : 0;
        return;
      }
      try {
        final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
        if (currentUser == null) {
          debugPrint('loadProfilesForCurrentUser: no current user');
          switchList.clear();
          return;
        }

        final function = ParseCloudFunction('getAllProfilesForCurrentUser');
        final ParseResponse response = await function.execute();

        if (!response.success || response.result == null) {
          debugPrint('loadProfilesForCurrentUser: cloud function failed: ${response.error?.message}');
          switchList.clear();
          return;
        }

        final Map<String, dynamic> resultMap =
            Map<String, dynamic>.from(response.result as Map);

        final bool success = resultMap['success'] == true;
        if (!success) {
          debugPrint('loadProfilesForCurrentUser: success == false, message = ${resultMap['message']}');
          switchList.clear();
          return;
        }

        final List<dynamic> dataList = (resultMap['data'] as List<dynamic>? ?? const <dynamic>[]);
        final List<ProfileSummary> profiles = dataList
            .map((item) => ProfileSummary.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();

        switchList.assignAll(profiles);

        if (profiles.isEmpty) {
          selectedRadio.value = 0;
          return;
        }

        // Select the profile whose membershipType == selectedProfileType
        final int idx = profiles.indexWhere(
          (p) => p.membershipType == selectedProfileType.value,
        );

        if (idx != -1) {
          selectedRadio.value = idx;
        } else {
          // Fallback: first item
          selectedRadio.value = 0;
        }

        debugPrint(
            'loadProfilesForCurrentUser: loaded ${profiles.length} profiles; selectedRadio=${selectedRadio.value}');
      } catch (e) {
        debugPrint('loadProfilesForCurrentUser error: $e');
        switchList.clear();
      }
    }


  /// Called when user taps "SWITCH ACCOUNT" in the dialog.
  /// Updates the selected profile type, persists it to SharedPreferences,
  /// and refreshes header state (photo, etc.) for the newly selected profile.
  Future<void> onSwitchAccountPressed(BuildContext context) async {
    debugPrint('SWITCH ACCOUNT pressed; selected index = ${selectedRadio.value}');

    if (switchList.isEmpty) {
      await showMyDialog(
        Get.context!,
        'No profiles available to switch.',
      );
      return;
    }

    // Clamp the selected index to be safe
    final int safeIndex = selectedRadio.value.clamp(0, switchList.length - 1);
    final ProfileSummary selected = switchList[safeIndex];

    // Update in-memory selected profile type from the chosen profile
    selectedProfileType.value = selected.membershipType;
    debugPrint('Switching to membershipType=${selectedProfileType.value}');

    final NavigatorState navigator = Navigator.of(context);
    isDialogLoading.value = true;
    try {
      // Persist the selected profile type so it survives app restarts
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(PrefKeys.selectedProfileType, selectedProfileType.value);
        debugPrint('Saved selectedProfileType=${selectedProfileType.value} to SharedPreferences');
      } catch (e) {
        debugPrint('Error saving selectedProfileType to SharedPreferences: $e');
      }

      // Refresh any state that depends on the selected profile (photo, etc.).
      await refreshForSelectedProfile();

      // Switch back to Home tab
      selectTab(0);
      
    } finally {
      if (navigator.mounted && navigator.canPop()) {
        navigator.pop();
      }
      isDialogLoading.value = false;
    }
  }

  // Call this when you want to completely reset the Home tab
// void resetHomeTabControllers() {
//   // Delete each sub-controller; `force: true` is needed because they are permanent.
//   //We delete the sub-controllers so that their next Get.put call in HomeScreen.build creates fresh instances and triggers onInit() again.
//   if (Get.isRegistered<CurrentController>()) {
//     Get.delete<CurrentController>(force: true);
//   }
//   if (Get.isRegistered<FutureTripsController>()) {
//     Get.delete<FutureTripsController>(force: true);
//   }
//   if (Get.isRegistered<HistoryController>()) {
//     Get.delete<HistoryController>(force: true);
//   }
//   if (Get.isRegistered<PendingController>()) {
//     Get.delete<PendingController>(force: true);
//   }
//   if (Get.isRegistered<UncrewedController>()) {
//     Get.delete<UncrewedController>(force: true);
//   }
//   if (Get.isRegistered<DraftController>()) {
//     Get.delete<DraftController>(force: true);
//   }

//   // Optional: also reset any state in HomeController itself
//   if (Get.isRegistered<HomeController>()) {
//     final home = Get.find<HomeController>();
//     // home.reloadForProfileChange(); // if you created such a method
//   }

//   // Finally bump the bodyReloadToken so Dashboard's Obx rebuilds,
//   // which rebuilds HomeScreen and re-creates the controllers.
//   // bodyReloadToken.value++;
// }

  /// If the user switches account, keep Home on a tab that is valid for the role.
  void _ensureValidHomeTabForRole() {
    try {
      if (!Get.isRegistered<HomeController>()) return;
      final home = Get.find<HomeController>();

      if (home.currentPage.value != 0) {
        debugPrint('resetting HomeController to Current (0)');
        home.selectTab(0);
      }
    } catch (e) {
      debugPrint('_ensureValidHomeTabForRole error: $e');
    }
  }

  /// Refresh dashboard state that depends on [selectedProfileType].
  /// Currently:
  ///  - Re-fetches the basic profile for the selected role
  ///  - Updates the header avatar photo
  ///  - Loads owner trips (current/future/history) when role is Owner
  Future<void> refreshForSelectedProfile() async {
    try {
      final basicProfile = await fetchBasicProfileForCurrentRole();
      photoUrl.value = basicProfile?.photoPath ?? '';
      isCurrentProfileDisabled.value = basicProfile?.isDisabled ?? false;
      selectedProfileId = basicProfile?.objectId;

      // Gate location updates via profile config
      isLocationEnabledForProfile.value = basicProfile?.currentLocation ?? false;

      // Persist this per selected profile type so app lifecycle/background entry
      // points can later decide whether location sync is allowed even when the
      // DashboardController is not in memory.
      await prefs.setBool(
        'locationEnabled_${selectedProfileType.value}',
        isLocationEnabledForProfile.value,
      );

      // Start/stop timer based on the profile flag plus the silent OS permission gate.
      await _restartLocationUpdatesIfNeeded();

      // Update top-bar heart/warning icon for the selected profile.
      await refreshTopBarLocationWarningState();

      // Optional immediate foreground sync, but only when the feature is enabled
      // and usable permission already exists. Never request permission from here.
      if (isLocationEnabledForProfile.value) {
        final bool hasPermission = await _hasUsableLocationPermissionForCurrentLocationFeature();
        if (hasPermission) {
          updateMyLocationToParse(
            locationSource: LocationSyncService.sourceForeground,
          );
        } else {
          debugPrint('[Location][foreground] Immediate sync skipped because usable location permission is not available.');
        }
      }

      // Load trips for owner (or clear lists when non-owner)
      await loadTrips();
      _ensureValidHomeTabForRole();
      // resetHomeTabControllers();
      // 👇 force the Expanded section to rebuild
      // reloadBody();
      debugPrint('Dashboard refreshed for profileType=${selectedProfileType.value}, profileId=$selectedProfileId, photo=${photoUrl.value}');

      await computeTutorialPrefKeyAndShowTutorial();

    } catch (e) {
      debugPrint('_refreshForSelectedProfile error: $e');
    }
  }

  /// Load trips for the current profile using the getOwnerTrips / getPilotTrips cloud function.
  ///
  /// - Populates [this.currentTrips], [this.futureTrips], [this.historyTrips], [this.pendingTrips], [this.draftTrips].
  Future<void> loadTrips() async {
    if (useMock) {
      isLoadingTrips.value = true;
      await Future.delayed(const Duration(milliseconds: 500));
      final mockTrip = TripModel(
        objectId: "trip1",
        tripName: "NYC to LA Mission",
        isCaptain: true,
        captain: "John Doe",
        isSIC: false,
        sic: "",
        isAttendant: false,
        attendant: "",
        isInstructor: false,
        instructor: "",
        pilotRate: 1500,
        sicRate: null,
        attendantRate: null,
        instructorRate: null,
        departureSourceId: 1,
        destinationSourceId: 2,
        enrouteSourceIds: [],
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 2)),
        aircraft: "Gulfstream G650",
        requirementsUrl: null,
        isStarted: false,
        isCompleted: false,
        isVoid: false,
        isRead: false,
        isDirect: true,
        radius: 100,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      currentTrips.assignAll([mockTrip]);
      currentBadgeCount.value = 1;
      futureTrips.clear();
      historyTrips.clear();
      pendingTrips.clear();
      draftTrips.clear();
      uncrewedTrips.clear();

      isLoadingTrips.value = false;
      return;
    }

    if (selectedProfileType.value != MembershipType.ownerOperator && selectedProfileType.value != MembershipType.pilot
        && selectedProfileType.value != MembershipType.flightAttendant) {
      currentTrips.clear();
      futureTrips.clear();
      historyTrips.clear();
      pendingTrips.clear();
      draftTrips.clear();
      uncrewedTrips.clear();

      currentBadgeCount.value = 0;
      futureBadgeCount.value = 0;
      historyBadgeCount.value = 0;
      pendingBadgeCount.value = 0;
      draftBadgeCount.value = 0;

      loadTripsError.value = null;
      return;
    }

    isLoadingTrips.value = true;
    loadTripsError.value = null;

    try {
      // Make sure a user is logged in
      final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        this.currentTrips.clear();
        this.futureTrips.clear();
        this.historyTrips.clear();
        this.pendingTrips.clear();
        this.draftTrips.clear();
        this.uncrewedTrips.clear();

        currentBadgeCount.value = 0;
        futureBadgeCount.value = 0;
        historyBadgeCount.value = 0;
        pendingBadgeCount.value = 0;
        draftBadgeCount.value = 0;

        loadTripsError.value = 'Not logged in.';
        return;
      }

      String cloudFunctionName = 'getOwnerTrips';

      if (selectedProfileType.value == MembershipType.pilot){
        cloudFunctionName = 'getPilotTrips';
      } else if (selectedProfileType.value == MembershipType.flightAttendant){
        cloudFunctionName = 'getAttendantTrips';
      }

      // Call the cloud function
      final function = ParseCloudFunction(cloudFunctionName);
      final ParseResponse response = await function.execute();

      if (!response.success || response.result == null) {
        this.currentTrips.clear();
        this.futureTrips.clear();
        this.historyTrips.clear();
        this.pendingTrips.clear();
        this.draftTrips.clear();

        currentBadgeCount.value = 0;
        futureBadgeCount.value = 0;
        historyBadgeCount.value = 0;
        pendingBadgeCount.value = 0;
        draftBadgeCount.value = 0;

        loadTripsError.value =
            response.error?.message ?? 'Failed to fetch trips from server.';
        return;
      }

      // Expected shape (new):
      // {
      //   "current": { "items": [...], "badgeCount": 0 },
      //   "future":  { "items": [...], "badgeCount": 0 },
      //   "history": { "items": [...], "badgeCount": 0 },
      //   "pending": { "items": [...], "badgeCount": 0 },
      //   "draft":   { "items": [...], "badgeCount": 0 }
      // }
      final Map<String, dynamic> resultMap =
          Map<String, dynamic>.from(response.result as Map);

      Map<String, dynamic> _bucket(String key) {
        final raw = resultMap[key];
        if (raw is Map) {
          return Map<String, dynamic>.from(raw);
        }
        // Backward compatibility (if server ever returns a plain list)
        if (raw is List) {
          return <String, dynamic>{"items": raw, "badgeCount": 0};
        }
        return <String, dynamic>{"items": const <dynamic>[], "badgeCount": 0};
      }

      List<TripModel> _parseTripsFromBucket(Map<String, dynamic> bucket) {
        final List<dynamic> items = (bucket['items'] as List<dynamic>? ?? const <dynamic>[]);
        return items
            .whereType<Map>()
            .map((e) => TripModel.fromJson(e.cast<String, dynamic>()))
            .toList();
      }

      int _badgeCountFromBucket(Map<String, dynamic> bucket) {
        final raw = bucket['badgeCount'];
        if (raw is int) return raw;
        if (raw is num) return raw.toInt();
        return 0;
      }

      final currentBucket = _bucket('current');
      final futureBucket = _bucket('future');
      final historyBucket = _bucket('history');
      final pendingBucket = _bucket('pending');
      final draftBucket = _bucket('draft');

      final List<TripModel> currentTrips = _parseTripsFromBucket(currentBucket);
      final List<TripModel> futureTrips = _parseTripsFromBucket(futureBucket);
      final List<TripModel> historyTrips = _parseTripsFromBucket(historyBucket);
      final List<TripModel> pendingTrips = _parseTripsFromBucket(pendingBucket);
      final List<TripModel> draftTrips = _parseTripsFromBucket(draftBucket);

      currentBadgeCount.value = _badgeCountFromBucket(currentBucket);
      futureBadgeCount.value = _badgeCountFromBucket(futureBucket);
      historyBadgeCount.value = _badgeCountFromBucket(historyBucket);
      pendingBadgeCount.value = _badgeCountFromBucket(pendingBucket);
      draftBadgeCount.value = _badgeCountFromBucket(draftBucket);

      // Update reactive lists (this will notify all listening controllers)
      this.currentTrips
        ..clear()
        ..addAll(currentTrips);

      this.futureTrips
        ..clear()
        ..addAll(futureTrips);

      this.historyTrips
        ..clear()
        ..addAll(historyTrips);

      this.pendingTrips
        ..clear()
        ..addAll(pendingTrips);

      this.draftTrips
        ..clear()
        ..addAll(draftTrips);

      debugPrint(
          'loadTrips: current=${currentTrips.length} (badge=${currentBadgeCount.value}), '
          'future=${futureTrips.length} (badge=${futureBadgeCount.value}), '
          'history=${historyTrips.length} (badge=${historyBadgeCount.value}), '
          'pending=${pendingTrips.length} (badge=${pendingBadgeCount.value}), '
          'draft=${draftTrips.length} (badge=${draftBadgeCount.value})');
    } catch (e) {
      loadTripsError.value = e.toString();
      this.currentTrips.clear();
      this.futureTrips.clear();
      this.historyTrips.clear();
      this.pendingTrips.clear();
      this.draftTrips.clear();

      currentBadgeCount.value = 0;
      futureBadgeCount.value = 0;
      historyBadgeCount.value = 0;
      pendingBadgeCount.value = 0;
      draftBadgeCount.value = 0;

      debugPrint('loadTrips error: $e');
    } finally {
      isLoadingTrips.value = false;
    }
  }

  //To be used by any other screen to return to dashboard and reload trips
  void goBackToDashboardAndReloadTrips() {
    debugPrint('goBackToDashboardAndReloadTrips: called, navigating back to Dashboard and reloading trips.');
    // If dashboard exists in stack, pop until it.
    // This keeps the existing DashboardController instance alive.
    Get.until((route) => route.settings.name == AppRoutes.dashboard);

    if (Get.isRegistered<TripDraftFlowService>()) {
      debugPrint('goBackToDashboardAndReloadTrips: clearing TripDraftFlowService');
      Get.delete<TripDraftFlowService>(force: true);
    }

    debugPrint('goBackToDashboardAndReloadTrips: returned to Dashboard, now reloading trips.');
    //Refresh dashboard trips
    loadTrips();
  }

  void goBackToDashboardHomeTabAndReloadTrips() {
    goBackToDashboardAndReloadTrips();
    selectTab(0);
  }

  /// Called when user taps "ADD ACCOUNT".
  /// Shows a dialog listing the profile types the user does NOT yet have.
  /// After selection, calls a cloud function to create that profile.
  Future<void> onAddAccountPressed(BuildContext context) async {
    debugPrint('ADD ACCOUNT pressed');

    // Determine which membershipTypes are missing for this user.
    const Set<int> allTypes = {1, 3, 4}; // Removed 2 (Instructor temporarily)
    final Set<int> existingTypes = switchList
        .map((p) => p.membershipType)
        .whereType<int>()
        .toSet();

    final List<int> missingTypes =
        allTypes.difference(existingTypes).toList()..sort();

    if (missingTypes.isEmpty) {
      debugPrint(
          'onAddAccountPressed: no missing profile types (button should be hidden).');
      return;
    }

    int? selectedType = missingTypes.first;

    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColor.bgColor2,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          content: StatefulBuilder(
            builder: (ctx, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Profile',
                    style: TextStyle(
                      fontSize: 12.spV2,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textColor1,
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  ...missingTypes.map((type) {
                    return Theme(
                      data: ThemeData(
                        unselectedWidgetColor: AppColor.secondaryColor2, // <-- FIX
                      ),
                      child: RadioListTile<int>(
                        value: type,
                        groupValue: selectedType,
                        activeColor: AppColor.secondaryColor1, // selected color
                        title: Text(
                          membershipLabelFromType(type),
                          style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1),
                        ),
                        onChanged: (int? value) {
                          if (value == null) return;
                          setState(() {
                            selectedType = value;
                          });
                        },
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 1.5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 10.spV2,
                            color: AppColor.secondaryColor1,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (selectedType == null) {
                            Navigator.pop(ctx);
                            return;
                          }
                          Navigator.pop(ctx); // close picker
                          await _createProfileForTypeAndReload(
                              selectedType!, context);
                        },
                        child: Text(
                          'Create',
                          style: TextStyle(
                            fontSize: 10.spV2,
                            color: AppColor.secondaryColor1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// Helper: call a cloud function to create the requested profile type
  /// for the current user, then refresh the local profile list.
  ///
  /// Expects a cloud function named `createProfileForMembershipType` that
  /// accepts `{ "membershipType": <int> }` and returns a JSON payload:
  /// { "success": true/false, "message": "...", "data": { ... } }
  Future<void> _createProfileForTypeAndReload(
      int membershipType, BuildContext context) async {
        debugPrint("_createProfileForTypeAndReload called for type $membershipType");
    isDialogLoading.value = true;
    try {
      final function = ParseCloudFunction('createProfileForMembershipType');
      final ParseResponse response = await function.execute(
        parameters: <String, dynamic>{
          'membershipType': membershipType,
        },
      );

      if (!response.success || response.result == null) {
        debugPrint(
            'createProfileForMembershipType failed: ${response.error?.message}');
        await showMyDialog(Get.context!, 'createProfileForMembershipType failed: ${response.error?.message}');
        return;
      }

      final Map<String, dynamic> resultMap =
          Map<String, dynamic>.from(response.result as Map);

      final bool success = resultMap['success'] == true;
      if (!success) {
        debugPrint(
            'createProfileForMembershipType returned success=false, message=${resultMap['message']}');
        await showMyDialog(Get.context!, 'createProfileForMembershipType failed: ${resultMap['message']}');
        return;
      }

      // Refresh profiles in dialog
      await loadProfilesForCurrentUser();
    } catch (e) {
      debugPrint('_createProfileForTypeAndReload error: $e');
    } finally {
      isDialogLoading.value = false;
    }
  }

  /// Called when user taps "SIGN OUT".
  /// For now we hook this into the existing Parse logout flow.
  Future<void> onSignOutPressed(BuildContext context) async {
    debugPrint('SIGN OUT pressed');

    // Simple version: reuse your existing Parse logout logic.
    // If you still need per-"account" sign out semantics,
    // you can port the legacy logic here.
    askLogoutConfirm();
    // await doUserLogout();
    // Navigator.of(context).pop(); // close the dialog
  }

  /// Called when user taps "DISABLE/ENABLE ACCOUNT".
  /// Shows a Cupertino-style confirmation dialog and then calls
  /// either `disableProfileByMembershipType` or
  /// `enableProfileByMembershipType` based on [isDisabled].
  void onDeleteAccountPressed(BuildContext context, {required bool isDisabled}) {
    debugPrint('DISABLE/ENABLE ACCOUNT pressed; isDisabled=$isDisabled');

    // Dialog text changes depending on whether the selected profile is
    // currently disabled or not.
    final String title = isDisabled ? 'Enable Account' : 'Disable Account';
    final String message = isDisabled
        ? 'This will enable your profile for this role.\nAre you sure?'
        : 'This will disable your profile for this role.\nAre you sure?';

    final Widget cancelButton = TextButton(
      child: Text(
        'No',
        style: TextStyle(color: AppColor.secondaryColor1),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    final Widget yesButton = TextButton(
      child: Text(
        'Yes',
        style: TextStyle(
          color: isDisabled
              ? Colors.green   // When enabling → GREEN
              : Colors.red,    // When disabling → RED
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () async {
        // Close the confirm dialog first
        Navigator.pop(context);

        if (switchList.isEmpty) {
          await showMyDialog(Get.context!, 'No profile selected.');
          return;
        }

        final ProfileSummary selectedProfile = switchList[
          selectedRadio.value.clamp(0, switchList.length - 1)
        ];
        final int membershipType = selectedProfile.membershipType;

        final String functionName = isDisabled
            ? 'enableProfileByMembershipType'
            : 'disableProfileByMembershipType';
        final String actionVerb = isDisabled ? 'enable' : 'disable';

        try {
          final function = ParseCloudFunction(functionName);
          final ParseResponse response = await function.execute(
            parameters: <String, dynamic>{ 'membershipType': membershipType },
          );

          if (!response.success || response.result == null) {
            await showMyDialog(
              Get.context!,
              'Failed to $actionVerb profile: ${response.error?.message ?? 'Unknown error'}',
            );
            return;
          }

          final Map<String, dynamic> resultMap =
              Map<String, dynamic>.from(response.result as Map);
          final bool success = resultMap['success'] == true;

          if (!success) {
            await showMyDialog(
              Get.context!,
              resultMap['message']?.toString() ??
                  'Failed to $actionVerb profile.',
            );
            return;
          }

          await showMyDialog(
            Get.context!,
            isDisabled
                ? 'Profile enabled successfully.'
                : 'Profile disabled successfully.',
          );

          // Refresh any state that depends on the selected profile (photo, etc.).
          await refreshForSelectedProfile();

          await loadProfilesForCurrentUser();
        } catch (e) {
          await showMyDialog(
            Get.context!,
            'Error trying to $actionVerb profile: $e',
          );
        }
      },
    );

    final Widget alert = Theme(
      data: ThemeData.dark(),
      child: CupertinoAlertDialog(
        content: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(message),
          ],
        ),
        actions: [
          cancelButton,
          yesButton,
        ],
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return alert;
      },
    );
  }

  /// Show the "Switch / Add / Sign Out / Delete Account" dialog.
  /// This is a GetX refactor of the legacy `showLoginDilog` function.
  Future<void> showLoginDialog({int initialIndex = 0}) async {
    // Use the current GetX context instead of passing BuildContext around
    final BuildContext? context = Get.context;
    if (context == null) {
      debugPrint('showLoginDialog called but Get.context is null');
      return;
    }

    // Set loading ON and clear list so dialog shows loader immediately
    isDialogLoading.value = true;
    switchList.clear();
    
    // await loadProfilesForCurrentUser();
    // Hide loading indicator after fetching profiles
    // isDialogLoading.value = false;

    // If caller passes an explicit index, we respect it as an override.
    selectedRadio.value = initialIndex;

    // IMPORTANT: start loading AFTER the dialog is scheduled
    Future.microtask(() async {
      try {
        await loadProfilesForCurrentUser();
      } catch (e) {
        debugPrint('showLoginDialog loadProfiles error: $e');
      } finally {
        isDialogLoading.value = false;
      }
    });

    await showDialog(
      context: context,
      builder: (dialogCtx) {
        // Preserve legacy sizing based on MediaQuery
        final double height = MediaQuery.of(dialogCtx).size.height * 0.8;
        final double width = MediaQuery.of(dialogCtx).size.width;

        return AlertDialog(
          backgroundColor: AppColor.bgColor2,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          content: SizedBox(
            height: height,
            width: width,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // ===== top row: close button + store logo =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                        },
                        icon: Icon(
                          Icons.clear,
                          size: 30.0.spV2, // not a font; keep .sp
                          color: AppColor.secondaryColor2,
                        ),
                      ),
                      
                      const SizedBox.shrink(),
                    ],
                  ),

                  SizedBox(height: 2.0.h),

                  // ===== account list / loading =====
                  Obx(() {
                    if (isDialogLoading.value) {
                      return SizedBox(
                        height: 50.0.h,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              LoadingAnimationWidget.threeRotatingDots(
                                color: AppColor.secondaryColor1,
                                size: 50.spV2,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  color: AppColor.textColor1,
                                  fontSize: 10.spV2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 50.0.h,
                      child: ListView.builder(
                        itemCount: switchList.length,
                        itemBuilder: (ctx, index) {
                          final ProfileSummary item = switchList[index];

                          final String photo = item.photoPath;
                          final String fullName =
                              '${item.firstName} ${item.lastName}'.trim();
                          final String membershipLabel =
                              membershipLabelFromType(item.membershipType);

                          // NEW: faded look for disabled profiles
                          final bool isDisabled = item.isDisabled;
                          final double alpha = isDisabled ? 0.4 : 1.0;

                          return GestureDetector(
                            onTap: () {
                              debugPrint("selected $index");
                              // Allow selecting the profile by tapping anywhere on the row
                              selectedRadio.value = index;
                            },
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Avatar + name
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundColor:
                                                AppColor.secondaryColor1.withOpacity(alpha),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(30),
                                              child: SizedBox(
                                                height: 60.0.sp,
                                                width: 60.0.sp,
                                                child: photo.isEmpty
                                                    ? CircleAvatar(
                                                        backgroundColor: AppColor.secondaryColor1
                                                            .withOpacity(alpha),
                                                        child: Icon(
                                                          Icons.account_circle,
                                                          size: 60,
                                                          color: AppColor.bgColor1,
                                                        ),
                                                      )
                                                    : Opacity(
                                                        // Fade only the image when disabled
                                                        opacity: alpha,
                                                        child: Image.network(
                                                          photo,
                                                          fit: BoxFit.fill,
                                                          height: 4.h,
                                                          width: 4.w,
                                                          loadingBuilder: (
                                                            BuildContext context,
                                                            Widget child,
                                                            ImageChunkEvent? loadingProgress,
                                                          ) {
                                                            if (loadingProgress == null) {
                                                              return child;
                                                            }
                                                            return Center(
                                                              child: CircularProgressIndicator(
                                                                color: AppColor.bgColor1,
                                                                value: loadingProgress
                                                                            .expectedTotalBytes !=
                                                                        null
                                                                    ? loadingProgress
                                                                            .cumulativeBytesLoaded /
                                                                        loadingProgress
                                                                            .expectedTotalBytes!
                                                                    : null,
                                                              ),
                                                            );
                                                          },
                                                          errorBuilder: (
                                                            BuildContext context,
                                                            Object exception,
                                                            StackTrace? stackTrace,
                                                          ) {
                                                            return CircleAvatar(
                                                              backgroundColor: AppColor.secondaryColor1
                                                                  .withOpacity(alpha),
                                                              child: Icon(
                                                                Icons.account_circle,
                                                                size: 60,
                                                                color: AppColor.bgColor1,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 25.w,
                                                child: Text(
                                                  fullName,
                                                  overflow: TextOverflow.fade,
                                                  softWrap: false,
                                                  style: TextStyle(
                                                    color: AppColor.textColor1.withOpacity(alpha),
                                                    fontSize: 12.0.spV2,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                membershipLabel,
                                                style: TextStyle(
                                                  color:
                                                      AppColor.secondaryColor2.withOpacity(alpha),
                                                  fontSize: 10.0.spV2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Radio button
                                    Theme(
                                      data: ThemeData(
                                        unselectedWidgetColor:
                                            AppColor.secondaryColor2.withOpacity(alpha),
                                      ),
                                      child: Obx(() {
                                        final int currentSelected = selectedRadio.value;
                                        return Radio<int>(
                                          value: index,
                                          groupValue: currentSelected,
                                          activeColor:
                                              AppColor.secondaryColor1.withOpacity(alpha),
                                          focusColor:
                                              AppColor.secondaryColor2.withOpacity(alpha),
                                          onChanged: (int? val) {
                                            if (val == null) return;
                                            selectedRadio.value = val;
                                          },
                                        );
                                      }),
                                    ),
                                  ],
                                ),

                                // Divider logic
                                if (switchList.length == 1)
                                  const Divider()
                                else if (switchList.length - 1 == index)
                                  const Divider()
                                else
                                  Divider(
                                    color: AppColor.secondaryColor2.withOpacity(alpha),
                                    thickness: 2,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    );


                  }),

                  // ===== Action buttons hidden while loading =====
                  Obx(() {
                    if (isDialogLoading.value) {
                      return const SizedBox.shrink();
                    }

                    final bool canAddAccount = !hasAllProfiles;
                    final bool hasProfiles = switchList.isNotEmpty;

                    ProfileSummary? selected;
                    if (hasProfiles) {
                      final int safeIndex = selectedRadio.value
                          .clamp(0, switchList.length - 1)
                          .toInt();
                      selected = switchList[safeIndex];
                    }

                    final bool isDisabled = selected?.isDisabled ?? false;
                    final String label =
                        isDisabled ? 'ENABLE ACCOUNT' : 'DISABLE ACCOUNT';
                    final Color stateColor =
                        isDisabled ? Colors.green : AppColor.deleteColor;

                    return Column(
                      children: [
                        MaterialButton(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          minWidth: 50.0.w,
                          textColor: AppColor.secondaryColor3,
                          color: AppColor.secondaryColor3.withAlpha(50),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: AppColor.secondaryColor3.withAlpha(50),
                              width: 0.6.w,
                            ),
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                          onPressed: () => onSwitchAccountPressed(dialogCtx),
                          child: Text(
                            "SWITCH ACCOUNT",
                            style: TextStyle(fontSize: 10.0.spV2),
                          ),
                        ),
                        if (canAddAccount)
                          MaterialButton(
                            minWidth: 50.0.w,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            textColor: AppColor.secondaryColor3,
                            color: AppColor.secondaryColor3.withAlpha(50),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: AppColor.secondaryColor3.withAlpha(50),
                                width: 0.6.w,
                              ),
                              borderRadius: BorderRadius.circular(2.w),
                            ),
                            onPressed: () => onAddAccountPressed(dialogCtx),
                            child: Text(
                              "ADD ACCOUNT",
                              style: TextStyle(fontSize: 10.0.spV2),
                            ),
                          ),
                        MaterialButton(
                          minWidth: 50.0.w,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          textColor: AppColor.textColor3,
                          color: AppColor.textColor3.withAlpha(50),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: AppColor.textColor3.withAlpha(50),
                              width: 0.6.w,
                            ),
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                          onPressed: () => onSignOutPressed(dialogCtx),
                          child: Text(
                            "SIGN OUT",
                            style: TextStyle(fontSize: 10.0.spV2),
                          ),
                        ),
                        if (hasProfiles)
                          MaterialButton(
                            minWidth: 50.0.w,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            textColor: stateColor,
                            color: stateColor.withAlpha(50),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: stateColor.withAlpha(50),
                                width: 0.6.w,
                              ),
                              borderRadius: BorderRadius.circular(2.w),
                            ),
                            onPressed: () {
                              onDeleteAccountPressed(
                                dialogCtx,
                                isDisabled: isDisabled,
                              );
                            },
                            child: Text(
                              label,
                              style: TextStyle(fontSize: 10.0.spV2),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    ); //showDialog ends here

    // If dialog closes while still loading, ensure state is reset
    isDialogLoading.value = false;
  }

  /// Thin wrapper kept on the controller for now so existing call sites do not
  /// need to change immediately. The actual location sync logic now lives in
  /// [LocationSyncService], which can later be reused by app lifecycle and
  /// background entry points.
  Future<void> updateMyLocationToParse({
    // Minimum distance moved before saving again (in metres)
    double minDistanceM = 100,
    // Minimum time gap before saving again
    Duration minInterval = const Duration(seconds: 30),
    // When true, a save is allowed once [minInterval] has elapsed even if the
    // distance moved is still below [minDistanceM].
    bool allowTimeOnlyFallback = true,
    String locationSource = LocationSyncService.sourceForeground,
  }) async {
    await LocationSyncService.instance.syncCurrentUserLocation(
      minDistanceM: minDistanceM,
      minInterval: minInterval,
      allowTimeOnlyFallback: allowTimeOnlyFallback,
      locationSource: locationSource,
    );
  }

}
