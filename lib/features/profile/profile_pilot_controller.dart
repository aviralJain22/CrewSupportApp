import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'dart:io' as Io;
import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/helper/user_helper.dart'; // ✅ new path
import 'package:crew_support/model/AircraftModel.dart';
import 'package:crew_support/model/CountryModel.dart';
import 'package:crew_support/model/rating_certification.dart';
import 'package:crew_support/utils/AppColor.dart'; // ✅ new path
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/constants.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart'; // ✅ spV2 extension
import 'package:crew_support/utils/social_field_utils.dart';
import 'package:crew_support/utils/url_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;
import 'package:multi_select_flutter/util/multi_select_item.dart';

class ProfilePilotController extends GetxController with WidgetsBindingObserver {
  // ---------- Text controllers (owned by controller) ----------
  final membershipTypeController = TextEditingController();
  final firstNameController = TextEditingController();
  String firstName = "";
  final lastNameController = TextEditingController();
  String lastName = "";
  final emailController = TextEditingController();
  String email = "";
  final passportController = TextEditingController();
  String passport = "";
  final picTimeController = TextEditingController();
  String picTime = "";
  final citizenship = TextEditingController();
  String citizenshipString = "";
  final genderController = TextEditingController();
  String gender = "";
  final phoneNumberController = TextEditingController();
  String phoneNumber = "";
  final noteController = TextEditingController();
  String note = "";
  final totalTimeController = TextEditingController();
  String totalTime = "";
  final currentLocationController = TextEditingController();
  String currentLocation = "";
  final medicalClassController = TextEditingController();
  String medicalClass = "";
  final passportExpireDateController = TextEditingController();
  String passportExpireDate = "";
  final continentEpController = TextEditingController();
  String continentEp = "";
  final instagramController = TextEditingController();
  String instagram = "";
  final facebookController = TextEditingController();
  String facebook = "";
  final linkedinController = TextEditingController();
  String linkedin = "";
  final bioController = TextEditingController();
  String bio = "";
  final cityController = TextEditingController();
  String cityString = "";
  final stateController = TextEditingController();
  String state = "";
  final zipCodeController = TextEditingController();
  String zipCode = "";
  final otherTrainingController = TextEditingController();
  String otherTraining = "";

  // ---------- UI state ----------
  final isLoadingPage = true.obs;
  final isLoadingRatings = true.obs;

  final isPressed = true.obs;
  final isClicked = false.obs;

  /// True after we send the user to app Settings from the Current Location flow.
  /// On resume, we re-check permission and auto-flip the toggle to ON if the
  /// user granted Always access there.
  bool _awaitingLocationSettingsReturn = false;

  // toggles to show "update" marker next to fields (as in old code)
  final firstNameBool = false.obs;
  final lastNameBool = false.obs;
  final emailBool = false.obs;
  final phoneBool = false.obs;
  final bioBool = false.obs;
  final currentLocaBool = false.obs;
  final passportBool = false.obs;
  final allowBool = false.obs;
  final fullTime = false.obs;
  final showResume = false.obs;
  final continentBool = false.obs;
  final oceanicBool = false.obs;
  final medicalBool = false.obs;
  final countryBool = false.obs;
  final passportDateBool = false.obs;
  final instaBool = false.obs;
  final facebookBool = false.obs;
  final linkedinBool = false.obs;
  final totalBool = false.obs;
  final genderBool = false.obs;
  final picBool = false.obs;

  /// True if ANY editable field has been modified.
  ///
  /// We reuse the same "update marker" booleans already used by the UI.
  /// This powers showing/hiding the bottom Update button.
  bool get hasAnyChange {
    // Marker flags already used throughout the UI
    final markerChanged =
        firstNameBool.value ||
        lastNameBool.value ||
        emailBool.value ||
        phoneBool.value ||
        bioBool.value ||
        currentLocaBool.value ||
        passportBool.value ||
        allowBool.value ||
        fullTime.value ||
        showResume.value ||
        continentBool.value ||
        oceanicBool.value ||
        medicalBool.value ||
        countryBool.value ||
        passportDateBool.value ||
        instaBool.value ||
        facebookBool.value ||
        linkedinBool.value ||
        totalBool.value ||
        genderBool.value ||
        picBool.value;

    if (markerChanged) return true;

    // Extra comparisons for fields that don't always toggle a dedicated marker flag
    // (keeps the button accurate even if a marker is missed somewhere).
    final specialTrainingChanged = (isSpecialTrainingRx.value != specialTrainingValue);
    if (specialTrainingChanged) return true;

    final selectTrainingChanged =
    _normalizeCommaSeparatedValues(selectTrainingSaveList.join(',')) !=
    _normalizeCommaSeparatedValues(selectTrainingStr);
    if (selectTrainingChanged) return true;

    final otherTrainingChanged = (otherTrainingController.text.trim() != otherTraining.trim());
    if (otherTrainingChanged) return true;

    final continentChanged = (continentSaveList.join(', ') != continentStr);
    if (continentChanged) return true;

    final oceanicChanged = (oceanicSaveList.join(', ') != oceanicStr);
    if (oceanicChanged) return true;

    return false;
  }

  String _normalizeCommaSeparatedValues(String raw) {
  return raw
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .join(', ');
}

