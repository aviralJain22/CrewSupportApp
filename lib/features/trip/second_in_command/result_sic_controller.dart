import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/features/trip/trip_draft_flow_service.dart';
import 'package:crew_support/features/trip/trip_draft_save_service.dart';
import 'package:crew_support/model/crew_list_item.dart';
import 'package:crew_support/model/trip_draft_payload.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crew_support/helper/user_helper.dart';
import 'package:crew_support/model/TripDetailsResponse.dart';
import 'package:crew_support/utils/constants.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Arguments container used when navigating to ResultSICScreen via named route.
/// Pass this object as Get.arguments.
class ResultSICArgs {
  final List<String> selectList;
  final List<CrewListItem> filterData;
  // final SICData? filterData;
  final String tripId;
  final bool boolFI;
  final bool boolFA;
  final bool boolSIC;
  final bool boolCAP;
  final String miles;
  final String rate;
  final String ratingAirCraftType;
  final int airCraftID;
  final bool? isTripOutOfDate;
  final String? startDate;
  final String? endDate;
  final String? oldCrewMemberId;
  final String? membershipId;
  final String? totalTime;
  final String? totalTimeType;
  // final String? picTimeType;
  // final String? picTime;
  final String? medicalClass;
  final int? rating;
  final bool? validPassport;
  final String? ratingType;
  final String? continentExp;
  // final String? oceanicExp;
  final bool? monthTraining;

  ResultSICArgs({
    required this.selectList,
    required this.filterData,
    required this.tripId,
    required this.boolFI,
    required this.boolFA,
    required this.boolSIC,
    required this.boolCAP,
    required this.miles,
    required this.rate,
    required this.ratingAirCraftType,
    required this.airCraftID,
    this.isTripOutOfDate,
    this.startDate,
    this.endDate,
    this.oldCrewMemberId,
    this.membershipId,
    this.totalTime,
    this.totalTimeType,
    this.medicalClass,
    this.rating,
    this.validPassport,
    this.ratingType,
    this.continentExp,
    this.monthTraining,
  });
}

/// GetX Controller for "Results - SIC" screen.
/// Mirrors the original state & logic but exposes observables for the UI.
class ResultSICController extends GetxController implements DraftCommitter {
  // ====== Input args ======
  late final List<String> selectList;
  // SICData? filterData;
  late List<CrewListItem> filterData;
  late final String tripId;
  late final bool boolFI;
  late final bool boolFA;
  late final bool boolSIC;
  late final bool boolCAP;
  late final String miles;
  late final dynamic rate;
  late final int airCraftID;
  late final String ratingAirCraftType;
  bool? isTripOutOfDate;
  String? startDate;
  String? endDate;
  String? oldCrewMemberId;
  String? membershipId;
  late final String? totalTime;
  late final String? totalTimeType;
  // late final String? picTimeType;
  // late final String? picTime;
  late final String? medicalClass;
  late final int? rating;
  late final bool? validPassport;
  late final String? ratingType;
  late final String? continentExp;
  // late final String? oceanicExp;
  late final bool? monthTraining;

  // ====== UI / state ======
  final isLoading = false.obs;
  final pilotChecked = <String>[].obs;
  final stopClicking = false.obs;
  final backButtonLocked = false
      .obs; // when true, back is disabled (same behavior as old 'backbutton')

  TripDetailsData? tripDetails;
  final appType = UserHelper().getAppType(); // 'live' or other
  bool? _fromPendingCached;

  bool get fromPendingComputed => _fromPendingCached ?? fromPending;

  late final TripDraftFlowService _flow;
  late final TripDraftSaveService _saveService;
  TripDraftPayload get draft => _flow.draft.value;
  bool get isFromAddCrew => _flow.isFromAddCrew;

