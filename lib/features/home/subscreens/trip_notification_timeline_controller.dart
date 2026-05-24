import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/model/owner_trip_detail_models.dart';
import 'package:crew_support/model/trip_notification.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class TripNotificationTimelineController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxnString title = RxnString();
  final Rxn<OwnerTripDetailResponse> tripDetails = Rxn<OwnerTripDetailResponse>();
  final RxList<TripNotification> notifications = <TripNotification>[].obs;

  late final TripCrewMemberModel crewMember;

  // final RxnInt pilotId = RxnInt();
  final RxnString pilotName = RxnString();

  late final DashboardController dash;

  bool? fromFutureCurrent;

  @override
  void onInit() async {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    tripDetails.value = args['tripDetails'] as OwnerTripDetailResponse?;
    crewMember = args['member'] as TripCrewMemberModel;
    fromFutureCurrent = (args['fromFutureCurrent']) as bool;
    title.value = tripDetails.value?.trip.tripName;

    dash = Get.find<DashboardController>();

    // pilotId.value = args['pilotId'] is int ? args['pilotId'] as int : int.tryParse(args['pilotId']?.toString() ?? '');
    // pilotName.value = args['pilotName']?.toString();

    // Load notifications from cloud function
    await _loadNotificationsFromCloud();

    isLoading.value = false;
  }

  /// Loads notifications for the given trip from Parse Cloud Function:
  /// `getPilotTripNotifications(tripId)`
  Future<void> _loadNotificationsFromCloud() async {
    final tid = tripDetails.value?.trip.objectId ; 
    if (tid == null || tid.isEmpty) {
      // No tripId to query
      notifications.clear();
      return;
    }

    try {

      String functionName = 'getPilotTripNotifications';
      Map<String, dynamic> parameters = {
        'tripId': tid,
      };

      if (dash.selectedProfileType.value == MembershipType.ownerOperator){
        functionName = 'getOwnerTripNotifications';

        parameters = {
          'tripId': tid,
          'membershipType': crewMember.membershipType,
          'profileClass': crewMember.profileClass,
          'profileId': crewMember.profileId
        };
      } else if (dash.selectedProfileType.value == MembershipType.flightAttendant){
        functionName = 'getAttendantTripNotifications';
      }

      final fn = ParseCloudFunction(functionName);
      final resp = await fn.execute(parameters: parameters);

      if (!resp.success) {
        // Keep UI stable; just show empty list.
        notifications.clear();
        return;
      }

      final result = resp.result;
      if (result is List) {
        final parsed = result
            .whereType<Map>()
            .map((e) => TripNotification.fromJson(
                Map<String, dynamic>.from(e)))
            .toList();

        notifications.assignAll(parsed);
      } else {
        notifications.clear();
      }
    } catch (_) {
      notifications.clear();
    }
  }
}