  void markProfileAsSaved() {
    firstName = firstNameController.text.trim();
    lastName = lastNameController.text.trim();
    email = emailController.text.trim();
    phoneNumber = phoneNumberController.text.trim();
    bio = bioController.text;
    currentLocation = currentLocationController.text.trim();
    passport = passportController.text.trim();
    totalTime = totalTimeController.text.trim();
    gender = genderController.text.trim();
    picTime = picTimeController.text.trim();
    medicalClass = medicalClassController.text.trim();
    citizenshipString = citizenship.text.trim();
    passportExpireDate = passportExpireDateController.text.trim();
    instagram = instagramController.text.trim();
    facebook = facebookController.text.trim();
    linkedin = linkedinController.text.trim();
    otherTraining = otherTrainingController.text.trim();

    isIgnoreAvailabilityCheck = isIgnoreAvailability;
    isFullTimeCheck = isFullTime;
    isShowResumeCheck = isShowResume;
    specialTrainingValue = isSpecialTrainingRx.value;

    selectTrainingStr = _normalizeCommaSeparatedValues(selectTrainingSaveList.join(','));
    continentStr = continentSaveList.join(', ');
    oceanicStr = oceanicSaveList.join(', ');

    firstNameBool.value = false;
    lastNameBool.value = false;
    emailBool.value = false;
    phoneBool.value = false;
    bioBool.value = false;
    currentLocaBool.value = false;
    passportBool.value = false;
    allowBool.value = false;
    fullTime.value = false;
    showResume.value = false;
    continentBool.value = false;
    oceanicBool.value = false;
    medicalBool.value = false;
    countryBool.value = false;
    passportDateBool.value = false;
    instaBool.value = false;
    facebookBool.value = false;
    linkedinBool.value = false;
    totalBool.value = false;
    genderBool.value = false;
    picBool.value = false;
  }

  // dropdown sources (kept identical)
  final itemsLocation = const ['ON', 'OFF'];
  final itemsGender = const ["Female", "Male", "Other"]; // ✅ includes "Other"
  final itemsPassport = const ['Yes', 'No'];

  List<String> continentCountryList = [
    'North America',
    'South America',
    'Antarctica',
    'Europe',
    'Asia',
    'Africa',
    'Australia'
  ];

  List<String> oceanicCountryList = [
    'North Atlantic',
    'South Pacific',
    'North Pacific'
  ];

  // other flags from old file
  DateTime currentDate = DateTime.now();
  bool permissions = false;
  String country = '';
  String city = '';
  String selectTrainingStr = '';

  List<RatingCertification> ratingData = [];
  final ratingCount = 0.0.obs;
  bool isIgnoreAvailability = false;
  String? resumePath;
  final resumePathRx = ''.obs;
  // String? resumePathStr;
  bool isFullTime = false;
  bool isFullTimeCheck = false;
  bool isShowResume = false;
  bool isShowResumeCheck = false;
  bool isUpdated = true;
  bool isIgnoreAvailabilityCheck = false;
  bool specialNameBool = false;
  bool isSpecialTraining = false;
  final isSpecialTrainingRx = false.obs; // reactive mirror for UI
  bool specialBool = false;
  bool specialTrainingValue = false;

  List<String> continentSaveList = [];
  String continentStr = '';
  List<String> continentFinalList = [];

  List<String> selectTrainingSaveList = [];
  List<String> selectTrainingFinalList = [];

  List<String> citizenshipSaveList = [];
  List<String> citizenshipFinalList = [];

  List<String> oceanicSaveList = [];
  String oceanicStr = '';
  List<String> oceanicFinalList = [];

  final searchController = TextEditingController();

  // Image + sharing
  final ImagePicker _picker = ImagePicker();
  final ImageCropper _cropper = ImageCropper();
  // final FirebaseDynamicLinks _dynamicLinks = FirebaseDynamicLinks.instance;

  final selectedImage = ''.obs;
  int updateFirstTime = 0;
  final checkTerm = false.obs;

  // These globals came from old code; kept for compatibility.
  // Make sure pkPilotId, switchList, kPhotoPath are defined somewhere shared.
  // ignore: non_constant_identifier_names
  String get pkPilotId => Get.parameters['pilotId'] ?? ""; // fallback

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

