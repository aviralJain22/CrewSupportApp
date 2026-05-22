import 'dart:convert';
import 'dart:io' show File, Platform;
import "dart:io" as Io;
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/utils/social_field_utils.dart';
import 'package:crew_support/utils/url_helper.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:crew_support/api/api_service.dart';
import 'package:crew_support/helper/user_helper.dart'; // NEW import path (as requested)
import 'package:crew_support/utils/Utility.dart'; // for showLoadingDialog / showMyDialog
import 'package:crew_support/utils/AppColor.dart'; // NEW AppColor import (as requested)
import 'package:crew_support/utils/constants.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart'; // for .spV2 (Sizer v2 compat)
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileOwnerController extends GetxController with WidgetsBindingObserver {
  // -----------------------
  // Text controllers (kept 1:1 with legacy)
  // -----------------------
  final membershipTypeController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final companyNameController = TextEditingController();
  final currentLocationController = TextEditingController();
  final genderController = TextEditingController();
  final instagramController = TextEditingController();
  final facebookController = TextEditingController();
  final linkedinController = TextEditingController();
  final bioController = TextEditingController();

  // -----------------------
  // Backing values (used for “has changed” checks, same as legacy)
  // -----------------------
  String firstName = "";
  String lastName = "";
  String email = "";
  String companyName = "";
  String currentLocation = "";
  String gender = "";
  String instagram = "";
  String facebook = "";
  String linkedin = "";
  String bio = "";

  // -----------------------
  // UI state
  // -----------------------
  final itemsLocation = const ['ON', 'OFF'];
  final itemsGender = const ['Female', 'Male', 'Other'];

  final isInputEmpty = false.obs;
  final ratingCount = 0.0.obs;

  final country = ''.obs;
  final city = ''.obs;

  final permissions = false.obs;
  final showCompanyName = false.obs; // “Use company name for profile?” toggle
  final isLoading = true.obs;
  final isPressed = true.obs;

  final isUpdated = true
      .obs; // legacy `isUpdated` from server (controls T&C dialog requirement)
  final checkTerm = false.obs; // T&C checkbox state

  // Flags to show “update” icon on modified fields (kept behavior)
  final firstNameBool = false.obs;
  final lastNameBool = false.obs;
  final companyNameBool = false.obs;
  final bioBool = false.obs;
  final currentLocaBool = false.obs;
  final instaBool = false.obs;
  final facebookBool = false.obs;
  final linkedInBool = false.obs;
  final genderBool = false.obs;

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
      showMyDialog(context, 'Please enter a ${platform[0].toUpperCase()}${platform.substring(1)} link or @username first.');
      return;
    }

    showMyDialog(
      context,
      ok ? 'Looks valid. You can preview it now.' : 'This does not look like a valid ${platform[0].toUpperCase()}${platform.substring(1)} profile link.',
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
      showMyDialog(context, 'Please verify and enter a valid ${platform[0].toUpperCase()}${platform.substring(1)} link first.');
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
      final canonical = canonicalizeSocialUrl(platform: platform, input: instagramController.text);
      _setCanonicalIfNeeded(instagramController, canonical);
    } else if (platform == 'facebook') {
      final canonical = canonicalizeSocialUrl(platform: platform, input: facebookController.text);
      _setCanonicalIfNeeded(facebookController, canonical);
    } else {
      final canonical = canonicalizeSocialUrl(platform: platform, input: linkedinController.text);
      _setCanonicalIfNeeded(linkedinController, canonical);
    }
  }

  // Image + share state
  final selectedImage = ''.obs;
  final isClicked = false.obs;

  /// True after we send the user to app Settings from the Current Location flow.
  /// On resume, we re-check permission and auto-flip the toggle to ON if the
  /// user granted Always access there.
  bool _awaitingLocationSettingsReturn = false;

  // Dependencies
  final ImagePicker _picker = ImagePicker();
  final ImageCropper _cropper = ImageCropper();
  // final FirebaseDynamicLinks _dynamicLinks = FirebaseDynamicLinks.instance;

  // Constant lists exposed to the view
  List<String> get genders => itemsGender;
  List<String> get onOff => itemsLocation;

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

  // -----------------------
  // Lifecycle
  // -----------------------
  @override
  Future<void> onInit() async {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void onClose() {
    // Match legacy: dismiss EasyLoading if visible
    EasyLoading.dismiss();
    // Dispose TextEditingControllers
    membershipTypeController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    companyNameController.dispose();
    currentLocationController.dispose();
    genderController.dispose();
    instagramController.dispose();
    facebookController.dispose();
    linkedinController.dispose();
    bioController.dispose();
    WidgetsBinding.instance.removeObserver(this);
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

  // -----------------------
  // Bootstrap: load profile + location (matches legacy initState)
  // -----------------------
  Future<void> _bootstrap() async {
    try {
      await getViewData();
      // await _loadUserFieldsFromParseUser();
      //TODO:
      // await getLocation();
    } catch (e) {
      print('bootstrap error: $e');
    }
  }

  // -----------------------
  // Pick image: gallery / camera → crop → compress → upload → refresh profile
  // -----------------------
  Future<void> openGallery(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    await _cropAndUpload(context, File(pickedFile.path));
  }

  Future<void> openCamera(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;
    await _cropAndUpload(context, File(pickedFile.path));
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
      final func = ParseCloudFunction('updateOwnerProfilePhoto');

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
      final func = ParseCloudFunction('clearOwnerProfilePhoto');
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

  // -----------------------
  // Cupertino action sheet for choosing camera/gallery/remove
  // (Screen calls this; kept in controller so logic is centralized)
  // -----------------------
  void showChoiceDialog(BuildContext context) {
    final action = Theme(
      data: ThemeData.dark(),
      child: CupertinoActionSheet(
        title: Text("Choose option", style: TextStyle(fontSize: 15.spV2)),
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              openGallery(context);
            },
            child: Text("Gallery", style: TextStyle(color: AppColor.textColor1)),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              openCamera(context);
            },
            child: Text("Camera", style: TextStyle(color: AppColor.textColor1)),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              clearProfileImage(context);
            },
            child: Text("Remove", style: TextStyle(color: AppColor.textColor1)),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child:
              Text("Cancel", style: TextStyle(color: AppColor.secondaryColor1)),
        ),
      ),
    );

    showCupertinoModalPopup(context: context, builder: (_) => action);
  }

  // -----------------------
  // Dynamic link + share (legacy behavior)
  // -----------------------
  Future<void> createAndShareDynamicLink(
      BuildContext context, String link) async {
    isClicked.value = true;
    // showLoadingDialog(context, '');

    //TODO:

    // try {
    //   final parameters = DynamicLinkParameters(
    //     uriPrefix: 'https://crewsupport.page.link',
    //     link: Uri.parse('https://crewsupport.page.link/ShareProfile/$link'),
    //     androidParameters: const AndroidParameters(
    //       packageName: 'com.crew_support.crew_support',
    //     ),
    //     iosParameters: const IOSParameters(
    //       bundleId: 'com.mobile.crewSupport',
    //       appStoreId: '1616109108',
    //     ),
    //     socialMetaTagParameters: SocialMetaTagParameters(
    //       title: 'Crew Support',
    //       imageUrl: Uri.parse(
    //           'https://crewsupport.net/wp-content/uploads/2022/05/CS-6-160-x-160.png'),
    //       description: 'Create an account or log in to Crew Support',
    //     ),
    //   );

    //   final ShortDynamicLink shortLink =
    //       await _dynamicLinks.buildShortLink(parameters);
    //   final url = shortLink.shortUrl.toString();

    //   if (Get.context != null) Navigator.of(Get.context!).pop();
    //   await _shareText(context, url, 'Profile link');
    // } catch (e) {
    //   print('dynamic link error: $e');
    //   if (Get.context != null) Navigator.of(Get.context!).pop();
    //   showMyDialog(context, 'Please try again later!');
    // } finally {
    //   isClicked.value = false;
    // }
  }

    void shareCurrentUserProfile(BuildContext context) {
      try {
        createAndShareDynamicLink(context, pkPilotId.toString());
      } catch (_) {
        showMyDialog(context, 'Unable to share profile link.');
      }
    }

  // Future<void> _shareText(
  //     BuildContext context, String text, String subject) async {
  //   final box = context.findRenderObject() as RenderBox?;
  //   await Share.share(
  //     text,
  //     subject: subject,
  //     sharePositionOrigin: (box?.localToGlobal(Offset.zero) ?? Offset.zero) &
  //         (box?.size ?? const Size(0, 0)),
  //   );
  // }

  // -----------------------
  // Location (legacy behavior preserved)
  // -----------------------
  Future<void> getLocation() async {
    try {
      final position = await _getGeoLocationPosition();
      permissions.value = true;
      await _addressFromPosition(position);
    } catch (e) {
      print('location error: $e');
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
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (Platform.isAndroid) {
        await Geolocator.openLocationSettings();
      } else {
        await Geolocator.openAppSettings();
      }
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );
  }

  Future<void> _addressFromPosition(Position position) async {
    final placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    final place = placemarks.first;

    // Legacy: update for each user in switchList
    for (int i = 0; i < switchList.length; i++) {
      //TODO:
      // await updateLocation(position, switchList[i].pkPilotId.toString());
    }

    country.value = place.country ?? '';
    city.value = place.locality ?? '';
  }

  // -----------------------
  // Load profile (new: via Back4App Cloud Function)
  // -----------------------
  Future<void> getViewData() async {
    try {
      // Call Back4App Cloud Function to fetch profile view data
      final func = ParseCloudFunction('getOwnerProfileViewData');
      final ParseResponse response = await func.execute();

      if (!response.success || response.result == null) {
        // If call failed or returned nothing, just stop loading
        isLoading.value = false;
        print('getViewData cloud function error: ${response.error?.message}');
        return;
      }

      // Expecting a plain JSON object from Cloud Code
      final data = Map<String, dynamic>.from(response.result as Map);

      // -----------------------
      // Identity fields (now coming from ownerProfile via Cloud Code)
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

      // phoneNumberController.text = (data['phoneNumber'] as String?) ?? '';
      // phoneNumber = phoneNumberController.text;

      // -----------------------
      // Fill controllers & backing values
      // -----------------------

      // Photo / avatar
      selectedImage.value = (data['PhotoPath'] as String?) ?? '';

      // Company name / showCompany toggle
      showCompanyName.value = (data['showCompany'] as bool?) ?? false;

      companyNameController.text = (data['CompanyName'] as String?) ?? '';
      companyName = companyNameController.text;

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
      isUpdated.value = (data['IsUpdated'] as bool?) ?? true;

      // Rating / ratingCount
      final ratingStr = (data['ratingCount'] as String?) ?? '0.0';
      ratingCount.value = double.tryParse(ratingStr) ?? 0.0;

      // CurrentLocation comes as Boolean - normalize to "ON"/"OFF"
      final currentLocRaw = data['CurrentLocation'];
      currentLocationController.text = _normalizeOnOff(currentLocRaw);
      currentLocation = currentLocationController.text;

      // (Optional) Rating text if you want to use it later
      // final ratingText = (data['Rating'] as String?) ?? '';

    } catch (e) {
      print('getViewData error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // -----------------------
  // Field change helpers (to show the little “update” hint suffix)
  // -----------------------
  void onFirstNameChanged(String _) {
    firstNameBool.value = firstNameController.text != firstName;
  }

  void onLastNameChanged(String _) {
    lastNameBool.value = lastNameController.text != lastName;
  }

  void onCompanyNameChanged(String _) {
    companyNameBool.value = companyNameController.text != companyName;
    isInputEmpty.value = firstNameController.text.isNotEmpty;
  }

  void onGenderChanged(String newVal) {
    genderBool.value = newVal != gender;
    genderController.text = newVal;
  }


  void setUseCompanyName(bool value) {
    showCompanyName.value = value;
  }

  /// True if ANY editable field has been modified
  bool get hasAnyChange =>
      firstNameBool.value ||
      lastNameBool.value ||
      companyNameBool.value ||
      genderBool.value ||
      currentLocaBool.value ||
      bioBool.value ||
      instaBool.value ||
      facebookBool.value ||
      linkedInBool.value;
  

  // --------------------- Update action ---------------------

  Future<void> onTapUpdate(BuildContext context) async {
    // Legacy validations preserved
    if (showCompanyName.value && companyNameController.text.isEmpty) {
      showMyDialog(context, 'Please enter company name');
      isPressed.value = true;
      return;
    }
    if (!showCompanyName.value && firstNameController.text.isEmpty) {
      showMyDialog(context, 'Please enter first name');
      isPressed.value = true;
      return;
    }
    if (!showCompanyName.value && !firstNameController.text.isAlphabetOnly) {
      showMyDialog(context, 'Please only enter letters in first name');
      isPressed.value = true;
      return;
    }
    if (!showCompanyName.value && lastNameController.text.isEmpty) {
      showMyDialog(context, 'Please enter last name');
      isPressed.value = true;
      return;
    }
    if (!showCompanyName.value && !lastNameController.text.isAlphabetOnly) {
      showMyDialog(context, 'Please only enter letters in last name');
      isPressed.value = true;
      return;
    }

    // If user has not accepted T&C before, show the dialog first.
    // if (isUpdated.isFalse) {
      // _showTermsDialog(context);
    // } else {
      // Directly call update if T&C already accepted.
      await _updateOwnerProfile(context);
    // }
  }

    /// Actually sends the updated data to Back4App via Cloud Code.
  /// This is called either directly (if isUpdated == true)
  /// or from the T&C dialog when user accepts.
  Future<void> _updateOwnerProfile(BuildContext context) async {
    try {
      isPressed.value = false;

      // Show loading dialog
      showLoadingDialog(context, 'Updating profile...');

      final bool ok = await updateOwnerProfileOnBack4App(
        isDefaultCompanyName: showCompanyName.value,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        companyName: companyNameController.text.trim(),
        gender: genderController.text.trim(),
        currentLocation: currentLocationController.text.trim(), // "ON"/"OFF"
        bio: bioController.text.trim(),
        instagram: instagramController.text.trim(),
        facebook: facebookController.text.trim(),
        linkedin: linkedinController.text.trim(),
      );

      // Close loading dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (!ok) {
        showMyDialog(context, 'Please try again later!');
        isPressed.value = true;
        return;
      }

      if (currentLocaBool.value){
        // Refresh dashboard if location was toggled (affects nearby search)
        Get.find<DashboardController>().refreshForSelectedProfile();
      }

      // Success: update backing values and reset "update" flags
      firstName = firstNameController.text;
      lastName = lastNameController.text;
      companyName = companyNameController.text;
      gender = genderController.text;
      currentLocation = currentLocationController.text;
      instagram = instagramController.text;
      facebook = facebookController.text;
      linkedin = linkedinController.text;
      bio = bioController.text;

      firstNameBool.value = false;
      lastNameBool.value = false;
      companyNameBool.value = false;
      genderBool.value = false;
      currentLocaBool.value = false;
      instaBool.value = false;
      facebookBool.value = false;
      linkedInBool.value = false;
      bioBool.value = false;

      // T&C gate is passed now
      isUpdated.value = true;

      showMyDialog(context, 'Profile updated successfully!');
    } catch (e) {
      print('updateOwnerProfile error: $e');
      // Ensure loading dialog is closed if something went wrong
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      showMyDialog(context, 'Please try again later!');
    } finally {
      isPressed.value = true;
    }
  }

  // void _showTermsDialog(BuildContext parentContext) {
  //   // NOTE: This builds a CupertinoAlertDialog exactly like the legacy screen.
  //   showDialog(
  //     context: parentContext,
  //     builder: (BuildContext dialogContext) => StatefulBuilder(
  //       builder: (ctx, setStateSB) => Theme(
  //         data: ThemeData.dark(),
  //         child: CupertinoAlertDialog(
  //           title: Text('Terms & Conditions',
  //               style: TextStyle(color: AppColor.textColor1)),
  //           content: Theme(
  //             data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
  //             child: SingleChildScrollView(
  //               child: Row(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Checkbox(
  //                     checkColor: AppColor.textColor2,
  //                     activeColor: AppColor.secondaryColor1,
  //                     value: checkTerm.value,
  //                     onChanged: (val) {
  //                       setStateSB(() {
  //                         checkTerm.value = val ?? false;
  //                       });
  //                     },
  //                   ),
  //                   Expanded(
  //                     child: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Wrap(
  //                           alignment: WrapAlignment.start,
  //                           crossAxisAlignment: WrapCrossAlignment.center,
  //                           spacing: 5,
  //                           children: [
  //                             Text(
  //                               'I accept',
  //                               style: TextStyle(
  //                                 color: AppColor.textColor1,
  //                                 fontSize: 10.spV2,
  //                               ),
  //                             ),
  //                             GestureDetector(
  //                               onTap: () async {
  //                                 const url = LegalUrls.terms;
  //                                 if (await canLaunchUrl(Uri.parse(url))) {
  //                                   await launchUrl(
  //                                     Uri.parse(url),
  //                                     mode: LaunchMode.externalApplication,
  //                                   );
  //                                   print(url);
  //                                 } else {
  //                                   throw 'Could not launch $url';
  //                                 }
  //                               },
  //                               child: Text(
  //                                 'Terms of use',
  //                                 style: TextStyle(
  //                                   color: AppColor.secondaryColor1,
  //                                   fontSize: 10.spV2,
  //                                 ),
  //                               ),
  //                             ),
  //                             Text(
  //                               ',',
  //                               style: TextStyle(fontSize: 10.spV2),
  //                             ),
  //                           ],
  //                         ),
  //                         Wrap(
  //                           alignment: WrapAlignment.start,
  //                           crossAxisAlignment: WrapCrossAlignment.center,
  //                           spacing: 5,
  //                           children: [
  //                             const SizedBox(width: 2),
  //                             GestureDetector(
  //                               onTap: () async {
  //                                 const url = LegalUrls.privacy;
  //                                 if (await canLaunchUrl(Uri.parse(url))) {
  //                                   await launchUrl(
  //                                     Uri.parse(url),
  //                                     mode: LaunchMode.externalApplication,
  //                                   );
  //                                   print(url);
  //                                 } else {
  //                                   throw 'Could not launch $url';
  //                                 }
  //                               },
  //                               child: Text(
  //                                 'Privacy Policy',
  //                                 style: TextStyle(
  //                                   color: AppColor.secondaryColor1,
  //                                   fontSize: 10.spV2,
  //                                 ),
  //                               ),
  //                             ),
  //                             const SizedBox(width: 5),
  //                             Text(
  //                               'and',
  //                               style: TextStyle(
  //                                 fontSize: 10.spV2,
  //                                 color: AppColor.textColor1,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                         Wrap(
  //                           alignment: WrapAlignment.start,
  //                           crossAxisAlignment: WrapCrossAlignment.center,
  //                           spacing: 5,
  //                           children: [
  //                             GestureDetector(
  //                               onTap: () async {
  //                                 const url = LegalUrls.disclaimer;
  //                                 if (await canLaunchUrl(Uri.parse(url))) {
  //                                   await launchUrl(
  //                                     Uri.parse(url),
  //                                     mode: LaunchMode.externalApplication,
  //                                   );
  //                                   print(url);
  //                                 } else {
  //                                   throw 'Could not launch $url';
  //                                 }
  //                               },
  //                               child: Text(
  //                                 'Disclaimer',
  //                                 style: TextStyle(
  //                                   color: AppColor.secondaryColor1,
  //                                   fontSize: 10.spV2,
  //                                 ),
  //                               ),
  //                             ),
  //                             Text(
  //                               '.',
  //                               style: TextStyle(
  //                                 fontSize: 10.spV2,
  //                                 color: AppColor.textColor1,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 isPressed.value = true;
  //                 Navigator.pop(dialogContext);
  //                 if (checkTerm.value) checkTerm.value = false;
  //               },
  //               child: Text("No",
  //                   style: TextStyle(color: AppColor.secondaryColor1)),
  //             ),
  //             TextButton(
  //               onPressed: checkTerm.value
  //                   ? () async {
  //                       Navigator.pop(dialogContext); // Close the dialog first
  //                       await _updateOwnerProfile(parentContext); // Use stable parent context
  //                     }
  //                   : null,
  //               child: Text('Update',
  //                   style: TextStyle(color: AppColor.secondaryColor1)),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

}