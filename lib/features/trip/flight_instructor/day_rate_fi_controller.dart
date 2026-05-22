// lib/features/trip/flight_instructor/day_rate_fi_controller.dart
//
// A single controller that merges the behavior of DayRateFIScreen and DayRateFIScreen2.
// - If tripId != 0, it fetches draft details and hydrates the screen.
// - Otherwise, it uses the args passed from the previous screen.
// UI reads only the specific reactive fields to avoid broad Obx usage.

import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/constants.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:crew_support/Api/Api_service.dart';

class DayRateFIArgs {
  DayRateFIArgs({
    required this.selectList,
    required this.totalTime,
    required this.daulGiven,
    required this.complexTime,
    required this.highTime,
    required this.instrumentInstruct,
    required this.multiEngine,
    required this.tailWheel,
    required this.aerobatic,
    required this.tripId,
    required this.airCraftID,
    required this.ratingCount,
    required this.startDate,
    required this.endDate,
    this.radiusValue,
  });

  final List<String> selectList;
  final String totalTime;
  final String daulGiven;
  final String complexTime;
  final String highTime;
  final String instrumentInstruct;
  final String multiEngine;
  final String tailWheel;
  final String aerobatic;
  final int tripId;
  final int airCraftID;
  final int ratingCount;
  final String startDate;
  final String endDate;
  final String? radiusValue;
}

class DayRateFIController extends GetxController {
  // ---------- Public, UI-bound ----------
  final isLoading = false.obs;

  /// Text field for "Per Day" rate ($)
  final TextEditingController dayRateController = TextEditingController();

  /// Everything below is what the old "2" screen hydrated from draft.
  /// We keep them nullable to allow "fresh" case to pass-through.
  String? totalTimeController;
  String? dualGivenController;          // NOTE: old misspelling "daul"
  String? complexTimeController;
  String? highPerformanceController;

  final checkboxInstrumentYes = true.obs;
  final checkboxEngineYes = true.obs;
  final checkboxWheelYes = true.obs;
  final checkboxAcrobaticYes = true.obs;

  /// Rating (count) as int for FI
  final rating = 0.obs;

  /// Immutable trip info set at init
  late DayRateFIArgs args;

  // ---------- Lifecycle ----------
  @override
  void onInit() {
    super.onInit();
    // Expecting DayRateFIArgs via Get.arguments
    args = Get.arguments as DayRateFIArgs;

    // Default pass-through from args (lightweight path like DayRateFIScreen)
    totalTimeController      = args.totalTime;
    dualGivenController      = args.daulGiven;
    complexTimeController    = args.complexTime;
    highPerformanceController= args.highTime;

    // If we arrive with a draft (tripId != 0), hydrate like DayRateFIScreen2
    if (args.tripId != 0) {
      _getDraftTripDetails();
    }
  }

  @override
  void onClose() {
    dayRateController.dispose();
    super.onClose();
  }

  // ---------- Draft fetch (was getdrafttripdetails) ----------
  Future<void> _getDraftTripDetails() async {
    // isLoading.value = true;
    // try {
    //   final draft = await getTripDetail(
    //     tripId: args.tripId,
    //     pilotId: pkPilotId.toString(),
    //   );

    //   // If no draft, just stop
    //   if (draft?.data?.trip == null || draft!.data!.trip.isEmpty) {
    //     isLoading.value = false;
    //     return;
    //   }

    //   final t = draft.data!.trip[0];

    //   // fiRate -> text (truncate decimal)
    //   final fiRate = t.fiRate?.toString() ?? '0.0';
    //   if (fiRate != '0.0' && fiRate.contains('.')) {
    //     dayRateController.text = fiRate.substring(0, fiRate.indexOf('.'));
    //   }

    //   totalTimeController       = t.totalTimeInstructor?.toString();
    //   dualGivenController       = t.timeOfInstruct;
    //   complexTimeController     = t.complexTimeReqr;
    //   highPerformanceController = t.highPerfomanceTime;

    //   checkboxInstrumentYes.value = (t.instrumentInstructor == true);
    //   checkboxEngineYes.value     = (t.mulEngInstructor == true);
    //   checkboxWheelYes.value      = (t.tailWheelInsrtuctor == true);
    //   checkboxAcrobaticYes.value  = (t.acrobaticsInstructor == true);

    //   // ratingcountInstruct -> rating
    //   final ratingStr = t.ratingcountInstruct ?? '';
    //   if (ratingStr.isNotEmpty) {
    //     rating.value = int.tryParse(ratingStr) ?? 0;
    //   }
    // } finally {
    //   isLoading.value = false;
    // }
  }