  final itemsYesNo = const ['Yes', 'No'];
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

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initPage();
  }

  @override
  void onClose() {

    WidgetsBinding.instance.removeObserver(this);

    membershipTypeController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passportController.dispose();
    picTimeController.dispose();
    citizenship.dispose();
    genderController.dispose();
    phoneNumberController.dispose();
    noteController.dispose();
    totalTimeController.dispose();
    currentLocationController.dispose();
    medicalClassController.dispose();
    passportExpireDateController.dispose();
    continentEpController.dispose();
    instagramController.dispose();
    facebookController.dispose();
    linkedinController.dispose();
    bioController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipCodeController.dispose();
    otherTrainingController.dispose();
    searchController.dispose();
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
        permissions = true;
        update();
      }
    } catch (e) {
      debugPrint('return from location settings check error: $e');
    }
  }

  Future<void> _initPage() async {
    try {
      await getViewData();
      // await _loadUserFieldsFromParseUser();
      await getRating();
      //TODO:
      // await getLocation();
    } catch (e, st) {
      log("init error: $e\n$st");
    } finally {
      isLoadingPage.value = false;
    }
  }

  // --------------------- Ratings ---------------------

  Future<void> getRating() async {
    // try {
    //   isLoadingRatings.value = true;
    //   final value = await getRatingCertificate(pkPilotId.toString());
    //   ratingData = value?.data?.ratingCertificates ?? [];
    //   // The star view is read-only; we still carry the double value:
    //   //TODO:
    //   // ratingCount.value = double.tryParse(value?.data?.pilot?.extraField1 ?? "0.0") ?? 0.0;
    // } catch (e) {
    //   ratingData = [];
    // } finally {
    //   isLoadingRatings.value = false;
    // }
    try {
      isLoadingRatings.value = true;
        final result = await fetchRatingCertifications();
        ratingData.assignAll(result);
      } catch (e) {
        debugPrint("Error loading certifications: $e");
      } finally {
        isLoadingRatings.value = false;
      }
  }

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
      final func = ParseCloudFunction('updatePilotProfilePhoto');

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
  /// Now calls the "clearProfilePhoto" Back4App Cloud Function, which is
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
      final func = ParseCloudFunction('clearPilotProfilePhoto');
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

  // --------------------- Share profile link ---------------------

  Future<void> createDynamicLink(BuildContext context, {required String link, bool short = true}) async {
    //TODO:
    // isClicked.value = true;
    // showLoadingDialog(context, '');

    // try {
    //   final params = DynamicLinkParameters(
    //     uriPrefix: 'https://crewsupport.page.link',
    //     link: Uri.parse('https://crewsupport.page.link/ShareProfile/$link'),
    //     androidParameters: const AndroidParameters(
    //       packageName: 'com.crew_support.crew_support',
    //     ),
    //     iosParameters: const IOSParameters(
    //       bundleId: 'com.mobile.crewSupport',
    //       appStoreId: '1616109108',
    //     ),
    //     socialMetaTagParameters: const SocialMetaTagParameters(
    //       title: 'Crew Support',
    //       imageUrl: Uri.parse('https://crewsupport.net/wp-content/uploads/2022/05/CS-6-160-x-160.png'),
    //       description: 'Create an account or log in to Crew Support',
    //     ),
    //   );

    //   late Uri url;
    //   if (short) {
    //     final shortLink = await _dynamicLinks.buildShortLink(params);
    //     url = shortLink.shortUrl;
    //   } else {
    //     url = await _dynamicLinks.buildLink(params);
    //   }

    //   Navigator.of(context).maybePop();
    //   await _onShare(context, url.toString(), 'Profile link');
    // } catch (e) {
    //   Navigator.of(context).maybePop();
    //   showMyDialog(context, 'Could not create link. Please try again later.');
    // } finally {
    //   isClicked.value = false;
    // }
  }

  // Future<void> _onShare(BuildContext context, String text, String subject) async {
  //   final box = context.findRenderObject() as RenderBox?;
  //   await Share.share(text, subject: subject, sharePositionOrigin: (box?.localToGlobal(Offset.zero) ?? Offset.zero) & (box?.size ?? const Size(0, 0)));
  // }

    // --------------------- Location ---------------------

  Future<void> getLocation() async {
    try {
      final position = await _getGeoLocationPosition();
      permissions = true;
      await _getAddressFromLatLong(position);
    } catch (_) {
      // Silently ignore if denied.
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
    final bool granted =
        await _ensureLocationPermissionForCurrentLocationFeature(context);

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
        permissions = true;
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
      // Try once more to upgrade to background access where supported.
      final LocationPermission upgradedPermission =
          await Geolocator.requestPermission();

      if (upgradedPermission == LocationPermission.always) {
        permissions = true;
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
      permissions = true;
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

  Future<void> _getAddressFromLatLong(Position position) async {
    final placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    final place = placemarks.first;

    for (int i = 0; i < switchList.length; i++) {
      // old code: updateLocation(position, switchList[i].pkPilotId.toString());
      //TODO:
      // await updateLocation(position, switchList[i].pkPilotId.toString());
    }

    country = place.country ?? '';
    city = place.locality ?? '';
  }

  // -----------------------
  // Load profile (new: via Back4App Cloud Function)
  // -----------------------
  Future<void> getViewData() async {
    try {
      // Call Back4App Cloud Function to fetch profile view data
      final func = ParseCloudFunction('getPilotProfileViewData');
      final ParseResponse response = await func.execute();

      if (!response.success || response.result == null) {
        // If call failed or returned nothing, just stop loading
        // isLoadingPage.value = false;
        print('getViewData cloud function error: ${response.error?.message}');
        return;
      }

      // Expecting a plain JSON object from Cloud Code
      final data = Map<String, dynamic>.from(response.result as Map);

      // -----------------------
      // Identity fields (now coming from pilotProfile via Cloud Code)
      // -----------------------

      // membershipType (Number -> label)
      final int? mt = data['membershipType'] is num ? (data['membershipType'] as num).toInt() : null;
      membershipTypeController.text = (mt == null) ? '' : getMembershipTypeText(mt);

      // firstName / lastName
      firstNameController.text = (data['firstName'] as String?) ?? '';
      firstName = firstNameController.text;

      lastNameController.text = (data['lastName'] as String?) ?? '';
      lastName = lastNameController.text;

      // gender (Number 0/1/2 -> label)
      // Your _normalizeGender currently accepts string input (like "0"/"1"/"2")
      final int? genCode = data['gender'] is num ? (data['gender'] as num).toInt() : null;
      final normalizedGender = (genCode == null) ? '' : _normalizeGender(genCode.toString());
      genderController.text = normalizedGender;
      gender = normalizedGender;

      // email / phoneNumber
      emailController.text = (data['email'] as String?) ?? '';
      email = emailController.text;

      phoneNumberController.text = (data['phoneNumber'] as String?) ?? '';
      phoneNumber = phoneNumberController.text;

      // -----------------------
      // Fill controllers & backing values
      // -----------------------

      // Photo / avatar
      selectedImage.value = (data['PhotoPath'] as String?) ?? '';

      // Instagram
      instagramController.text = (data['instagram'] as String?) ?? '';
      instagram = instagramController.text;
      instagramStatus.value = '';

      // Facebook
      facebookController.text = (data['facebook'] as String?) ?? '';
      facebook = facebookController.text;
      facebookStatus.value = '';

      // LinkedIn
      linkedinController.text = (data['linkedIn'] as String?) ?? '';
      linkedin = linkedinController.text;
      linkedinStatus.value = '';

      // Bio
      bioController.text = (data['Bio'] as String?) ?? '';
      bio = bioController.text;

      // IsUpdated gate for Terms & Conditions
      isUpdated = (data['IsUpdated'] as bool?) ?? true;

      // Rating / ratingCount
      final ratingStr = (data['ratingCount'] as String?) ?? '0.0';
      ratingCount.value = double.tryParse(ratingStr) ?? 0.0;

      // CurrentLocation comes as Boolean - normalize to "ON"/"OFF"
      final currentLocRaw = data['CurrentLocation'];
      currentLocationController.text = _normalizeOnOff(currentLocRaw);
      currentLocation = currentLocationController.text;

      final havePassportRaw = data['HavePassport'];
      passportController.text = _normalizeYesNo(havePassportRaw);
      passport = passportController.text;

      isIgnoreAvailability = (data['IsSearchAll'] as bool?) ?? false;
      isIgnoreAvailabilityCheck = (data['IsSearchAll'] as bool?) ?? false;

      isFullTime = (data['IsFullTime'] as bool?) ?? false;
      isFullTimeCheck = (data['IsFullTime'] as bool?) ?? false;

      isShowResume = (data['IsResume'] as bool?) ?? false;
      isShowResumeCheck = (data['IsResume'] as bool?) ?? false;

      resumePath = (data['ResumePath'] as String?) ?? '';
      resumePathRx.value = (data['ResumePath'] as String?) ?? '';
      // resumePathStr = (data['ResumePath'] as String?) ?? '';

      // totalTime / totalPICTime now come from Cloud Code as Number (or null)
      final dynamic totalTimeRaw = data['totalTime'];
      final dynamic totalPICTimeRaw = data['totalPICTime'];

      totalTimeController.text = (totalTimeRaw == null) ? '' : totalTimeRaw.toString();
      totalTime = totalTimeController.text;

      picTimeController.text = (totalPICTimeRaw == null) ? '' : totalPICTimeRaw.toString();
      picTime = picTimeController.text;

      // FAAMedical is stored on server as Number (1/2/3) or can be null.
      // If we try to cast it as String, it becomes null and the field shows blank.
      final dynamic faMedicalRaw = data['FAAMedical'];
      String medicalText = '';
      if (faMedicalRaw is num) {
        // Normalize to integer string (e.g., 1, 2, 3)
        medicalText = faMedicalRaw.toInt().toString();
      } else if (faMedicalRaw is String) {
        // In case some older data comes back as string
        medicalText = faMedicalRaw.trim();
      }

      // Only allow valid values or blank
      if (medicalText != '1' && medicalText != '2' && medicalText != '3') {
        medicalText = '';
      }

      medicalClassController.text = medicalText;
      medicalClass = medicalText;

      citizenshipSaveList = ((data['CitizenCountry'] as String?) ?? '').split(",");
      citizenship.text = citizenshipSaveList.isEmpty ? " " : citizenshipSaveList.join(",");
      citizenshipString = citizenship.text;

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

      // Special Training
      isSpecialTraining = (data['IsSpecialTrained'] as bool?) ?? false;
      isSpecialTrainingRx.value = isSpecialTraining;
      specialTrainingValue = isSpecialTraining;

      selectTrainingSaveList.clear();
      selectTrainingFinalList.clear();

      final specialTrainedRaw = (data['SpecialTrained'] as String?) ?? '';
      selectTrainingStr = _normalizeCommaSeparatedValues(specialTrainedRaw);

      if (selectTrainingStr.isNotEmpty) {
        final savedTrainings = selectTrainingStr
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        selectTrainingSaveList.addAll(savedTrainings);
        selectTrainingFinalList.addAll(savedTrainings);
      }

      // Other Training
      // Show saved custom training text only when "Other" is selected.
      final bool hasOtherTrainingSelected = selectTrainingSaveList.any(
        (training) => training.trim().toLowerCase() == 'other',
      );

      final String specialTrainedOtherRaw =
          (data['SpecialTrainedOther'] as String?) ?? '';

      otherTrainingController.text = hasOtherTrainingSelected
          ? specialTrainedOtherRaw.trim()
          : '';

      otherTraining = otherTrainingController.text;

      
      continentSaveList = ((data['Continent'] as String?) ?? '').split(",");
      continentStr = continentSaveList.join(", ");

      oceanicSaveList = ((data['OceanicExp'] as String?) ?? '').split(",");
      oceanicStr = oceanicSaveList.join(", ");

      update(); // Trigger UI update after loading all fields

      // (Optional) Rating text if you want to use it later
      // final ratingText = (data['Rating'] as String?) ?? '';

      // try {
      //   final result = await fetchRatingCertifications();
      //   ratingData.assignAll(result);
      // } catch (e) {
      //   debugPrint("Error loading certifications: $e");
      // } finally {
      //   isLoadingRatings.value = false;
      // }

    } catch (e) {
      print('getViewData error: $e');
    } finally {
      // isLoadingPage.value = false;
    }
  }

  /// Fetch all rating certifications for logged-in pilot
  Future<List<RatingCertification>> fetchRatingCertifications() async {
    final ParseCloudFunction function =
        ParseCloudFunction('getRatingCertifications');

    // Call cloud function
    final ParseResponse response = await function.execute();

    if (!response.success || response.result == null) {
      return [];
    }

    // Convert JSON list to Dart model list
    final List<dynamic> data = response.result;

    return data.map((item) => RatingCertification.fromJson(item)).toList();
  }


  List<String> aircraftTypeExp = [];
  List<AircraftTypeList> aircraftExpFinalList = [];

  /// Opens the citizenship country multi‑select dialog.
  ///
  /// This is a direct port of the old `citizenLocation()` method, but rewritten
  /// to work inside the GetX controller (no `setState`, all updates go through
  /// our controllers and reactive flags).
  Future<void> citizenLocation(BuildContext context) async {
    // For debugging parity with old code
    print(citizenshipString);

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Theme(
          data: ThemeData.dark(),
          child: MultiSelectDialog<String>(
            title: Text(
              'Select Country',
              style: TextStyle(
                color: AppColor.secondaryColor1,
                fontSize: 12.spV2,
              ),
            ),
            items: citizenshipCountryList
                .map((country) => MultiSelectItem<String>(country, country))
                .toList(),
            initialValue: List<String>.from(citizenshipSaveList),
            itemsTextStyle: TextStyle(
              color: AppColor.textColor1,
              fontSize: 11.spV2,
            ),
            checkColor: AppColor.textColor2,
            unselectedColor: AppColor.textColor1,
            selectedColor: AppColor.secondaryColor1,
            selectedItemsTextStyle: TextStyle(
              color: AppColor.secondaryColor1,
              fontSize: 11.spV2,
            ),
            searchable: true,
            onConfirm: (values) {
              // Clear previous selections
              citizenshipFinalList.clear();
              citizenshipSaveList.clear();

              if (values.isEmpty) {
                print('country citizenship empty');
                citizenship.clear();
              }

              // Convert to a typed list of strings
              citizenshipFinalList = values.map((e) => e.toString()).toList();

              // Preserve the same ordering logic as old code:
              for (int i = 0; i < citizenshipCountryList.length; i++) {
                for (int j = 0; j < citizenshipFinalList.length; j++) {
                  if (citizenshipCountryList[i] == citizenshipFinalList[j]) {
                    citizenshipSaveList.add(citizenshipCountryList[i]);
                    print(citizenshipCountryList[i]);

                    // Update the text controller so UI reflects selection
                    citizenship.text = citizenshipSaveList.join(",");
                    print("first -- ${citizenship.text}");
                    print("second --${citizenshipSaveList.join(", ")}");
                  }
                }
              }

              // Toggle the "update" marker exactly like old code
              print('$citizenshipString -- ${citizenship.text}');
              if (citizenship.text == citizenshipString) {
                countryBool.value = false;
              } else {
                countryBool.value = true;
              }
            },
          ),
        );
      },
    );
  }

  // Legacy: showMedicalPicker() – now implemented with GetX fields
  Future<void> showMedicalPicker(BuildContext context) async {
    // We keep the same CupertinoActionSheet UI as the old screen
    final sheet = Theme(
      data: ThemeData.dark(),
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "1",
              style: TextStyle(color: AppColor.textColor1, fontSize: 12.spV2),
            ),
            isDefaultAction: false,
            onPressed: () {
              // Save previous value to compare for "update" marker
              final old = medicalClass;
              medicalClassController.text = "1";
              medicalClass = "1";
              // Toggle the update marker if value actually changed
              medicalBool.value = (medicalClass != old);
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              "2",
              style: TextStyle(color: AppColor.textColor1, fontSize: 12.spV2),
            ),
            isDestructiveAction: false,
            onPressed: () {
              final old = medicalClass;
              medicalClassController.text = "2";
              medicalClass = "2";
              medicalBool.value = (medicalClass != old);
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              "3",
              style: TextStyle(color: AppColor.textColor1, fontSize: 12.spV2),
            ),
            isDestructiveAction: false,
            onPressed: () {
              final old = medicalClass;
              medicalClassController.text = "3";
              medicalClass = "3";
              medicalBool.value = (medicalClass != old);
              Navigator.pop(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: AppColor.secondaryColor1, fontSize: 12.spV2),
          ),
          onPressed: () {
            // If user cancels and the field matches the original value,
            // we clear the "update" marker (same behavior as old code).
            if (medicalClassController.text == medicalClass) {
              medicalBool.value = false;
            }
            Navigator.pop(context);
          },
        ),
      ),
    );

    await showCupertinoModalPopup(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => sheet,
    );
  }

  // --------------------- Date Picker ---------------------

  Future<void> selectPassportDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            primaryColor: AppColor.secondaryColor1,
            colorScheme: ColorScheme.dark(
              primary: AppColor.secondaryColor1,
              onPrimary: AppColor.textColor1,
              onSurface: AppColor.textColor1,
              surface: AppColor.bgColor2,
              background: AppColor.bgColor2,
              secondary: AppColor.secondaryColor1,
              tertiary: AppColor.secondaryColor1,
            ),
            dialogBackgroundColor: AppColor.bgColor2,
            focusColor: AppColor.secondaryColor1,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != currentDate) {
      currentDate = picked;
      final dateStr = DateFormat('MM/dd/yyyy').format(picked);
      passportExpireDateController.text = dateStr;
      passportDateBool.value = (passportExpireDateController.text != passportExpireDate);
    }
  }

  // --------------------- Update action ---------------------

  Future<void> onUpdatePressed(BuildContext context) async {
    FocusScope.of(context).unfocus();

    // legacy validations (kept exactly)
    if (firstNameController.text.isEmpty) {
      showMyDialog(context, 'Please enter first name'); return;
    } else if (!firstNameController.text.isAlphabetOnly) {
      showMyDialog(context, 'Please only enter letters in first name'); return;
    } else if (lastNameController.text.isEmpty) {
      showMyDialog(context, 'Please enter last name'); return;
    } else if (!lastNameController.text.isAlphabetOnly) {
      showMyDialog(context, 'Please only enter letters in last name'); return;
    } else if (phoneNumberController.text.isEmpty) {
      showMyDialog(context, 'Please enter phone number'); return;
    } else if (phoneNumberController.text.length != 10) {
      showMyDialog(context, 'Phone number is not valid'); return;
    } else if (emailController.text.isEmpty) {
      showMyDialog(context, 'Please enter email id'); return;
    } else if (!Utility.isValidEmail(emailController.text.trim())) {
      showMyDialog(context, 'Email address is not valid'); return;
    }

    await _doUpdate(context);

    // Old flow: if not updated before, show terms gate
    // if (isUpdated == false) {
    //   await _showTermsDialog(context);
    // } else {
    //   await _doUpdate(context);
    // }
  }

  // Future<void> _showTermsDialog(BuildContext context) async {
  //   await showDialog(
  //     context: context,
  //     builder: (_) => StatefulBuilder(
  //       builder: (context, setSt) => Theme(
  //         data: ThemeData.dark(),
  //         child: CupertinoAlertDialog(
  //           title: Text('Terms & Conditions', style: TextStyle(fontSize: 12.spV2)),
  //           content: Theme(
  //             data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
  //             child: CheckboxListTile(
  //               activeColor: AppColor.secondaryColor1,
  //               checkColor: AppColor.textColor2,
  //               controlAffinity: ListTileControlAffinity.leading,
  //               title: Column(
  //                 children: [
  //                   Row(children: [
  //                     Text('I accept', style: TextStyle(color: AppColor.textColor1, fontSize: 10.spV2)),
  //                     const SizedBox(width: 5),
  //                     GestureDetector(
  //                       onTap: () async {
  //                         const url = 'https://crewsupport.net/privacy-policy/';
  //                         if (await canLaunchUrl(Uri.parse(url))) {
  //                           await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  //                         }
  //                       },
  //                       child: Text('Terms of use', style: TextStyle(color: AppColor.secondaryColor1, fontSize: 10.spV2)),
  //                     ),
  //                     Text(",", style: TextStyle(color: AppColor.textColor1, fontSize: 10.spV2)),
  //                   ]),
  //                   Row(children: [
  //                     const SizedBox(width: 2),
  //                     GestureDetector(
  //                       onTap: () async {
  //                         const url = 'https://crewsupport.net/privacy-policy/';
  //                         if (await canLaunchUrl(Uri.parse(url))) {
  //                           await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  //                         }
  //                       },
  //                       child: Text('Privacy Policy', style: TextStyle(color: AppColor.secondaryColor1, fontSize: 10.spV2)),
  //                     ),
  //                     const SizedBox(width: 5),
  //                     Text("and", style: TextStyle(color: AppColor.textColor1, fontSize: 10.spV2)),
  //                   ]),
  //                   Row(mainAxisAlignment: MainAxisAlignment.center, children: [
  //                     GestureDetector(
  //                       onTap: () async {
  //                         const url = 'https://crewsupport.net/disclaimer/';
  //                         if (await canLaunchUrl(Uri.parse(url))) {
  //                           await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  //                         }
  //                       },
  //                       child: Text('Disclaimer', style: TextStyle(color: AppColor.secondaryColor1, fontSize: 10.spV2)),
  //                     ),
  //                     Text(".", style: TextStyle(color: AppColor.textColor1, fontSize: 10.spV2)),
  //                   ]),
  //                 ],
  //               ),
  //               value: checkTerm.value,
  //               onChanged: (v) => setSt(() => checkTerm.value = v ?? false),
  //             ),
  //           ),
  //           actions: [
  //             TextButton(
  //               child: Text("No", style: TextStyle(color: AppColor.secondaryColor1, fontSize: 11.spV2)),
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                 if (checkTerm.value) checkTerm.value = false;
  //               },
  //             ),
  //             TextButton(
  //               onPressed: checkTerm.value ? () async {
  //                 Navigator.pop(context);
  //                 await _doUpdate(context);
  //               } : null,
  //               child: Text('Update', style: TextStyle(color: AppColor.secondaryColor1, fontSize: 11.spV2)),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  /// Helper to safely close the loading dialog.
  ///
  /// Uses rootNavigator: true to ensure we close the dialog that
  /// `showLoadingDialog` likely opened. Wrapped in try/catch so we
  /// don't accidentally crash if there is nothing to pop.
  void _closeLoadingDialog(BuildContext context) {
    try {
      Navigator.of(context, rootNavigator: true).pop();
    } catch (_) {
      // Ignore if there's nothing to pop
    }
  }

  /// Performs the actual update (API contract identical to the old `UpdatePilot`).
  Future<void> _doUpdate(BuildContext context) async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Show loading dialog
    showLoadingDialog(context, "Updating...");

    try {

      // totalTime / totalPICTime are Number-only now (Cloud Code rejects numeric strings)
      final String totalTimeStr = totalTimeController.text.trim();
      final String totalPICTimeStr = picTimeController.text.trim();

      // If blank -> send null (clears the field)
      // If not blank -> must parse to number
      double? totalTimeNum;
      if (totalTimeStr.isEmpty) {
        totalTimeNum = null;
      } else {
        totalTimeNum = double.tryParse(totalTimeStr);
        if (totalTimeNum == null) {
          _closeLoadingDialog(context); // ✅ close loader before showing error
          showMyDialog(context, 'Please enter a valid numeric Total Time');
          return;
        }
      }

      double? totalPICTimeNum;
      if (totalPICTimeStr.isEmpty) {
        totalPICTimeNum = null;
      } else {
        totalPICTimeNum = double.tryParse(totalPICTimeStr);
        if (totalPICTimeNum == null) {
          _closeLoadingDialog(context); // ✅ close loader before showing error
          showMyDialog(context, 'Please enter a valid numeric PIC Time');
          return;
        }
      }

      // Parse medical class text ("1", "2", "3") into an int
      int? medicalClassInt;
      final medicalText = medicalClassController.text.trim();
      if (medicalText.isNotEmpty) {
        medicalClassInt = int.tryParse(medicalText);
      }

      // NOTE: membershipType is not editable; do not send it to Cloud Code.
      // Prepare parameters exactly as Cloud Function expects
      final Map<String, dynamic> params = {
        // Identity fields -> pilotProfile (NOT _User)
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'gender': genderController.text.trim(), // "Male"/"Female"/"Other"
        'email': emailController.text.trim(),          // read-only in UI but safe to send
        'phoneNumber': phoneNumberController.text.trim(), // read-only in UI but safe to send

        // ----- pilotProfile fields -----
        'currentLocation': currentLocationController.text.trim(), // "ON"/"OFF"

        'bio': bioController.text.trim(),
        'instagram': instagramController.text.trim(),
        'facebook': facebookController.text.trim(),
        'linkedin': linkedinController.text.trim(),

        // Boolean flags
        'HavePassport': passportController.text.trim(),   // "Yes"/"No"
        'IsSearchAll': isIgnoreAvailability,              // bool
        'IsFullTime': isFullTime,                         // bool
        'IsResume': isShowResume,                         // bool

        // Numbers
        "totalTime": totalTimeNum,
        "totalPICTime": totalPICTimeNum,
        
        // 🔹 FAAMedical as NUMBER (1/2/3) 🔹
        'FAAMedical': medicalClassInt,                        // int? -> Number on Parse
        
        'CitizenCountry': citizenship.text.trim(),        // comma-separated string

        // Passport Expiration
        'PassportExpDate': passportExpireDateController.text.trim(), // "MM/dd/yyyy"

        // Special training
        'IsSpecialTrained': isSpecialTrainingRx.value,    // bool
        'SpecialTrained': selectTrainingSaveList.join(","),   // comma-separated
        'SpecialTrainedOther': otherTrainingController.text.trim(),

        // Continent & Oceanic Experience
        'Continent': continentSaveList.join(","),         // comma-separated
        'OceanicExp': oceanicSaveList.join(","),          // comma-separated
      };

      // Call Back4App Cloud Function
      final ParseCloudFunction func = ParseCloudFunction('updatePilotProfile');
      final ParseResponse response = await func.execute(parameters: params);

      // Check for failures
      if (!response.success || response.result == null) {
        // ✅ Always close the "Updating..." dialog first
        _closeLoadingDialog(context);

        showMyDialog(context, 'Failed to update your profile. Please try again.');
        return;
      }

      // ✅ Close the loader on success as well
      _closeLoadingDialog(context);

      // Show success message
      showMyDialog(context, "Profile updated successfully!");

      isUpdated = true; // mark as updated for terms dialog logic

      if (currentLocaBool.value){
        // Refresh dashboard if location was toggled (affects nearby search)
        Get.find<DashboardController>().refreshForSelectedProfile();
      }

      markProfileAsSaved();

      // Refresh profile data after update
      await getViewData();
      // await _loadUserFieldsFromParseUser();

    } catch (e) {
      // ✅ Ensure the loader is closed even when an exception is thrown
      _closeLoadingDialog(context);

      showMyDialog(context, "Something went wrong. Please try again later.");
      debugPrint("updatePilotProfile error: $e");
    }
  }
  

  // --------------------- Helpers for safe Dropdown value ---------------------

  String? safeGenderValue() {
    final v = genderController.text.trim();
    return itemsGender.contains(v) ? v : null;
  }

  String? safeLocationValue() {
    final v = currentLocationController.text.trim().isEmpty
        ? null
        : currentLocationController.text.trim();
    return v != null && itemsLocation.contains(v) ? v : null;
  }

  String? safePassportValue() {
    final v = passportController.text.trim();
    return itemsPassport.contains(v) ? v : null;
  }

