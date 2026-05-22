import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/features/trip/trip_draft_flow_service.dart';
import 'package:crew_support/features/trip/trip_draft_save_service.dart';
import 'package:crew_support/model/trip_draft_payload.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/Utility.dart';

/// Input payload for this screen (keeps navigation tidy).
class RequiredExperienceSICArgs {
  final List<String> selectList;
  final String tripId;
  final int airCraftID;
  final String miles;
  final bool boolFI;
  final bool boolFA;
  final bool boolSIC;
  final bool? lockBackButton; // old: bacbutton / backbutton
  final String ratingAirCraftType;
  final String? startDate;
  final String? endDate;
  final bool loadDraft; // when true, mimics old "Screen2" behavior

  const RequiredExperienceSICArgs({
    required this.selectList,
    required this.tripId,
    required this.airCraftID,
    required this.miles,
    required this.boolFI,
    required this.boolFA,
    required this.boolSIC,
    required this.ratingAirCraftType,
    this.startDate,
    this.endDate,
    this.lockBackButton,
    this.loadDraft = false,
  });

  @override
  String toString() {
    return 'RequiredExperienceSICArgs('
        'selectList: $selectList, '
        'tripId: $tripId, '
        'airCraftID: $airCraftID, '
        'miles: $miles, '
        'boolFI: $boolFI, '
        'boolFA: $boolFA, '
        'boolSIC: $boolSIC, '
        'lockBackButton: $lockBackButton, '
        'ratingAirCraftType: $ratingAirCraftType, '
        'startDate: $startDate, '
        'endDate: $endDate, '
        'loadDraft: $loadDraft'
        ')';
  }
}

/// GetX Controller that holds all state & actions for Required Experience (SIC).
class RequiredExperienceSICController extends GetxController implements DraftCommitter {
  /// Text controllers (match old behavior)
  final totalTimeController = TextEditingController();
  final totalTimeTypeController = TextEditingController();
  final medicalClassController = TextEditingController(text: "1");
  final dayRateController = TextEditingController();

  /// Reactive state (maps 1:1 with legacy booleans/ints)
  final isValidPass = false.obs;
  final isCommercial = false.obs;
  final isATP = true.obs;
  final checkbox12SimulatorYes = true.obs;
  final rating = 0.obs;

  /// Multi-select continent state
  final continentExpCountryList = <String>[
    'North America',
    'South America',
    'Antarctica',
    'Europe',
    'Asia',
    'Africa',
    'Australia'
  ];
  final continentExpSaveList = <String>[].obs;

  /// Loader (used in Screen2 flow)
  final isLoading = false.obs;

  /// Navigation arguments
  late final RequiredExperienceSICArgs args;

  /// Convenience
  bool get lockBack => args.lockBackButton == true;

  late final TripDraftFlowService _flow;
  late final TripDraftSaveService _saveService;
  TripDraftPayload get draft => _flow.draft.value;
  bool get isFromAddCrew => _flow.isFromAddCrew;

  /// Lifecycle
  @override
  void onInit() {
    super.onInit();
    debugPrint('RequiredExperienceSICController._readArguments - Get.arguments: ${Get.arguments}');
    // Read arguments passed via Get.toNamed(..., arguments: RequiredExperienceSICArgs(...))
    args = _parseArgs(Get.arguments);

    // If mimicking old RequiredExperienceSICScreen2 -> preload draft
    if (args.loadDraft) {
      _getDraftTripDetails();
    } else {
      // Matches old Screen1: just print miles
      print("miles ${args.miles}");
    }

    _flow = Get.find<TripDraftFlowService>();
    _saveService = TripDraftSaveService(_flow);
    final isFromDraftTab = _flow.isFromDraftTab;

    debugPrint('draft: ${draft.toJson()}');

    if (isFromAddCrew) {
      debugPrint('RequiredExperienceSICController initialized from Add Crew flow with args: $args');
      _prefillFromDraftRequirements();
    } else if (isFromDraftTab) {
      debugPrint('RequiredExperienceSICController initialized from Drafts tab with args: $args');
      _prefillFromDraftRequirements();
    }
  }
  
