import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/features/trip/second_in_command/required_experience_sic_controller.dart';
import 'package:crew_support/features/trip/trip_draft_flow_service.dart';
import 'package:crew_support/features/trip/trip_draft_save_service.dart';
import 'package:crew_support/model/crew_list_item.dart';
import 'package:crew_support/model/trip_draft_payload.dart';
import 'package:crew_support/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crew_support/Api/Api_service.dart';
import 'package:crew_support/helper/user_helper.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/model/TripDetailsResponse.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ResultCaptainController extends GetxController implements DraftCommitter {
  // ---------- Inputs (from old widget fields) ----------
  // final Data? filterData;
  final List<CrewListItem> filterData;
  final String tripId;
  final bool boolSIC;
  final bool boolFI;
  final bool boolFA;
  final bool boolCAP;
  final List<String> selectList;
  final int airCraftID;
  final String miles;
  final String ratingAirCraftType;
  final String rate;
  final bool? isTripOutOfDate;
  final String? startDate;
  final String? endDate;
  final String? oldCrewMemberId;
  final String? membershipId;
  final String? totalTime;
  final String? totalTimeType;
  final String? picTimeType;
  final String? picTime;
  final String? medicalClass;
  final int? rating;
  final bool? validPassport;
  final String? ratingType;
  final String? continentExp;
  final String? oceanicExp;
  final bool? monthTraining;


  ResultCaptainController({
    required this.filterData,
    required this.tripId,
    required this.boolSIC,
    required this.boolFI,
    required this.boolFA,
    required this.boolCAP,
    required this.selectList,
    required this.airCraftID,
    required this.miles,
    required this.ratingAirCraftType,
    required this.rate,
    this.isTripOutOfDate,
    this.startDate,
    this.endDate,
    this.oldCrewMemberId,
    this.membershipId,
    this.totalTime,
    this.totalTimeType,
    this.picTimeType,
    this. picTime,
    this. medicalClass,
    this.rating,
    this.validPassport,
    this.ratingType,
    this.continentExp,
    this.oceanicExp,
    this.monthTraining,
  });

  // ---------- Reactive state ----------
  final isLoading = true.obs;
  final pilotChecked = <String>[].obs;
  final stopClicking = false.obs;
  final backButtonLocked = false.obs;
  final selectAll = false.obs;

  // Derived/other state from legacy code
  // final _appType = UserHelper().getAppType();
  final RxBool _isTripOutOfDateRx = false.obs;

  TripDetailsData? tripDetails;

  late final TripDraftFlowService _flow;
  late final TripDraftSaveService _saveService;
  TripDraftPayload get draft => _flow.draft.value;

  // ---------- Lifecycle ----------
  @override
  void onInit() {
    super.onInit();
    debugPrint("onInit called for ResultCaptainController");
    debugPrint('ResultCaptainController._readArguments - Get.arguments: ${Get.arguments}');
    debugPrint("ResultCaptainController filterData length = ${filterData.length}");
    
    _isTripOutOfDateRx.value = isTripOutOfDate ?? false;

    // In the old code, this was called in didChangeDependencies().
    // Safe to call on init here so pending badges etc. stay in sync.
    Future.microtask(() => UserHelper().getPendingDetail());

    isLoading.value = false;

    _flow = Get.find<TripDraftFlowService>();
    _saveService = TripDraftSaveService(_flow);

    debugPrint("draft in ResultCaptainController: ${draft.toJson()}");
  }

  @override
  void commitToDraft() {
  }

  // ---------- Helpers ----------
  bool get isTripOutOfDateComputed => _isTripOutOfDateRx.value;

  /// Toggle one pilot checkbox
  void togglePilotSelection(bool selected, String id) {
    if (selected) {
      if (!pilotChecked.contains(id)) pilotChecked.add(id);
    } else {
      pilotChecked.remove(id);
    }
    // Keep 'Select All' in sync with the list
    // final total = filterData?.pilots.length ?? 0;
    final total = filterData.length;
    selectAll.value = pilotChecked.length == total && total > 0;
  }

  /// Select/Deselect all pilots
  void toggleSelectAll(bool value) {
    selectAll.value = value;
    if (value) {
      pilotChecked.value =
          // List<int>.from(filterData!.pilots.map((p) => p.pkPilotId));
          List<String>.from(filterData.map((p) => p.id));
    } else {
      pilotChecked.clear();
    }
  }

  // ---------- Actions (bottom bar buttons) ----------

  /// Back4App-based flow: Send Trip Request for selected captains.
  Future<void> sendTripRequest(BuildContext context) async {
    
    // 1) Validate that at least one captain is selected
    if (pilotChecked.isEmpty) {
      stopClicking.value = true;
      await showMyDialog(context, "Please select captain");
      stopClicking.value = false;
      return;
    }

    // Prevent multiple taps
    stopClicking.value = true;

    if (draft.tripObjectId == null || draft.tripObjectId!.isEmpty) {
      debugPrint('Draft trip has no objectId, so saving trip first (ResultCaptainController)');
    } else {
      debugPrint('Draft trip already has objectId ${draft.tripObjectId}, probably from Draft tab or Add Crew, saving and sending trip request (ResultCaptainController)');
    }

    final ctx = Get.context!;

    showLoadingDialog(ctx, 'Saving Trip...');
    try {
      await _saveService.saveDraft(committer: this);

      Navigator.pop(ctx); // close loading dialog
      debugPrint(
        'Trip saved successfully, now sending trip request (ResultCaptainController)',
      );
    } catch (e) {
      debugPrint(
        'Error saving trip draft before sending (ResultCaptainController): $e',
      );
      Navigator.pop(ctx); // close loading dialog
      showMyDialog(ctx, e.toString());
      // Re-enable bottom bar button
      stopClicking.value = false;
      return;
    }

    // Show loading while we call the cloud function(s)
    showLoadingDialog(context, "Sending...");

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
          'membershipType': 3,      // 3 = Pilot/Captain in our mapping
          'crewRole': 'Captain',    // used only for notification text
          'isEdit': false,
          'fromAddCrew': _flow.isFromAddCrew,
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
      Navigator.of(context).pop();

      // Show success dialog
      await showMyDialog(context, 'Trip request sent successfully.');

      // 4) Follow legacy navigation rules after sending
      backButtonLocked.value = true;
      goToNextStepAfterSend(context);
    } catch (e) {
      // On any error, close loading dialog and show error.
      Navigator.of(context).pop();
      await showMyDialog(
        context,
        'Failed to send trip request: $e',
      );
    } finally {
      // Re-enable bottom bar button
      stopClicking.value = false;
    }
  }

  /// Save as draft
  Future<void> onTapSaveDraft() async {
    final ctx = Get.context!;

    showLoadingDialog(ctx, 'Saving...');
    try {
      await _saveService.saveDraft(committer: this);

      Navigator.pop(ctx); // close loading dialog

      // Wait for user to tap OK on success dialog
      await showMyDialog(ctx, 'Draft saved successfully');

      // After dialog is dismissed, exit this screen and return updated draft
      Get.find<DashboardController>().goBackToDashboardAndReloadTrips();
    } catch (e) {
      Navigator.pop(ctx); // close loading dialog
      showMyDialog(ctx, e.toString());
    }
  }

  /// Old flow: Send Trip Request (non-edit flow).
  /// Shows dialogs exactly like the old screen and navigates similarly.
  Future<void> sendTripRequestOld(BuildContext context) async {
    if (pilotChecked.isEmpty) {
      stopClicking.value = true;
      await showMyDialog(context, "Please select captain");
      stopClicking.value = false;
      return;
    }
  }

  /// Edit flow (when trip is out of date) – mirrors old `isEdit: true` branch.
  Future<void> sendTripRequestEdit(BuildContext context) async {
    if (pilotChecked.isEmpty) {
      await showMyDialog(context, "Please select captain");
      return;
    }

  }

  /// Delete draft (Cupertino confirm dialog is shown from the View; this just performs delete)
  Future<void> deleteDraftAndExit(BuildContext context) async {
    showLoadingDialog(context, "Deleting...");
    try {
      await deleteDraft(tripId);
    } finally {
      Navigator.of(context).pop(); // loading
    }
  }

  // ---------- Navigation branches (replicate original) ----------

  /// After non-edit send flow: navigates based on boolSIC/boolFA/boolFI and isCreateTrip.
  void goToNextStepAfterSend(BuildContext context) {

    if (_flow.isFromAddCrew){
      // If we came from Add Crew, always go back to Dashboard after sending, no matter the role.
      Get.find<DashboardController>().goBackToDashboardAndReloadTrips();
      return;
    }

    // Legacy globals kept as-is: isCreateTrip, fromPending, etc.
    if (boolSIC == true) {
      if (isCreateTrip == true) {
        // navigator?.pushReplacement(_routeToRequiredExperienceSIC1());
        // Legacy Screen1 behavior
        Get.offNamed(
          AppRoutes.requiredExperienceSIC,
          arguments: RequiredExperienceSICArgs(
            miles: miles,
            boolSIC: boolSIC,
            selectList: selectList,
            tripId: draft.tripObjectId!,
            boolFI: boolFI,
            boolFA: boolFA,
            airCraftID: airCraftID,
            ratingAirCraftType: ratingAirCraftType,
            startDate: startDate,
            endDate: endDate,
            // lockBackButton: false, // or true
            loadDraft: false, // Screen1
          ),
        );
      } else {
        // navigator?.pushReplacement(_routeToRequiredExperienceSIC2());
        // Legacy Screen2 behavior
        Get.offNamed(
          AppRoutes.requiredExperienceSIC,
          arguments: RequiredExperienceSICArgs(
            miles: miles,
            boolSIC: boolSIC,
            selectList: selectList,
            tripId: draft.tripObjectId ?? "",
            boolFI: boolFI,
            boolFA: boolFA,
            airCraftID: airCraftID,
            ratingAirCraftType: ratingAirCraftType,
            startDate: startDate,
            endDate: endDate,
            // lockBackButton: false, // or true
            loadDraft: false, // Screen2
          ),
        );
      }
      return;
    }

    if (boolFA == true) {
      if (isCreateTrip == true) {
        // navigator?.pushReplacement(_routeToRequiredExperienceFA1());
        Get.offNamed(
            AppRoutes.requiredExperienceFA,
            arguments: {
              'miles': miles,
              'selectList': selectList,
              'tripId': draft.tripObjectId!,
              'airCraftID': airCraftID,
              'boolFI': boolFI,
              'startDate': startDate,
              'endDate': endDate,
              'ratingAirCraftType': ratingAirCraftType,
              //backbutton
            },
          );
      } else {
        Get.offNamed(
            AppRoutes.requiredExperienceFA,
            arguments: {
              'miles': miles,
              'selectList': selectList,
              'tripId': draft.tripObjectId!,
              'airCraftID': airCraftID,
              'boolFI': boolFI,
              'startDate': startDate,
              'endDate': endDate,
              'ratingAirCraftType': ratingAirCraftType,
              //backbutton
            },
          );
      }
      return;
    }

    if (boolFI == true) {
      if (isCreateTrip == true) {
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
              'ratingAirCraftType': ratingAirCraftType,
              //backbutton
            },
          );
      } else {
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
              'ratingAirCraftType': ratingAirCraftType,
              //backbutton
            },
          );
      }
      return;
    }

    // Else go home
    Get.find<DashboardController>().goBackToDashboardAndReloadTrips();
  }

}