Future<void> openResume(BuildContext context) async {
  final url = (resumePathRx.value).trim().isEmpty ? (resumePath ?? '').trim() : resumePathRx.value.trim();
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

Future<void> pickAndUploadResume(BuildContext context) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );
  if (result == null) return; // user cancelled

  final path = result.files.single.path;
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
                final func = ParseCloudFunction('updatePilotProfileResume');
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
                resumePath = url;
                resumePathRx.value = resumePath ?? '';

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

}

/// Deletes the resume by delegating server-side cleanup to Cloud Code.
/// Fix: Always closes the "Deleting..." loader, even on early returns/errors.
Future<void> deleteResume(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (_) => Theme(
      data: ThemeData.dark(),
      child: CupertinoAlertDialog(
        content: Text('Are you sure you want to delete this resume?'),
        actions: [
          CupertinoButton(
            child: Text('Cancel', style: TextStyle(color: AppColor.secondaryColor1, fontSize: 10.spV2)),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoButton(
            child: Text('Delete', style: TextStyle(color: AppColor.deleteColor, fontSize: 10.spV2)),
            onPressed: () async {
              // Close confirmation dialog first
              Navigator.pop(context);

              // Show loader
              showLoadingDialog(context, 'Deleting...');
              try {
                // --- Cloud Code handles unsetting the Resume File field and deleting the underlying Parse file.
                final func = ParseCloudFunction('clearPilotProfileResume');
                final response = await func.execute();

                // ✅ close loader FIRST
                final nav = Navigator.of(context, rootNavigator: true);
                if (nav.canPop()) nav.pop();

                // If failed, show message (loader will still close in finally)
                if (!response.success || response.result == null) {
                  showMyDialog(context, 'Please try again later!');
                  return;
                }

                // Update local UI state
                resumePath = '';
                resumePathRx.value = '';

                // ✅ now show success dialog
                showMyDialog(context, 'Resume deleted successfully.');
              } catch (e) {
                debugPrint('[ProfilePilot] deleteResume error: $e');

                // ✅ close loader FIRST
                final nav = Navigator.of(context, rootNavigator: true);
                if (nav.canPop()) nav.pop();

                showMyDialog(context, 'Please try again later!');
              }
            },
          ),
        ],
      ),
    ),
  );
}