  /// Prefills UI fields from draft.roleRequirements['sic'] when editing a saved draft.
  void _prefillFromDraftRequirements() {
    try {
      final dynamic raw = draft.roleRequirements['sic'];
      if (raw is! Map) {
        debugPrint('No SIC requirements found in draft.roleRequirements; skipping prefill.');
        return;
      }

      final Map<String, dynamic> req = raw.cast<String, dynamic>();

      String _s(String key) => (req[key]?.toString() ?? '').trim();

      bool _b(String key, {bool fallback = false}) {
        final v = req[key];
        if (v is bool) return v;
        if (v is String) {
          final t = v.trim().toLowerCase();
          if (t == 'true' || t == 'yes' || t == '1') return true;
          if (t == 'false' || t == 'no' || t == '0') return false;
        }
        if (v is num) return v != 0;
        return fallback;
      }

      int _i(String key, {int fallback = 0}) {
        final v = req[key];
        if (v is int) return v;
        if (v is num) return v.toInt();
        return int.tryParse(v?.toString() ?? '') ?? fallback;
      }

      List<String> _csvList(String key) {
        final t = _s(key);
        if (t.isEmpty) return <String>[];
        return t.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }

      // Text fields
      totalTimeController.text = _s('totalTime');
      totalTimeTypeController.text = _s('totalTimeType');

      // Medical class (default to '1' if missing)
      final med = _s('medicalClass');
      medicalClassController.text = med.isEmpty ? '1' : med;

      // Checkbox flags
      checkbox12SimulatorYes.value = _b('monthTraining', fallback: false);
      isValidPass.value = _b('validPassport', fallback: false);

      // Rating stars
      rating.value = _i('ratingCount', fallback: 0).clamp(0, 5);

      // Rating type (Commercial / ATP / both)
      final rt = _s('ratingType');
      if (rt == 'ATP,Commercial' || rt == 'Commercial,ATP') {
        isCommercial.value = true;
        isATP.value = true;
      } else if (rt == 'Commercial') {
        isCommercial.value = true;
        isATP.value = false;
      } else if (rt == 'ATP') {
        isCommercial.value = false;
        isATP.value = true;
      } else {
        isCommercial.value = false;
        isATP.value = true;
      }

      // Multi-select lists
      continentExpSaveList.assignAll(_csvList('continentExp'));

      debugPrint('Prefilled SIC requirements from draft (${req.keys.length} keys).');
    } catch (e) {
      debugPrint('Failed to prefill SIC requirements from draft: $e');
    }
  }

  @override
  void onClose() {
    // Dispose controllers to avoid leaks
    totalTimeController.dispose();
    totalTimeTypeController.dispose();
    medicalClassController.dispose();
    dayRateController.dispose();
    super.onClose();
  }

  @override
  void commitToDraft() {
    _applySICRequirementsToDraft();
  }

  /// Updates the shared draft.roleRequirements['sic'] from the current form state.
  void _applySICRequirementsToDraft() {
    // Match Captain controller semantics for ratingType string
    final String ratingType = isCommercial.value && isATP.value
        ? 'ATP,Commercial'
        : (isCommercial.value ? 'Commercial' : 'ATP');

    final Map<String, dynamic> sicReq = <String, dynamic>{
      'totalTime': totalTimeController.text.trim(),
      'totalTimeType': totalTimeTypeController.text.trim(),
      'continentExp': continentExpSaveList.join(','),
      'ratingType': ratingType,
      'monthTraining': checkbox12SimulatorYes.value,
      'medicalClass': medicalClassController.text.trim(),
      'validPassport': isValidPass.value,
      'ratingCount': rating.value,
      // Keep dayRate out here (handled on DayRateSIC screen and stored in draft.sicRate)
      // 'dayRate': dayRateController.text.trim(),
    };

    final updated = draft.copyWith(
      roleRequirements: <String, dynamic>{
        ...draft.roleRequirements,
        'sic': sicReq,
      },
    );

    _flow.updateDraft(updated);
  }

