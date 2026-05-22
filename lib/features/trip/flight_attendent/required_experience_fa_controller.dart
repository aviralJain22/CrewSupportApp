import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/features/trip/trip_draft_flow_service.dart';
import 'package:crew_support/features/trip/trip_draft_save_service.dart';
import 'package:crew_support/model/trip_draft_payload.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/model/CountryModel.dart';
import 'package:crew_support/model/LanguagesListModel.dart';
import 'package:crew_support/model/TripDetailsResponse.dart';

class RequiredExperienceFAController extends GetxController implements DraftCommitter {
  // =====================
  // Incoming arguments
  // =====================
  // Provided via Get.toNamed(..., arguments: {...})
  final List<String> selectList;
  final String tripId;
  final int airCraftID;
  final bool boolFI;
  final String miles;
  final bool? backbutton;
  final String? ratingAirCraftType;
  final String? startDate;
  final String? endDate;

  RequiredExperienceFAController({
    required this.selectList,
    required this.tripId,
    required this.airCraftID,
    required this.boolFI,
    required this.miles,
    this.ratingAirCraftType,
    this.backbutton,
    this.startDate,
    this.endDate,
  });

  // =====================
  // Text Controllers
  // =====================
  final totalTimeController = TextEditingController();
  final totalTimeTypeController = TextEditingController();
  final picTimeController = TextEditingController();
  final totalPicTypeController = TextEditingController();
  final medicalClassController = TextEditingController(text: "1");
  final yrExperienceController = TextEditingController();
  final unrestrictedController = TextEditingController();
  final dualGivenController = TextEditingController();
  final complexTimeController = TextEditingController();
  final highPerformanceController = TextEditingController();
  final specialTrainingController = TextEditingController(text: "No");
  final selectTrainingController = TextEditingController();
  final internationalVisaController = TextEditingController();
  final otherSelectTrainingController = TextEditingController();

  // =====================
  // State (reactive)
  // =====================
  final checkboxValidPassportYes = false.obs;
  final checkboxSimulatorYes = false.obs; // kept for parity; not visible in UI
  final checkboxInternationalYes = false.obs; // legacy parity
  final checkboxShowProfileYes = false.obs;
  final checkboxShowGenderYes = false.obs;
  final checkboxTrainingYes = false.obs; // Aircraft specific training

  final continentExpSaveList = <String>[].obs;
  final oceanicSaveList = <String>[].obs; // used for special training selection
  final internationalVisaSaveList = <String>[].obs;
  final languageSaveList = <String>[].obs;

  final rating = 0.obs; // 0..5
  final specialTrainingValue = 'No'.obs;        // mirrors specialTrainingController.text
  final selectedTrainingValue = ''.obs;         // mirrors selectTrainingController.text (may be comma-separated)
  String? yearOfExp; // encoded range value like "1-3"

  final draftBtnClicked = 0.obs;
  final isLoading = false.obs;

  // Static lists (from legacy)
  final List<String> continentExpCountryList = const [
    'North America',
    'South America',
    'Antarctica',
    'Europe',
    'Asia',
    'Africa',
    'Australia',
  ];

  final List<String> specialTrainingList = const [
    'Airline Trained',
    'Beyond & Above',
    'Clay Lacy Onboarding',
    'Corporate Air Parts',
    'CPR Training',
    'Cullinary Training',
    'EJM Onboarding',
    'Evacuation Training',
    'FACTS Training',
    'Flight Safety',
    'Jet Aviation',
    'Jet Edge Onboarding',
    'None',
    'Other',
    'SkyAngels SKYacademy',
    'Solairus Onboarding',
    'VVIP International',
  ];

  // Trip prefill support
  final tripData = <TripDetails>[].obs;

  late final TripDraftFlowService _flow;
  late final TripDraftSaveService _saveService;
  TripDraftPayload get draft => _flow.draft.value;
  bool get isFromAddCrew => _flow.isFromAddCrew;