/// Show multi-select dialog for Continent Experience (preLocation in old code)
  Future<void> preLocation(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Theme(
          data: ThemeData.dark(),
          child: MultiSelectDialog<String>(
            height: 50.h,
            width: 80.w,
            title: Text(
              'Select Country',
              style: TextStyle(color: AppColor.secondaryColor1),
            ),
            items: continentCountryList
                .map((city) => MultiSelectItem<String>(city, city))
                .toList(),
            initialValue: continentSaveList,
            itemsTextStyle: TextStyle(color: AppColor.textColor1),
            checkColor: AppColor.textColor2,
            unselectedColor: AppColor.textColor1,
            selectedColor: AppColor.secondaryColor1,
            selectedItemsTextStyle: TextStyle(color: AppColor.secondaryColor1),
            onConfirm: (values) {
              // Mirror old _preLocation logic, but with GetX observables
              continentFinalList.clear();
              continentSaveList.clear();

              // values should already be List<String>, but ensure type safety
              continentFinalList = List<String>.from(values);

              for (int i = 0; i < continentCountryList.length; i++) {
                for (int j = 0; j < continentFinalList.length; j++) {
                  if (continentCountryList[i] == continentFinalList[j]) {
                    continentSaveList.add(continentCountryList[i]);
                  }
                }
              }

              final newStr = continentSaveList.join(", ");
              // Compare against previous string used to detect "update" tick
              if (newStr == continentStr) {
                continentBool.value = false;
              } else {
                continentBool.value = true;
              }

              // Update stored string for future comparisons and UI
              continentStr = newStr;
            },
          ),
        );
      },
    );
  }


