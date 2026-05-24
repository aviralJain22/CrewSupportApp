import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/features/trip/trip_draft_flow_service.dart';
import 'package:crew_support/features/trip/trip_draft_save_service.dart';
import 'package:crew_support/app/routes.dart';
import 'package:crew_support/model/trip_draft_payload.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart'; // for .spV2 font scaling parity
import 'package:crew_support/model/TripDetailsResponse.dart';

class RequiredExperienceCaptainController extends GetxController implements DraftCommitter {
  // ====== Route arguments ======
  late List<String> selectList;
  late String tripId;
  late bool boolSIC;
  late bool boolFI;
  late bool boolFA;
  late bool boolCAP;
  late String miles;
  late int airCraftID;
  late String ratingAirCraftType;
  String? startDate;
  String? endDate;

  // ====== Text controllers (form fields) ======
  final totalTimeController = TextEditingController();
  final totalTimeTypeController = TextEditingController();
  final picTimeController = TextEditingController();
  final totalPicTypeController = TextEditingController();
  final medicalClassController = TextEditingController(text: '1');
  final selectTrainingController = TextEditingController(); // holds CSV of selections
  final otherSelectTrainingController = TextEditingController();
  final unrestrictedController = TextEditingController();
  final specialTrainingController = TextEditingController(); // "Yes"/"No"
  final dayRateController = TextEditingController();

  // ====== Reactive state ======
  final isLoading = false.obs;
  final checkboxValidPassportYes = false.obs; // Default: No
  final checkboxSimulatorYes = true.obs; // "12 month simulator current"
  final isCommercial = false.obs;
  final isATP = true.obs; // Default: ATP
  final rating = 0.obs; // 0..5

  // Mirror non-Rx TextEditingController values for Obx visibility conditions
  final specialTraining = ''.obs; // holds 'Yes' / 'No'
  final selectTrainingCsv = ''.obs; // CSV of selected 135 trainings (may include 'Other')

  // Multi-select selections (reactive)
  final continentExpSaveList = <String>[].obs;
  final oceanicSaveList = <String>[].obs;
  final languageSaveList = <String>[].obs; // (not shown on UI here, but kept for parity)

  // Static lists (keep order to match legacy UI text/ordering)
  final List<String> specialTrainingList = const [
    'Clay Lacy Qualified',
    'EJM Qualified',
    'Jet Edge Qualified',
    'Solairus Qualified',
  ];

  final List<String> continentExpCountryList = const [
    'North America',
    'South America',
    'Antarctica',
    'Europe',
    'Asia',
    'Africa',
    'Australia',
  ];

  final List<String> oceanicCountryList = const [
    'North Atlantic',
    'South Pacific',
    'North Pacific',
  ];

  // Draft trip cache
  final tripData = <TripDetails>[].obs;

  late final TripDraftFlowService _flow;
  late final TripDraftSaveService _saveService;
  TripDraftPayload get draft => _flow.draft.value;
  bool get isFromAddCrew => _flow.isFromAddCrew;

  @override
  void onInit() {
    super.onInit();
    debugPrint('RequiredExperienceCaptainController.onInit - Get.arguments: ${Get.arguments}');
    // Reset state so this controller never shows stale values if it gets reused.
    totalTimeController.clear();
    totalTimeTypeController.clear();
    picTimeController.clear();
    totalPicTypeController.clear();
    medicalClassController.text = '1';
    selectTrainingController.clear();
    otherSelectTrainingController.clear();
    unrestrictedController.clear();
    specialTrainingController.clear();
    dayRateController.clear();

    isLoading.value = false;
    checkboxValidPassportYes.value = false; // Default: No
    checkboxSimulatorYes.value = true;
    isCommercial.value = false;
    isATP.value = true; // Default: ATP
    rating.value = 0;
    specialTraining.value = '';
    selectTrainingCsv.value = '';
    continentExpSaveList.assignAll(<String>[]);
    oceanicSaveList.assignAll(<String>[]);
    languageSaveList.assignAll(<String>[]);
    tripData.assignAll(<TripDetails>[]);

    final args = (Get.arguments ?? {}) as Map<String, dynamic>;

    selectList = (args['selectList'] as List?)?.cast<String>() ?? <String>[];
    tripId = args['tripId'] ?? "";
    boolSIC = args['boolSIC'] ?? false;
    boolFI = args['boolFI'] ?? false;
    boolFA = args['boolFA'] ?? false;
    boolCAP = args['boolCAP'] ?? false;
    miles = args['miles'] ?? '';
    airCraftID = args['airCraftID'] ?? 0;
    ratingAirCraftType = args['ratingAirCraftType'] ?? '';
    startDate = args['startDate'];
    endDate = args['endDate'];

    _flow = Get.find<TripDraftFlowService>();
    _saveService = TripDraftSaveService(_flow);
    final isFromDraftTab = _flow.isFromDraftTab;

    debugPrint('draft: ${draft.toJson()}');

    if (isFromAddCrew) {
      debugPrint('RequiredExperienceCaptainController initialized from Add Crew flow with args: $args');
      _prefillFromDraftRequirements();
    } else if (isFromDraftTab) {
      debugPrint('RequiredExperienceCaptainController initialized from Drafts tab with args: $args');
      _prefillFromDraftRequirements();
    }
  }

