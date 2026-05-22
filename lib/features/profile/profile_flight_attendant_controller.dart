import 'dart:convert';
import 'dart:io' show File, Platform;
import 'dart:io' as Io;
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/helper/user_helper.dart';
import 'package:crew_support/model/AircraftModel.dart';
import 'package:crew_support/utils/AppColor.dart'; // NEW path
import 'package:crew_support/utils/constants.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart'; // NEW spV2
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/social_field_utils.dart';
import 'package:crew_support/utils/url_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileFlightAttendantController extends GetxController with WidgetsBindingObserver {
  // ----------------------------
  // Text editing controllers
  // ----------------------------
  final membershipTypeController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passportController = TextEditingController();
  final genderController = TextEditingController();
  final phoneNumberController = TextEditingController();

  final dayDomesticController = TextEditingController();
  final dayInternationalController = TextEditingController();

  final instagramController = TextEditingController();
  final facebookController = TextEditingController();
  final linkedinController = TextEditingController();

  final bioController = TextEditingController();
  final yrExperienceController = TextEditingController();
  final passportExpireDateController = TextEditingController();
  final otherTrainingController = TextEditingController();
  final currentLocationController = TextEditingController();

  // ----------------------------
  // Mirrors of original values to detect edits
  // ----------------------------
  String firstName = '';
  String lastName = '';
  String email = '';
  String passport = '';
  String gender = '';
  String phoneNumber = '';
  String dayDomestic = '';
  String dayInternational = '';
  String instagram = '';
  String facebook = '';
  String linkedin = '';
  String bio = '';
  String yrExperience = '';
  String passportExpireDate = '';
  String otherTraining = '';
  String currentLocation = '';

  bool isIgnoreAvailability = false;
  bool isIgnoreAvailabilityCheck = false;

  // ----------------------------
  // UI + state
  // ----------------------------
  final isLoading = true.obs;
  final isPressed = true.obs;

  final isSpecialTraining = false.obs;
  final specialTrainingValue = false.obs;

  final checkboxTrainingNo = false.obs;
  final checkboxTrainingYes = false.obs;
  final checkBoxValue = false.obs;

  final isFullTime = false.obs;
  final isFullTimeCheck = false.obs;

  final isDefault = false.obs;
  final isDefaultCheck = false.obs;

  final isShowResume = false.obs;
  final isShowResumeCheck = false.obs;

  final permissions = false.obs;
  final country = RxnString('');
  final city = RxnString('');

  // “this field changed?” flags (legacy dots)
  final firstNameBool = false.obs;
  final lastNameBool = false.obs;
  final emailBool = false.obs;
  final phoneBool = false.obs;
  final bioBool = false.obs;
  final currentLocaBool = false.obs;
  final fullTime = false.obs;
  final showResume = false.obs;
  final aircraftBool = false.obs;
  final aircraftSpecialBool = false.obs;
  final internationalBool = false.obs;
  final languageBool = false.obs;
  final specialBool = false.obs;
  final specialNameBool = false.obs;
  final continent2Bool = false.obs;
  final continentBool = false.obs;
  final yroeBool = false.obs;
  final passportBool = false.obs;
  final passportDateBool = false.obs;
  final instaBool = false.obs;
  final facebookBool = false.obs;
  final linkedinBool = false.obs;
  final domRPDBool = false.obs;
  final genderBool = false.obs;
  final intRPDBool = false.obs;
  final allowBool = false.obs; //for ignoring availability

  /// True if ANY editable field has been modified.
  ///
  /// Uses existing per-field marker flags first, and then falls back to a few
  /// direct comparisons for areas where a marker could be missed.
  bool get hasAnyChange {
    // 1) Marker flags (fast path)
    final markerChanged =
        firstNameBool.value ||
        lastNameBool.value ||
        emailBool.value ||
        phoneBool.value ||
        bioBool.value ||
        currentLocaBool.value ||
        fullTime.value ||
        showResume.value ||
        aircraftBool.value ||
        aircraftSpecialBool.value ||
        internationalBool.value ||
        languageBool.value ||
        specialBool.value ||
        specialNameBool.value ||
        continent2Bool.value ||
        continentBool.value ||
        yroeBool.value ||
        passportBool.value ||
        passportDateBool.value ||
        instaBool.value ||
        facebookBool.value ||
        linkedinBool.value ||
        domRPDBool.value ||
        genderBool.value ||
        intRPDBool.value ||
        allowBool.value;

    if (markerChanged) return true;

    // 2) Fallback comparisons (keeps the button accurate even if a marker is missed)

    // Special training toggle
    final specialTrainingChanged = (isSpecialTraining.value != specialTrainingValue.value);
    if (specialTrainingChanged) return true;

    // Multi-selects
    final selectTrainingChanged = (selectTrainingSaveList.join(', ') != selectTrainingStr.value);
    if (selectTrainingChanged) return true;

    final languageChanged = (languageSaveList.join(', ') != languageStr.value);
    if (languageChanged) return true;

    final visasChanged = (internationalVisaSaveList.join(', ') != internationalVisaStr.value);
    if (visasChanged) return true;

    final continentChanged = (continentSaveList.join(', ') != continentStr.value);
    if (continentChanged) return true;

    final regionExpChanged = (continentExpSaveList.join(', ') != continentExpStr.value);
    if (regionExpChanged) return true;

    final aircraftChanged = (aircraftTypeExp.join(', ') != aircraftExpStr.value);
    if (aircraftChanged) return true;

    // Other training free text
    final otherTrainingChanged = (otherTrainingController.text.trim() != otherTraining.trim());
    if (otherTrainingChanged) return true;

    // Toggles that are tracked with separate "original" mirrors
    final ignoreAvailabilityChanged = (isIgnoreAvailability != isIgnoreAvailabilityCheck);
    if (ignoreAvailabilityChanged) return true;

    final fullTimeChanged = (isFullTime.value != isFullTimeCheck.value);
    if (fullTimeChanged) return true;

    final showResumeChanged = (isShowResume.value != isShowResumeCheck.value);
    if (showResumeChanged) return true;

    return false;
  }

  // Dropdown sources (same as old)
  final itemsLocation = const ["ON", "OFF"];
  final itemsGender = const ["Female", "Male", "Other"];
  final itemsYearsOfExp = const [
    'Less than 1 year',
    '1-3 years',
    '3-5 years',
    '5-10 years',
    'More than 10 years'
  ];
  final itemsYesNo = const ['Yes', 'No'];

  // Lists (legacy)
  final languageSaveList = <String>[].obs;
  final languageFinalList = <String>[].obs;

  final selectTrainingSaveList = <String>[].obs;
  final selectTrainingFinalList = <String>[].obs;
  final selectTrainingCountryList = const [
    'Airline Trained',
    'Beyond & Above',
    'Clay Lacy Onboarding',
    'Corporate Air Parts',
    'CPR Training',
    'Cullinary Training',
    "EJM Onboarding",
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

  final internationalVisaSaveList = <String>[].obs;

  // Aircraft
  final aircraftExpSaveList = <AircraftTypeList>[].obs;
  final aircraftExpFinalList = <AircraftTypeList>[].obs;
  final aircraftTypeExp = <String>[].obs;

  final continentSaveList = <String>[].obs;
  final continentFinalList = <String>[].obs;
  final continentCountryList = const [
    'North America',
    'South America',
    'Antarctica',
    'Europe',
    'Asia',
    'Africa',
    'Australia'
  ];

  final continentExpSaveList = <String>[].obs;
  final continentExpFinalList = <String>[].obs;
  final continentExpCountryList = const [
    'North America',
    'South America',
    'Antarctica',
    'Europe',
    'Asia',
    'Africa',
    'Australia'
  ];

  // Derived display strings
  final continentStr = ''.obs;
  final continentExpStr = ''.obs;
  final internationalVisaStr = ''.obs;
  final selectTrainingStr = ''.obs;
  final languageStr = ''.obs;
  final aircraftExpStr = ''.obs;

  // Images
  final selectedImage = ''.obs;
  final image1 = RxnString();
  final image2 = RxnString();
  final image3 = RxnString();
  final image4 = RxnString();
  final image5 = RxnString();
  final image6 = RxnString();

  // Rating
  final ratingCount = 0.0.obs;

  // Other
  final currentDate = DateTime.now().obs;
  final isClicked = false.obs;
  /// True after we send the user to app Settings from the Current Location flow.
  /// On resume, we re-check permission and auto-flip the toggle to ON if the
  /// user granted Always access there.
  bool _awaitingLocationSettingsReturn = false;
  final isUpdated = true.obs;
  final resumePath = RxnString();
  final checkTerm = false.obs;

  // Media pickers (legacy behavior)
  final ImagePicker picker = ImagePicker();
  final ImageCropper imageCropper = ImageCropper();
  FilePickerResult? resumePickResult;

  // Local picked files (profile + 6 gallery images)
  final pickedProfileFile = Rxn<File>();
  final pickedFAFiles = <int, File>{}.obs; // keys: 1..6

  // These existed in legacy project; keeping them here preserves the UI flow.
  final languageCountryList = const [
    'Arabic',
    'Bengali',
    'Chinese',
    'Dutch',
    'English',
    'French',
    'German',
    'Gujarati',
    'Hindi',
    'Italian',
    'Japanese',
    'Kannada',
    'Korean',
    'Malayalam',
    'Marathi',
    'Portuguese',
    'Punjabi',
    'Russian',
    'Spanish',
    'Tamil',
    'Telugu',
    'Urdu',
  ];

  final internationalVisaCountryList = const [
    'Australia',
    'Canada',
    'China',
    'Europe (Schengen)',
    'India',
    'Japan',
    'Mexico',
    'New Zealand',
    'United Kingdom',
    'United States',
  ];

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // debugPrint('id = $pkPilotId'); // from your globals
    // isLoading.value = false;
    // getViewData();
    // getLocation();
    _initPage();
  }

  @override
  void onClose() {
    EasyLoading.dismiss();
    
    WidgetsBinding.instance.removeObserver(this);
    
    membershipTypeController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passportController.dispose();
    genderController.dispose();
    phoneNumberController.dispose();
    dayDomesticController.dispose();
    dayInternationalController.dispose();
    instagramController.dispose();
    facebookController.dispose();
    linkedinController.dispose();
    bioController.dispose();
    yrExperienceController.dispose();
    passportExpireDateController.dispose();
    otherTrainingController.dispose();
    currentLocationController.dispose();

    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handleReturnFromLocationSettings();
    }
  }

  /// When the user comes back from Settings, silently re-check permission.
  ///
  /// UI rule:
  /// - If iPhone permission is now `whileInUse` or `always`, keep the Current
  ///   Location field ON so the field reflects that location is enabled.
  /// - Dashboard/background sync can still separately require stricter access
  ///   (`always`) for background behavior.
  Future<void> _handleReturnFromLocationSettings() async {
    if (!_awaitingLocationSettingsReturn) return;
    _awaitingLocationSettingsReturn = false;

    try {
      final bool servicesEnabled = await Geolocator.isLocationServiceEnabled();
      final LocationPermission permission = await Geolocator.checkPermission();

      final bool shouldKeepToggleOn =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (servicesEnabled && shouldKeepToggleOn) {
        currentLocationController.text = 'ON';
        currentLocaBool.value = currentLocation != 'ON';
        permissions.value = true;
        update();
      }
    } catch (e) {
      debugPrint('return from location settings check error: $e');
    }
  }

  Future<void> _initPage() async {
  try {
    await getViewData();
    // Optional:
    // await getLocation();
  } catch (e, st) {
    debugPrint('ProfileFlightAttendant _initPage error: $e\n$st');
  }
}