  @override
  void onInit() {
    super.onInit();

    debugPrint('ResultSICController._readArguments - Get.arguments: ${Get.arguments}');

    // Pull arguments
    final args = Get.arguments;
    if (args is ResultSICArgs) {
      selectList = args.selectList;
      filterData = args.filterData;
      tripId = args.tripId;
      boolFI = args.boolFI;
      boolFA = args.boolFA;
      boolSIC = args.boolSIC;
      boolCAP = args.boolCAP;
      miles = args.miles;
      rate = args.rate;
      airCraftID = args.airCraftID;
      isTripOutOfDate = args.isTripOutOfDate ?? false;
      startDate = args.startDate;
      endDate = args.endDate;
      oldCrewMemberId = args.oldCrewMemberId;
      membershipId = args.membershipId;
      ratingAirCraftType = args.ratingAirCraftType;
      totalTime = args.totalTime;
      totalTimeType = args.totalTimeType;
      medicalClass = args.medicalClass;
      rating = args.rating;
      validPassport = args.validPassport;
      ratingType = args.ratingType;
      continentExp = args.continentExp;
      monthTraining = args.monthTraining;
    } else {
      // Fallback for Map or partial usage
      final m = (args ?? {}) as Map;
      selectList = (m['selectList'] as List?)?.cast<String>() ?? const [];
      // filterData = m['filterData'] as SICData?;
      filterData = m['filterData'] as List<CrewListItem>;
      tripId = m['tripId'] as String? ?? "";
      boolFI = m['boolFI'] as bool? ?? false;
      boolFA = m['boolFA'] as bool? ?? false;
      boolSIC = m['boolSIC'] as bool? ?? false;
      boolCAP = m['boolCAP'] as bool? ?? false;
      miles = m['miles']?.toString() ?? '0';
      rate = m['rate'];
      airCraftID = m['airCraftID'] as int? ?? 0;
      isTripOutOfDate = m['isTripOutOfDate'] as bool? ?? false;
      startDate = m['startDate'] as String?;
      endDate = m['endDate'] as String?;
      oldCrewMemberId = m['oldCrewMemberId'] as String?;
      membershipId = m['membershipId'] as String?;
      ratingAirCraftType = args['ratingAirCraftType'] as String;
      totalTime = (args['totalTime'] ?? '').toString();
      totalTimeType = (args['totalTimeType'] ?? '').toString();
      // picTimeType: (args['picTimeType'] ?? '').toString();
      // picTime: (args['picTime'] ?? '').toString();
      medicalClass = (args['medicalClass'] ?? '').toString();
      rating = int.tryParse((args['rating'] ?? 0).toString()) ?? 0;
      validPassport = (args['validPassport'] ?? false) as bool;
      ratingType = (args['ratingType'] ?? '').toString();
      continentExp = (args['continentExp'] ?? '').toString();
      // oceanicExp = (args['oceanicExp'] ?? '').toString();
      monthTraining = (args['monthTraining'] ?? false) as bool;
    }

    // Log to match legacy prints
    debugPrint('selectMembers = $selectList');
    debugPrint('membershipId = $membershipId');
    debugPrint("Miles $miles");

    // Eagerly update 'fromPending' mirror (legacy global) once deps are ready
    _initPendingFlag();

    _flow = Get.find<TripDraftFlowService>();
    _saveService = TripDraftSaveService(_flow);

    debugPrint("draft in ResultSICController: ${draft.toJson()}");
  }

  @override
  void commitToDraft() {
  }

  Future<void> _initPendingFlag() async {
    await UserHelper().getPendingDetail();
    // mirrors: print("++++++$fromPending");
    print("++++++$fromPending");
    _fromPendingCached = fromPending;
    update(); // for GetBuilder if used anywhere
  }

  // Toggle selection of a pilot id
  void onSelected(bool selected, String id) {
    if (selected) {
      if (!pilotChecked.contains(id)) {
        pilotChecked.add(id);
      }
    } else {
      pilotChecked.remove(id);
    }
  }

  void goBackToDashboardAndReloadTrips() {
    Get.find<DashboardController>().goBackToDashboardAndReloadTrips();
  }

  // === Main "Send Trip Request" / "Search For Next" actions (two flows) ===

