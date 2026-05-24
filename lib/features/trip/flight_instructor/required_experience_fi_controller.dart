// ignore_for_file: unnecessary_this

import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/trip/flight_instructor/day_rate_fi_controller.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crew_support/Api/Api_service.dart';

// ────────────────────────────────────────────────────────────────────────────
// Arguments model for navigation
// ────────────────────────────────────────────────────────────────────────────
class RequiredExperienceFIArgs {
  final List<String> selectList;
  final int tripId;            // if 0 => create mode; else => edit mode
  final int airCraftID;
  final String radiusValue;
  final bool? backbutton;      // when true => disable back
  final String? startDate;
  final String? endDate;

  const RequiredExperienceFIArgs({
    required this.selectList,
    required this.tripId,
    required this.airCraftID,
    required this.radiusValue,
    this.backbutton,
    this.startDate,
    this.endDate,
  });
}

// ────────────────────────────────────────────────────────────────────────────
// GetX Controller
// ────────────────────────────────────────────────────────────────────────────
class RequiredExperienceFIController extends GetxController {
  // Exposed from args
  late final List<String> selectList;
  late final int tripId;
  late final int airCraftID;
  late final String radiusValue;
  bool get isEdit => tripId != 0;
  late final bool backBlocked;
  String? startDate;
  String? endDate;

  // Text controllers (exact same fields as old UI)
  final totalTimeController = TextEditingController();
  final dualGivenController = TextEditingController();
  final complexTimeController = TextEditingController();
  final highPerformanceController = TextEditingController();

  // Toggles
  final checkboxInstrumentYes = false.obs;
  final checkboxEngineYes = false.obs;
  final checkboxWheelYes = false.obs;
  final checkboxAcrobaticYes = false.obs;

  // Rating (0..5)
  final rating = 0.obs;

  // Loading + draft state
  final isLoading = false.obs;
  int _draftBtnClicked = 0;

  // Optional server-side FI day rate in the v2 screen existed, but this
  // screen doesn’t show the day rate field; we still keep wiring symmetrical
  // by allowing the “filterFlightInstructor” call to accept blank rate.
  String get _rateForDraft => ""; // keep parity with RequiredExperienceFIScreen

  // ──────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ──────────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    // Read and cache arguments up front
    final args = Get.arguments as RequiredExperienceFIArgs;
    selectList = args.selectList;
    tripId = args.tripId;
    airCraftID = args.airCraftID;
    radiusValue = args.radiusValue;
    backBlocked = args.backbutton == true;
    startDate = args.startDate;
    endDate = args.endDate;