  // --- Argument parsing helpers to accept either our Args class or a legacy Map ---
  RequiredExperienceSICArgs _parseArgs(dynamic raw) {
    if (raw is RequiredExperienceSICArgs) return raw;
    if (raw is Map) {
      T? _pick<T>(List<String> keys) {
        for (final k in keys) {
          if (raw.containsKey(k) && raw[k] is T) return raw[k] as T;
        }
        return null;
      }

      List<String> _pickStringList(List<String> keys) {
        for (final k in keys) {
          final v = raw[k];
          if (v is List) {
            return v.map((e) => e.toString()).toList();
          }
          if (v is String) {
            // handle comma-separated
            return v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          }
        }
        return <String>[];
      }

      int _pickInt(List<String> keys, {int fallback = 0}) {
        final v = _pick<dynamic>(keys);
        if (v == null) return fallback;
        if (v is int) return v;
        if (v is String) return int.tryParse(v) ?? fallback;
        if (v is double) return v.toInt();
        return fallback;
      }

      bool _pickBool(List<String> keys, {bool fallback = false}) {
        final v = _pick<dynamic>(keys);
        if (v == null) return fallback;
        if (v is bool) return v;
        if (v is String) return v.toLowerCase() == 'true' || v == '1';
        if (v is num) return v != 0;
        return fallback;
      }

      String _pickString(List<String> keys, {String fallback = ''}) {
        final v = _pick<dynamic>(keys);
        if (v == null) return fallback;
        return v.toString();
      }

      return RequiredExperienceSICArgs(
        selectList: _pickStringList(['selectList','SelectList']),
        tripId: _pickString(['tripId','TripId','tripID']),
        airCraftID: _pickInt(['airCraftID','airCraftId','AircraftId','AircraftID']),
        miles: _pickString(['miles','Miles'], fallback: ''),
        boolFI: _pickBool(['boolFI','BoolFI','fi']),
        boolFA: _pickBool(['boolFA','BoolFA','fa']),
        boolSIC: _pickBool(['boolSIC','BoolSIC','sic']),
        ratingAirCraftType: _pickString(['ratingAirCraftType','RatingAirCraftType','aircraftType'], fallback: ''),
        startDate: _pickString(['startDate','StartDate'], fallback: '').isEmpty ? null : _pickString(['startDate','StartDate']),
        endDate: _pickString(['endDate','EndDate'], fallback: '').isEmpty ? null : _pickString(['endDate','EndDate']),
        lockBackButton: _pickBool(['lockBackButton','backbutton','bacbutton'], fallback: false),
        loadDraft: _pickBool(['loadDraft','LoadDraft'], fallback: false),
      );
    }

    // Fallback minimal args to avoid crash; you can navigate here with Map safely.
    return RequiredExperienceSICArgs(
      selectList: const <String>[],
      tripId: "",
      airCraftID: 0,
      miles: '',
      boolFI: false,
      boolFA: false,
      boolSIC: false,
      ratingAirCraftType: '',
      lockBackButton: false,
      loadDraft: false,
    );
  }

  /// Show Medical Class picker (CupertinoActionSheet as in legacy code)
  void showMedicalPicker(BuildContext context) {
    final action = Theme(
      data: ThemeData.dark(),
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            isDefaultAction: false,
            onPressed: () {
              medicalClassController.text = "1";
              Navigator.pop(context);
            },
            child: Text("1", style: TextStyle(color: AppColor.textColor1)),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: false,
            onPressed: () {
              medicalClassController.text = "2";
              Navigator.pop(context);
            },
            child: Text("2", style: TextStyle(color: AppColor.textColor1)),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: false,
            onPressed: () {
              medicalClassController.text = "3";
              Navigator.pop(context);
            },
            child: Text("3", style: TextStyle(color: AppColor.textColor1)),
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text("Cancel", style: TextStyle(color: AppColor.secondaryColor1)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
    showCupertinoModalPopup(context: context, builder: (_) => action);
  }

  /// Show Continent Experience multi-select dialog (same look/feel)
  Future<void> showContinentDialog(BuildContext context) async {
    // We use the original package widget by opening a dialog from the screen (keeps UI identical).
    // Controller only prepares the confirm action handler.
    await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Theme(
          data: ThemeData.dark(),
          child: MultiSelectDialog(
            height: 45.h,
            width: 80.w,
            title: Text('Select Continent', style: TextStyle(color: AppColor.secondaryColor1)),
            selectedColor: AppColor.secondaryColor1,
            checkColor: AppColor.textColor2,
            unselectedColor: AppColor.textColor1,
            itemsTextStyle: TextStyle(color: AppColor.textColor1),
            selectedItemsTextStyle: TextStyle(color: AppColor.secondaryColor1),
            items: continentExpCountryList
                .map((c) => MultiSelectItem<String>(c, c))
                .toList(),
            initialValue: continentExpSaveList.toList(),
            onConfirm: (values) {
              // Keep exact algorithm to preserve order & legacy behavior
              final List<String> picked = values;
              final List<String> finalList = [];
              for (int i = 0; i < continentExpCountryList.length; i++) {
                for (int j = 0; j < picked.length; j++) {
                  if (continentExpCountryList[i] == picked[j]) {
                    finalList.add(continentExpCountryList[i]);
                  }
                }
              }
              continentExpSaveList
                ..clear()
                ..addAll(finalList);
              print(continentExpSaveList.join(","));
            },
          ),
        );
      },
    );
  }

