import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/features/trip/trip_draft_flow_service.dart';
import 'package:crew_support/features/trip/trip_draft_save_service.dart';
import 'package:crew_support/model/crew_list_item.dart';
import 'package:crew_support/model/trip_draft_payload.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crew_support/Api/Api_service.dart';
import 'package:crew_support/helper/user_helper.dart';
import 'package:crew_support/model/TripDetailsResponse.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'dart:async';

class ResultFAController extends GetxController implements DraftCommitter {
  // ---------- Incoming arguments (from Get.arguments) ----------
  // Mirror the old widget fields 1:1 to preserve logic
  late final List<String> selectList;
  // Data? filterData;
  late final List<CrewListItem> filterData;
  dynamic rate;
  late final String tripId;
  late final int airCraftID;
  late final String miles;

  late final bool hideProfilePicture;
  late final bool hideGender;
  late final bool boolFI;
  late final bool boolCAP;
  late final bool boolSIC;
  late final bool boolFA;

  late final int flag;
  bool? isTripOutOfDate;
  String? startDate;
  String? endDate;
  String? oldCrewMemberId;
  String? membershipId;

  // ---------- Local state ----------
  final RxList<String> pilotChecked = <String>[].obs;
  final RxBool stopClicking = false.obs;
  final RxBool backButton = false.obs;
  TripDetailsData? tripDetails;

  final appType = UserHelper().getAppType();

  // Exposed for view
  bool get isOutOfDate => (isTripOutOfDate ?? false);

  late final TripDraftFlowService _flow;
  late final TripDraftSaveService _saveService;
  TripDraftPayload get draft => _flow.draft.value;
  bool get isFromAddCrew => _flow.isFromAddCrew;

  // ---------- Lifecycle ----------
  @override
  void onInit() {
    super.onInit();

    debugPrint('ResultFAController._readArguments - Get.arguments: ${Get.arguments}');

    // Read all args in one go; keys must match what you pass during navigation.
    final args = Get.arguments as Map<String, dynamic>? ?? {};

    selectList      = (args['selectList'] as List<dynamic>?)?.cast<String>() ?? <String>[];
    // filterData      = args['filterData'] as Data?;
    filterData      = args['filterData'] as List<CrewListItem>;
    rate            = args['rate'];
    tripId          = args['tripId']?.toString() ?? '';
    airCraftID      = args['airCraftID'] as int? ?? 0;
    miles           = args['miles']?.toString() ?? '';

    hideProfilePicture     = args['hideProfilePicture'] as bool? ?? false;
    hideGender      = args['hideGender'] as bool? ?? false;
    boolFI          = args['boolFI'] as bool? ?? false;
    boolCAP         = args['boolCAP'] as bool? ?? false;
    boolSIC         = args['boolSIC'] as bool? ?? false;
    boolFA          = args['boolFA'] as bool? ?? false;

    flag            = args['flag'] as int? ?? 0;
    isTripOutOfDate = args['isTripOutOfDate'] as bool?;
    startDate       = args['startDate'] as String?;
    endDate         = args['endDate'] as String?;
    oldCrewMemberId = args['oldCrewMemberId'] as String?;
    membershipId    = args['membershipId'] as String?;

    // Legacy pending fetch (side-effect)
    // Keeping it here to mimic old didChangeDependencies flow
    // _warmPendingDetails();

    debugPrint('selectMembers = $selectList');
    debugPrint('membershipId = $membershipId');
    debugPrint("Miles $miles");

    _flow = Get.find<TripDraftFlowService>();
    _saveService = TripDraftSaveService(_flow);

    debugPrint("draft in ResultFAController: ${draft.toJson()}");
  }

  @override
  void commitToDraft() {
  }

  // ---------- UI handlers ----------
  void onSelectAttendant(bool selected, String id) {
    if (selected) {
      if (!pilotChecked.contains(id)) {
        pilotChecked.add(id);
      }
    } else {
      pilotChecked.remove(id);
    }
  }

  // ---------- Actions mirroring old button flows ----------