  /// Flow for CREATE (isEdit == false in legacy) – called when `isTripOutOfDate == false` branch
  
  /// Back4App-based flow: Send Trip Request for selected SICs.
  ///
  /// When we land on this screen, the trip has already been created
  /// in the create_trip_controller and its objectId is passed in as [tripId].
  ///
  /// So here we *only* need to:
  ///  - create the SIC-side tripOperation / tripNotification / tripRecentActivity
  ///    via the `insertTripOperation` cloud function.
  ///  - we do NOT touch trip dates or rates here; they are already stored on `trip`.
  Future<void> handlePrimaryActionCreate(
      {required void Function() showLoading,
      required void Function() hideLoading,
      required Future<void> Function(String message) showDialog}) async {
    // if (filterData == null) return;

    // If no SIC found but FA/FI is next, jump ahead
    // if (filterData!.sic.isEmpty && (boolFA || boolFI)) {

    if (!isFromAddCrew) {
      if (filterData.isEmpty && (boolFA || boolFI)) {
        if (boolFA) {
          // push RequiredExperienceFAScreen or v2 based on isCreateTrip
          if (isCreateTrip == true) {
            Get.offNamed(
              AppRoutes.requiredExperienceFA,
              arguments: {
                'radiusValue': miles,
                'selectList': selectList,
                'tripId': tripId,
                'airCraftID': airCraftID,
                'boolFI': boolFI,
              },
            );
          } else {
            Get.offNamed(
              AppRoutes.requiredExperienceFA,
              arguments: {
                'radiusValue': miles,
                'selectList': selectList,
                'tripId': tripId,
                'airCraftID': airCraftID,
                'boolFI': boolFI,
              },
            );
          }
          return;
        } else if (boolFI) {
          if (isCreateTrip == true) {
            Get.offNamed(
              AppRoutes.requiredExperienceFI,
              arguments: {
                'radiusValue': miles,
                'selectList': selectList,
                'tripId': tripId,
                'airCraftID': airCraftID,
              },
            );
          } else {
            Get.offNamed(
              AppRoutes.requiredExperienceFI,
              arguments: {
                'radiusValue': miles,
                'selectList': selectList,
                'tripId': tripId,
                'airCraftID': airCraftID,
              },
            );
          }
          return;
        } else {
          goBackToDashboardAndReloadTrips();
          return;
        }
      }
    }

    // Otherwise require at least one SIC selection
    if (pilotChecked.isEmpty) {
      stopClicking.value = true;
      await showDialog("Please select second in command");
      stopClicking.value = false;
      return;
    }

    stopClicking.value = true;

    if (draft.tripObjectId == null || draft.tripObjectId!.isEmpty) {
      debugPrint('Draft trip has no objectId, so saving trip first (ResultSICController)');
    } else {
      debugPrint('Draft trip already has objectId ${draft.tripObjectId}, probably from Draft tab or Add Crew, saving and sending trip request (ResultSICController)');
    }

    final ctx = Get.context!;

    showLoadingDialog(ctx, 'Saving Trip...');
    try {
      await _saveService.saveDraft(committer: this);

      Navigator.pop(ctx); // close loading dialog
      debugPrint(
        'Trip saved successfully, now sending trip request (ResultSICController)',
      );
    } catch (e) {
      debugPrint(
        'Error saving trip draft before sending (ResultSICController): $e',
      );
      Navigator.pop(ctx); // close loading dialog
      showMyDialog(ctx, e.toString());
      // Re-enable bottom bar button
      stopClicking.value = false;
      return;
    }

    // Proceed with notifications
    showLoading();

    try {
      // 2) For each selected pilotProfile, call the Back4App cloud function
      //    `insertTripOperation`.
      //
      // NOTE: `pilotChecked` contains `p.id`, which for this screen is the
      //       pilotProfile.objectId.

      for (final pilotProfileId in pilotChecked) {
        final params = <String, dynamic>{
          'tripId': draft.tripObjectId,
          'crewProfileId': pilotProfileId,
          'membershipType': 5,      // 5 = SIC Pilot/Captain in our mapping
          'crewRole': 'Second In Command',    // used only for notification text
          'isEdit': false,
          'fromAddCrew': isFromAddCrew,
          // We intentionally do NOT send startDate / endDate / rate here,
          // because the trip already has them stored from createTrip.
        };

        final function = ParseCloudFunction('insertTripOperation');
        final ParseResponse response =
            await function.execute(parameters: params);

        if (!response.success) {
          final errorMessage =
              response.error?.message ?? 'Failed to send trip request.';
          throw Exception(errorMessage);
        }

        // Optional debug:
        // debugPrint('insertTripOperation result: ${response.result}');
      }

      // 3) All requests succeeded → close "Sending..." dialog

      hideLoading();
      await showDialog("Trip Request Sent"); // msg is shown by API below anyway
      stopClicking.value = false;
      backButtonLocked.value = true;

      // await _sendNotificationsAndUpdateCounts(
      //   isEdit: false,
      //   startDate: null,
      //   endDate: null,
      // );

      if (isFromAddCrew){
        // If we came from Add Crew, always go back to Dashboard after sending, no matter the role.
        goBackToDashboardAndReloadTrips();
        return;
      }

      // Decide next step
      if (boolFA) {
        final route = isCreateTrip ? AppRoutes.requiredExperienceFA : AppRoutes.requiredExperienceFA;
        Get.offNamed(route, arguments: {
          'miles': miles,
          'selectList': selectList,
          'tripId': draft.tripObjectId!,
          'backbutton': backButtonLocked.value,
          'airCraftID': airCraftID,
          'boolFI': boolFI,
          'startDate': startDate,
          'endDate': endDate,
          'ratingAirCraftType': ratingAirCraftType,
        });
      } else if (boolFI) {
        final route = isCreateTrip ? AppRoutes.requiredExperienceFI : AppRoutes.requiredExperienceFI;
        Get.offNamed(route, arguments: {
          'radiusValue': miles,
          'selectList': selectList,
          'backbutton': backButtonLocked.value,
          'tripId': draft.tripObjectId!,
          'airCraftID': airCraftID,
          'startDate': startDate,
          'endDate': endDate,
          'ratingAirCraftType': ratingAirCraftType,
        });
      } else {
        goBackToDashboardAndReloadTrips();
      }
    } catch (e) {
      hideLoading();
      stopClicking.value = false;
      rethrow;
    }
  }