  @override
  void onInit() {
    super.onInit();
    debugPrint('RequiredExperienceFAController._readArguments - Get.arguments: ${Get.arguments}');
    // If needed later, you can auto-load existing draft data here like legacy class 2 did.
    // Keeping UI instant for now unless explicitly requested.
    specialTrainingValue.value = specialTrainingController.text;
    selectedTrainingValue.value = selectTrainingController.text;

    _flow = Get.find<TripDraftFlowService>();
    _saveService = TripDraftSaveService(_flow);

    final isFromDraftTab = _flow.isFromDraftTab;

    debugPrint('draft: ${draft.toJson()}');

    if (isFromAddCrew) {
      debugPrint('RequiredExperienceFAController initialized from Add Crew flow with args: ${Get.arguments}');
      _prefillFromDraftRequirements();
    } else if (isFromDraftTab) {
      debugPrint('RequiredExperienceFAController initialized from Drafts tab with args: ${Get.arguments}');
      _prefillFromDraftRequirements();
    }
  }

  @override
  void onClose() {
    // Dispose text controllers
    totalTimeController.dispose();
    totalTimeTypeController.dispose();
    picTimeController.dispose();
    totalPicTypeController.dispose();
    medicalClassController.dispose();
    yrExperienceController.dispose();
    unrestrictedController.dispose();
    dualGivenController.dispose();
    complexTimeController.dispose();
    highPerformanceController.dispose();
    specialTrainingController.dispose();
    selectTrainingController.dispose();
    internationalVisaController.dispose();
    otherSelectTrainingController.dispose();
    super.onClose();
  }