/// Show multi-select dialog for Oceanic Experience (oceanic in old code)
  Future<void> oceanic(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Theme(
          data: ThemeData.dark(),
          child: MultiSelectDialog<String>(
            height: 50.h,
            width: 80.w,
            title: Text(
              'Select Country',
              style: TextStyle(color: AppColor.secondaryColor1),
            ),
            items: oceanicCountryList
                .map((city) => MultiSelectItem<String>(city, city))
                .toList(),
            initialValue: oceanicSaveList,
            itemsTextStyle: TextStyle(color: AppColor.textColor1),
            checkColor: AppColor.textColor2,
            unselectedColor: AppColor.textColor1,
            selectedColor: AppColor.secondaryColor1,
            selectedItemsTextStyle: TextStyle(color: AppColor.secondaryColor1),
            onConfirm: (values) {
              // Mirror old _oceanic logic, but with GetX observables
              oceanicFinalList.clear();
              oceanicSaveList.clear();

              debugPrint("oceanic values: $values");

              // values should already be List<String>, but ensure type safety
              oceanicFinalList = List<String>.from(values);

              for (int i = 0; i < oceanicCountryList.length; i++) {
                for (int j = 0; j < oceanicFinalList.length; j++) {
                  if (oceanicCountryList[i] == oceanicFinalList[j]) {
                    oceanicSaveList.add(oceanicCountryList[i]);
                  }
                }
              }

              final newStr = oceanicSaveList.join(", ");
              if (newStr == oceanicStr) {
                oceanicBool.value = false;
              } else {
                oceanicBool.value = true;
              }

              // Update stored string for future comparisons and UI
              oceanicStr = newStr;
            },
          ),
        );
      },
    );
  }

