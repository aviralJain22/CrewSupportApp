import 'dart:convert';

import 'package:crew_support/Api/Api_service.dart';
import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/features/trip/trip_draft_flow_service.dart';
import 'package:crew_support/features/trip/trip_draft_save_service.dart';
import 'package:crew_support/model/crew_list_item.dart';
import 'package:crew_support/model/trip_draft_payload.dart';
import 'package:crew_support/utils/constants.dart';
import 'package:crew_support/utils/Utility.dart'; // showLoadingDialog, showMyDialog
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Arguments model (optional but clarifies what's expected)
class DayRateFAArgs {
  // Required (from both legacy screens)
  final List<String> selectList;
  final String yrExp;
  final bool aircraftSpecificTraining;
  final bool? unrestrictedUSPass;
  final bool specialTraining;
  final String languageSpoken;
  final bool validPassport;
  final String internationalVisa;
  final String continentExp;
  final bool? monthTraining;
  final bool hideProfilePicture;
  final bool hideGender;
  final String otherSelectTraining;
  final String specialTrainedName;
  final String tripId;
  final int airCraftID;
  final int ratingCount;
  final bool boolFI;
  final dynamic othertraning;
  final String miles;
  final String startDate;
  final String endDate;
  final String? ratingAirCraftType;

  /// Legacy code had two spellings. We accept both and normalize.
  final String? oceanicexp; // from DayRateFAScreen
  final String? ocenicExp;  // from DayRateFAScreen2

  DayRateFAArgs({
    required this.selectList,
    required this.yrExp,
    required this.aircraftSpecificTraining,
    required this.unrestrictedUSPass,
    required this.specialTraining,
    required this.languageSpoken,
    required this.validPassport,
    required this.internationalVisa,
    required this.continentExp,
    required this.monthTraining,
    required this.hideProfilePicture,
    required this.hideGender,
    required this.otherSelectTraining,
    required this.specialTrainedName,
    required this.tripId,
    required this.airCraftID,
    required this.ratingCount,
    required this.boolFI,
    required this.othertraning,
    required this.miles,
    required this.startDate,
    required this.endDate,
    this.oceanicexp,
    this.ocenicExp,
    this.ratingAirCraftType,
  });

  /// One canonical value to use everywhere.
  String get oceanicExpNormalized => (oceanicexp ?? ocenicExp ?? '').trim();

  /// Build from Get.arguments (Map) safely.
  factory DayRateFAArgs.from(dynamic raw) {
    final m = (raw ?? {}) as Map;
    return DayRateFAArgs(
      selectList: List<String>.from(m['selectList'] ?? const []),
      yrExp: (m['yrExp'] ?? '').toString(),
      aircraftSpecificTraining: (m['aircraftSpecificTraining'] ?? false) as bool,
      unrestrictedUSPass: m['unrestrictedUSPass'] as bool?,
      specialTraining: (m['specialTraining'] ?? false) as bool,
      languageSpoken: (m['languageSpoken'] ?? '').toString(),
      validPassport: (m['validPassport'] ?? false) as bool,
      internationalVisa: (m['internationalVisa'] ?? '').toString(),
      continentExp: (m['continentExp'] ?? '').toString(),
      monthTraining: m['monthTraining'] as bool?,
      hideProfilePicture: (m['hideProfilePicture'] ?? false) as bool,
      hideGender: (m['hideGender'] ?? false) as bool,
      otherSelectTraining: (m['otherSelectTraining'] ?? '').toString(),
      specialTrainedName: (m['specialTrainedName'] ?? '').toString(),
      tripId: (m['tripId'] ?? '').toString(),
      airCraftID: int.tryParse((m['airCraftID'] ?? 0).toString()) ?? 0,
      ratingCount: int.tryParse((m['ratingCount'] ?? 0).toString()) ?? 0,
      boolFI: (m['boolFI'] ?? false) as bool,
      othertraning: m['othertraning'],
      miles: (m['miles'] ?? '').toString(),
      startDate: (m['startDate'] ?? '').toString(),
      endDate: (m['endDate'] ?? '').toString(),
      oceanicexp: m['oceanicexp']?.toString(),
      ocenicExp: m['ocenicExp']?.toString(),
      ratingAirCraftType: (m['ratingAirCraftType'] ?? '').toString(),
    );
  }
}

class DayRateFAController extends GetxController implements DraftCommitter {
  late final DayRateFAArgs args;

  /// Determines “fresh vs draft mode” (old Screen vs Screen2)
  // bool get isDraftMode => args.tripId != 0;
  /// Draft mode when tripId is non-empty and not "0".
  bool get isDraftMode => args.tripId.trim().isNotEmpty && args.tripId.trim() != '0';

  /// UI controllers
  final dayRateController = TextEditingController();

  /// Screen-level loading (for draft fetch)
  final isLoading = false.obs;

  /// State replicated from legacy DayRateFAScreen2 for draft prefill
  final checkboxValidPassportYes = false.obs;
  final checkboxSimulatorYes = false.obs; // isReqPrev12MonthTraining
  final usPass = false.obs;
  final checkboxShowProfileYes = false.obs;
  final checkboxTrainingYes = false
      .obs; // aircraft specific training (legacy _checkboxTrainingYes)

  /// Lists (we keep them because Save Draft (Screen2) used joined strings)
  final continentExpSaveList = <String>[].obs;
  final oceanicSaveList = <String>[].obs;
  final internationalVisaSaveList = <String>[].obs;
  final languageSaveList = <String>[].obs;

  /// Rating
  final rating = 0.obs;

  /// Normalized helpers
  String get yrExp => args.yrExp;
  String get oceanicExp => args.oceanicExpNormalized;

  late final TripDraftFlowService _flow;
  late final TripDraftSaveService _saveService;
  TripDraftPayload get draft => _flow.draft.value;
  bool get isFromAddCrew => _flow.isFromAddCrew;

  String get miles => args.miles;

  @override
  void onInit() {
    super.onInit();
    debugPrint('DayRateFAController._readArguments - Get.arguments: ${Get.arguments}');
    args = DayRateFAArgs.from(Get.arguments);

    _flow = Get.find<TripDraftFlowService>();
    _saveService = TripDraftSaveService(_flow);

    debugPrint('DayRateFAController draft: ${draft.toJson()}');

    final far = draft.attendantRate;
    if (far != null) dayRateController.text = far.toString().split('.').first;
  }

  @override
  void onClose() {
    dayRateController.dispose();
    super.onClose();
  }

  void applyFARateToDraft() {
    final parsed = num.tryParse(dayRateController.text.trim());
    if (parsed != null) {
      _flow.updateDraft(draft.copyWith(attendantRate: parsed));
    }
  }

  @override
  void commitToDraft() {
    applyFARateToDraft();
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

  /// Tap “OK” in radio dialog with option "Post trip for crew to apply"
  Future<void> postUncrewed(BuildContext context) async {
    // Legacy Screen1 showed a loader and awaited; Screen2 didn’t.
    // We’ll follow Screen1 (safer UX).
    showLoadingDialog(context, 'Loading...');
    try {
      final pilotId = (pkPilotId ?? '').toString();
      await postUncrewRequest(
        tripId: args.tripId.toString(),
        oppositeId: pilotId.toString(),
        startDate: args.startDate,
        rate: dayRateController.text.toString(),
        endDate: args.endDate,
        membershiptype: 'Flight Attendant',
      );
      Navigator.of(context).pop(); // close loader
      // Pop to root (same as legacy)
      Get.offAllNamed('/'); // or: Get.until((route) => route.isFirst);
    } catch (e) {
      Navigator.of(context).pop(); // close loader
      // Optionally: showMyDialog(context, 'Failed to post: $e');
    }
  }

  Future<List<CrewListItem>> fetchAttendantListItems({bool debug = false}) async {
    final function = ParseCloudFunction('getAttendantList');
    final int? departureSourceId = draft.departureSourceId;
    debugPrint("DepartureSourceId for attendant list fetch: $departureSourceId");

    // Legacy flow passes MM/dd/yyyy strings.
    // final DateTime tripStart = parseMmDdYyyy(args.startDate);
    // final DateTime tripEnd = parseMmDdYyyy(args.endDate);

    final int? milesInt = draft.radius;

    if (milesInt == null) {
      throw Exception('Invalid miles value.');
    }

    if (departureSourceId == null || departureSourceId <= 0) {
      throw Exception('Invalid departureSourceId value.');
    }

    // yearsOfExperience comes from `yrExp` (string)
    double? yearsExpNum;
    if (yrExp.trim().isNotEmpty) {
      yearsExpNum = double.tryParse(yrExp.replaceAll(',', '').trim());
    }

    // maximumRate comes from `rate` (string)
    int? maximumRateInt;
    if (_safeRateTwoDecimals().trim().isNotEmpty) {
      maximumRateInt = int.tryParse(_safeRateTwoDecimals().replaceAll(',', '').trim());
    }

    // internationalVisa is stored in this controller as a String (legacy).
    // New Cloud Code expects a bool.
    // We treat any non-empty, non-zero, non-false value as true.
    bool internationalVisaBool = false;
    final String visaRaw = args.internationalVisa.trim().toLowerCase();
    if (visaRaw.isNotEmpty && visaRaw != '0' && visaRaw != 'false' && visaRaw != 'off' && visaRaw != 'no') {
      internationalVisaBool = true;
    }

    // rating: we map ratingCount (int) to rating threshold (Number) for attendants.
    // If your UI uses ratingCount differently, tell me and we’ll adjust.
    final int ratingThreshold = args.ratingCount;

    // ratingType: not present in FA controller inputs; keep as empty string for API parity.
    final String ratingTypeValue = '';

    // Build params
    final params = <String, dynamic>{
      'startDate': dateOnlyToUtcIsoString(draft.startDate!),
      'endDate': dateOnlyToUtcIsoString(draft.endDate!),

      // Required by Cloud Code implementation
      'aircraftType': draft.aircraftName,

      // Optional filters
      if (yearsExpNum != null) 'yearsOfExperience': yearsExpNum,
      'ratingType': ratingTypeValue,
      if (maximumRateInt != null) 'maximumRate': maximumRateInt,
      'rating': ratingThreshold,
      'validPassport': args.validPassport,
      'continentExp': args.continentExp,
      'internationalVisa': internationalVisaBool,
      'languageSpoken': args.languageSpoken,
      'aircraftSpecificTraining': args.aircraftSpecificTraining,
      'specialTraining': args.specialTraining,
      'specialTrainedName': args.specialTrainedName,
      'otherSelectTraining': args.otherSelectTraining,
      'miles': draft.radius!,
      'departureSourceId': draft.departureSourceId,

      // Availability behavior
      'availabilityRequired': false,
      if (debug) 'debug': true,
    };

    if (debug) {
      debugPrint('getAttendantList payload: ${jsonEncode(params)}');
    }

    final ParseResponse response = await function.execute(parameters: params);

    if (!response.success) {
      final errorMsg = response.error?.message ?? 'Failed to fetch attendant list (no details).';
      debugPrint('getAttendantList error: $errorMsg');
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
        debugPrint('getAttendantList debug response missing results list: $map');
        throw Exception('Unexpected debug response from server.');
      }

      final dynamic dbgVal = map['debug'];
      if (dbgVal is Map) {
        debugBlock = Map<String, dynamic>.from(dbgVal);
      }
    } else {
      debugPrint('getAttendantList unexpected result type: ${result.runtimeType} -> $result');
      throw Exception('Unexpected response from server.');
    }

    final List<CrewListItem> items = rawList
        .whereType<Map<String, dynamic>>()
        .map((json) => CrewListItem.fromJson(json))
        .toList();

    debugPrint('getAttendantList fetched ${items.length} crew members.');

    if (debug && debugBlock != null) {
      _printAttendantListDebug(debugBlock);
    }

    return items;
  }

  void _printAttendantListDebug(Map<String, dynamic> debugBlock) {
    try {
      final stage = debugBlock['stage'];
      final message = debugBlock['message'];
      debugPrint('===== getAttendantList DEBUG =====');
      debugPrint('Stage: $stage');
      debugPrint('Message: $message');

      final counts = debugBlock['counts'];
      if (counts is Map) {
        debugPrint('Counts: ${Map<String, dynamic>.from(counts)}');
      }

      final reasons = debugBlock['reasonsByAttendantId'];
      if (reasons is! Map) {
        debugPrint('No reasonsByAttendantId found in debug response.');
        debugPrint('===== END DEBUG =====');
        return;
      }

      final reasonsById = Map<String, dynamic>.from(reasons);
      if (reasonsById.isEmpty) {
        debugPrint('No attendant reasons recorded.');
        debugPrint('===== END DEBUG =====');
        return;
      }

      int rejectedCount = 0;
      int passedCount = 0;

      for (final entry in reasonsById.entries) {
        final attendantId = entry.key;
        final val = entry.value;
        if (val is! Map) continue;

        final stageMap = Map<String, dynamic>.from(val);
        final profile = (stageMap['profile'] as List?)?.cast<dynamic>() ?? const [];
        final availability = (stageMap['availability'] as List?)?.cast<dynamic>() ?? const [];

        bool hasRejection(List<dynamic> msgs) => msgs.any((m) => m.toString() != 'PASSED');
        final rejected = hasRejection(profile) || hasRejection(availability);

        if (!rejected) {
          passedCount++;
          continue;
        }

        rejectedCount++;
        debugPrint('--- Attendant: $attendantId (REJECTED) ---');

        void printStage(String name, List<dynamic> msgs) {
          final filtered = msgs.where((m) => m.toString() != 'PASSED').toList();
          if (filtered.isEmpty) return;
          debugPrint('  $name:');
          for (final m in filtered) {
            debugPrint('    - $m');
          }
        }

        printStage('profile', profile);
        printStage('availability', availability);
      }

      debugPrint('Rejected attendants: $rejectedCount | Passed (not printed): $passedCount');
      debugPrint('===== END DEBUG =====');
    } catch (e) {
      debugPrint('Failed to print getAttendantList debug info: $e');
    }
  }

  Future<void> onTapNext() async {
    final rawRate = dayRateController.text.trim();
    if (rawRate.isEmpty) {
      throw Exception('Please enter rate');
    }

    final parsedRate = num.tryParse(rawRate);
    if (parsedRate == null) {
      throw Exception('Invalid rate: $rawRate');
    }

    applyFARateToDraft(); // Update draft with attendantRate (no server call here)

    final BuildContext ctx = Get.context!;

    // Show loading
    showLoadingDialog(ctx, 'Searching...');

    try {
      // Fetch attendants via Cloud Code (same pattern as captain)
      final List<CrewListItem> userList = await fetchAttendantListItems(debug: kDebugMode);
      debugPrint('users fetched: ${userList.length}');

      // Close loading dialog
      Get.back();

      // Navigate
      Get.toNamed(
        AppRoutes.resultFA,
        arguments: {
          'miles': args.miles.toString(),
          'filterData': userList,
          'tripId': args.tripId,
          'boolFI': args.boolFI,
          'hideGender': args.hideGender,
          'hideProfilePicture': args.hideProfilePicture,
          'airCraftID': args.airCraftID,
          'selectList': args.selectList,
          'rate': _safeRateTwoDecimals(),
          'startDate': args.startDate,
          'endDate': args.endDate,
        },
      );
    } catch (e) {
      // Close loader if open
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      await showMyDialog(ctx, 'Something went wrong. Please try again.');
      debugPrint('Exception in SearchByFAController.onTapNext: $e');
    }

    //OLD CODE AFTER HERE:

    // Navigate to SearchByFA with the existing payload
    
  }
  
  /// Mimics `double.parse(x).toStringAsFixed(2)` but safely handles blanks
  String _safeRateTwoDecimals() {
    final raw = dayRateController.text.trim();
    if (raw.isEmpty) return '0.00';
    final v = double.tryParse(raw) ?? 0.0;
    return v.toStringAsFixed(2);
    // NOTE: fresh vs draft keyboard differences are handled in the screen
  }
}

class DayRateFABinding extends Bindings {
  @override
  void dependencies() {
    // Avoid reusing a stale controller instance when navigating to this route
    // multiple times with different arguments.
    if (Get.isRegistered<DayRateFAController>()) {
      Get.delete<DayRateFAController>(force: true);
    }

    Get.put<DayRateFAController>(DayRateFAController());
  }
}