  /// Flow for EDIT (isEdit == true in legacy) – called when `isTripOutOfDate == true` branch
  Future<void> handlePrimaryActionEdit(
      {required void Function() showLoading,
      required void Function() hideLoading,
      required Future<void> Function(String message) showDialog}) async {
    // If no SIC found but next search step is FA or FI, pull tripDetails and route to SearchByFA/FI with isTripOutOfDate=true
    //if (filterData?.sic.isEmpty == true &&
    if (filterData.isEmpty == true &&
        selectList.contains("Second In Command") &&
        (selectList.contains("Flight Attendant") ||
            selectList.contains("Flight Instructor") ||
            selectList.contains("Instructor"))) {
      await _navigateToNextSearchFromEdit(showLoading: showLoading, hideLoading: hideLoading);
      return;
    }

    // Otherwise require a selection
    if (pilotChecked.isEmpty) {
      stopClicking.value = true;
      await showDialog("Please select second in command");
      stopClicking.value = false;
      return;
    }

    // Proceed with notifications (isEdit=true)
    showLoading();
    stopClicking.value = true;

    try {
      await _sendNotificationsAndUpdateCounts(
        isEdit: true,
        startDate: startDate,
        endDate: endDate,
      );

      hideLoading();

      // Refresh trip detail and go next (FA/FI) OR home
      await showDialog("Trip Request Sent");

      await _navigateToNextSearchFromEdit(showLoading: showLoading, hideLoading: hideLoading);
    } catch (e) {
      hideLoading();
      stopClicking.value = false;
      rethrow;
    }
  }

