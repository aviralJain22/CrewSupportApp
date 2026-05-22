import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/helper/user_helper.dart';
import 'package:crew_support/model/trip_model.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:crew_support/model/owner_trip_detail_models.dart';

class TripCrewOverviewController extends GetxController {
  /// Trip detail payload from Back4App cloud function: getOwnerTripDetail
  final Rxn<OwnerTripDetailResponse> tripDetails = Rxn<OwnerTripDetailResponse>();

  /// Convenience list for UI
  final RxList<TripCrewMemberModel> crewList = <TripCrewMemberModel>[].obs;

  /// AppBar title (trip name)
  final RxString title = ''.obs;

  /// Loader flag
  final RxBool isLoading = true.obs;

  /// Current date string
  late final String now;

  /// Selected member designations for this trip
  final RxList<String> selectedMembers = <String>[].obs;

  /// Whether this is a direct trip (IsDirectTrip)
  final RxBool isDirectTrip = false.obs;

  /// Live / local app type for Firebase paths
  final dynamic appType = UserHelper().getAppType();

  late String tripId;

  bool? fromFutureCurrent;

  TripModel? tripModel; //For Add Crew flow, to pass to Select Profile screen

  @override
  void onInit() {
    super.onInit();

    now = DateFormat("yyyy-MM-dd").format(DateTime.now());

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    tripId = (args['tripId']) as String;
    fromFutureCurrent = (args['fromFutureCurrent']) as bool;
    tripModel = (args['trip']) as TripModel?;
    debugPrint("tripCrewOverviewController - tripId: $tripId");
    debugPrint("tripCrewOverviewController - fromFutureCurrent: $fromFutureCurrent");
    debugPrint("tripCrewOverviewController - tripModel: $tripModel");
    _fetchData();
    _markAsRead();
  }

  /// Loads trip + crew from Back4App (Parse Cloud Function: getOwnerTripDetail)
  Future<void> _fetchData() async {
    try {
      isLoading.value = true;

      // Reset state each time
      tripDetails.value = null;
      crewList.clear();
      selectedMembers.clear();
      title.value = '';

      String functionName = 'getOwnerTripDetail';

      final dash = Get.find<DashboardController>();
      if (dash.selectedProfileType.value == MembershipType.pilot){
              functionName = 'getPilotTripDetail';
      } else if (dash.selectedProfileType.value == MembershipType.flightAttendant){
              functionName = 'getAttendantTripDetail';
      }

      debugPrint('TripCrewOverviewController: calling $functionName for tripId=$tripId');

      // Call Parse Cloud Function
      final result = await ParseCloudFunction(functionName).execute(
        parameters: {
          'tripId': tripId,
        },
      );

      if (result.success != true) {
        // Parse SDK includes error details in `result.error`
        final msg = result.error?.message ?? 'Unknown error';
        throw Exception('getOwnerTripDetail failed: $msg');
      }

      final raw = result.result;
      if (raw is! Map) {
        throw Exception('getOwnerTripDetail returned unexpected payload: ${raw.runtimeType}');
      }

      final parsed = OwnerTripDetailResponse.fromJson(raw.cast<String, dynamic>());

      // Store and expose to UI
      tripDetails.value = parsed;
      crewList.assignAll(parsed.crewList);

      // AppBar title
      title.value = parsed.trip.tripName;

      // For old "Add Crew" visibility checks
      selectedMembers.assignAll(parsed.crewList.map((e) => e.roleLabel));

      debugPrint('selectedMembers for tripId=$tripId: ${selectedMembers.join(', ')}');

      // Direct trip flag (kept for future usage)
      isDirectTrip.value = parsed.trip.isDirect;

      debugPrint('TripCrewOverviewController: loaded crewList length=${crewList.length}');
    } catch (e) {
      debugPrint('Error in _fetchData (TripCrewOverviewController): $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Marks this trip as read for the logged-in user.
  ///
  /// - If the user is Owner/Operator:
  ///   Calls cloud function `setOwnerTripReadFlag` (needs ownerProfileId + tripId)
  /// - Otherwise:
  ///   Calls cloud function `setCrewTripReadFlag` (needs tripId only)
  ///
  /// This matches the legacy MySQL procedure where owners updated `tripmaster.IsRead`
  /// while crew updated `tripoperationmaster.IsRead`.
  Future<void> _markAsRead() async {
    try {
      final dash = Get.find<DashboardController>();
      final bool isOwner =
          dash.selectedProfileType.value == MembershipType.ownerOperator;

      debugPrint(
        'TripCrewOverviewController._markAsRead: tripId=$tripId, isOwner=$isOwner',
      );

      if (isOwner) {
        // Owner: trip.isRead
        final res = await ParseCloudFunction('setOwnerTripReadFlag').execute(
          parameters: {
            'isRead': true,
            'tripId': tripId,
          },
        );

        if (res.success != true) {
          final msg = res.error?.message ?? 'Unknown error';
          throw Exception('setOwnerTripReadFlag failed: $msg');
        }

        debugPrint('TripCrewOverviewController._markAsRead: owner trip marked read.');
      } else {
        // Crew: tripOperation.isRead for the logged in _User
        final res = await ParseCloudFunction('setCrewTripReadFlag').execute(
          parameters: {
            'isRead': true,
            'tripId': tripId,
            'membershipType': dash.selectedProfileType.value,
          },
        );

        if (res.success != true) {
          final msg = res.error?.message ?? 'Unknown error';
          throw Exception('setCrewTripReadFlag failed: $msg');
        }

        debugPrint('TripCrewOverviewController._markAsRead: crew trip marked read.');
      }
    } catch (e) {
      debugPrint('Error in _markAsRead (TripCrewOverviewController): $e');
    }
  }

  void openCrewProfile(TripCrewMemberModel member) {
    final String profileId = member.profileId.trim();

    if (profileId.isEmpty) {
      debugPrint(
        'TripCrewOverviewScreen: profile open blocked because profileId is empty for userId=${member.userId}, membershipType=${member.membershipType}',
      );
      Get.snackbar(
        'Unable to open profile',
        'This crew member\'s profile is not available yet.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    debugPrint(
      'TripCrewOverviewScreen: opening profile for profileId=$profileId, membershipType=${member.membershipType}',
    );

    if (member.membershipType == MembershipType.ownerOperator) {
      Get.toNamed(
        AppRoutes.ownerViewProfile,
        arguments: {
          'profileId': profileId,
        },
      );
    } else if (member.membershipType == MembershipType.pilot ||
        member.membershipType == 5 ) {
      Get.toNamed(
        AppRoutes.pilotViewProfile,
        arguments: {
          'profileId': profileId,
        },
      );
    } else if (member.membershipType == MembershipType.flightAttendant) {
      Get.toNamed(
        AppRoutes.fAViewProfile,
        arguments: {
          'profileId': profileId,
        },
      );
    } else {
      debugPrint(
        'TripCrewOverviewScreen: unsupported membershipType for profile navigation: ${member.membershipType}',
      );
      Get.snackbar(
        'Unable to open profile',
        'Profile screen is not available for this crew type yet.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }


  /// Public method so the UI can refresh after navigation returns.
  Future<void> reload() async {
    await _fetchData();
  }
}