List<String> selectTrainingCountryList = [
    // 'Airline Trained',
    // 'Beyond & Above',
    'Clay Lacy Qualified',
    // 'Corporate Air Parts',
    // 'CPR Training',
    // 'Cullinary Training',
    "EJM Qualified",
    // 'Evacuation Training',
    // 'FACTS Training',
    // 'Flight Safety',
    // 'Jet Aviation',
    'Jet Edge Qualified',
    // 'None',
    // 'SkyAngels SKYacademy',
    'Solairus Qualified',
    // 'VVIP International',
    'Other',
  ];

/// Opens the "Select Training" multi-select dialog.
///
/// Port of the old `selectTraining()` method, adapted for GetX.
/// Uses `selectTrainingCountryList`, `selectTrainingSaveList`,
/// `selectTrainingFinalList`, `selectTrainingStr`, and `specialNameBool`
/// to preserve old behavior exactly.
Future<void> selectTrainingDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return Theme(
        data: ThemeData.dark(),
        child: MultiSelectDialog<String>(
          // height / width were commented out in old code, so we keep defaults
          title: Text(
            'Select Training',
            style: TextStyle(
              color: AppColor.secondaryColor1,
              fontSize: 12.spV2,
            ),
          ),
          items: selectTrainingCountryList
              .map((item) => MultiSelectItem<String>(item, item))
              .toList(),
          initialValue: List<String>.from(selectTrainingSaveList),
          itemsTextStyle: TextStyle(
            color: AppColor.textColor1,
            fontSize: 11.spV2,
          ),
          checkColor: AppColor.textColor2,
          unselectedColor: AppColor.textColor1,
          selectedColor: AppColor.secondaryColor1,
          selectedItemsTextStyle: TextStyle(
            color: AppColor.secondaryColor1,
            fontSize: 11.spV2,
          ),
          onConfirm: (values) {
            // Reset previous state
            selectTrainingFinalList.clear();
            selectTrainingSaveList.clear();

            print("selectTrainingDialog values: $values");
            print(values.contains("None"));

            // Ensure we have a typed list of strings
            selectTrainingFinalList =
                values.map((e) => e.toString()).toList();

            // Preserve ordering logic from old code
            for (int i = 0; i < selectTrainingCountryList.length; i++) {
              for (int j = 0; j < selectTrainingFinalList.length; j++) {
                if (selectTrainingCountryList[i] ==
                    selectTrainingFinalList[j]) {
                  selectTrainingSaveList.add(selectTrainingCountryList[i]);
                  print(selectTrainingSaveList.join(","));
                }
              }
            }

            // Mark field as updated if selection changed
            if (selectTrainingSaveList.join(", ") == selectTrainingStr) {
              specialNameBool = false;
            } else {
              specialNameBool = true;
            }
          },
        ),
      );
    },
  );
}

  // ----- Type Rating navigations (legacy equivalent) -----
  Future<void> openAddRatingType(BuildContext context) async {
    FocusScope.of(context).unfocus();
    // Wait until AddRatingType route is popped
    await Get.toNamed(AppRoutes.addRatingType);
    // Now this runs AFTER the user returns
    await getRating();
  }

  Future<void> openEditTypeRatings(BuildContext context) async {
    FocusScope.of(context).unfocus();
    // Wait until TypeRating route is popped
    await Get.toNamed(AppRoutes.typeRating);
    // Now this runs AFTER the user returns
    await getRating();
  }

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