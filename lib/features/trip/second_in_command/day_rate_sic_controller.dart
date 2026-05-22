import 'dart:convert';

import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/features/trip/trip_draft_flow_service.dart';
import 'package:crew_support/features/trip/trip_draft_save_service.dart';
import 'package:crew_support/model/crew_list_item.dart';
import 'package:crew_support/model/trip_draft_payload.dart';
import 'package:crew_support/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:crew_support/utils/Utility.dart'; // for showLoadingDialog / showMyDialog
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart'; // <-- spV2 (font scaling compat)
import 'package:crew_support/Api/Api_service.dart';       // new API import
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:sizer/sizer.dart';     // for logged-in pilot id (pkPilotId etc.)

/// Controller that unifies the old DayRateSICScreen and DayRateSICScreen2.
/// - If tripId > 0 => loads draft (Screen2 behavior)
/// - Else           => plain screen (Screen1 behavior)
class DayRateSicController extends GetxController implements DraftCommitter {
  // ---------- Inputs from previous screen (kept 1:1 with old code) ----------
  // Keep names to reduce confusion during migration.
  late final List<String> selectList;
  late final String totalTime;
  late final String totalTimeType;
  late final String medicalClass;
  late final bool validPassport;
  late final String ratingType;
  late final String continentExp;
  late final bool monthTraining;
  late final String ratingAirCraftType;
  // late final String fAAMedical;
  late final String tripId;
  late final bool boolFI;
  late final bool boolFA;
  late final bool boolSIC;
  late final int airCraftId;
  late final String miles;
  late final int rating;
  late final String startDate;
  late final String endDate;

  // ---------- UI / State ----------
  final dayRateController = TextEditingController();
  final isLoading = false.obs;

  // Optional: expose a currency symbol in case the old UI ever toggled it.
  final currencySymbol = '\$';

  late final TripDraftFlowService _flow;
  late final TripDraftSaveService _saveService;
  TripDraftPayload get draft => _flow.draft.value;
  bool get isFromAddCrew => _flow.isFromAddCrew;

  @override
  void onInit() {
    super.onInit();

    debugPrint('DayRateSicController._readArguments - Get.arguments: ${Get.arguments}');

    // Safely extract arguments passed via Get.toNamed(...)
    final args = (Get.arguments as Map?) ?? <String, dynamic>{};

    selectList          = (args['selectList'] as List?)?.cast<String>() ?? const <String>[];
    totalTime           = args['totalTime']            ?? '';
    totalTimeType       = args['totalTimeType']        ?? '';
    medicalClass        = args['medicalClass']         ?? '';
    validPassport       = args['validPassport']        ?? false;
    ratingType          = args['ratingType']           ?? '';
    continentExp        = args['continentExp']         ?? '';
    monthTraining       = args['monthTraining']        ?? false;
    tripId              = args['tripId']               ?? "";
    boolFI              = args['boolFI']               ?? false;
    boolFA              = args['boolFA']               ?? false;
    boolSIC             = args['boolSIC']              ?? false;
    miles               = args['miles']                ?? '';
    airCraftId          = args['airCraftId']           ?? 0;
    // ratingCount         = args['ratingCount']          ?? '0';
    // fAAMedical          = args['fAAMedical']           ?? '';
    ratingAirCraftType  = args['ratingAirCraftType']   ?? '';
    startDate           = args['startDate']            ?? '';
    endDate             = args['endDate']              ?? '';
    rating = int.tryParse((args['rating'] ?? 0).toString()) ?? 0;

    // If we came here to edit an existing draft, fetch and pre-fill (Screen2 behavior)
    //TODO:
    // if (tripId > 0) {
    //   _loadDraftIfAny();
    // }

    _flow = Get.find<TripDraftFlowService>();
    _saveService = TripDraftSaveService(_flow);

    debugPrint('DayRateSICController draft: ${draft.toJson()}');

    final sicr = draft.sicRate;
    if (sicr != null) dayRateController.text = sicr.toString().split('.').first;
  }