  /// Bottom main button: "Send Trip Request" / "Search for Next" paths (isTripOutOfDate == false branch)
  Future<void> handlePrimaryActionWhenInDate({
    required bool isCreateTrip,
  }) async {

    if (!isFromAddCrew){
      if ((filterData.isEmpty) && boolFI == true) {
        // if ((filterData?.fa.isEmpty ?? true) && boolFI == true) {
          // When FA empty and FI is next in flow
          if (boolFI == true) {
            // Navigate to RequiredExperience FI (v1/v2) by isCreateTrip
            if (isCreateTrip) {
              // Get.toNamed(AppRoutes.requiredExperienceFI, arguments: {...})
              Get.offNamed(
                // TODO: replace with your route name
                '/required_experience_fi',
                arguments: {
                  'radiusValue': miles,
                  'selectList': selectList,
                  'tripId': tripId,
                  'airCraftID': airCraftID,
                  'backbutton': backButton.value,
                },
              );
            } else {
              Get.offNamed(
                // TODO: replace with your route name
                '/required_experience_fi_v2',
                arguments: {
                  'radiusValue': miles,
                  'selectList': selectList,
                  'tripId': tripId,
                  'airCraftID': airCraftID,
                  'backbutton': backButton.value,
                },
              );
            }
          } else {
            // Back to home
            Get.offAllNamed('/home'); // TODO: use your actual landing owner route
          }
          return;
        }
    }

    
    // Else => actually send notifications (requires at least one selection)
    if (pilotChecked.isEmpty) {
      stopClicking.value = true;
      await showMyDialog(Get.context!, "Please select flight attendant");
      stopClicking.value = false;
      return;
    }

    stopClicking.value = true;

    if (draft.tripObjectId == null || draft.tripObjectId!.isEmpty) {
      debugPrint('Draft trip has no objectId, so saving trip first (ResultFAController)');
    } else {
      debugPrint('Draft trip already has objectId ${draft.tripObjectId}, probably from Draft tab or Add Crew, saving and sending trip request (ResultFAController)');
    }

    final ctx = Get.context!;

    showLoadingDialog(ctx, 'Saving Trip...');
    try {
      await _saveService.saveDraft(committer: this);

      Navigator.pop(ctx); // close loading dialog
      debugPrint(
        'Trip saved successfully, now sending trip request (ResultFAController)',
      );
    } catch (e) {
      debugPrint(
        'Error saving trip draft before sending (ResultFAController): $e',
      );
      Navigator.pop(ctx); // close loading dialog
      showMyDialog(ctx, e.toString());
      // Re-enable bottom bar button
      stopClicking.value = false;
      return;
    }

    // -------------------------------
    // Back4App-based flow (same as ResultSICController.handlePrimaryActionCreate):
    // Create tripOperation / notifications via `insertTripOperation` for each
    // selected flight attendant profile.
    // -------------------------------
    debugPrint('[ResultFA] handlePrimaryActionWhenInDate START');
    debugPrint('[ResultFA] tripId=${draft.tripObjectId}, airCraftID=$airCraftID, miles=$miles, boolFI=$boolFI');
    debugPrint('[ResultFA] selected FA count = ${pilotChecked.length}');
    debugPrint('[ResultFA] selected FA ids = ${pilotChecked.toList()}');
    
    // IMPORTANT: do NOT await the loading dialog, otherwise execution pauses
    // until the dialog is dismissed.
    showLoadingDialog(Get.context!, "Sending...");
    debugPrint('[ResultFA] Loading dialog shown, starting cloud calls...');

    try {
      for (final crewProfileId in pilotChecked) {
        final params = <String, dynamic>{
          'tripId': draft.tripObjectId,
          'crewProfileId': crewProfileId,
          'membershipType': MembershipType.flightAttendant, // 4 = Flight Attendant in our mapping
          'crewRole': 'Flight Attendant', // used only for notification text
          'isEdit': false,
          'fromAddCrew': isFromAddCrew,
          // Intentionally not sending startDate/endDate/rate here.
        };

        debugPrint('[ResultFA] insertTripOperation -> start for crewProfileId=$crewProfileId');
        debugPrint('[ResultFA] params: $params');

        final function = ParseCloudFunction('insertTripOperation');

        ParseResponse response;
        try {
          response = await function
              .execute(parameters: params)
              .timeout(const Duration(seconds: 30));
        } on TimeoutException catch (_) {
          debugPrint('[ResultFA] insertTripOperation TIMEOUT for crewProfileId=$crewProfileId');
          throw Exception('Request timed out while sending trip request. Please try again.');
        }

        debugPrint('[ResultFA] insertTripOperation -> done for crewProfileId=$crewProfileId');
        debugPrint('[ResultFA] success=${response.success}, error=${response.error?.message}, result=${response.result}');

        if (!response.success) {
          final errorMessage = response.error?.message ?? 'Failed to send trip request.';
          throw Exception(errorMessage);
        }
      }

      debugPrint('[ResultFA] All insertTripOperation calls completed successfully.');
      // Close loader
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      await showMyDialog(Get.context!, "Trip Request Sent");
      backButton.value = true;
    } catch (e) {
      debugPrint('[ResultFA] ERROR: $e');
      // Close loader on error
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      await showMyDialog(Get.context!, e.toString());
      rethrow;
    } finally {
      debugPrint('[ResultFA] handlePrimaryActionWhenInDate END');
      stopClicking.value = false;
    }


    // After success -> decide next screen

    if (isFromAddCrew){
      // If we came from Add Crew, always go back to Dashboard after sending, no matter the role.
      Get.find<DashboardController>().goBackToDashboardAndReloadTrips();
      return;
    }

    if (boolFI == true) {
      // Continue to FI step
      Get.offNamed(
        AppRoutes.requiredExperienceFI,
        arguments: {
          'miles': miles,
          'selectList': selectList,
          'tripId': draft.tripObjectId!,
          'airCraftID': airCraftID,
          'boolFI': boolFI,
          'startDate': startDate,
          'endDate': endDate,
      // 'ratingAirCraftType': ratingAirCraftType,
          'backbutton': true,
        },
      );
    } else {
      // Finish to home
      Get.find<DashboardController>().goBackToDashboardAndReloadTrips();
    }
  }