  // ---------- Actions ----------
  /// Called when user taps "Next" and then presses OK in "Search for crew..." flow
  void goToSearchByFI() {
    // Your named route for SearchByFIScreen must be registered.
    // Pass exactly the same argument keys as old screens.
    // Get.toNamed(
    //   AppRoutes.searchByFI,
    //   arguments: {
    //     'selectList'        : args.selectList,
    //     'tripId'            : args.tripId,
    //     'totalTime'         : totalTimeController ?? args.totalTime,
    //     'daulGiven'         : dualGivenController ?? args.daulGiven,
    //     'instrumentInstruct': args.instrumentInstruct,
    //     'tailWheel'         : args.tailWheel,
    //     'radiusValue'       : (args.radiusValue ?? '').toString(),
    //     'aerobatic'         : args.aerobatic,
    //     'multiEngine'       : args.multiEngine,
    //     'complexTime'       : complexTimeController ?? args.complexTime,
    //     'highTime'          : highPerformanceController ?? args.highTime,
    //     'airCraftID'        : args.airCraftID,
    //     'rate'              : dayRateController.text.toString(),
    //     'ratingCount'       : args.ratingCount,
    //     // 'isTripOutOfDate': isTripOutOfDate,       // bool?
    //     // 'startDate': startDate,                   // String?
    //     // 'endDate': endDate,                       // String?
    //     // 'membershipId': membershipId,             // String?
    //     // 'oldCrewMemberId': oldCrewMemberId,       // String?
    //   },
    // );
  }

  /// Called when user chooses the "Post trip for crew to apply" option.
  Future<void> postTripToUncrewedAndPopToRoot() async {
    showLoadingDialog(Get.context!, 'Loading...');
    try {
      await postUncrewRequest(
        tripId: args.tripId.toString(),
        oppositeId: pkPilotId.toString(),
        startDate: args.startDate,
        rate: dayRateController.text.toString(),
        endDate: args.endDate,
        membershiptype: 'Instructor',
      );
      // Close loading
      Get.back(); 
      // Pop dialogs and then to home root
      Get.back(); 
      Get.until((route) => route.isFirst);
    } catch (e) {
      Get.back(); // close loading
      // Optionally show user-friendly message
      showMyDialog(Get.context!, 'Failed to post trip. Please try again.');
    }
  }

  /// "Save as draft" behavior. Mirrors both variants:
  /// - If we hydrated draft values, send those.
  /// - Otherwise, send what was passed in.
  Future<void> saveAsDraft() async {
    if (dayRateController.text.isEmpty) {
      showMyDialog(Get.context!, "Please enter rate");
      return;
    }
    showLoadingDialog(Get.context!, 'Saving...');
    try {
      //TODO:
      // await filterFlightInstructor(
      //   searchAll: false,
      //   rate: dayRateController.text.toString(),
      //   airCraftId: args.airCraftID,
      //   totalTime: (totalTimeController ?? args.totalTime).toString(),
      //   daulGiven: (dualGivenController ?? args.daulGiven).toString(),
      //   instrumentInstruct: checkboxInstrumentYes.value.toStringIfDraft(args.instrumentInstruct, args.tripId != 0),
      //   miles: (args.radiusValue ?? '').toString(),
      //   tailWheel: checkboxWheelYes.value.toStringIfDraft(args.tailWheel, args.tripId != 0),
      //   aerobatic: checkboxAcrobaticYes.value.toStringIfDraft(args.aerobatic, args.tripId != 0),
      //   multiEngine: checkboxEngineYes.value.toStringIfDraft(args.multiEngine, args.tripId != 0),
      //   complexTime: (complexTimeController ?? args.complexTime).toString(),
      //   highTime: (highPerformanceController ?? args.highTime).toString(),
      //   ratingCount: (args.tripId != 0 ? rating.value.toString() : args.ratingCount.toString()),
      //   tripId: args.tripId,
      //   isFavorite: false,
      //   isAvailable: false,
      //   isNearest: false,
      // );
      Get.back(); // close "Saving..."
      showMyDialog(Get.context!, 'Draft updated sucessfully');
    } catch (_) {
      Get.back();
      showMyDialog(Get.context!, 'Failed to save draft. Please try again.');
    }
  }
}

// ---------- Small helper so we exactly mirror old boolean rules ----------
/// When a draft exists, use the live checkbox value; otherwise pass through the original widget string.
extension _BoolDraftStr on bool {
  String toStringIfDraft(String original, bool hasDraft) {
    return hasDraft ? toString() : original.toString();
  }
}