  void applySICRateToDraft() {
    final parsed = num.tryParse(dayRateController.text.trim());
    if (parsed != null) {
      _flow.updateDraft(draft.copyWith(sicRate: parsed));
    }
  }

  @override
  void commitToDraft() {
    applySICRateToDraft();
  }

  /// Handles "Next" flow -> shows the two-option dialog and proceeds accordingly.
  /// Kept identical to legacy: Search OR Post Uncrewed.
  Future<void> onTapNext(BuildContext context) async {
    // We show a dialog with two radio options; implement here to keep logic in controller.
    int selected = 0; // default same as old code

    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                borderRadius: BorderRadius.circular(5.w),
              ),
              backgroundColor: AppColor.bgColor1,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _optionTile(
                    title: 'Search for crew matching your criteria.',
                    selected: selected == 0,
                    onChanged: () => setState(() => selected = 0),
                  ),
                  // const SizedBox(height: 10),
                  // _optionTile(
                  //   title: 'Post trip for crew to apply',
                  //   selected: selected == 1,
                  //   onChanged: () => setState(() => selected = 1),
                  // ),
                ],
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColor.secondaryColor1),
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text('Cancel', style: TextStyle(color: AppColor.bgColor1, fontSize: 10.spV2)),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColor.secondaryColor1),
                    onPressed: () async {
                      Navigator.of(dialogCtx).pop(); // close the choice dialog
                      if (selected == 0) {
                        // === Option 0: Update SIC rate then go to SearchBySIC ===
                        // showLoadingDialogNew('Loading...');
                        try {
                          await _goToResultSic();
                        } catch (e) {
                          // closeLoadingDialog();
                          await showMyDialogNew(e.toString().replaceFirst('Exception: ', ''));
                        }
                      } else {
                        // === Option 1: Post uncrewed ===
                        await _postUncrewed(context);
                      }
                    },
                    child: Text('OK', style: TextStyle(color: AppColor.bgColor1, fontSize: 10.spV2)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Builds a single radio option tile used by the dialog above.
  Widget _optionTile({
    required String title,
    required bool selected,
    required VoidCallback onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.bgColor1, width: 1),
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(color: AppColor.secondaryColor1, fontSize: 13.spV2)),
        leading: Radio<bool>(
          value: true,
          groupValue: selected,
          fillColor: MaterialStateProperty.all(AppColor.secondaryColor1),
          onChanged: (_) => onChanged(),
        ),
        onTap: onChanged,
      ),
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
    debugPrint("DepartureSourceId for SIC pilot list fetch: $departureSourceId");

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
    // final double? picTimeNum = _toDouble(picTime);
    // final double? picTimeTypeNum = _toDouble(picTimeType);

    final int? milesInt = draft.radius;
    final int? medicalClassInt = _toInt(medicalClass);

    // `args.rate` is dynamic in legacy flow; cloud expects maximumRate as int.
    // We support num / String gracefully.
    int? maximumRateInt;
    // if (rate is int) {
    //   maximumRateInt = rate as int;
    // } else if (rate is num) {
    //   maximumRateInt = (rate as num).round();
    // } else if (rate is String) {
      maximumRateInt = int.tryParse(dayRateController.text.trim());
    // }

    if (totalTimeNum == null || totalTimeTypeNum == null) {
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
        // 'picTimeType': picTimeTypeNum, // compares to ratingCertification.pic (Number)
        'monthTraining': monthTraining, // compares to ratingCertification.isReqPrev12MonthTraining
        'ratingType': ratingType, // special case: only filters if exactly 'ATP'
        'maximumRate': maximumRateInt, // compares to ratingCertification.minimumRate

        // pilotProfile filters
        'totalTime': totalTimeNum, // compares to pilotProfile.totalTime (Number)
        // 'picTime': picTimeNum, // compares to pilotProfile.totalPICTime (Number)
        'medicalClass': medicalClassInt, // compares to pilotProfile.FAAMedical
        'rating': rating, // compares to pilotProfile.rating (Number)
        'validPassport': validPassport, // if true, PassportExpDate must be after trip end
        'continentExp': continentExp, // CSV inclusion check against pilotProfile.Continent
        // 'oceanicExp': oceanicExp, // CSV inclusion check against pilotProfile.OceanicExp
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


  /// Updates ONLY SICRate on the trip (cloud function: updateTrip), then navigates.
  /// Mirrors DayRateCaptainController.goToSearchByCaptain behavior.
  Future<void> _goToResultSic() async {
    final rateText = dayRateController.text.trim();
    if (rateText.isEmpty) {
      throw Exception('Rate is empty');
    }

    // Legacy behavior: rate is stored without decimals.
    final parsedRate = num.tryParse(rateText);
    if (parsedRate == null) {
      throw Exception('Invalid rate: $rateText');
    }

    // Update draft with sicRate (no server call here)
    applySICRateToDraft();

    showLoadingDialog(Get.context!, 'Searching...');
    
    List<CrewListItem> userList = await fetchPilotListItems(debug: kDebugMode);
    debugPrint("users fetched: ${userList.length}");

    // Close the loading dialog regardless
    Get.back();

    // Navigate to Result screen. View layer handles import.
        Get.toNamed(
          AppRoutes.resultSIC,
          arguments: {
            // 'filterData': value?.data,
            'filterData': userList,
            'miles': miles,
            'selectList': selectList,
            'airCraftID': airCraftId,
            'tripId': tripId,
            'boolSIC': boolSIC,
            'boolFI': boolFI,
            'boolFA': boolFA,
            'ratingAirCraftType': ratingAirCraftType,
            'rate': dayRateController.text,
            'startDate': startDate,
            'endDate': endDate,
            'totalTime': totalTime,
            'totalTimeType': totalTimeType,
            // 'picTime': picTime,
            // 'picTimeType': picTimeType,
            'medicalClass': medicalClass,
            'rating': rating,
            'validPassport': validPassport,
            'ratingType': ratingType,
            'continentExp': continentExp,
            // 'oceanicExp': oceanicExp,
            'monthTraining': monthTraining,

          },
        );
  }

  /// Posts an uncrewed request (kept as close to old behavior as possible).
  Future<void> _postUncrewed(BuildContext context) async {
    showLoadingDialog(context, 'Loading...');
    try {
      final pilotId = (pkPilotId ?? '').toString(); // adjust getter if needed
      await postUncrewRequest(
        tripId: '$tripId',
        oppositeId: pilotId,
        startDate: startDate,
        rate: dayRateController.text,
        endDate: endDate,
        membershiptype: 'Second In Command',
      );
      Navigator.of(context).pop(); // close loading
      // Show final confirmation just like old code did in the secondary dialog
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
            borderRadius: BorderRadius.circular(5.w),
          ),
          backgroundColor: AppColor.bgColor1,
          title: Text(
            'Trip has been added to uncrewed tab.',
            style: TextStyle(color: AppColor.secondaryColor1, fontSize: 12.spV2),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColor.secondaryColor1),
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK', style: TextStyle(color: AppColor.bgColor1, fontSize: 10.spV2)),
              ),
            ),
          ],
        ),
      );
      // Pop to root (old code used popUntil(isFirst))
      Get.until((route) => route.isFirst);
    } catch (e) {
      Navigator.of(context).pop(); // close loading
      // Mirror old try/catch — show a simple error message
      showMyDialog(context, 'Error posting trip. Please try again.');
    }
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

  @override
  void onClose() {
    dayRateController.dispose();
    super.onClose();
  }
}

class DayRateSicBinding extends Bindings {
  @override
  void dependencies() {
    // Avoid reusing a stale controller instance when navigating to this route
    // multiple times with different arguments.
    if (Get.isRegistered<DayRateSicController>()) {
      Get.delete<DayRateSicController>(force: true);
    }

    Get.put<DayRateSicController>(DayRateSicController());
  }
}