  /// Prefills UI fields from draft.roleRequirements['fa'] when editing a saved draft.
  void _prefillFromDraftRequirements() {
    try {
      final dynamic raw = draft.roleRequirements['fa'];
      if (raw is! Map) {
        debugPrint('No FA requirements found in draft.roleRequirements; skipping prefill.');
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

      // Year of experience: stored as encoded range (yrExp). Map it back to visible text.
      final yrRange = _s('yrExp');
      if (yrRange.isNotEmpty) {
        yearOfExp = yrRange;
        yrExperienceController.text = _mapYearRangeToText(yrRange) ?? yrExperienceController.text;
      }

      // Checkboxes
      checkboxTrainingYes.value = _b('aircraftSpecificTraining', fallback: false);
      checkboxValidPassportYes.value = _b('validPassport', fallback: false);
      checkboxShowProfileYes.value = _b('hideProfilePicture', fallback: false);
      checkboxShowGenderYes.value = _b('hideGender', fallback: false);

      // Rating
      rating.value = _i('ratingCount', fallback: 0).clamp(0, 5);

      // Special training yes/no and selected training list
      final bool st = _b('specialTraining', fallback: false);
      specialTrainingController.text = st ? 'Yes' : 'No';
      specialTrainingValue.value = specialTrainingController.text;

      // Special training names are stored in oceanicExp as CSV (legacy)
      final trainingNames = _csvList('oceanicExp');
      oceanicSaveList.assignAll(trainingNames);
      selectTrainingController.text = trainingNames.join(',');
      selectedTrainingValue.value = selectTrainingController.text;

      // Other training text
      otherSelectTrainingController.text = _s('otherSelectTraining');

      // Multi-select lists
      continentExpSaveList.assignAll(_csvList('continentExp'));
      internationalVisaSaveList.assignAll(_csvList('internationalVisa'));
      languageSaveList.assignAll(_csvList('languageSpoken'));

      debugPrint('Prefilled FA requirements from draft (${req.keys.length} keys).');
    } catch (e) {
      debugPrint('Failed to prefill FA requirements from draft: $e');
    }
  }

  /// Maps the encoded year range back to UI display text.
  String? _mapYearRangeToText(String range) {
    switch (range) {
      case '1-1':
        return 'First Available';
      case '0-1':
        return 'Less than 1 year';
      case '1-3':
        return '1-3 years';
      case '3-5':
        return '3-5 years';
      case '5-10':
        return '5-10 years';
      case '10-50':
        return 'More than 10 years';
      default:
        return null;
    }
  }

  @override
  void commitToDraft() {
    _applyFARequirementsToDraft();
  }

  /// Updates the shared draft.roleRequirements['fa'] from the current form state.
  /// This mirrors the Captain controller pattern and preserves other roles' requirements.
  void _applyFARequirementsToDraft() {
    // Year-of-experience encoded range (legacy format)
    final String? yr = mapYearTextToRange(yrExperienceController.text);

    // Special training details
    final bool specialTrainingYes = specialTrainingController.text.trim() == 'Yes';
    final String selectedTraining = selectTrainingController.text.trim();
    final String otherTraining = otherSelectTrainingController.text.trim();

    // Legacy semantics: if "Other" chosen, use otherTraining as the effective name
    final String specialTrainedName =
        (selectedTraining == 'Other') ? otherTraining : selectedTraining;

    final Map<String, dynamic> faReq = <String, dynamic>{
      'yrExp': yr, // e.g. '1-3'
      'aircraftSpecificTraining': checkboxTrainingYes.value,
      'specialTraining': specialTrainingYes,

      // In this FA controller oceanicSaveList is used as training-name selection holder
      'oceanicExp': oceanicSaveList.join(','),

      'continentExp': continentExpSaveList.join(','),
      'internationalVisa': internationalVisaSaveList.join(','),
      'languageSpoken': languageSaveList.join(','),
      'validPassport': checkboxValidPassportYes.value,
      'hideProfilePicture': checkboxShowProfileYes.value,
      'hideGender': checkboxShowGenderYes.value,
      'ratingCount': rating.value,
      'specialTrainedName': specialTrainedName,
      'otherSelectTraining': otherTraining,
    };

    final updated = draft.copyWith(
      roleRequirements: <String, dynamic>{
        ...draft.roleRequirements,
        'fa': faReq,
      },
    );

    _flow.updateDraft(updated);
  }

  // =====================
  // Helpers (UI actions)
  // =====================

  /// Maps the visible text to the encoded year range used by backend.
  String? mapYearTextToRange(String text) {
    switch (text) {
      case 'First Available':
        return '1-1';
      case 'Less than 1 year':
        return '0-1';
      case '1-3 years':
        return '1-3';
      case '3-5 years':
        return '3-5';
      case '5-10 years':
        return '5-10';
      case 'More than 10 years':
        return '10-50';
      default:
        return null;
    }
  }

  /// Opens year-of-experience selector (CupertinoActionSheet). Updates text + internal range.
  void showYearOfExperiencePicker(BuildContext context) {
    final action = Theme(
      data: ThemeData.dark(),
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text('First Available', style: TextStyle(color: AppColor.textColor1)),
            onPressed: () {
              yrExperienceController.text = 'First Available';
              yearOfExp = '1-1';
              Get.back();
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Less than 1 year', style: TextStyle(color: AppColor.textColor1)),
            onPressed: () {
              yrExperienceController.text = 'Less than 1 year';
              yearOfExp = '0-1';
              Get.back();
            },
          ),
          CupertinoActionSheetAction(
            child: Text('1-3 years', style: TextStyle(color: AppColor.textColor1)),
            onPressed: () {
              yrExperienceController.text = '1-3 years';
              yearOfExp = '1-3';
              Get.back();
            },
          ),
          CupertinoActionSheetAction(
            child: Text('3-5 years', style: TextStyle(color: AppColor.textColor1)),
            onPressed: () {
              yrExperienceController.text = '3-5 years';
              yearOfExp = '3-5';
              Get.back();
            },
          ),
          CupertinoActionSheetAction(
            child: Text('5-10 years', style: TextStyle(color: AppColor.textColor1)),
            onPressed: () {
              yrExperienceController.text = '5-10 years';
              yearOfExp = '5-10';
              Get.back();
            },
          ),
          CupertinoActionSheetAction(
            child: Text('More than 10 years', style: TextStyle(color: AppColor.textColor1)),
            onPressed: () {
              yrExperienceController.text = 'More than 10 years';
              yearOfExp = '10-50';
              Get.back();
            },
          ),
        ],
      ),
    );
    showCupertinoModalPopup(context: context, builder: (c) => action);
  }

  /// Multi-select for Continent Experience
  Future<void> openContinentExpDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return Theme(
          data: ThemeData.dark(),
          child: MultiSelectDialog<String>(
            height: 30.h,
            width: 80.w,
            selectedColor: AppColor.secondaryColor1,
            checkColor: AppColor.textColor2,
            unselectedColor: AppColor.textColor1,
            itemsTextStyle: TextStyle(color: AppColor.textColor1),
            selectedItemsTextStyle: TextStyle(color: AppColor.secondaryColor1),
            title: Text('Select Continent', style: TextStyle(color: AppColor.secondaryColor1)),
            items: continentExpCountryList.map((e) => MultiSelectItem<String>(e, e)).toList(),
            initialValue: continentExpSaveList.toList(),
            onConfirm: (values) {
              continentExpSaveList.assignAll(values);
            },
          ),
        );
      },
    );
  }

  /// Multi-select for Special Training names
  Future<void> openSpecialTrainingNamesDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return Theme(
          data: ThemeData.dark(),
          child: MultiSelectDialog<String>(
            title: Text('Select Training', style: TextStyle(color: AppColor.secondaryColor1)),
            height: 30.h,
            width: 80.w,
            items: specialTrainingList.map((e) => MultiSelectItem<String>(e, e)).toList(),
            initialValue: oceanicSaveList.toList(),
            itemsTextStyle: TextStyle(color: AppColor.textColor1),
            checkColor: AppColor.textColor2,
            unselectedColor: AppColor.textColor1,
            selectedColor: AppColor.secondaryColor1,
            selectedItemsTextStyle: TextStyle(color: AppColor.secondaryColor1),
            onConfirm: (values) {
              oceanicSaveList.assignAll(values);
              selectTrainingController.text = oceanicSaveList.join(',');
              selectedTrainingValue.value = selectTrainingController.text;
            },
          ),
        );
      },
    );
  }

  /// Multi-select for International Visa Held (countries)
  Future<void> openInternationalVisaDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return Theme(
          data: ThemeData.dark(),
          child: MultiSelectDialog<String>(
            title: Text('Select Country', style: TextStyle(color: AppColor.secondaryColor1)),
            items: citizenshipCountryList.map((e) => MultiSelectItem<String>(e, e)).toList(),
            initialValue: internationalVisaSaveList.toList(),
            itemsTextStyle: TextStyle(color: AppColor.textColor1),
            checkColor: AppColor.textColor2,
            unselectedColor: AppColor.textColor1,
            selectedColor: AppColor.secondaryColor1,
            selectedItemsTextStyle: TextStyle(color: AppColor.secondaryColor1),
            searchable: true,
            onConfirm: (values) {
              internationalVisaSaveList.assignAll(values);
            },
          ),
        );
      },
    );
  }

  /// Multi-select for Languages
  Future<void> openLanguageDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return Theme(
          data: ThemeData.dark(),
          child: MultiSelectDialog<String>(
            title: Text('Select Language', style: TextStyle(color: AppColor.secondaryColor1)),
            items: languageCountryList.map((e) => MultiSelectItem<String>(e, e)).toList(),
            initialValue: languageSaveList.toList(),
            itemsTextStyle: TextStyle(color: AppColor.textColor1),
            checkColor: AppColor.textColor2,
            unselectedColor: AppColor.textColor1,
            selectedColor: AppColor.secondaryColor1,
            selectedItemsTextStyle: TextStyle(color: AppColor.secondaryColor1),
            searchable: true,
            onConfirm: (values) {
              languageSaveList.assignAll(values);
            },
          ),
        );
      },
    );
  }

  /// Yes/No picker for Special Training
  void showSpecialTrainingPicker(BuildContext context) {
    final action = Theme(
      data: ThemeData.dark(),
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text('Yes', style: TextStyle(color: AppColor.textColor1)),
            onPressed: () {
              specialTrainingController.text = 'Yes';
              specialTrainingValue.value = 'Yes';
              Get.back();
            },
          ),
          CupertinoActionSheetAction(
            child: Text('No', style: TextStyle(color: AppColor.textColor1)),
            onPressed: () {
              specialTrainingController.text = 'No';
              specialTrainingValue.value = 'No';
              oceanicSaveList.clear();
              selectTrainingController.clear();
              selectedTrainingValue.value = '';
              otherSelectTrainingController.clear();
              Get.back();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel', style: TextStyle(color: AppColor.textColor1)),
          onPressed: Get.back,
        ),
      ),
    );
    showCupertinoModalPopup(context: context, builder: (_) => action);
  }

  // =====================
  // Actions (NEXT / Save Draft)
  // =====================

  /// Validates and navigates to Day Rate screen
  void onTapNext(BuildContext context) {
    if (yrExperienceController.text.isEmpty) {
      showMyDialog(context, 'Please enter year of experience');
      return;
    }
    if (specialTrainingController.text.isEmpty) {
      showMyDialog(context, 'Please select Yes or No for special training');
      return;
    }
    if (specialTrainingController.text == 'Yes' && selectTrainingController.text.isEmpty) {
      showMyDialog(context, 'Please select special training');
      return;
    }
    if (specialTrainingController.text == 'Yes' && selectTrainingController.text == 'Other' && otherSelectTrainingController.text.isEmpty) {
      showMyDialog(context, 'Please enter other training');
      return;
    }

    final mapped = mapYearTextToRange(yrExperienceController.text);

    _applyFARequirementsToDraft(); // Update shared draft with current FA requirements before navigating
    
    // Navigate using named route (adjust route & arg keys if needed in your app)
    Get.toNamed(
      AppRoutes.dayRateFA,
      arguments: {
        'startDate': startDate?.toString(),
        'endDate': endDate?.toString(),
        'othertraning': otherSelectTrainingController.text, // legacy carried this along
        'selectList': selectList,
        'tripId': tripId, // 0 => fresh entry (old DayRateFAScreen) and any other value switches it to draft-aware mode 
        'airCraftID': airCraftID,
        'boolFI': boolFI,
        'yrExp': mapped,
        'aircraftSpecificTraining': checkboxTrainingYes.value,
        'specialTraining': specialTrainingController.text == 'Yes',
        'oceanicexp': oceanicSaveList.join(','),
        'continentExp': continentExpSaveList.join(','),
        'internationalVisa': internationalVisaSaveList.join(','),
        'languageSpoken': languageSaveList.join(','),
        'validPassport': checkboxValidPassportYes.value,
        'hideProfilePicture': checkboxShowProfileYes.value,
        'hideGender': checkboxShowGenderYes.value,
        'ratingCount': rating.value,
        'specialTrainedName': selectTrainingController.text == 'Other' ? otherSelectTrainingController.text : selectTrainingController.text,
        'otherSelectTraining': otherSelectTrainingController.text.trim(),
        'miles': miles.toString(),
        "ratingAirCraftType": ratingAirCraftType,
        // 'unrestrictedUSPass': true,
        // 'monthTraining': true,

      },
    );
  }

  /// Save as draft
  Future<void> onTapSaveDraft() async {
    debugPrint("Saving draft with current FA requirements...");

    final ctx = Get.context!;

    // If user hasn't filled mandatory fields for this screen, do not save.
    if (yrExperienceController.text.isEmpty) {
      showMyDialog(ctx, 'Please enter year of experience');
      return;
    }
    if (specialTrainingController.text.isEmpty) {
      showMyDialog(ctx, 'Please select Yes or No for special training');
      return;
    }
    if (specialTrainingController.text == 'Yes' && selectTrainingController.text.isEmpty) {
      showMyDialog(ctx, 'Please select special training');
      return;
    }
    if (specialTrainingController.text == 'Yes' && selectTrainingController.text == 'Other' && otherSelectTrainingController.text.isEmpty) {
      showMyDialog(ctx, 'Please enter other training');
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
}

/// Binding for RequiredExperienceFAScreen
///
/// Pulls arguments from Get.arguments and constructs the controller.
/// This keeps your screen widget lean and matches the legacy ctor params.
class RequiredExperienceFABinding extends Bindings {
  @override
  void dependencies() {
    final args = (Get.arguments as Map?) ?? <String, dynamic>{};

    // Defensive parsing with sensible defaults
    final List<String> selectList =
        (args['selectList'] as List?)?.cast<String>() ?? <String>[];
    final String tripId = args['tripId'].toString();
    final int airCraftID = _toInt(args['airCraftID']);
    final bool boolFI = (args['boolFI'] as bool?) ?? false;
    final String miles = (args['miles']?.toString()) ?? '0';
    final bool? backbutton = args['backbutton'] as bool?;
    final String? startDate = args['startDate']?.toString();
    final String? endDate = args['endDate']?.toString();
    final String ratingAirCraftType = args['ratingAirCraftType']?.toString() ?? '';

    // Avoid reusing a stale controller instance when navigating to this route
    // multiple times with different arguments.
    if (Get.isRegistered<RequiredExperienceFAController>()) {
      Get.delete<RequiredExperienceFAController>(force: true);
    }

    Get.put<RequiredExperienceFAController>(
      RequiredExperienceFAController(
        selectList: selectList,
        tripId: tripId,
        airCraftID: airCraftID,
        boolFI: boolFI,
        miles: miles,
        backbutton: backbutton,
        startDate: startDate,
        endDate: endDate,
        ratingAirCraftType: ratingAirCraftType,
      ),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}