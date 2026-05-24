import 'dart:convert';
import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/features/trip/trip_draft_flow_service.dart';
import 'package:crew_support/features/trip/trip_draft_save_service.dart';
import 'package:crew_support/model/crew_list_item.dart';
import 'package:crew_support/model/trip_draft_payload.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crew_support/Api/Api_service.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class DayRateCaptainController extends GetxController implements DraftCommitter {
  // Text controller for the rate field
  final TextEditingController dayRateController = TextEditingController();

  // -------- Arguments (formerly widget.*) --------
  late List<String> selectList;
  late String totalTime;
  late String totalTimeType;
  late String picTimeType;
  late String picTime;
  late String medicalClass;
  late bool validPassport;
  late String ratingType;
  late String continentExp;
  late bool monthTraining;
  late String ratingAirCraftType;
  late String oceanicExp;
  late String tripId;
  late bool boolSIC;
  late bool boolFI;
  late bool boolFA;
  late bool boolCAP;
  late int airCraftID;
  late String miles;
  late int rating;
  late String startDate;
  late String endDate;

  // Screen-level loading used when fetching a draft (legacy Screen2)
  final isLoading = false.obs;

  late final TripDraftFlowService _flow;
  late final TripDraftSaveService _saveService;
  TripDraftPayload get draft => _flow.draft.value;
  bool get isFromAddCrew => _flow.isFromAddCrew;

  @override
  void onInit() {
    super.onInit();

    // Reset state so this controller never shows stale values if it gets reused.
    dayRateController.clear();
    isLoading.value = false;

    _readArguments();

    _flow = Get.find<TripDraftFlowService>();
    _saveService = TripDraftSaveService(_flow);

    debugPrint('DayRateCaptainController draft: ${draft.toJson()}');

    final pr = draft.pilotRate;
    if (pr != null) dayRateController.text = pr.toString().split('.').first;
  }

  void applyCaptainRateToDraft() {
    final parsed = num.tryParse(dayRateController.text.trim());
    if (parsed != null) {
      _flow.updateDraft(draft.copyWith(pilotRate: parsed));
    }
  }

  @override
  void commitToDraft() {
    applyCaptainRateToDraft();
  }

  @override
  void onReady() {
    super.onReady();
    // Legacy DayRateCaptainScreen2: prefill when editing a draft
    // if (tripId != 0) {
    //   fetchDraftTripDetails();
    // }
  }

  @override
  void onClose() {
    dayRateController.dispose();
    super.onClose();
  }

  // Safely read all arguments passed via Get.toNamed(..., arguments: {...})
  void _readArguments() {
    debugPrint('DayRateCaptainController._readArguments - Get.arguments: ${Get.arguments}');
    final args = (Get.arguments ?? <String, dynamic>{}) as Map<String, dynamic>;

    selectList = (args['selectList'] as List<dynamic>?)?.cast<String>() ?? <String>[];
    totalTime = (args['totalTime'] ?? '').toString();
    totalTimeType = (args['totalTimeType'] ?? '').toString();
    picTimeType = (args['picTimeType'] ?? '').toString();
    picTime = (args['picTime'] ?? '').toString();
    medicalClass = (args['medicalClass'] ?? '').toString();
    validPassport = (args['validPassport'] ?? false) as bool;
    ratingType = (args['ratingType'] ?? '').toString();
    continentExp = (args['continentExp'] ?? '').toString();
    monthTraining = (args['monthTraining'] ?? false) as bool;
    ratingAirCraftType = (args['ratingAirCraftType'] ?? '').toString();
    oceanicExp = (args['oceanicExp'] ?? '').toString();
    tripId = (args['tripId'] ?? 0).toString();
    boolSIC = (args['boolSIC'] ?? false) as bool;
    boolFI = (args['boolFI'] ?? false) as bool;
    boolFA = (args['boolFA'] ?? false) as bool;
    boolCAP = (args['boolCAP'] ?? false) as bool;
    airCraftID = int.tryParse((args['airCraftID'] ?? 0).toString()) ?? 0;
    miles = (args['miles'] ?? '').toString();
    rating = int.tryParse((args['rating'] ?? 0).toString()) ?? 0;
    startDate = (args['startDate'] ?? '').toString();
    endDate = (args['endDate'] ?? '').toString();

    // Legacy Screen2 had an optional `rate` argument; respect it if present.
    final dynamic initialRate = args['rate'];
    if (initialRate != null && initialRate.toString().trim().isNotEmpty) {
      dayRateController.text = initialRate.toString();
    }
  }

  /// Load draft trip data and prefill day rate similar to Screen2.
  Future<void> fetchDraftTripDetails() async {

  }

  /// Save as draft
  Future<void> onTapSaveDraft() async {
    final ctx = Get.context!;

    // If user hasn't filled mandatory fields for this screen, do not save.
    if (dayRateController.text.isEmpty) {
      showMyDialog(ctx, "Please enter rate");
      return;
    }

    showLoadingDialog(ctx, 'Saving...');
    try {
      await _saveService.saveDraft(committer: this);

      //(Next step) Upload JSON requirements file and attach to trip
      // await _uploadRoleRequirementsFileIfNeeded();

      Navigator.pop(ctx); // close loading dialog

      // Wait for user to tap OK on success dialog
      await showMyDialog(ctx, 'Draft created successfully');

      // After dialog is dismissed, exit this screen and return updated draft
      Get.find<DashboardController>().goBackToDashboardAndReloadTrips();
    } catch (e) {
      Navigator.pop(ctx); // close loading dialog
      showMyDialog(ctx, e.toString());
    }
  }

  /// Post to Uncrewed (calls postUncrewRequest) — the screen handles success UI.
  Future<void> postToUncrewed() async {
    await postUncrewRequest(
      tripId: tripId.toString(),
      oppositeId: pkPilotId.toString(),
      startDate: startDate,
      rate: dayRateController.text,
      endDate: endDate,
      membershiptype: 'Captain',
    );
  }

  /// Fetches available pilots for the given trip window.
  ///
  /// Returns a List<CrewListItem>. Throws an Exception on error so that
  /// caller can show a proper error message.
  Future<List<CrewListItem>> fetchPilotListItems({bool debug = false}) async {
    // Name must match the Cloud Code function name exactly
    final function = ParseCloudFunction('getPilotList');
    final int? departureSourceId = draft.departureSourceId;
    debugPrint("DepartureSourceId for pilot list fetch: $departureSourceId");

    // Convert the MM/dd/yyyy strings to DateTime
    // final DateTime tripStart = parseMmDdYyyy(startDate);
    // final DateTime tripEnd = parseMmDdYyyy(endDate);

    // Convert legacy string inputs to numeric params for Cloud Code.
    // Cloud Code expects Numbers for time thresholds now.
    double? _toDouble(String v) {
      final cleaned = v.replaceAll(',', '').trim();
      return double.tryParse(cleaned);
    }

    int? _toInt(String v) {
      final cleaned = v.replaceAll(',', '').trim();
      return int.tryParse(cleaned);
    }

    final double? totalTimeNum = _toDouble(totalTime);
    final double? totalTimeTypeNum = _toDouble(totalTimeType);
    final double? picTimeNum = _toDouble(picTime);
    final double? picTimeTypeNum = _toDouble(picTimeType);

    final int? milesInt = draft.radius;
    final int? medicalClassInt = _toInt(medicalClass);

    // `args.rate` is dynamic in legacy flow; cloud expects maximumRate as int.
    // We support num / String gracefully.
    int? maximumRateInt;
    
    maximumRateInt = int.tryParse(dayRateController.text);

    if (totalTimeNum == null || totalTimeTypeNum == null || picTimeNum == null || picTimeTypeNum == null) {
      throw Exception('Invalid numeric filter values. Please verify total time / PIC time inputs.');
    }

    if (milesInt == null) {
      throw Exception('Invalid miles value.');
    }

    if (departureSourceId == null || departureSourceId <= 0) {
      throw Exception('Invalid departureSourceId value.');
    }

    if (maximumRateInt == null) {
      throw Exception('Invalid maximum rate value.');
    }

    if (medicalClassInt == null) {
      throw Exception('Invalid medical class value.');
    }

    // Availability logic:
    // •	Available Captains ✅ → true
    // •	Search All Captains ✅ → false
    // - If user selected "Available Captains" => require date-window availability.
    // - If user selected "Search All Captains" => skip date-window availability.
    // (Your Cloud Code still requires pilotProfile.IsAvailability == true when availabilityRequired is false.)
    // final bool availabilityRequiredValue = true;

    try {
      // Prepare parameters to send to Cloud Code.
      // Back4App stores dates in UTC, so we send UTC ISO strings.
      final params = <String, dynamic>{
        // Trip window
        'startDate': dateOnlyToUtcIsoString(draft.startDate!),
        'endDate': dateOnlyToUtcIsoString(draft.endDate!),

        // ratingCertification filters
        'aircraftType': draft.aircraftName, // maps to ratingCertification.aircraftType
        'totalTimeType': totalTimeTypeNum, // compares to ratingCertification.totalHours (Number)
        'picTimeType': picTimeTypeNum, // compares to ratingCertification.pic (Number)
        'monthTraining': monthTraining, // compares to ratingCertification.isReqPrev12MonthTraining
        'ratingType': ratingType, // special case: only filters if exactly 'ATP'
        'maximumRate': maximumRateInt, // compares to ratingCertification.minimumRate

        // pilotProfile filters
        'totalTime': totalTimeNum, // compares to pilotProfile.totalTime (Number)
        'picTime': picTimeNum, // compares to pilotProfile.totalPICTime (Number)
        'medicalClass': medicalClassInt, // compares to pilotProfile.FAAMedical
        'rating': rating, // compares to pilotProfile.rating (Number)
        'validPassport': validPassport, // if true, PassportExpDate must be after trip end
        'continentExp': continentExp, // CSV inclusion check against pilotProfile.Continent
        'oceanicExp': oceanicExp, // CSV inclusion check against pilotProfile.OceanicExp
        'miles': draft.radius!,
        'departureSourceId': draft.departureSourceId,

        // Availability behavior
        'availabilityRequired': false,
        if (debug) 'debug': true,
      };

      if (debug) {
        // Copy/paste friendly payload for testing (matches what Cloud Code logs)
        debugPrint('getPilotList payload: ${jsonEncode(params)}');
      }

      final ParseResponse response = await function.execute(parameters: params);

      if (!response.success) {
        // response.error?.message may be null, so use a fallback
        final errorMsg =
            response.error?.message ?? 'Failed to fetch pilot list (no details).';
        debugPrint('getPilotList error: $errorMsg');
        throw Exception(errorMsg);
      }

      final result = response.result;

      // Cloud Code returns:
      // - normal mode: List<Map<String,dynamic>>
      // - debug mode: { results: List<...>, debug: { ... } }
      List<dynamic> rawList;
      Map<String, dynamic>? debugBlock;

      if (result is List) {
        rawList = result;
      } else if (result is Map) {
        final map = Map<String, dynamic>.from(result);
        final dynamic resultsVal = map['results'];
        if (resultsVal is List) {
          rawList = resultsVal;
        } else {
          debugPrint('getPilotList debug response missing results list: $map');
          throw Exception('Unexpected debug response from server.');
        }

        final dynamic dbgVal = map['debug'];
        if (dbgVal is Map) {
          debugBlock = Map<String, dynamic>.from(dbgVal);
        }
      } else {
        debugPrint('getPilotList unexpected result type: ${result.runtimeType} -> $result');
        throw Exception('Unexpected response from server.');
      }

      // Map each Map<String, dynamic> into CrewListItem
      final List<CrewListItem> items = rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => CrewListItem.fromJson(json))
          .toList();

      debugPrint('getPilotList fetched ${items.length} crew members.');

      // Nicely print rejection reasons when debug mode requested and debug block is present
      if (debug && debugBlock != null) {
        _printPilotListDebug(debugBlock);
      }

      return items;
    } catch (e, stack) {
      // Log detailed error for debugging
      debugPrint('Exception in fetchCrewListItems: $e');
      debugPrint(stack.toString());
      rethrow; // let the caller decide how to handle the error
    }
  }

  void _printPilotListDebug(Map<String, dynamic> debugBlock) {
    try {
      final stage = debugBlock['stage'];
      final message = debugBlock['message'];
      debugPrint('===== getPilotList DEBUG =====');
      debugPrint('Stage: $stage');
      debugPrint('Message: $message');

      final counts = debugBlock['counts'];
      if (counts is Map) {
        debugPrint('Counts: ${Map<String, dynamic>.from(counts)}');
      }

      final reasons = debugBlock['reasonsByPilotId'];
      if (reasons is! Map) {
        debugPrint('No reasonsByPilotId found in debug response.');
        debugPrint('===== END DEBUG =====');
        return;
      }

      final reasonsByPilotId = Map<String, dynamic>.from(reasons);
      if (reasonsByPilotId.isEmpty) {
        debugPrint('No pilot reasons recorded.');
        debugPrint('===== END DEBUG =====');
        return;
      }

      int rejectedCount = 0;
      int passedCount = 0;

      // Print each pilot's reasons grouped by stage (only rejected pilots)
      for (final entry in reasonsByPilotId.entries) {
        final pilotId = entry.key;
        final val = entry.value;
        if (val is! Map) continue;

        final stageMap = Map<String, dynamic>.from(val);
        final cert = (stageMap['cert'] as List?)?.cast<dynamic>() ?? const [];
        final profile = (stageMap['profile'] as List?)?.cast<dynamic>() ?? const [];
        final availability = (stageMap['availability'] as List?)?.cast<dynamic>() ?? const [];

        // Rejected if any stage contains a message other than PASSED
        bool hasRejection(List<dynamic> msgs) => msgs.any((m) => m.toString() != 'PASSED');
        final rejected = hasRejection(cert) || hasRejection(profile) || hasRejection(availability);

        if (!rejected) {
          passedCount++;
          continue; // Skip noise
        }

        rejectedCount++;
        debugPrint('--- Pilot: $pilotId (REJECTED) ---');

        void printStage(String name, List<dynamic> msgs) {
          // Print only rejection lines (skip PASSED)
          final filtered = msgs.where((m) => m.toString() != 'PASSED').toList();
          if (filtered.isEmpty) return;
          debugPrint('  $name:');
          for (final m in filtered) {
            debugPrint('    - $m');
          }
        }

        printStage('cert', cert);
        printStage('profile', profile);
        printStage('availability', availability);
      }

      debugPrint('Rejected pilots: $rejectedCount | Passed (not printed): $passedCount');
      debugPrint('===== END DEBUG =====');
    } catch (e) {
      debugPrint('Failed to print getPilotList debug info: $e');
    }
  }

  /// Updates ONLY pilotRate in the draft, then navigates.
  Future<void> goToDayRateCaptain() async {
    final rateText = dayRateController.text.trim();
    if (rateText.isEmpty) {
      throw Exception('Rate is empty');
    }

    // Legacy behavior: rate is stored without decimals.
    final parsedRate = num.tryParse(rateText);
    if (parsedRate == null) {
      throw Exception('Invalid rate: $rateText');
    }

    // Update draft with pilotRate (no server call here)
    applyCaptainRateToDraft();

    showLoadingDialog(Get.context!, 'Searching...');

    List<CrewListItem> userList = await fetchPilotListItems(debug: kDebugMode);
    debugPrint("users fetched: ${userList.length}");

    // Close the loading dialog regardless
    Get.back();

    debugPrint("Now navigating to ResultCaptainController");

    // Navigate to Result screen. View layer handles import.
    Get.toNamed(
      AppRoutes.resultCaptain,
      arguments: {
        // 'filterData': value?.data,
        'filterData': userList,
        'miles': miles,
        'selectList': selectList,
        'airCraftID': airCraftID,
        'tripId': tripId,
        'boolSIC': boolSIC,
        'boolFI': boolFI,
        'boolFA': boolFA,
        'ratingAirCraftType': ratingAirCraftType,
        'rate': dayRateController.text,
        'startDate': startDate,
        'endDate': endDate,
        'boolCAP': boolCAP,
        'totalTime': totalTime,
        'totalTimeType': totalTimeType,
        'picTime': picTime,
        'picTimeType': picTimeType,
        'medicalClass': medicalClass,
        'rating': rating,
        'validPassport': validPassport,
        'ratingType': ratingType,
        'continentExp': continentExp,
        'oceanicExp': oceanicExp,
        'monthTraining': monthTraining,
      },
    );
  }
}

class DayRateCaptainBinding extends Bindings {
  @override
  void dependencies() {
    // Avoid reusing a stale controller instance when navigating to this route
    // multiple times with different arguments.
    if (Get.isRegistered<DayRateCaptainController>()) {
      Get.delete<DayRateCaptainController>(force: true);
    }

    Get.put<DayRateCaptainController>(DayRateCaptainController());
  }
}