  /// NEXT button: validate & navigate (matches legacy)
  void onTapNext() {
    if (totalTimeController.text.isEmpty) {
      showMyDialog(Get.context!, "Please enter total time");
      return;
    }
    if (totalTimeTypeController.text.isEmpty) {
      showMyDialog(Get.context!, "Please enter total time in type");
      return;
    }
    if (!isCommercial.value && !isATP.value) {
      showMyDialog(Get.context!, "Please select rating type");
      return;
    }

    // Build shared arguments for the DayRate screen(s)
    final map = {
      "startDate": args.startDate?.toString(),
      "endDate": args.endDate?.toString(),
      "boolSIC": args.boolSIC,
      "miles": args.miles,
      "selectList": args.selectList,
      "boolFA": args.boolFA,
      "boolFI": args.boolFI,
      "tripId": args.tripId, // int (0 for new; >0 to load draft)
      "airCraftId": args.airCraftID,
      "totalTime": totalTimeController.text,
      "totalTimeType": totalTimeTypeController.text,
      "continentExp": continentExpSaveList.join(","),
      // Preserve exact concatenation logic from the legacy code
      "ratingType": (isCommercial.value ? "Commercial," : "") +
          (isCommercial.value && isATP.value ? "" : "") +
          (isATP.value ? "ATP" : ""),
      "monthTraining": checkbox12SimulatorYes.value,
      "medicalClass": medicalClassController.text,
      "validPassport": isValidPass.value,
      "rating": rating.value,
      "ratingAirCraftType": args.ratingAirCraftType,
    };

    _applySICRequirementsToDraft(); // Update draft with current form values before navigating

    Get.toNamed(
      AppRoutes.dayRateSIC,
      arguments: map,
    );

    // Get.toNamed(routeName, arguments: map);
  }

  /// Save as draft
  Future<void> onTapSaveDraft() async {

    // If user hasn't filled mandatory fields for this screen, do not save.
    if (totalTimeController.text.isEmpty) {
      showMyDialog(Get.context!, "Please enter total time");
      return;
    }
    if (totalTimeTypeController.text.isEmpty) {
      showMyDialog(Get.context!, "Please enter total time in type");
      return;
    }
    if (!isCommercial.value && !isATP.value) {
      showMyDialog(Get.context!, "Please select rating type");
      return;
    }

    final ctx = Get.context!;

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

  /// Legacy Screen2 only: fetch draft and prefill form
  Future<void> _getDraftTripDetails() async {
    // isLoading.value = true;
    // try {
    //   final t = args.tripId;
    //   if (t != 0) {
    //     final draftData = await getTripDetail(
    //       tripId: args.tripId,
    //       pilotId: pkPilotId.toString(),
    //     );

    //     if (draftData?.data?.trip == null) {
    //       isLoading.value = false;
    //       return;
    //     }

    //     final trip = draftData!.data!.trip[0];

    //     // Rating type toggles from one of: 'Commercial', 'ATP', 'ATP,Commercial'
    //     final r = trip.ratingSIC?.toString() ?? '';
    //     if (r == 'Commercial') {
    //       isCommercial.value = true;
    //       isATP.value = false;
    //     } else if (r == 'ATP') {
    //       isCommercial.value = false;
    //       isATP.value = true;
    //     } else if (r == 'ATP,Commercial') {
    //       isCommercial.value = true;
    //       isATP.value = true;
    //     }

    //     // 12-month simulator current
    //     checkbox12SimulatorYes.value = (trip.IsReqPrev12MonthTrainingSIC == true);

    //     // Valid passport
    //     isValidPass.value = (trip.HavePassportSIC == true);

    //     // Rating count
    //     final sc = (trip.RatingCountSIC ?? '').toString();
    //     if (sc.isNotEmpty) {
    //       rating.value = int.tryParse(sc) ?? 0;
    //     }

    //     // Day rate (strip decimals like legacy)
    //     final rateSic = (trip.rateSIC ?? '').toString();
    //     if (rateSic.isNotEmpty && rateSic != '0.0') {
    //       final idx = rateSic.indexOf('.');
    //       dayRateController.text = idx > 0 ? rateSic.substring(0, idx) : rateSic;
    //     }

    //     // FAA Medical
    //     final faa = (trip.FAAMedicalSIC).toString();
    //     medicalClassController.text = faa.isEmpty ? '1' : faa;

    //     // Times
    //     totalTimeController.text = (trip.AircraftTotalTimeSIC ?? '').toString();
    //     totalTimeTypeController.text = (trip.TotalTimeAircraftIdSIC ?? '').toString();

    //     // Continents
    //     final cont = (trip.ContinentSIC ?? '').toString();
    //     if (cont.isNotEmpty) {
    //       continentExpSaveList
    //         ..clear()
    //         ..addAll(cont.split(","));
    //     }

    //     isLoading.value = false;
    //   } else {
    //     isLoading.value = false;
    //   }
    // } catch (e) {
    //   isLoading.value = false;
    //   print('getDraftTripDetails error: $e');
    // }
  }
}

/// Binding for this screen (so GetX can lazily create controller with args)
class RequiredExperienceSICBinding extends Bindings {
  @override
  void dependencies() {
    // Avoid reusing a stale controller instance when navigating to this route
    // multiple times with different arguments.
    if (Get.isRegistered<RequiredExperienceSICController>()) {
      Get.delete<RequiredExperienceSICController>(force: true);
    }

    Get.put<RequiredExperienceSICController>(RequiredExperienceSICController());
  }
}