  /// Bottom main button: Out-of-Date branch (isTripOutOfDate == true in old code)
  Future<void> handlePrimaryActionOutOfDateFlow() async {
    // If FA empty but FI present in selection -> redirect to SearchByFIScreen
    // final faEmpty = (filterData?.fa.isEmpty ?? true);
    final faEmpty = (filterData.isEmpty);
    final hasFI = selectList.contains("Flight Instructor") || selectList.contains("Instructor");

    if (faEmpty && selectList.contains("Flight Attendant") && hasFI) {
      // Load trip detail then go search FI
      await _openSearchByFIForOutOfDate();
      return;
    }

    // Else: send notification (edit=true path)
    if (pilotChecked.isEmpty) {
      stopClicking.value = true;
      await showMyDialog(Get.context!, "Please select flight attendant");
      stopClicking.value = false;
      return;
    }

    await _sendTripRequestAndFanOutCounts(
      isEdit: true,
      oldCrewMemberId: oldCrewMemberId,
      membershipId: membershipId,
      startDate: startDate,
      endDate: endDate,
    );

    // After success, if FI next, open SearchByFIScreen with isTripOutOfDate=true; else go home
    final nextHasFI = hasFI;
    if (nextHasFI) {
      await _openSearchByFIForOutOfDate();
    } else {
      Get.offAllNamed('/home'); // TODO
    }
  }

  Future<void> _openSearchByFIForOutOfDate() async {
    // Mirrors the legacy: fetch trip detail -> push SearchByFIScreen with flags
    // showLoadingDialog(Get.context!, "Please Wait...");
    // try {
    //   if (tripId != 0) {
    //     final td = await getTripDetail(tripId: tripId, pilotId: pkPilotId.toString());
    //     final tripList = td?.data?.trip ?? <TripDetails>[];
    //     if (tripList.isEmpty) {
    //       // No trip found, fallback home (legacy did this)
    //       Get.back(); // close loading
    //       Get.offAllNamed('/home'); // TODO
    //       return;
    //     }
    //     final t = tripList.first;

    //     Get.back(); // close loading
    //     Get.toNamed(
    //       // TODO: replace with your SearchByFIScreen route
    //       '/search_by_fi',
    //       arguments: {
    //         'startDate': startDate,
    //         'endDate': endDate,
    //         'selectList': selectList,
    //         'tripId': t.pkTripId,
    //         'ratingCount': int.tryParse(t.ratingCount) ?? 0,
    //         'rate': t.fiRate.round().toString(),
    //         'radiusValue': t.radius,
    //         'airCraftID': t.fkAircraftId,
    //         'complexTime': t.complexTimeReqr,
    //         'highTime': t.highPerfomanceTime,
    //         'daulGiven': t.timeOfInstruct,
    //         'aerobatic': t.acrobaticsInstructor?.toString(),
    //         'multiEngine': t.mulEngInstructor?.toString(),
    //         'tailWheel': t.tailWheelInsrtuctor?.toString(),
    //         'instrumentInstruct': t.instrumentInstructor?.toString(),
    //         'totalTime': t.totalTimeInstructor,
    //         'isTripOutOfDate': true,
    //       },
    //     );
    //   } else {
    //     Get.back(); // close loading
    //     Get.offAllNamed('/home'); // TODO
    //   }
    // } catch (e) {
    //   Get.back(); // close loading if error
    //   log('SearchByFI (out-of-date) error: $e');
    //   Get.offAllNamed('/home'); // fallback similar to legacy
    // }
  }