  Future<void> _navigateToNextSearchFromEdit({
    required void Function() showLoading,
    required void Function() hideLoading,
  }) async {
    // Pull trip detail for building next screen arguments
    // List<TripDetails> tripData = [];
    // showLoading();
    // if (tripId != 0) {
    //   final details = await getTripDetail(tripId: tripId, pilotId: pkPilotId.toString());
    //   hideLoading();
    //   if (details?.data?.trip == null) {
    //     tripData = [];
    //   } else {
    //     tripData = details!.data!.trip;
    //     final first = tripData.first;

    //     if (selectList.contains("Flight Attendant")) {
    //       Get.toNamed(AppRoutes.searchByFA, arguments: {
    //         'startDate': startDate,
    //         'endDate': endDate,
    //         'selectList': selectList,
    //         'validPassport': first.havePassport,
    //         'continentExp': first.continent,
    //         'monthTraining': first.IsReqPrev12MonthTraining_FA,
    //         'boolFI': first.flightInstructor,
    //         'tripId': first.pkTripId,
    //         'ratingCount': int.parse(first.ratingCount),
    //         'rate': first.faRate.round().toString(),
    //         'oceanicExp': first.ocean,
    //         'radiusValue': first.radius,
    //         'otherSelectTraining': first.specialTrainedOther,
    //         'specialTraining': first.IsSpecialTraining_FA,
    //         'yrExp': first.YEAREXP_FA.toString().contains('50')
    //             ? "10-50"
    //             : first.YEAREXP_FA.toString().contains('10')
    //                 ? "5-10"
    //                 : first.YEAREXP_FA.toString().contains('5')
    //                     ? "3-5"
    //                     : first.YEAREXP_FA.toString().contains('3')
    //                         ? "1-3"
    //                         : first.YEAREXP_FA.toString().contains('1')
    //                             ? "0-1"
    //                             : "0-1",
    //         'languageSpoken': first.LANG_SPOKEN_FA,
    //         'profile': first.IsShowprofile_FA,
    //         'internationalVisa': first.InternationalVisaHeld_FA,
    //         'gender': first.HideGender_FA,
    //         'specialTrainedName': first.SpecTraining_FA,
    //         'airCraftID': first.fkAircraftId,
    //         'aircraftSpeTraining': first.AircraftSpecifictraining_FA,
    //         'isTripOutOfDate': true,
    //       });
    //     } else if (selectList.contains("Flight Instructor") ||
    //         selectList.contains("Instructor")) {
    //       Get.toNamed(AppRoutes.searchByFI, arguments: {
    //         'startDate': startDate,
    //         'endDate': endDate,
    //         'selectList': selectList,
    //         'tripId': first.pkTripId,
    //         'ratingCount': int.parse(first.ratingCount),
    //         'rate': first.fiRate.round().toString(), // NOTE: old code had a typo using faRate; fixed to fiRate
    //         'radiusValue': first.radius,
    //         'airCraftID': first.fkAircraftId,
    //         'complexTime': first.complexTimeReqr,
    //         'highTime': first.highPerfomanceTime,
    //         'daulGiven': first.timeOfInstruct,
    //         'aerobatic': first.acrobaticsInstructor.toString(),
    //         'multiEngine': first.mulEngInstructor.toString(),
    //         'tailWheel': first.tailWheelInsrtuctor.toString(),
    //         'instrumentInstruct': first.instrumentInstructor.toString(),
    //         'totalTime': first.totalTimeInstructor,
    //         'isTripOutOfDate': true,
    //       });
    //     } else {
    //       goHome();
    //     }
    //   }
    // } else {
    //   hideLoading();
    // }
  }