class ResultCaptainBinding extends Bindings {
  @override
  void dependencies() {
    // Retrieve the arguments passed via Get.toNamed(...)
    final args = Get.arguments as Map<String, dynamic>;

    // Ensure we never reuse a stale ResultCaptainController instance when
    // navigating to this route multiple times with different arguments.
    if (Get.isRegistered<ResultCaptainController>()) {
      Get.delete<ResultCaptainController>(force: true);
    }

    Get.put<ResultCaptainController>(
      ResultCaptainController(
        // filterData: args['filterData'] as Data?,
        filterData: args['filterData'] as List<CrewListItem>,
        startDate: args['startDate'] as String?,
        endDate: args['endDate'] as String?,
        membershipId: args['membershipId'] as String?,
        oldCrewMemberId: args['oldCrewMemberId'] as String?,
        boolSIC: args['boolSIC'] as bool,
        selectList: (args['selectList'] as List).cast<String>(),
        airCraftID: args['airCraftID'] as int,
        boolFA: args['boolFA'] as bool,
        miles: args['miles'] as String,
        boolFI: args['boolFI'] as bool,
        boolCAP: args['boolCAP'] as bool,
        tripId: args['tripId'] as String,
        rate: args['rate'] as String,
        ratingAirCraftType: args['ratingAirCraftType'] as String,
        isTripOutOfDate: args['isTripOutOfDate'] as bool?,
        totalTime: (args['totalTime'] ?? '').toString(),
        totalTimeType: (args['totalTimeType'] ?? '').toString(),
        picTimeType: (args['picTimeType'] ?? '').toString(),
        picTime: (args['picTime'] ?? '').toString(),
        medicalClass: (args['medicalClass'] ?? '').toString(),
        rating: int.tryParse((args['rating'] ?? 0).toString()) ?? 0,
        validPassport: (args['validPassport'] ?? false) as bool,
        ratingType: (args['ratingType'] ?? '').toString(),
        continentExp: (args['continentExp'] ?? '').toString(),
        oceanicExp: (args['oceanicExp'] ?? '').toString(),
        monthTraining: (args['monthTraining'] ?? false) as bool,
      ),
    );
  }
}