  /// Delete Draft flow (Cupertino dialog is in the view; this completes the action)
  Future<void> deleteDraftTrip() async {
    showLoadingDialog(Get.context!, "Deleting...");
    try {
      await deleteDraft(tripId);
      Get.back(); // close loading
      await showMyDialog(Get.context!, 'Trip deleted successfully');
      Get.offAllNamed('/home'); // TODO: landing owner screen
    } catch (e) {
      Get.back();
      await showMyDialog(Get.context!, 'Failed to delete trip');
    }
  }

  // ---------- Core send-notification + Firestore counters ----------
  Future<void> _sendTripRequestAndFanOutCounts({
    required bool isEdit,
    String? oldCrewMemberId,
    String? membershipId,
    String? startDate,
    String? endDate,
  }) async {
    // UX guards
    // stopClicking.value = true;
    // showLoadingDialog(Get.context!, "Sending...");

    // try {
    //   final filterIds = pilotChecked.join(",");
    //   final resp = await sendNotification(
    //     SICNumber: "",
    //     filterPilotId: filterIds,
    //     tripId: tripId,
    //     rate: rate,
    //     isEdit: isEdit,
    //     oldCrewMemberId: oldCrewMemberId,
    //     membershipId: membershipId,
    //     startDate: startDate,
    //     endDate: endDate,
    //   );

    //   // Update trip notification per selected pilot (legacy behavior)
    //   for (final pid in pilotChecked) {
    //     // final multi = await getTripDetailMultiplePilot(
    //     //   MemberType: "Pilot",
    //     //   tripId: tripId,
    //     //   oppositeId: pid,
    //     // );
    //     // tripDetails = multi?.data;

    //     final notifId = tripDetails?.summary.first.pkTripNotificationId.toString();
    //     if (notifId != null) {
    //       await updateTripNotification(TripId: tripId, NotificationId: notifId);
    //     }

    //     // Firestore counters (mirror legacy fan-out)
    //     await _incPendingCountForUser(pid.toString());
    //     await _ensureTripCountDoc('${pid} - $pkPilotId', 1); // notificationCount += 1
    //     await _ensureTripCountDoc('$pkPilotId - ${pid}', 0); // ensure mirror doc exists with 0
    //   }

    //   // Also bump current user's pendingCount
    //   await _incPendingCountForUser(pkPilotId.toString());

    //   Get.back(); // close "Sending..."
    //   await showMyDialog(Get.context!, resp?.msg ?? "Sent.");
    //   backButton.value = true;
    // } catch (e) {
    //   Get.back(); // close "Sending..."
    //   await showMyDialog(Get.context!, "Failed to send. Please try again.");
    //   log('sendTripRequest error: $e');
    // } finally {
    //   stopClicking.value = false;
    // }
  }

  // Future<void> _incPendingCountForUser(String userId) async {
    //TODO:
    // final usersCol = (appType.toString() == 'live')
    //     ? AppStrings.fireBaseUserlive
    //     : AppStrings.fireBaseUserlocal;

    // await FirebaseFirestore.instance
    //     .collection(usersCol)
    //     .doc(userId)
    //     .update({'pendingCount': FieldValue.increment(1)});
  // }

  // Future<void> _ensureTripCountDoc(String docId, int incrementToApply) async {
    //TODO:
  //   final tripsCol = (appType.toString() == 'live')
  //       ? AppStrings.fireBaseTripslive
  //       : AppStrings.fireBaseTripslocal;

  //   final docTrip = FirebaseFirestore.instance
  //       .collection(tripsCol)
  //       .doc('$tripId')
  //       .collection('tripCount')
  //       .doc(docId);

  //   final snap = await docTrip.get();
  //   if (snap.exists) {
  //     await docTrip.update({'notificationCount': FieldValue.increment(incrementToApply)});
  //   } else {
  //     await docTrip.set({'notificationCount': incrementToApply});
  //   }
  // }
}


class ResultFABinding extends Bindings {
  @override
  void dependencies() {
    // Avoid reusing a stale controller instance when navigating to this route
    // multiple times with different arguments.
    if (Get.isRegistered<ResultFAController>()) {
      Get.delete<ResultFAController>(force: true);
    }

    Get.put<ResultFAController>(ResultFAController());
  }
}