Future<void> getViewData() async {
  try {
    isLoading.value = true;

    final func = ParseCloudFunction('getAttendantProfileViewData');
    final res = await func.execute();

    if (!res.success || res.result == null) {
      debugPrint('getAttendantProfileViewData failed: ${res.error}');
      return;
    }

    final data = Map<String, dynamic>.from(res.result as Map);

    // ------------------ Identity ------------------
    final int? mt = data['membershipType'] is num ? (data['membershipType'] as num).toInt() : null;
    membershipTypeController.text = (mt == null) ? '' : getMembershipTypeText(mt);
    // membershipTypeController.text = (data['membershipType'] ?? 4).toString();

    firstNameController.text = (data['firstName'] ?? '').toString();
    firstName = firstNameController.text;

    lastNameController.text = (data['lastName'] ?? '').toString();
    lastName = lastNameController.text;

    emailController.text = (data['email'] ?? '').toString();
    email = emailController.text;

    phoneNumberController.text = (data['phoneNumber'] ?? '').toString();
    phoneNumber = phoneNumberController.text;

    // gender (Number 0/1/2 -> label)
    // Your _normalizeGender currently accepts string input (like "0"/"1"/"2")
    final int? genCode = data['gender'] is num ? (data['gender'] as num).toInt() : null;
    final normalizedGender = (genCode == null) ? '' : _normalizeGender(genCode.toString());
    genderController.text = normalizedGender;
    gender = normalizedGender;

    // ------------------ Profile ------------------
    final havePassportRaw = data['HavePassport'];
      passportController.text = _normalizeYesNo(havePassportRaw);
      passport = passportController.text;

    isUpdated.value = (data['IsUpdated'] as bool?) ?? true;

    // Read the ISO date string we returned from Cloud Code
    final String? passportExpDateStr = data['PassportExpDate'] as String?;
    debugPrint("PassportExpDateStr: $passportExpDateStr");
    if (passportExpDateStr != null && passportExpDateStr.isNotEmpty) {
      try {
        // Parse ISO string to DateTime
        final DateTime parsedDate = DateTime.parse(passportExpDateStr);
        // Format it the same way as your old code
        passportExpireDateController.text = DateFormat('MM/dd/yyyy').format(parsedDate);
        passportExpireDate = passportExpireDateController.text;
      } catch (_) {
        // If parsing/formatting fails, clear the value
        passportExpireDateController.clear();
        passportExpireDate = "";
      }
    } else {
      // No date stored for this profile
      passportExpireDateController.clear();
      passportExpireDate = "";
    }

    // CurrentLocation comes as Boolean - normalize to "ON"/"OFF"
    final currentLocRaw = data['CurrentLocation'];
    currentLocationController.text = _normalizeOnOff(currentLocRaw);
    currentLocation = currentLocationController.text;

    // ratingCount is stored as string in schema
    final ratingRaw = (data['ratingCount'] ?? '0').toString();
    ratingCount.value = double.tryParse(ratingRaw) ?? 0.0;

    // years of exp (server sends raw; UI expects mapped label)
    final yrRaw = (data['yearOfExperiance'] ?? '').toString();
    yrExperienceController.text = _mapYearsOfExperience(yrRaw);
    yrExperience = yrExperienceController.text;

    // day rates
    final dom = data['DomPDRate'];
    dayDomesticController.text = (dom is num) ? dom.toStringAsFixed(0) : '0';
    dayDomestic = dayDomesticController.text;

    final intl = data['InterPDRate'];
    dayInternationalController.text = (intl is num) ? intl.toStringAsFixed(0) : '0';
    dayInternational = dayInternationalController.text;

    // special training
    isSpecialTraining.value = (data['IsSpecialTrained'] == true);
    specialTrainingValue.value = isSpecialTraining.value;

    selectTrainingSaveList.assignAll(_splitCSV((data['SpecialTrained'] ?? '').toString()));
    selectTrainingStr.value = selectTrainingSaveList.join(', ');

    otherTrainingController.text = (data['SpecialTrainedOther'] ?? '').toString();
    otherTraining = otherTrainingController.text;

    // languages + visas
    languageSaveList.assignAll(_splitCSV((data['LanguagesSpoken'] ?? '').toString()));
    languageStr.value = languageSaveList.join(', ');

    internationalVisaSaveList.assignAll(_splitCSV((data['InternationalVisas'] ?? '').toString()));
    internationalVisaStr.value = internationalVisaSaveList.join(', ');

    // continents + regions
    continentSaveList.assignAll(_splitCSV((data['Continent'] ?? '').toString()));
    continentStr.value = continentSaveList.join(', ');

    continentExpSaveList.assignAll(_splitCSV((data['RegionExp'] ?? '').toString()));
    continentExpStr.value = continentExpSaveList.join(', ');

    // Aircraft list mapping (csv of aircraft names)
    aircraftTypeExp.clear();
    aircraftExpFinalList.clear();
    final aircraftCsv = (data['TrainAircraftList'] ?? '').toString();
    final ids = _splitCSV(aircraftCsv);
    for (final id in ids) {
      final match = aircraftTypeList.firstWhereOrNull((e) => e.name == id);
      if (match != null) {
        aircraftExpFinalList.add(match);
        aircraftTypeExp.add(match.name);
      }
    }
    aircraftExpStr.value = aircraftTypeExp.join(', ');

    // aircraft specific training (checkbox UI)
    // final isAircraftSpecific = (data['isAircraftSpecificTraining'] == true);
    // if (!isAircraftSpecific) {
    //   checkboxTrainingNo.value = true;
    //   checkboxTrainingYes.value = false;
    //   checkBoxValue.value = false;
    // } else {
    //   checkboxTrainingNo.value = false;
    //   checkboxTrainingYes.value = true;
    //   checkBoxValue.value = true;
    // }

    // social + bio
    bioController.text = (data['Bio'] ?? '').toString();
    bio = bioController.text;

    instagramController.text = (data['instagram'] ?? '').toString();
    instagram = instagramController.text;
    instagramStatus.value = '';

    facebookController.text = (data['facebook'] ?? '').toString();
    facebook = facebookController.text;
    facebookStatus.value = '';

    linkedinController.text = (data['linkedIn'] ?? '').toString();
    linkedin = linkedinController.text;
    linkedinStatus.value = '';

    // toggles
    isIgnoreAvailability = (data['IsSearchAll'] == true);
    isIgnoreAvailabilityCheck = (data['IsSearchAll'] == true);

    isFullTime.value = (data['IsFullTime'] == true);
    isFullTimeCheck.value = isFullTime.value;

    isShowResume.value = (data['IsResume'] == true);
    isShowResumeCheck.value = isShowResume.value;

    // resume + images
    resumePath.value = (data['ResumePath'] ?? '').toString();
    selectedImage.value = (data['PhotoPath'] ?? '').toString();

    image1.value = _emptyToNull((data['FAImage1'] ?? '').toString());
    image2.value = _emptyToNull((data['FAImage2'] ?? '').toString());
    image3.value = _emptyToNull((data['FAImage3'] ?? '').toString());
    image4.value = _emptyToNull((data['FAImage4'] ?? '').toString());
    image5.value = _emptyToNull((data['FAImage5'] ?? '').toString());
    image6.value = _emptyToNull((data['FAImage6'] ?? '').toString());
  } catch (e, st) {
    debugPrint('getViewData(attendant) error: $e\n$st');
  } finally {
    isLoading.value = false;
  }
}

  // --- Normalizers to keep DropdownButton value consistent with items ---
  String _normalizeGender(String raw) {
    final t = (raw).toString().trim();
    if (t.isEmpty) return '';
    // Accept common variants and int codes used elsewhere in the app
    if (t == '0' || t.toLowerCase() == 'male') return 'Male';
    if (t == '1' || t.toLowerCase() == 'female') return 'Female';
    if (t == '2' || t.toLowerCase() == 'other') return 'Other';
    // If API already returns a label, only keep it if in items
    return itemsGender.contains(t) ? t : '';
  }

  String _normalizeOnOff(dynamic raw) {
    final t = (raw ?? '').toString().trim().toLowerCase();
    if (t.isEmpty) return '';
    if (t == 'true' || t == 'on' || t == '1') return 'ON';
    if (t == 'false' || t == 'off' || t == '0') return 'OFF';
    return itemsLocation.contains(raw) ? raw : '';
  }

  String _normalizeYesNo(dynamic raw) {
    // Dropdowns for Yes/No fields use `itemsYesNo = ['Yes', 'No']`.
    // So this MUST return only: 'Yes', 'No', or ''.
    final t = (raw ?? '').toString().trim().toLowerCase();
    if (t.isEmpty) return '';

    // Accept common variants from old API / legacy UI.
    if (t == 'true' || t == 'yes' || t == '1' || t == 'on') return 'Yes';
    if (t == 'false' || t == 'no' || t == '0' || t == 'off') return 'No';

    // If the server already returns a label, keep it only if it matches items.
    final cap = t[0].toUpperCase() + t.substring(1);
    return itemsYesNo.contains(cap) ? cap : '';
  }

  String? _emptyToNull(String s) {
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  double _parseMoney(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return 0.0;
    return double.tryParse(t) ?? 0.0;
  }

  List<String> _splitCSV(String? raw) {
    if (raw == null || raw.trim().isEmpty) return <String>[];
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _mapYearsOfExperience(String yr) {
    // Preserves old mapping logic
    switch (yr) {
      case '0':
      case '0-1':
        return 'Less than 1 year';
      case '1-1':
        return 'First Available';
      case '1-3':
        return '1-3 years';
      case '3-5':
        return '3-5 years';
      case '5-10':
        return '5-10 years';
      default:
        return yr.isEmpty ? '' : 'More than 10 years';
    }
  }

  // -------------- SHARE --------------

  Future<void> shareProfile(BuildContext context, String link) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      link,
      subject: 'Profile link',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  // -------------- LOCATION --------------

  Future<void> getLocation() async {
    try {
      final position = await _getGeoLocationPosition();
      permissions.value = true;
      await _fillAddressFromLatLng(position);
    } catch (e) {
      debugPrint('getLocation error: $e');
    }
  }

  /// Handles user changes to the "Current Location" dropdown.
  ///
  /// We intentionally start the iOS location permission flow only when the
  /// user explicitly turns this feature ON. If permission is not sufficient,
  /// the UI is reverted so the profile does not claim location is enabled.
  Future<void> onCurrentLocationChanged(
    BuildContext context,
    String? newValue,
  ) async {
    final String normalizedNewValue = _normalizeOnOff(newValue);
    final String oldValue = currentLocation;

    if (normalizedNewValue.isEmpty) {
      return;
    }

    // Turning OFF should never trigger a location permission prompt.
    if (normalizedNewValue == 'OFF') {
      currentLocationController.text = 'OFF';
      currentLocation = 'OFF';
      currentLocaBool.value = (currentLocation != oldValue);
      return;
    }

    // User is turning the feature ON, so require permission first.
    final bool granted = await _ensureLocationPermissionForCurrentLocationFeature(context);

    if (!granted) {
      // Revert the field if permission was not granted/upgraded.
      currentLocationController.text = oldValue.isEmpty ? 'OFF' : oldValue;
      currentLocation = currentLocationController.text;
      currentLocaBool.value = (currentLocation != oldValue);
      return;
    }

    currentLocationController.text = 'ON';
    currentLocation = 'ON';
    currentLocaBool.value = (currentLocation != oldValue);
  }

  /// Requests the permissions needed for the Current Location feature.
  ///
  /// iOS requires `always` access for this feature.
  /// Android needs foreground access first and then background access for the
  /// feature to keep working when the app is closed. Depending on Android
  /// version/OS behavior, the upgrade to background access may require a second
  /// permission request or a trip to app settings.
  Future<bool> _ensureLocationPermissionForCurrentLocationFeature(
    BuildContext context,
  ) async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      final bool openSettings = await _showLocationPermissionDialog(
        context,
        title: 'Location Services Off',
        message: Platform.isAndroid
            ? 'Crew Support needs device location turned on so operators can find you based on your current location. Please turn on Location for your device.'
            : 'Crew Support needs location enabled for this app so operators can find you based on your current location. Please open this app\'s Settings and set Location access to Always.',
        confirmText: Platform.isAndroid ? 'Open Location Settings' : 'Open Settings',
      );

      if (openSettings) {
        _awaitingLocationSettingsReturn = true;
        if (Platform.isAndroid) {
          await Geolocator.openLocationSettings();
        } else {
          await Geolocator.openAppSettings();
        }
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (Platform.isIOS) {
      if (permission == LocationPermission.always) {
        permissions.value = true;
        return true;
      }

      if (permission == LocationPermission.deniedForever) {
        final bool openSettings = await _showLocationPermissionDialog(
          context,
          title: 'Location Permission Needed',
          message:
              'Please allow Always location access in Settings so Crew Support can keep your location available for proximity-based trip searches even when the app is not open.',
          confirmText: 'Open Settings',
        );

        if (openSettings) {
          _awaitingLocationSettingsReturn = true;
          await Geolocator.openAppSettings();
        }
        return false;
      }

      if (permission == LocationPermission.whileInUse) {
        final bool openSettings = await _showLocationPermissionDialog(
          context,
          title: 'Allow Always Location Access',
          message:
              'To appear in nearby trip searches while the app is closed, please change this app\'s location access to Always in Settings.',
          confirmText: 'Open Settings',
        );

        if (openSettings) {
          _awaitingLocationSettingsReturn = true;
          await Geolocator.openAppSettings();
        }
        return false;
      }

      return false;
    }

    // Android flow:
    // 1) Foreground permission is required first.
    // 2) Then we try to upgrade to background access.
    // Geolocator reports background access as `always` on Android.
    if (permission == LocationPermission.deniedForever) {
      final bool openSettings = await _showLocationPermissionDialog(
        context,
        title: 'Location Permission Needed',
        message:
            'Please allow location access for Crew Support in Settings, then enable Allow all the time so nearby trip search can keep working when the app is closed.',
        confirmText: 'Open Settings',
      );

      if (openSettings) {
        _awaitingLocationSettingsReturn = true;
        await Geolocator.openAppSettings();
      }
      return false;
    }

    if (permission == LocationPermission.whileInUse) {
      final LocationPermission upgradedPermission =
          await Geolocator.requestPermission();

      if (upgradedPermission == LocationPermission.always) {
        permissions.value = true;
        return true;
      }

      final bool openSettings = await _showLocationPermissionDialog(
        context,
        title: 'Allow Background Location',
        message:
            'To appear in nearby trip searches while the app is closed, please open Settings for Crew Support and set Location to Allow all the time.',
        confirmText: 'Open Settings',
      );

      if (openSettings) {
        _awaitingLocationSettingsReturn = true;
        await Geolocator.openAppSettings();
      }
      return false;
    }

    if (permission == LocationPermission.always) {
      permissions.value = true;
      return true;
    }

    return false;
  }

  /// Shared helper dialog used by the Current Location permission flow.
  Future<bool> _showLocationPermissionDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColor.bgColor1,
          title: Text(
            title,
            style: TextStyle(
              color: AppColor.textColor1,
              fontSize: 12.spV2,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: AppColor.textColor1,
              fontSize: 10.spV2,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColor.textColor1),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                confirmText,
                style: TextStyle(color: AppColor.secondaryColor1),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<Position> _getGeoLocationPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (Platform.isAndroid) {
        await Geolocator.openLocationSettings();
      } else {
        await Geolocator.openAppSettings();
      }
      return Future.error('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
  }

  Future<void> _fillAddressFromLatLng(Position position) async {
    final placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    // Old code loops switchList and calls updateLocation for each
    for (int i = 0; i < switchList.length; i++) {
      // TODO: await updateLocation(position, switchList[i].pkPilotId.toString());
    }

    final place = placemarks.first;
    country.value = place.country;
    city.value = place.locality;
  }

  // -------------- DATE PICKER HOOK --------------

  void setPassportDate(DateTime picked) {
    currentDate.value = picked;
    final date = DateFormat('MM/dd/yyyy').format(picked);
    passportExpireDateController.text = date;
    passportDateBool.value = passportExpireDateController.text != passportExpireDate;
  }

  // ------------------ Multi-select dialogs (legacy UI) ------------------

  Future<void> openMultiSelectDialog({
    required BuildContext context,
    required String title,
    required List<String> items,
    required List<String> initial,
    required void Function(List<String> values) onConfirm,
    bool searchable = false,
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return Theme(
          data: ThemeData.dark(),
          child: MultiSelectDialog<String>(
            title: Text(title, style: TextStyle(color: AppColor.secondaryColor1)),
            items: items.map((e) => MultiSelectItem<String>(e, e)).toList(),
            initialValue: initial,

            // Search is disabled by default because this helper is shared by
            // multiple profile fields. Enable it only for long lists such as
            // Aircraft Experience.
            searchable: searchable,
            searchHint: 'Search...',

            itemsTextStyle: TextStyle(color: AppColor.textColor1),
            checkColor: AppColor.textColor2,
            unselectedColor: AppColor.textColor1,
            selectedColor: AppColor.secondaryColor1,
            selectedItemsTextStyle: TextStyle(color: AppColor.secondaryColor1),
            onConfirm: (values) => onConfirm(values),
          ),
        );
      },
    );
  }

  Future<void> selectLanguages(BuildContext context) async {
    await openMultiSelectDialog(
      context: context,
      title: 'Select Language',
      items: languageCountryList,
      initial: languageSaveList.toList(),
      onConfirm: (values) {
        languageFinalList.assignAll(values);
        languageSaveList.assignAll(values);
        languageStr.value = values.join(', ');
        languageBool.value = true;
      },
    );
  }

  Future<void> selectTrainingDialog(BuildContext context) async {
    await openMultiSelectDialog(
      context: context,
      title: 'Select Training',
      items: selectTrainingCountryList,
      initial: selectTrainingSaveList.toList(),
      onConfirm: (values) {
        selectTrainingFinalList.assignAll(values);
        selectTrainingSaveList.assignAll(values);
        selectTrainingStr.value = values.join(', ');
        specialBool.value = true;
      },
    );
  }

  Future<void> selectContinents(BuildContext context) async {
    await openMultiSelectDialog(
      context: context,
      title: 'Select Continent',
      items: continentCountryList,
      initial: continentSaveList.toList(),
      onConfirm: (values) {
        continentFinalList.assignAll(values);
        continentSaveList.assignAll(values);
        continentStr.value = values.join(', ');
        continentBool.value = true;
      },
    );
  }

  Future<void> selectRegionExperience(BuildContext context) async {
    await openMultiSelectDialog(
      context: context,
      title: 'Select Region Experience',
      items: continentExpCountryList,
      initial: continentExpSaveList.toList(),
      onConfirm: (values) {
        continentExpFinalList.assignAll(values);
        continentExpSaveList.assignAll(values);
        continentExpStr.value = values.join(', ');
        continent2Bool.value = true;
      },
    );
  }

  Future<void> selectInternationalVisas(BuildContext context) async {
    await openMultiSelectDialog(
      context: context,
      title: 'International Visas',
      items: internationalVisaCountryList,
      initial: internationalVisaSaveList.toList(),
      onConfirm: (values) {
        internationalVisaSaveList.assignAll(values);
        internationalVisaStr.value = values.join(', ');
        internationalBool.value = true;
      },
    );
  }

  Future<void> selectAircraftExperience(BuildContext context) async {
    // Local dialog state so only this dialog gets the custom aircraft picker UI.
    // Other profile multi-select dialogs continue to use MultiSelectDialog.
    final TextEditingController searchController = TextEditingController();
    final ScrollController resultsScrollController = ScrollController();
    List<AircraftTypeList> tempList = List<AircraftTypeList>.from(aircraftTypeList);

    // Stage selected aircraft locally so Cancel can discard changes.
    final Set<String> stagedAircraftNames = aircraftTypeExp.toSet();

    final Future<void> dialogFuture = showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void filterAircraft(String query) {
              final String normalizedQuery = query.trim().toLowerCase();

              if (normalizedQuery.isEmpty) {
                tempList = List<AircraftTypeList>.from(aircraftTypeList);
              } else {
                tempList = aircraftTypeList
                    .where((aircraft) => aircraft.name.toLowerCase().contains(normalizedQuery))
                    .toList();
              }

              if (resultsScrollController.hasClients) {
                resultsScrollController.jumpTo(0);
              }
            }

            return Dialog(
              backgroundColor: AppColor.bgColor2,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              child: SizedBox(
                height: 70.h,
                width: 90.w,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.w),
                      child: Text(
                        'Aircraft Experience (${stagedAircraftNames.length})',
                        style: TextStyle(
                          color: AppColor.secondaryColor1,
                          fontSize: 13.spV2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: SizedBox(
                        height: 6.h,
                        child: TextField(
                          controller: searchController,
                          autocorrect: false,
                          enableSuggestions: false,
                          style: TextStyle(
                            color: AppColor.textColor1,
                            fontSize: 10.spV2,
                          ),
                          onChanged: (text) {
                            setState(() => filterAircraft(text));
                          },
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(
                              color: AppColor.secondaryColor2,
                              fontSize: 9.spV2,
                            ),
                            contentPadding: const EdgeInsets.all(5),
                            prefixIcon: Icon(Icons.search, color: AppColor.secondaryColor1),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: AppColor.secondaryColor1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: AppColor.secondaryColor1),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Divider(color: AppColor.secondaryColor1, height: 1),
                    Expanded(
                      child: tempList.isEmpty
                          ? Center(
                              child: Text(
                                'No aircraft found',
                                style: TextStyle(
                                  color: AppColor.secondaryColor2,
                                  fontSize: 10.spV2,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: resultsScrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: tempList.length,
                              itemBuilder: (_, index) {
                                final AircraftTypeList aircraft = tempList[index];
                                final bool isSelected = stagedAircraftNames.contains(aircraft.name);

                                return Column(
                                  children: [
                                    CheckboxListTile(
                                      value: isSelected,
                                      side: BorderSide(
                                        color: AppColor.secondaryColor2,
                                        width: 1.2,
                                      ),
                                      fillColor: MaterialStateProperty.resolveWith<Color?>(
                                        (states) {
                                          if (states.contains(MaterialState.selected)) {
                                            return AppColor.secondaryColor1;
                                          }
                                          return Colors.transparent;
                                        },
                                      ),
                                      controlAffinity: ListTileControlAffinity.leading,
                                      activeColor: AppColor.secondaryColor1,
                                      checkColor: AppColor.textColor2,
                                      title: Text(
                                        aircraft.name,
                                        style: TextStyle(
                                          color: AppColor.textColor1,
                                          fontSize: 10.spV2,
                                        ),
                                      ),
                                      onChanged: (_) {
                                        setState(() {
                                          if (isSelected) {
                                            stagedAircraftNames.remove(aircraft.name);
                                          } else {
                                            stagedAircraftNames.add(aircraft.name);
                                          }
                                        });
                                      },
                                    ),
                                    Divider(
                                      indent: 10,
                                      endIndent: 10,
                                      thickness: 1,
                                      color: AppColor.textColor1,
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MaterialButton(
                              textColor: AppColor.textColor2,
                              color: AppColor.secondaryColor1,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                                borderRadius: BorderRadius.circular(2.w),
                              ),
                              onPressed: () => Navigator.pop(dialogContext),
                              child: Text('Cancel', style: TextStyle(fontSize: 10.spV2)),
                            ),
                            CupertinoButton.filled(
                              child: Text('Done', style: TextStyle(fontSize: 10.spV2)),
                              onPressed: () {
                                final List<String> selectedNames = stagedAircraftNames.toList();

                                aircraftTypeExp.assignAll(selectedNames);
                                aircraftExpStr.value = selectedNames.join(', ');
                                aircraftExpFinalList.assignAll(
                                  aircraftTypeList.where((aircraft) => stagedAircraftNames.contains(aircraft.name)),
                                );
                                aircraftBool.value = true;

                                Navigator.pop(dialogContext);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    await dialogFuture;

    // Let the dialog dismissal animation finish before disposing controllers.
    // This prevents "TextEditingController was used after being disposed".
    await Future<void>.delayed(const Duration(milliseconds: 300));

    searchController.dispose();
    resultsScrollController.dispose();
  }

  // Image + sharing
  final ImagePicker _picker = ImagePicker();
  final ImageCropper _cropper = ImageCropper();

  // --------------------- Image Picking / Upload ---------------------

  Future<void> openGallery(BuildContext context) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    await _cropAndUpload(context, File(picked.path));
  }

  Future<void> openCamera(BuildContext context) async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    await _cropAndUpload(context, File(picked.path));
  }

  Future<void> _cropAndUpload(BuildContext context, File image) async {
    // Step 1: Crop the image into a circle and compress it
    final croppedFile = await _cropper.cropImage(
      sourcePath: image.path,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop',
          cropStyle: CropStyle.circle,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          title: 'Crop',
          cropStyle: CropStyle.circle,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
        ),
      ],
    );
    if (croppedFile == null) return;

    // Step 2: Show loading dialog while uploading
    showLoadingDialog(context, "Uploading...");
    try {
      // Step 3: Read, resize to max width 600, then compress
      final originalBytes = Io.File(croppedFile.path).readAsBytesSync();
      final decoded = img.decodeImage(originalBytes);
      if (decoded == null) {
        showMyDialog(context, 'Failed to process image.');
        return;
      }

      // Resize image to max width 600 while keeping aspect ratio
      final resized = img.copyResize(decoded, width: 600);

      // Encode back to JPEG for compression
      final resizedBytes = img.encodeJpg(resized, quality: 90);

      // Compress resized image
      final compressed = await FlutterImageCompress.compressWithList(
        resizedBytes,
        quality: 80,
      );

      // Step 4: Convert to base64 for Cloud Code
      final img64 = base64Encode(compressed);
      final fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Step 5: Call Cloud Function to handle Parse.File + profile update
      final func = ParseCloudFunction('updateAttendantProfilePhoto');

      final Map<String, dynamic> params = {
        'imageBase64': img64,
        'fileName': fileName,
      };

      final response = await func.execute(parameters: params);

      if (!response.success || response.result == null) {
        showMyDialog(context, 'Failed to upload image. Please try again later!');
        return;
      }

      final data = Map<String, dynamic>.from(response.result as Map);
      final url = data['url'] as String?;
      if (url == null || url.isEmpty) {
        showMyDialog(context, 'Failed to update profile picture.');
        return;
      }

      // Step 6: Update local UI with new URL
      selectedImage.value = url;
      // Also update dashboard avatar immediately
      Get.find<DashboardController>().updatePhoto(url);
    } catch (e) {
      print('image upload error: $e');
      showMyDialog(context, 'Please try again later!');
    } finally {
      // Step 8: Always close the loading dialog
      if (Get.context != null) {
        Navigator.of(Get.context!).pop();
      }
    }
  }

  /// Clears the user's profile image by delegating all server-side cleanup
  /// (unsetting the File field and deleting the file) to Cloud Code.
  ///
  /// Now calls the "clearAttendantProfilePhoto" Back4App Cloud Function, which is
  /// responsible for unsetting the user's PhotoPath/File field and deleting
  /// the Parse.File on the server. This ensures all cleanup is handled
  /// atomically and securely server-side.
  ///
  /// UI is updated only if the cloud function succeeds.
  Future<void> clearProfileImage(BuildContext context) async {
    // Step 1: Show loading dialog to indicate operation in progress
    showLoadingDialog(context, "Removing...");
    try {
      // Step 2: Call Back4App Cloud Function to clear profile photo.
      // The cloud code is responsible for unsetting the File field and deleting the file.
      final func = ParseCloudFunction('clearAttendantProfilePhoto');
      final response = await func.execute();

      // Step 3: Check if the call succeeded.
      // If not, show error dialog and do NOT update UI.
      if (!response.success || response.result == null) {
        showMyDialog(context, 'Failed to remove profile picture. Please try again later!');
        return;
      }

      // Step 4: If call succeeded, update UI to fall back to default avatar.
      selectedImage.value = '';

      // Also update dashboard avatar immediately
      Get.find<DashboardController>().updatePhoto('');
    } catch (e) {
      // Step 5: Catch and log any exceptions, show generic error dialog.
      print('clearProfileImage error: $e');
      showMyDialog(context, 'Please try again later!');
    } finally {
      // Step 6: Always close the loading dialog if possible.
      if (Get.context != null && Navigator.of(Get.context!).canPop()) {
        Navigator.of(Get.context!).pop();
      }
    }
  }

  void showChoiceDialog(BuildContext context) {
    final sheet = Theme(
      data: ThemeData.dark(),
      child: CupertinoActionSheet(
        title: Text("Choose option", style: TextStyle(color: AppColor.textColor1, fontSize: 15.spV2)),
        actions: [
          CupertinoActionSheetAction(
            child: Text("Gallery", style: TextStyle(color: AppColor.textColor1, fontSize: 12.spV2)),
            onPressed: () {
              Navigator.pop(context);
              openGallery(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text("Camera", style: TextStyle(color: AppColor.textColor1, fontSize: 12.spV2)),
            onPressed: () {
              Navigator.pop(context);
              openCamera(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text("Remove", style: TextStyle(color: AppColor.textColor1, fontSize: 12.spV2)),
            onPressed: () {
              Navigator.pop(context);
              clearProfileImage(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text("Cancel", style: TextStyle(color: AppColor.secondaryColor1, fontSize: 12.spV2)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );

    showCupertinoModalPopup(context: context, builder: (_) => sheet);
  }

  /// Opens a Cupertino-style action sheet (Gallery/Camera/Remove) for one of the
  /// 6 Flight Attendant gallery images (FAImage1..FAImage6).
  ///
  /// This mirrors the profile picture flow (crop circle, resize to max width 600,
  /// compress, base64 upload), but calls dedicated cloud functions:
  /// - updateAttendantFAImage
  /// - clearAttendantFAImage
  Future<void> pickFAImage(BuildContext context, int index) async {
    // Validate index 1..6
    if (index < 1 || index > 6) {
      debugPrint('pickFAImage: invalid index $index');
      return;
    }

    final sheet = Theme(
      data: ThemeData.dark(),
      child: CupertinoActionSheet(
        title: Text(
          "Choose option",
          style: TextStyle(color: AppColor.textColor1, fontSize: 15.spV2),
        ),
        actions: [
          CupertinoActionSheetAction(
            child: Text(
              "Gallery",
              style: TextStyle(color: AppColor.textColor1, fontSize: 12.spV2),
            ),
            onPressed: () {
              Navigator.pop(context);
              _pickFAFromGallery(context, index);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              "Camera",
              style: TextStyle(color: AppColor.textColor1, fontSize: 12.spV2),
            ),
            onPressed: () {
              Navigator.pop(context);
              _pickFAFromCamera(context, index);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              "Remove",
              style: TextStyle(color: AppColor.textColor1, fontSize: 12.spV2),
            ),
            onPressed: () {
              Navigator.pop(context);
              _clearFAImage(context, index);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: AppColor.secondaryColor1, fontSize: 12.spV2),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );

    showCupertinoModalPopup(context: context, builder: (_) => sheet);
  }

  // --------------------- FA Gallery Images (1..6) ---------------------

  Future<void> _pickFAFromGallery(BuildContext context, int index) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    await _cropAndUploadFAImage(context, File(picked.path), index);
  }

  Future<void> _pickFAFromCamera(BuildContext context, int index) async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;
    await _cropAndUploadFAImage(context, File(picked.path), index);
  }

  /// Crops (circle), resizes (max width 600), compresses, converts to base64 and
  /// uploads one of FAImage1..FAImage6 via Cloud Code.
  Future<void> _cropAndUploadFAImage(BuildContext context, File image, int index) async {
    // Step 1: Crop the image into a circle and compress it
    final croppedFile = await _cropper.cropImage(
      sourcePath: image.path,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop',
          cropStyle: CropStyle.rectangle,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(
          title: 'Crop',
          cropStyle: CropStyle.rectangle,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
      ],
    );
    if (croppedFile == null) return;

    // Step 2: Show loading dialog while uploading
    showLoadingDialog(context, "Uploading...");

    try {
      // Step 3: Read, resize to max width 600, then compress
      final originalBytes = Io.File(croppedFile.path).readAsBytesSync();
      final decoded = img.decodeImage(originalBytes);
      if (decoded == null) {
        showMyDialog(context, 'Failed to process image.');
        return;
      }

      final resized = img.copyResize(decoded, width: 600);
      final resizedBytes = img.encodeJpg(resized, quality: 90);

      final compressed = await FlutterImageCompress.compressWithList(
        resizedBytes,
        quality: 80,
      );

      // Step 4: Convert to base64 for Cloud Code
      final img64 = base64Encode(compressed);
      final fileName = 'fa_${index}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Step 5: Call Cloud Function to handle Parse.File + profile update
      final func = ParseCloudFunction('updateAttendantFAImage');
      final Map<String, dynamic> params = {
        'imageNumber': index,
        'imageBase64': img64,
        'fileName': fileName,
      };

      final response = await func.execute(parameters: params);
      if (!response.success || response.result == null) {
        showMyDialog(context, 'Failed to upload image. Please try again later!');
        return;
      }

      final data = Map<String, dynamic>.from(response.result as Map);
      final url = data['url'] as String?;
      if (url == null || url.isEmpty) {
        showMyDialog(context, 'Failed to update image.');
        return;
      }

      // Step 6: Update local UI with new URL (no dashboard update)
      _setFAImageUrl(index, url);
    } catch (e) {
      debugPrint('FA image upload error: $e');
      showMyDialog(context, 'Please try again later!');
    } finally {
      // Step 7: Always close the loading dialog
      if (Get.context != null && Navigator.of(Get.context!).canPop()) {
        Navigator.of(Get.context!).pop();
      }
    }
  }

  /// Clears a FAImageX by delegating cleanup to Cloud Code.
  Future<void> _clearFAImage(BuildContext context, int index) async {
    showLoadingDialog(context, "Removing...");

    try {
      final func = ParseCloudFunction('clearAttendantFAImage');
      final response = await func.execute(parameters: {
        'imageNumber': index,
      });

      if (!response.success || response.result == null) {
        showMyDialog(context, 'Failed to remove image. Please try again later!');
        return;
      }

      _setFAImageUrl(index, null);
    } catch (e) {
      debugPrint('clearFAImage error: $e');
      showMyDialog(context, 'Please try again later!');
    } finally {
      if (Get.context != null && Navigator.of(Get.context!).canPop()) {
        Navigator.of(Get.context!).pop();
      }
    }
  }

  /// Helper to update the correct observable image slot.
  void _setFAImageUrl(int index, String? url) {
    switch (index) {
      case 1:
        image1.value = url;
        break;
      case 2:
        image2.value = url;
        break;
      case 3:
        image3.value = url;
        break;
      case 4:
        image4.value = url;
        break;
      case 5:
        image5.value = url;
        break;
      case 6:
        image6.value = url;
        break;
      default:
        break;
    }
  }

  // ------------------ Resume picking ------------------

  Future<void> pickAndUploadResume(BuildContext context) async {
    // Keep Flight Attendant logic intact
    return pickResume(context);
  }

  Future<void> openResume(BuildContext context) async {
    final url = (resumePath.value ?? '').trim();
    if (url.isEmpty || url == 'http') {
      showMyDialog(context, 'No resume found.');
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      showMyDialog(context, 'Invalid resume URL.');
      return;
    }

    if (!await canLaunchUrl(uri)) {
      showMyDialog(context, 'Could not open resume.');
      return;
    }

    UrlHelper.openInAppNoContext(url);
  }

  Future<void> pickResume(BuildContext context) async {
    try {
      final res = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (res == null) return; // user cancelled

      resumePickResult = res;
      final path = res.files.single.path;
      if (path == null) {
        showMyDialog(context, 'File not found.');
        return;
      }

      if (p.extension(path).toLowerCase() != '.pdf') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select only PDF file.')),
        );
        return;
      }

      // Check file size (must be <= 10 MB)
      final file = Io.File(path);
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        showMyDialog(context, 'Please select only PDF file of size 10 MB or less.');
        return;
      }

      await showDialog(
        context: context,
        builder: (_) => Theme(
          data: ThemeData.dark(),
          child: CupertinoAlertDialog(
            content: const Text("The old uploaded resume will be replaced by the new one."),
            actions: [
              CupertinoButton(
                child: Text("Cancel", style: TextStyle(color: AppColor.secondaryColor1)),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoButton(
                child: Text("Upload", style: TextStyle(color: AppColor.secondaryColor1)),
                onPressed: () async {
                  // First close the confirmation dialog
                  Navigator.pop(context);

                  // Show the loading dialog while we upload the file
                  showLoadingDialog(context, 'Uploading...');

                  try {
                    // Read the PDF bytes and base64 encode them
                    final bytes = await Io.File(path).readAsBytes();
                    final pdf64 = base64Encode(bytes);

                    // If for some reason we got an empty string, just close the loader and return
                    if (pdf64.isEmpty) {
                      Navigator.of(context).maybePop(); // close "Uploading..." dialog
                      return;
                    }

                    // --- All resume file handling is delegated to Back4App Cloud Code.
                    //     The Cloud Function will update the File column `Resume` in the `profile` class.
                    final func = ParseCloudFunction('updateAttendantProfileResume');
                    final params = {
                      'pdfBase64': pdf64,
                      'fileName': p.basename(path),
                    };

                    final response = await func.execute(parameters: params);

                    // Close the loading dialog before showing any result dialogs
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }

                    if (!response.success || response.result == null) {
                      showMyDialog(context, 'Please try again later!');
                      return;
                    }

                    final data = Map<String, dynamic>.from(response.result as Map);
                    final url = data['url'] as String?;

                    if (url == null || url.isEmpty) {
                      showMyDialog(context, 'Please try again later!');
                      return;
                    }

                    // Update local state with the new resume URL
                    resumePath.value = url;
                    // resumePathRx.value = resumePath ?? '';
                    showResume.value = true;

                    // Let the user know we are done
                    showMyDialog(context, 'Resume Updated Successfully!');
                  } catch (e) {
                    // Ensure the loading dialog is closed on error
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    showMyDialog(context, 'Please try again later!');
                  }
                },
              ),
            ],
          ),
        ),
      );


      // resumePath.value = path;
      // showResume.value = true;
    
    } catch (e) {
      showMyDialog(context, 'Failed to pick resume');
    }
  }

  Future<void> deleteResume(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => Theme(
        data: ThemeData.dark(),
        child: CupertinoAlertDialog(
          content: const Text('Are you sure you want to delete this resume?'),
          actions: [
            CupertinoButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColor.secondaryColor1, fontSize: 10.spV2),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoButton(
              child: Text(
                'Delete',
                style: TextStyle(color: AppColor.deleteColor, fontSize: 10.spV2),
              ),
              onPressed: () async {
                Navigator.pop(context); // close confirm dialog

                showLoadingDialog(context, 'Deleting...');

                bool success = false;

                try {
                  // --- Cloud Code handles unsetting the Resume File field and deleting the underlying Parse file.
                  final func = ParseCloudFunction('clearAttendantProfileResume');
                  final response = await func.execute();

                  success = response.success && response.result != null;

                  if (success) {
                    resumePath.value = '';
                    showResume.value = false;
                  }
                } catch (_) {
                  success = false;
                } finally {
                  // ✅ ALWAYS close the loading dialog FIRST (root navigator)
                  final nav = Navigator.of(context, rootNavigator: true);
                  if (nav.canPop()) nav.pop();
                }

                // ✅ Now show result dialog (after loader is gone)
                if (success) {
                  showMyDialog(context, 'Resume deleted.');
                } else {
                  showMyDialog(context, 'Please try again later!');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // -------------- UPDATE --------------

  Future<void> submitUpdate(BuildContext context) async {
    // Basic validations (preserved)
    if (firstNameController.text.isEmpty) {
      showMyDialog(context, 'Please enter first name');
      return;
    }
    if (!firstNameController.text.isAlphabetOnly) {
      showMyDialog(context, 'Please only enter letters in first name');
      return;
    }
    if (lastNameController.text.isEmpty) {
      showMyDialog(context, 'Please enter last name');
      return;
    }
    if (!lastNameController.text.isAlphabetOnly) {
      showMyDialog(context, 'Please only letters in last name');
      return;
    }
    if (!Utility.isValidEmail(emailController.text)) {
      showMyDialog(context, 'Email address is not valid');
      return;
    }
    if (phoneNumberController.text.isEmpty) {
      showMyDialog(context, 'Please enter phone number');
      return;
    }
    if (phoneNumberController.text.length != 10) {
      showMyDialog(context, 'Phone number is not valid');
      return;
    }
    if (emailController.text.isEmpty) {
      showMyDialog(context, 'Please enter email id');
      return;
    }

    final ok = await _updateFA(context);
      if (ok) {
        isUpdated.value = true; // (still good to keep consistent)
      }

    // if (!isUpdated.value) {
      // await showCupertinoDialog(
      //   context: context,
      //   builder: (ctx) => StatefulBuilder(
      //     builder: (ctx, setState) => Theme(
      //       data: ThemeData.dark(),
      //       child: CupertinoAlertDialog(
      //         title: const Text('Terms & Conditions'),
      //         content: Theme(
      //           data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
      //           child: CheckboxListTile(
      //             controlAffinity: ListTileControlAffinity.leading,
      //             checkColor: AppColor.textColor2,
      //             activeColor: AppColor.secondaryColor1,
      //             title: Column(
      //               children: [
      //                 Wrap(
      //                   crossAxisAlignment: WrapCrossAlignment.center,
      //                   children: [
      //                   Text('I accept',
      //                       style: TextStyle(
      //                           color: AppColor.textColor1,
      //                           fontSize: 10.spV2)),
      //                   const SizedBox(width: 5),
      //                   GestureDetector(
      //                     onTap: () async {
      //                       const url = LegalUrls.terms;
      //                       await launchUrl(Uri.parse(url),
      //                           mode: LaunchMode.externalApplication);
      //                     },
      //                     child: Text('Terms of use',
      //                         style: TextStyle(
      //                             color: AppColor.secondaryColor1,
      //                             fontSize: 10.spV2)),
      //                   ),
      //                   Text(',',
      //                       style: TextStyle(
      //                           color: AppColor.textColor1,
      //                           fontSize: 10.spV2)),
      //                 ]),
      //                 Row(children: [
      //                   const SizedBox(width: 2),
      //                   GestureDetector(
      //                     onTap: () async {
      //                       const url = LegalUrls.privacy;
      //                       await launchUrl(Uri.parse(url),
      //                           mode: LaunchMode.externalApplication);
      //                     },
      //                     child: Text('Privacy Policy',
      //                         style: TextStyle(
      //                             color: AppColor.secondaryColor1,
      //                             fontSize: 10.spV2)),
      //                   ),
      //                   const SizedBox(width: 5),
      //                   Text('and',
      //                       style: TextStyle(
      //                           fontSize: 10.spV2,
      //                           color: AppColor.textColor1)),
      //                 ]),
      //                 Row(
      //                     mainAxisAlignment: MainAxisAlignment.center,
      //                     children: [
      //                       GestureDetector(
      //                         onTap: () async {
      //                           const url =
      //                               LegalUrls.disclaimer;
      //                           await launchUrl(Uri.parse(url),
      //                               mode: LaunchMode.externalApplication);
      //                         },
      //                         child: Text('Disclaimer',
      //                             style: TextStyle(
      //                                 color: AppColor.secondaryColor1,
      //                                 fontSize: 10.spV2)),
      //                       ),
      //                       Text('.',
      //                           style: TextStyle(
      //                               fontSize: 10.spV2,
      //                               color: AppColor.textColor1)),
      //                     ]),
      //               ],
      //             ),
      //             value: checkTerm.value,
      //             onChanged: (v) =>
      //                 setState(() => checkTerm.value = v ?? false),
      //           ),
      //         ),
      //         actions: [
      //           TextButton(
      //             child: Text('No',
      //                 style:
      //                     TextStyle(color: AppColor.secondaryColor1)),
      //             onPressed: () {
      //               checkTerm.value = false;
      //               Navigator.pop(ctx);
      //             },
      //           ),
      //           TextButton(
      //             onPressed: checkTerm.value
      //                 ? () async {
      //                     Navigator.pop(ctx);
      //                     final ok = await _updateFA(context);
      //                     if (ok) {
      //                       isUpdated.value = true;   // ✅ prevents Terms dialog next time
      //                       checkTerm.value = false;  // ✅ reset checkbox state
      //                     }
      //                   }
      //                 : null,
      //             child: Text('Update',
      //                 style:
      //                     TextStyle(color: AppColor.secondaryColor1)),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // );
    // } else {
      // final ok = await _updateFA(context);
      // if (ok) {
      //   isUpdated.value = true; // (still good to keep consistent)
      // }
    // }
  }

  /// Updates Flight Attendant profile fields via Cloud Code `updateAttendantProfile`.
  ///
  /// Important:
  /// - This uses the exact parameter names expected by the Cloud Function.
  /// - We send the *code* for `yearOfExperiance` (NOT the UI label), because
  ///   `getViewData()` maps codes -> labels using `_mapYearsOfExperience`.
  /// - Yes/No dropdown values are sent as strings; the Cloud Function converts
  ///   them to booleans using its `toBool` helper.
  Future<bool> _updateFA(BuildContext context) async {
    // Helper: map UI label -> server code for yearOfExperiance
    String yearsOfExpLabelToCode(String label) {
      final t = label.trim();
      if (t.isEmpty) return '';
      if (t == 'Less than 1 year') return '0-1';
      if (t == '1-3 years') return '1-3';
      if (t == '3-5 years') return '3-5';
      if (t == '5-10 years') return '5-10';
      if (t == 'More than 10 years') return '10+';
      // Fallback: if already a code, keep it; otherwise store as-is.
      return t;
    }

    String? dialogMsg;

    // 1) Show loader
    showLoadingDialog(context, 'Updating...');

    try {

      // ----------------------------
      // Build payload for Cloud Code
      // ----------------------------
      final params = <String, dynamic>{
        // Identity fields
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'gender': genderController.text.trim(), // "Male"/"Female"/"Other"
        'email': emailController.text.trim(),
        'phoneNumber': phoneNumberController.text.trim(),

        // Profile fields
        'currentLocation': currentLocationController.text.trim(), // "ON"/"OFF"
        'bio': bioController.text.trim(),
        'instagram': instagramController.text.trim(),
        'facebook': facebookController.text.trim(),
        'linkedin': linkedinController.text.trim(),

        // Optional fields (Cloud Code converts these)
        'HavePassport': passportController.text.trim(), // "Yes"/"No"
        'IsSearchAll': isIgnoreAvailability,
        'IsFullTime': isFullTime.value,
        'IsResume': isShowResume.value,

        // Rates (Number)
        'DomPDRate': _parseMoney(dayDomesticController.text),
        // 'InterPDRate': _parseMoney(dayInternationalController.text),

        // Experience fields
        'yearOfExperiance': yearsOfExpLabelToCode(yrExperienceController.text),

        // Lists (stored as comma-separated strings)
        'LanguagesSpoken': languageSaveList.join(', '),
        'InternationalVisas': internationalVisaSaveList.join(', '),
        'Continent': continentSaveList.join(', '),
        // 'RegionExp': continentExpSaveList.join(', '),

        // Aircraft specific training
        // 'isAircraftSpecificTraining': checkBoxValue.value,
        'TrainAircraftList': aircraftTypeExp.join(', '),

        // Special training
        'IsSpecialTrained': isSpecialTraining.value,
        'SpecialTrained': selectTrainingSaveList.join(', '),
        'SpecialTrainedOther': otherTrainingController.text.trim(),

        // Passport Exp Date (MM/dd/yyyy)
        'PassportExpDate': passportExpireDateController.text.trim(),
      };

      // Execute Cloud Function
      final func = ParseCloudFunction('updateAttendantProfile');
      final res = await func.execute(parameters: params);

      if (!res.success) {
        debugPrint('updateAttendantProfile failed: ${res.error}');
        showMyDialog(context, 'Failed to update. Please try again later!');
        return false;
      }

      if (currentLocaBool.value){
        // Refresh dashboard if location was toggled (affects nearby search)
        Get.find<DashboardController>().refreshForSelectedProfile();
      }

      // ----------------------------
      // Sync "original" mirrors so update dots reset
      // ----------------------------
      firstName = firstNameController.text;
      lastName = lastNameController.text;
      email = emailController.text;
      phoneNumber = phoneNumberController.text;
      gender = genderController.text;
      passport = passportController.text;
      currentLocation = currentLocationController.text;
      yrExperience = yrExperienceController.text;
      passportExpireDate = passportExpireDateController.text;
      dayDomestic = dayDomesticController.text;
      dayInternational = dayInternationalController.text;
      instagram = instagramController.text;
      facebook = facebookController.text;
      linkedin = linkedinController.text;
      bio = bioController.text;
      otherTraining = otherTrainingController.text;

      // Reset change flags (legacy dots)
      firstNameBool.value = false;
      lastNameBool.value = false;
      emailBool.value = false;
      phoneBool.value = false;
      genderBool.value = false;
      passportBool.value = false;
      passportDateBool.value = false;
      currentLocaBool.value = false;
      yroeBool.value = false;
      domRPDBool.value = false;
      intRPDBool.value = false;
      instaBool.value = false;
      facebookBool.value = false;
      linkedinBool.value = false;
      bioBool.value = false;
      allowBool.value = false;

      // These are list-based fields (if you track dots for these, keep them consistent)
      aircraftBool.value = false;
      aircraftSpecialBool.value = false;
      internationalBool.value = false;
      languageBool.value = false;
      specialBool.value = false;
      specialNameBool.value = false;
      continentBool.value = false;
      continent2Bool.value = false;

      // Success
      dialogMsg = 'Profile updated successfully.';
      return true;
    } catch (e, st) {
      debugPrint('_updateFA error: $e\n$st');
      dialogMsg = 'Please try again later!';
      return false;
    } finally {
      // 2) Close loader FIRST (important!)
      try {
        final nav = Navigator.of(context, rootNavigator: true);
        if (nav.canPop()) nav.pop();
      } catch (_) {}

      // 3) Then show dialog
      if (dialogMsg != null) {
        // ignore: use_build_context_synchronously
        await showMyDialog(context, dialogMsg);
      }
    }
  }

  // -------------- Field change hooks --------------

  void onGenderChanged(String? newValue) {
    if (newValue == null) return;
    genderBool.value = newValue != gender;
    genderController.text = newValue;
  }

  void onPassportChanged(String? newValue) {
    if (newValue == null) return;
    passportBool.value = newValue != passport;
    passportController.text = newValue;
  }

  // void onCurrentLocationChanged(String? newValue) {
  //   if (newValue == null) return;
  //   currentLocaBool.value = newValue != currentLocation;
  //   currentLocationController.text = newValue;
  // }

  // -----------------------
// Social link verification (Option A: canonicalize + validate + preview)
// -----------------------
final instagramStatus = ''.obs; // '', 'valid', 'invalid'
final facebookStatus = ''.obs;
final linkedinStatus = ''.obs;

/// Converts user input like "@username" or "instagram.com/username" to a canonical profile URL.
/// Returns empty string if input is empty.
String canonicalizeSocialUrl({required String platform, required String input}) {
  final p = platform == 'instagram'
      ? SocialPlatform.instagram
      : platform == 'facebook'
          ? SocialPlatform.facebook
          : SocialPlatform.linkedin;

  return SocialLinkUtils.canonicalize(platform: p, input: input);
}

/// Basic validation: checks scheme + allowed host.
bool _isValidSocialUrl({required String platform, required String url}) {
  final p = platform == 'instagram'
      ? SocialPlatform.instagram
      : platform == 'facebook'
          ? SocialPlatform.facebook
          : SocialPlatform.linkedin;

  return SocialLinkUtils.isValid(platform: p, url: url);
}

void _setCanonicalIfNeeded(TextEditingController c, String canonical) {
  if (canonical.isEmpty) return;
  if (c.text.trim() == canonical.trim()) return;

  c.value = TextEditingValue(
    text: canonical,
    selection: TextSelection.collapsed(offset: canonical.length),
  );
}

/// Verifies (soft) a social link: canonicalizes + validates + sets status.
void verifySocial(BuildContext context, {required String platform}) {
  TextEditingController c;
  RxString status;

  if (platform == 'instagram') {
    c = instagramController;
    status = instagramStatus;
  } else if (platform == 'facebook') {
    c = facebookController;
    status = facebookStatus;
  } else {
    c = linkedinController;
    status = linkedinStatus;
  }

  final canonical = canonicalizeSocialUrl(platform: platform, input: c.text);
  _setCanonicalIfNeeded(c, canonical);

  final ok = _isValidSocialUrl(platform: platform, url: c.text.trim());
  status.value = ok ? 'valid' : 'invalid';

  if (c.text.trim().isEmpty) {
    status.value = '';
    showMyDialog(context,
        'Please enter a ${platform[0].toUpperCase()}${platform.substring(1)} link or @username first.');
    return;
  }

  showMyDialog(
    context,
    ok
        ? 'Looks valid. You can preview it now.'
        : 'This does not look like a valid ${platform[0].toUpperCase()}${platform.substring(1)} profile link.',
  );
}

Future<void> previewSocial(BuildContext context, {required String platform}) async {
  TextEditingController c;
  if (platform == 'instagram') {
    c = instagramController;
  } else if (platform == 'facebook') {
    c = facebookController;
  } else {
    c = linkedinController;
  }

  final canonical = canonicalizeSocialUrl(platform: platform, input: c.text);
  _setCanonicalIfNeeded(c, canonical);

  final url = c.text.trim();
  if (!_isValidSocialUrl(platform: platform, url: url)) {
    showMyDialog(context,
        'Please verify and enter a valid ${platform[0].toUpperCase()}${platform.substring(1)} link first.');
    return;
  }

  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await UrlHelper.openInAppNoContext(uri.toString());
  } else {
    showMyDialog(context, 'Unable to open this link on your device.');
  }
}

/// Canonicalize on "done" (avoids cursor jump while typing).
void canonicalizeOnDone({required String platform}) {
  if (platform == 'instagram') {
    final canonical =
        canonicalizeSocialUrl(platform: platform, input: instagramController.text);
    _setCanonicalIfNeeded(instagramController, canonical);
  } else if (platform == 'facebook') {
    final canonical =
        canonicalizeSocialUrl(platform: platform, input: facebookController.text);
    _setCanonicalIfNeeded(facebookController, canonical);
  } else {
    final canonical =
        canonicalizeSocialUrl(platform: platform, input: linkedinController.text);
    _setCanonicalIfNeeded(linkedinController, canonical);
  }
}

}