  /// Prefills UI fields from draft.roleRequirements['captain'] when editing a saved draft.
  void _prefillFromDraftRequirements() {
    try {
      final dynamic raw = draft.roleRequirements['captain'];
      if (raw is! Map) {
        debugPrint('No captain requirements found in draft.roleRequirements; skipping prefill.');
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
        // Some legacy strings might be joined with ',' without spaces
        return t.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }

      // Text fields
      totalTimeController.text = _s('totalTime');
      totalTimeTypeController.text = _s('totalTimeType');
      picTimeController.text = _s('picTime');
      totalPicTypeController.text = _s('picTimeType');

      // Medical class (default to '1' if missing)
      final med = _s('medicalClass');
      medicalClassController.text = med.isEmpty ? '1' : med;

      // Checkbox flags
      checkboxValidPassportYes.value = _b('validPassport', fallback: true);
      checkboxSimulatorYes.value = _b('monthTraining', fallback: true);

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
        // Unknown / empty -> leave as false/false (user must choose)
        isCommercial.value = false;
        isATP.value = false;
      }

      // Multi-select lists
      continentExpSaveList.assignAll(_csvList('continentExp'));
      oceanicSaveList.assignAll(_csvList('oceanicExp'));

      debugPrint('Prefilled Captain requirements from draft (${req.keys.length} keys).');
    } catch (e) {
      debugPrint('Failed to prefill Captain requirements from draft: $e');
    }
  }

  @override
  void commitToDraft() {
    _applyCaptainRequirementsToDraft();
  }

  /// Updates the in-memory draft.roleRequirements['captain'] from the current form state.
  void _applyCaptainRequirementsToDraft() {
    final String ratingType = isCommercial.value && isATP.value
        ? 'ATP,Commercial'
        : (isCommercial.value ? 'Commercial' : 'ATP');

    final Map<String, dynamic> captainReq = <String, dynamic>{
      'totalTime': totalTimeController.text.trim(),
      'totalTimeType': totalTimeTypeController.text.trim(),
      'picTime': picTimeController.text.trim(),
      'picTimeType': totalPicTypeController.text.trim(),
      'continentExp': continentExpSaveList.join(','),
      'oceanicExp': oceanicSaveList.join(','),
      'ratingType': ratingType,
      'monthTraining': checkboxSimulatorYes.value,
      'medicalClass': medicalClassController.text.trim(),
      'validPassport': checkboxValidPassportYes.value,
      'ratingCount': rating.value,
      // Keep dayRate here too; it is passed forward to DayRate screen anyway.
      // 'dayRate': dayRateController.text.trim(),
    };

    final updated = draft.copyWith(
      roleRequirements: {
        ...draft.roleRequirements,
        'captain': captainReq,
      },
    );

    _flow.updateDraft(updated);
  }

  @override
  void onClose() {
    totalTimeController.dispose();
    totalTimeTypeController.dispose();
    picTimeController.dispose();
    totalPicTypeController.dispose();
    medicalClassController.dispose();
    selectTrainingController.dispose();
    otherSelectTrainingController.dispose();
    unrestrictedController.dispose();
    specialTrainingController.dispose();
    dayRateController.dispose();
    super.onClose();
  }

  // ====== Pickers (Cupertino & MultiSelect) ======
  void showMedicalPicker() {
    final ctx = Get.context!;
    final sheet = Theme(
      data: ThemeData.dark(),
      child: CupertinoActionSheet(
        title: Text('Medical Class', style: TextStyle(fontSize: 15.spV2)),
        actions: [
          CupertinoActionSheetAction(
            child: Text('1', style: TextStyle(color: AppColor.textColor1)),
            onPressed: () {
              medicalClassController.text = '1';
              Navigator.pop(ctx);
            },
          ),
          CupertinoActionSheetAction(
            child: Text('2', style: TextStyle(color: AppColor.textColor1)),
            onPressed: () {
              medicalClassController.text = '2';
              Navigator.pop(ctx);
            },
          ),
          CupertinoActionSheetAction(
            child: Text('3', style: TextStyle(color: AppColor.textColor1)),
            onPressed: () {
              medicalClassController.text = '3';
              Navigator.pop(ctx);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel', style: TextStyle(color: AppColor.secondaryColor1)),
          onPressed: () => Navigator.pop(ctx),
        ),
      ),
    );
    showCupertinoModalPopup(context: ctx, builder: (_) => sheet);
  }

  Future<void> openContinentExpDialog() async {
    final ctx = Get.context!;
    await showDialog(
      context: ctx,
      builder: (_) => Theme(
        data: ThemeData.dark(),
        child: MultiSelectDialog<String>(
          height: 45.h,
          width: 80.w,
          selectedColor: AppColor.secondaryColor1,
          checkColor: AppColor.textColor2,
          unselectedColor: AppColor.textColor1,
          itemsTextStyle: TextStyle(color: AppColor.textColor1),
          selectedItemsTextStyle: TextStyle(color: AppColor.secondaryColor1),
          title: Text('Select  Continent', style: TextStyle(color: AppColor.secondaryColor1)),
          items: continentExpCountryList
              .map((c) => MultiSelectItem<String>(c, c))
              .toList(),
          initialValue: continentExpSaveList.toList(),
          onConfirm: (values) {
            final selected = <String>[];
            for (final item in continentExpCountryList) {
              if (values.contains(item)) selected.add(item);
            }
            continentExpSaveList.assignAll(selected);
          },
        ),
      ),
    );
  }

  Future<void> openOceanicDialog() async {
    final ctx = Get.context!;
    await showDialog(
      context: ctx,
      builder: (_) => Theme(
        data: ThemeData.dark(),
        child: MultiSelectDialog<String>(
          height: 25.h,
          width: 80.w,
          selectedColor: AppColor.secondaryColor1,
          checkColor: AppColor.textColor2,
          unselectedColor: AppColor.textColor1,
          itemsTextStyle: TextStyle(color: AppColor.textColor1),
          selectedItemsTextStyle: TextStyle(color: AppColor.secondaryColor1),
          title: Text('Select oceanic region', style: TextStyle(color: AppColor.secondaryColor1)),
          items: oceanicCountryList
              .map((c) => MultiSelectItem<String>(c, c))
              .toList(),
          initialValue: oceanicSaveList.toList(),
          onConfirm: (values) {
            final selected = <String>[];
            for (final item in oceanicCountryList) {
              if (values.contains(item)) selected.add(item);
            }
            oceanicSaveList.assignAll(selected);
          },
        ),
      ),
    );
  }

  Future<void> openSpecialTrainingMulti() async {
    final ctx = Get.context!;
    await showDialog(
      context: ctx,
      builder: (_) => Theme(
        data: ThemeData.dark(),
        child: MultiSelectDialog<String>(
          title: Text('Select 135 Training', style: TextStyle(color: AppColor.secondaryColor1)),
          height: 30.h,
          width: 80.w,
          items: specialTrainingList
              .map((c) => MultiSelectItem<String>(c, c))
              .toList(),
          // Legacy used same holder (oceanicSaveList) to show selections line—keeping for parity
          initialValue: oceanicSaveList.toList(),
          itemsTextStyle: TextStyle(color: AppColor.textColor1),
          checkColor: AppColor.textColor2,
          unselectedColor: AppColor.textColor1,
          selectedColor: AppColor.secondaryColor1,
          selectedItemsTextStyle: TextStyle(color: AppColor.secondaryColor1),
          onConfirm: (values) {
            final selected = <String>[];
            for (final item in specialTrainingList) {
              if (values.contains(item)) selected.add(item);
            }
            oceanicSaveList.assignAll(selected);
            selectTrainingController.text = oceanicSaveList.join(',');
            selectTrainingCsv.value = selectTrainingController.text;
          },
        ),
      ),
    );
  }

  void showSpecialTrainingYesNo() {
    final ctx = Get.context!;
    final sheet = Theme(
      data: ThemeData.dark(),
      child: CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Yes'),
            onPressed: () {
              specialTrainingController.text = 'Yes';
              specialTraining.value = 'Yes';
              Navigator.pop(ctx);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('No'),
            onPressed: () {
              specialTrainingController.text = 'No';
              specialTraining.value = 'No';
              Navigator.pop(ctx);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(ctx),
        ),
      ),
    );
    showCupertinoModalPopup(context: ctx, builder: (_) => sheet);
  }

  // ====== Form actions ======
  bool _validateForm() {
    final ctx = Get.context!;
    if (totalTimeController.text.isEmpty || totalTimeController.text == '0') {
      showMyDialog(ctx, 'Please enter total time');
      return false;
    }
    if (picTimeController.text.isEmpty || picTimeController.text == '0') {
      showMyDialog(ctx, 'Please enter PIC time');
      return false;
    }
    if (totalTimeTypeController.text.isEmpty ||
        totalTimeTypeController.text == '0') {
      showMyDialog(ctx, 'Please enter total time in type');
      return false;
    }
    if (totalPicTypeController.text.isEmpty ||
        totalPicTypeController.text == '0') {
      showMyDialog(ctx, 'Please enter PIC time in type');
      return false;
    }
    if (medicalClassController.text == '0') {
      showMyDialog(ctx, 'Please select proper medical class');
      return false;
    }
    if (!isCommercial.value && !isATP.value) {
      showMyDialog(ctx, 'Please select rating type');
      return false;
    }
    return true;
  }

  /// NEXT button → navigate via named route (ensure AppRoutes.dayRateCaptain exists).
  void onTapNext() {
    if (!_validateForm()) return;

    _applyCaptainRequirementsToDraft(); // Update draft with current form values before navigating

    Get.toNamed(
      AppRoutes.dayRateCaptain,
      arguments: {
        'boolCAP': boolCAP,
        'miles': miles,
        // 'rate': dayRateController.text,
        'selectList': selectList,
        'tripId': tripId,
        'boolSIC': boolSIC,
        'boolFA': boolFA,
        'boolFI': boolFI,
        'airCraftID': airCraftID,
        'totalTime': totalTimeController.text,
        'totalTimeType': totalTimeTypeController.text,
        'picTime': picTimeController.text,
        'picTimeType': totalPicTypeController.text,
        'continentExp': continentExpSaveList.join(','),
        'ratingType': isCommercial.value && isATP.value
            ? 'ATP,Commercial'
            : (isCommercial.value ? 'Commercial' : 'ATP'),
        'monthTraining': checkboxSimulatorYes.value,
        'medicalClass': medicalClassController.text,
        'validPassport': checkboxValidPassportYes.value,
        'ratingAirCraftType': ratingAirCraftType,
        'rating': rating.value,
        'oceanicExp': oceanicSaveList.join(','),
        'startDate': startDate?.toString(),
        'endDate': endDate?.toString(),
      },
    );
  }

  /// Save as draft
  Future<void> onTapSaveDraft() async {
    final ctx = Get.context!;

    // If user hasn't filled mandatory fields for this screen, do not save.
    if (!_validateForm()) return;

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
}

class RequiredExperienceCaptainBinding extends Bindings {
  @override
  void dependencies() {
    // Avoid reusing a stale controller instance when navigating to this route
    // multiple times with different arguments.
    if (Get.isRegistered<RequiredExperienceCaptainController>()) {
      Get.delete<RequiredExperienceCaptainController>(force: true);
    }

    Get.put<RequiredExperienceCaptainController>(
      RequiredExperienceCaptainController(),
    );
  }
}