    // If we’re editing an existing draft, fetch & prefill
    if (isEdit) _loadDraft();
  }

  @override
  void onClose() {
    totalTimeController.dispose();
    dualGivenController.dispose();
    complexTimeController.dispose();
    highPerformanceController.dispose();
    super.onClose();
  }

  // ──────────────────────────────────────────────────────────────────────
  // Data loading (edit mode)
  // ──────────────────────────────────────────────────────────────────────
  Future<void> _loadDraft() async {
    // isLoading.value = true;
    // try {
    //   final draft = await getTripDetail(
    //     tripId: tripId,
    //     pilotId: pkPilotId.toString(), // from Constants
    //   );

    //   // If API contract differs, keep same null/empty checks as legacy
    //   final tripList = draft?.data?.trip;
    //   if (tripList == null || tripList.isEmpty) {
    //     isLoading.value = false;
    //     return;
    //   }

    //   final t0 = tripList[0];

    //   // Replicate the legacy mapping:
    //   // strings "0" mean empty; booleans map to checkboxes.
    //   if (t0.totalTimeInstructor != null && t0.totalTimeInstructor != "0") {
    //     totalTimeController.text = t0.totalTimeInstructor!;
    //   }
    //   if (t0.timeOfInstruct != null && t0.timeOfInstruct != "0") {
    //     dualGivenController.text = t0.timeOfInstruct!;
    //   }
    //   if (t0.complexTimeReqr != null && t0.complexTimeReqr != "0") {
    //     complexTimeController.text = t0.complexTimeReqr!;
    //   }
    //   if (t0.highPerfomanceTime != null && t0.highPerfomanceTime != "0") {
    //     highPerformanceController.text = t0.highPerfomanceTime!;
    //   }

    //   checkboxInstrumentYes.value = (t0.instrumentInstructor == true);
    //   checkboxEngineYes.value = (t0.mulEngInstructor == true);
    //   checkboxWheelYes.value = (t0.tailWheelInsrtuctor == true);
    //   checkboxAcrobaticYes.value = (t0.acrobaticsInstructor == true);

    //   final rc = (t0.ratingcountInstruct ?? "").trim();
    //   if (rc.isNotEmpty) {
    //     final parsed = int.tryParse(rc) ?? 0;
    //     rating.value = parsed.clamp(0, 5);
    //   }
    // } catch (_) {
    //   // Silent, keep UI stable; optionally you could show a toast/snackbar.
    // } finally {
    //   isLoading.value = false;
    // }
  }

  // ──────────────────────────────────────────────────────────────────────
  // Actions
  // ──────────────────────────────────────────────────────────────────────
  bool validateAndWarn(BuildContext context) {
    if (totalTimeController.text.isEmpty) {
      showMyDialog(context, "Please enter total time");
      return false;
    }
    if (dualGivenController.text.isEmpty) {
      showMyDialog(context, "Please enter dual given time");
      return false;
    }
    if (complexTimeController.text.isEmpty) {
      showMyDialog(context, "Please enter complex time");
      return false;
    }
    if (highPerformanceController.text.isEmpty) {
      showMyDialog(context, "Please enter high performance time");
      return false;
    }
    return true;
  }

  Future<void> onSaveDraft(BuildContext context) async {
    _draftBtnClicked += 1;
    showLoadingDialog(context, 'Saving...');
    //TODO:

    try {
      // await filterFlightInstructor(
      //   searchAll: false,
      //   rate: _rateForDraft,
      //   airCraftId: airCraftID,
      //   totalTime: totalTimeController.text,
      //   daulGiven: dualGivenController.text,
      //   instrumentInstruct: checkboxInstrumentYes.value.toString(),
      //   tailWheel: checkboxWheelYes.value.toString(),
      //   aerobatic: checkboxAcrobaticYes.value.toString(),
      //   multiEngine: checkboxEngineYes.value.toString(),
      //   complexTime: complexTimeController.text,
      //   highTime: highPerformanceController.text,
      //   ratingCount: rating.value.toString(),
      //   tripId: tripId,
      //   miles: radiusValue,
      //   isFavorite: false,
      //   isAvailable: false,
      //   isNearest: false,
      // );

      Get.back(); // close loading dialog
      if (_draftBtnClicked == 1 && !isEdit) {
        showMyDialog(context, 'Draft saved sucessfully');
      } else {
        showMyDialog(context, 'Draft updated sucessfully');
      }
    } catch (e) {
      Get.back(); // close loading
      showMyDialog(context, 'Failed to save draft');
    }
  }

  // Push to Day Rate screen (single route; that screen can also check isEdit)
  void onNext() {
    // IMPORTANT: keep argument names consistent with your new Day Rate screen
    Get.toNamed(
      AppRoutes.dayRateFI, // <-- replace with your actual route constant
      arguments: DayRateFIArgs(
        selectList: selectList,
        totalTime: totalTimeController.text,
        daulGiven: dualGivenController.text,
        complexTime: complexTimeController.text,
        highTime: highPerformanceController.text,
        instrumentInstruct: checkboxInstrumentYes.value.toString(),
        multiEngine: checkboxEngineYes.value.toString(),
        tailWheel: checkboxWheelYes.value.toString(),
        aerobatic: checkboxAcrobaticYes.value.toString(),
        tripId: tripId, // - If tripId != 0, it fetches draft details and hydrates the screen.
        airCraftID: airCraftID,
        ratingCount: rating.value, // keep as int (old FI2 sent int)
        startDate: startDate.toString(),
        endDate: endDate.toString(),
        radiusValue: radiusValue,
      ),
    );
  }
}