  /// Core side-effects: sendNotification -> update trip notif -> bump Firestore counters
  Future<void> _sendNotificationsAndUpdateCounts({
    required bool isEdit,
    required String? startDate,
    required String? endDate,
  }) async {
    print("In SIC boolFA=$boolFA");

    // 1) Send the API notification call
    // final resp = await sendNotification(
    //   SICNumber: pilotChecked.join(","),
    //   filterPilotId: pilotChecked.join(","),
    //   tripId: tripId,
    //   rate: rate,
    //   // edit-mode extras:
    //   startDate: isEdit ? startDate : null,
    //   endDate: isEdit ? endDate : null,
    //   oldCrewMemberId: isEdit ? oldCrewMemberId : null,
    //   isEdit: isEdit ? true : null,
    //   membershipId: isEdit ? membershipId : null,
    // );

    // 2) For each chosen SIC, fetch TripDetails for notif id, then update it
    for (int i = 0; i < pilotChecked.length; i++) {
      // final oppositeId = pilotChecked[i];
      // final multi = await getTripDetailMultiplePilot(
      //   MemberType: "Pilot",
      //   tripId: tripId,
      //   oppositeId: oppositeId,
      // );
      // tripDetails = multi?.data;

      //TODO:
      // if (tripDetails?.summary.isNotEmpty == true) {
      //   final notifId = tripDetails!.summary[0].pkTripNotificationId.toString();
      //   await updateTripNotification(
      //     TripId: tripId,
      //     NotificationId: notifId,
      //   );
      // }

      //TODO:
      // 3) Firestore pending & tripCount updates (both directions)
      // await FirebaseFirestore.instance
      //     .collection(appType.toString() == 'live'
      //         ? AppStrings.fireBaseUserlive
      //         : AppStrings.fireBaseUserlocal)
      //     .doc('$oppositeId')
      //     .update({'pendingCount': FieldValue.increment(1)});

      // // A -> B (opposite - me): increment to 1 (create if missing)
      // {
      //   final docTrip = FirebaseFirestore.instance
      //       .collection(appType.toString() == 'live'
      //           ? AppStrings.fireBaseTripslive
      //           : AppStrings.fireBaseTripslocal)
      //       .doc('$tripId')
      //       .collection('tripCount')
      //       .doc('$oppositeId - $pkPilotId');

      //   final snap = await docTrip.get();
      //   if (snap.exists) {
      //     await docTrip.update({'notificationCount': FieldValue.increment(1)});
      //   } else {
      //     await docTrip.set({'notificationCount': 1});
      //   }
      // }

      // // B -> A (me - opposite): ensure 0 if missing
      // {
      //   final docTrip = FirebaseFirestore.instance
      //       .collection(appType.toString() == 'live'
      //           ? AppStrings.fireBaseTripslive
      //           : AppStrings.fireBaseTripslocal)
      //       .doc('$tripId')
      //       .collection('tripCount')
      //       .doc('$pkPilotId - $oppositeId');

      //   final snap = await docTrip.get();
      //   if (snap.exists) {
      //     await docTrip.update({'notificationCount': 0});
      //   } else {
      //     await docTrip.set({'notificationCount': 0});
      //   }
      // }
    }

    // 4) Increment my pendingCount as well
    // await FirebaseFirestore.instance
    //     .collection(appType.toString() == 'live'
    //         ? AppStrings.fireBaseUserlive
    //         : AppStrings.fireBaseUserlocal)
    //     .doc('$pkPilotId')
    //     .update({'pendingCount': FieldValue.increment(1)});

    print(pilotChecked);
    // The legacy screen shows server's msg via showMyDialog afterwards.
    // Let the screen call its dialog with resp.msg.
    // if (resp != null) {
    //   print('sendNotification -> ${resp.msg}');
    // }
  }
}


class ResultSICBinding extends Bindings {
  @override
  void dependencies() {
    // Avoid reusing a stale controller instance when navigating to this route
    // multiple times with different arguments.
    if (Get.isRegistered<ResultSICController>()) {
      Get.delete<ResultSICController>(force: true);
    }

    Get.put<ResultSICController>(ResultSICController());
  }
}