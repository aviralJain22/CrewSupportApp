import 'package:crew_support/utils/AppColor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Controller for the read-only owner profile view screen.
///
/// Converted from legacy `owner_profile.dart`.
/// Keeps UI data/state here so the screen stays clean.
class OwnerViewProfileController extends GetxController {
  // ---------------------------------------------------------------------------
  // Text controllers used by the UI
  // ---------------------------------------------------------------------------
  final TextEditingController membershipTypeController =
      TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController currentLocationController =
      TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  // ---------------------------------------------------------------------------
  // Reactive UI state
  // ---------------------------------------------------------------------------
  final RxBool isLoading = true.obs;
  final RxBool isFavorite = false.obs;
  final RxDouble ratingCount = 0.0.obs;

  final RxString userPhoto = ''.obs;
  final RxString instagramLink = ''.obs;
  final RxString facebookLink = ''.obs;
  final RxString linkedinLink = ''.obs;
  final RxString lat = ''.obs;
  final RxString long = ''.obs;

  /// ownerProfile.objectId of the profile being viewed.
  final RxString ownerProfileId = ''.obs;
  final RxString ownerUserId = ''.obs;
  final RxString fullName = ''.obs;
  final RxInt viewedMembershipType = 1.obs;
  final RxBool currentLocationEnabled = false.obs;

  /// Stores the raw profile response for future use/debugging if needed.
  final RxMap<String, dynamic> rawProfile = <String, dynamic>{}.obs;

  final RxnInt membershipType = RxnInt();
  final RxBool showCompany = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadReadOnlyOwnerProfileViewData();
  }

  /// Loads the read-only owner profile payload from the cloud function
  /// `getReadOnlyOwnerProfileViewData`.
  ///
  /// The screen can receive either `profileId` or `userId` as a String in
  /// Get.arguments. If `profileId` is missing, the cloud function will resolve
  /// it using `userId`.
  Future<void> _loadReadOnlyOwnerProfileViewData() async {
    try {
      isLoading.value = true;

      final dynamic args = Get.arguments;
      final String profileId = _toStr(
        _extractArg(args, const ['profileId']),
      ).trim();
      final String userId = _toStr(
        _extractArg(args, const ['userId']),
      ).trim();

      if (profileId.isEmpty && userId.isEmpty) {
        throw Exception('Either profileId or userId is required');
      }

      // Keep the viewed owner profile id locally when it is already available.
      // If only userId was passed, the cloud function will resolve profileId and
      // the returned payload can populate ownerProfileId later.
      if (profileId.isNotEmpty) {
        ownerProfileId.value = profileId;
      }

      // Call the cloud function using profileId when available, otherwise fall
      // back to userId so the backend can resolve the ownerProfile row.
      final dynamic response = await getReadOnlyOwnerProfileViewData(
        profileId: profileId,
        userId: userId,
      );

      final dynamic dataNode =
          _extractArg(response, const ['data', 'datas', 'result']) ?? response;

      if (dataNode == null) {
        throw Exception('Empty profile response');
      }

      _applyProfileData(dataNode);

      // Favourite state still comes from the legacy favourite list API.
      await _loadFavoriteState();
    } catch (e) {
      debugPrint(
        'OwnerViewProfileController _loadReadOnlyOwnerProfileViewData error: $e',
      );
      Get.snackbar(
        'Error',
        'Unable to load profile details.',
        backgroundColor: Colors.white,
        colorText: AppColor.secondaryColor1,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Calls the Back4App cloud function `getReadOnlyOwnerProfileViewData`.
  ///
  /// Accepts either `profileId` or `userId`. When `profileId` is empty, the
  /// backend resolves the owner profile using `userId`.
  Future<dynamic> getReadOnlyOwnerProfileViewData({
    String profileId = '',
    String userId = '',
  }) async {
    final String trimmedProfileId = profileId.trim();
    final String trimmedUserId = userId.trim();

    if (trimmedProfileId.isEmpty && trimmedUserId.isEmpty) {
      throw Exception('Either profileId or userId is required');
    }

    final ParseCloudFunction cloudFunction =
        ParseCloudFunction('getReadOnlyOwnerProfileViewData');

    final Map<String, dynamic> parameters = <String, dynamic>{};
    if (trimmedProfileId.isNotEmpty) {
      parameters['profileId'] = trimmedProfileId;
    }
    if (trimmedUserId.isNotEmpty) {
      parameters['userId'] = trimmedUserId;
    }

    final ParseResponse response = await cloudFunction.execute(
      parameters: parameters,
    );

    if (!response.success) {
      final String errorMessage =
          (response.error?.message.trim().isNotEmpty == true)
              ? response.error!.message
              : 'Unable to load read-only owner profile.';
      throw Exception(errorMessage);
    }

    return response.result;
  }

  Future<void> _loadFavoriteState() async {
    // try {
    //   final dynamic response = await getFavoriteList();
    //   final dynamic dataNode = _extractArg(response, const ['datas', 'data']);
    //   final dynamic favorites =
    //       _extractArg(dataNode, const ['favourites']) ?? [];

    //   if (favorites is List) {
    //     for (final dynamic item in favorites) {
    //       final String favProfileId = _toStr(
    //         _extractArg(item, const ['fkPilotid', 'fkPilotId', 'pilotID']),
    //       ).trim();

    //       if (favProfileId.isNotEmpty && favProfileId == ownerProfileId.value) {
    //         isFavorite.value = _toBool(
    //               _extractArg(item, const ['isFavourite', 'isFavorite']),
    //             ) ??
    //             isFavorite.value;
    //         break;
    //       }
    //     }
    //   }
    // } catch (e) {
    //   debugPrint('OwnerViewProfileController _loadFavoriteState error: $e');
    // }
  }

  /// Maps read-only owner profile response fields onto controller state.
  void _applyProfileData(dynamic profile) {
    rawProfile.assignAll(_toMap(profile));

    final String firstName = _toStr(
      _extractArg(profile, const ['firstName', 'pilotFname', 'fname']),
    );
    final String lastName = _toStr(
      _extractArg(profile, const ['lastName', 'pilotLname', 'lname']),
    );

    firstNameController.text = firstName;
    lastNameController.text = lastName;
    fullName.value =
        [firstName, lastName].where((e) => e.trim().isNotEmpty).join(' ').trim();

    final dynamic membershipTypeValue =
        _extractArg(profile, const ['membershipTypeName', 'membershipType']);
    membershipType.value = (membershipTypeValue is num) ? membershipTypeValue.toInt() : null;
    membershipTypeController.text = _membershipTypeLabel(membershipTypeValue);

    companyNameController.text = _toStr(
      _extractArg(profile, const ['CompanyName', 'companyName']),
    );

    showCompany.value =
    _toBool(_extractArg(profile, const ['showCompany'])) ?? false;

    final g = _extractArg(profile, const ['gender']);
    final gender = (g is num) ? g.toInt() : null;

    genderController.text = getGenderText(gender);

    final bool locationOn =
        _toBool(_extractArg(profile, const ['CurrentLocation', 'currentLocation'])) ??
            false;
    currentLocationEnabled.value = locationOn;
    currentLocationController.text = locationOn ? 'ON' : 'OFF';

    userPhoto.value = _toStr(
      _extractArg(profile, const ['PhotoPath', 'photoPath', 'profilePicture', 'photo']),
    );

    instagramLink.value = _toStr(
      _extractArg(profile, const ['instagram', 'instagramLink', 'extraField2']),
    );

    facebookLink.value = _toStr(
      _extractArg(profile, const ['facebook', 'facebookLink', 'extraField3']),
    );

    linkedinLink.value = _toStr(
      _extractArg(profile, const ['linkedIn', 'linkedin', 'linkedinLink', 'linkedInProfile']),
    );

    bioController.text = _toStr(
      _extractArg(profile, const ['Bio', 'bio']),
    );

    final String returnedProfileId = _toStr(
      _extractArg(profile, const ['profileId', 'id', 'objectId']),
    ).trim();
    if (returnedProfileId.isNotEmpty) {
      ownerProfileId.value = returnedProfileId;
    }

    ownerUserId.value = _toStr(
      _extractArg(profile, const ['userId', 'userObjectId']),
    );

    viewedMembershipType.value = _toInt(
          _extractArg(profile, const ['membershipType']),
        ) ??
        1;

    final String latLong =
        _toStr(_extractArg(profile, const ['latlong', 'latLong']));
    if (latLong.contains(',')) {
      final List<String> parts = latLong.split(',');
      lat.value = parts.first.trim();
      long.value = parts.last.trim();
    } else {
      lat.value = '';
      long.value = '';
    }

    final dynamic ratingValue = _extractArg(
      profile,
      const ['Rating', 'rating', 'extraField1'],
    );
    ratingCount.value = _toDouble(ratingValue) ?? 0.0;

    final bool? fav = _toBool(
      _extractArg(profile, const ['isFavrouite', 'isFavourite', 'isFavorite']),
    );
    if (fav != null) {
      isFavorite.value = fav;
    }
  }
  // ---------------------------------------------------------------------------
  // Computed UI helpers
  // ---------------------------------------------------------------------------
  bool get hasAnySocialLink =>
      instagramLink.value.trim().isNotEmpty ||
      facebookLink.value.trim().isNotEmpty ||
      linkedinLink.value.trim().isNotEmpty;

  bool get canShowLocationPin =>
      currentLocationEnabled.value &&
      lat.value.trim().isNotEmpty &&
      long.value.trim().isNotEmpty;

  bool get canOpenFullImage {
    final String url = userPhoto.value.trim();
    return url.isNotEmpty && url != 'http';
  }

  /// Legacy screen only showed message icon in a specific scenario.
  /// Keeping that behaviour as close as possible.
  bool get canMessageOwner {
    // final String? currentProfileId = _currentProfileIdAsString();
    // final String? currentMembership = _currentMembershipTypeAsString();

    // if (currentProfileId == null || currentProfileId.isEmpty) {
    //   return false;
    // }

    // if (currentProfileId == ownerProfileId.value.toString()) {
    //   return false;
    // }

    // return currentMembership == '1';
    return true;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------
  void toggleFavorite() {
    
  }
  // Future<void> toggleFavorite() async {
  //   final bool newValue = !isFavorite.value;
  //   isFavorite.value = newValue;

  //   try {
  //     await insertUpdateFavourite(
  //       isFavourite: newValue,
  //       userId: ownerProfileId.value,
  //       pilotID: ownerProfileId.value,
  //     );
  //   } catch (e) {
  //     debugPrint('OwnerViewProfileController toggleFavorite error: $e');
  //     isFavorite.value = !newValue;
  //     Get.snackbar(
  //       'Error',
  //       'Unable to update favourite status.',
  //       backgroundColor: Colors.white,
  //       colorText: AppColor.secondaryColor1,
  //     );
  //   }
  // }

  Future<void> openSocialLink(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      final bool canOpen = await canLaunchUrl(uri);

      if (!canOpen) {
        Get.snackbar(
          'Invalid Link',
          'This profile link could not be opened.',
          backgroundColor: Colors.white,
          colorText: AppColor.secondaryColor1,
        );
        return;
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('OwnerViewProfileController openSocialLink error: $e');
      Get.snackbar(
        'Error',
        'Unable to open link.',
        backgroundColor: Colors.white,
        colorText: AppColor.secondaryColor1,
      );
    }
  }

  void openImagePreview() {
    if (!canOpenFullImage) return;

    // Adjust this route if your image preview route name is different.
    Get.toNamed(
      '/image-view',
      arguments: {
        'imageUrl': userPhoto.value,
      },
    );
  }

  void openChat() {
    // Adjust this route / argument keys if your chat module expects different ones.
    Get.toNamed(
      '/chat',
      arguments: {
        'otherProfileId': ownerProfileId.value,
        'otherUserId': ownerUserId.value,
        'otherProfileType': viewedMembershipType.value,
        'title': fullName.value,
        'photoUrl': userPhoto.value,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Generic parsing helpers
  // These allow the controller to work with either map-based data or old model
  // objects while you continue the migration.
  // ---------------------------------------------------------------------------
  dynamic _extractArg(dynamic source, List<String> keys) {
    if (source == null) return null;

    if (source is Map) {
      for (final String key in keys) {
        if (source.containsKey(key)) {
          return source[key];
        }
      }
      return null;
    }

    final Map<String, dynamic> map = _toMap(source);
    for (final String key in keys) {
      if (map.containsKey(key)) {
        return map[key];
      }
    }

    return null;
  }

  Map<String, dynamic> _toMap(dynamic value) {
    if (value == null) return <String, dynamic>{};

    if (value is Map<String, dynamic>) return value;

    if (value is Map) {
      return value.map((key, dynamic val) => MapEntry(key.toString(), val));
    }

    try {
      final dynamic json = (value as dynamic).toJson();
      if (json is Map<String, dynamic>) return json;
      if (json is Map) {
        return json.map((key, dynamic val) => MapEntry(key.toString(), val));
      }
    } catch (_) {}

    return <String, dynamic>{};
  }

  String _toStr(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;

    final String text = value.toString().toLowerCase().trim();
    if (text == 'true' || text == '1' || text == 'yes' || text == 'on') {
      return true;
    }
    if (text == 'false' || text == '0' || text == 'no' || text == 'off') {
      return false;
    }
    return null;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// Converts membership type values into the same user-facing label expected
  /// by the legacy UI.
  String _membershipTypeLabel(dynamic value) {
    if (value == null) return '';

    if (value is String) {
      final String text = value.trim();
      if (text.isEmpty) return '';

      // If the backend already sent a human-readable label, keep it.
      if (int.tryParse(text) == null) {
        return text;
      }
    }

    switch (_toInt(value)) {
      case 1:
        return 'Owner/Operator';
      case 2:
        return 'Instructor';
      case 3:
        return 'Pilot';
      case 4:
        return 'Flight Attendant';
      case 5:
        return 'SIC';
      default:
        return _toStr(value);
    }
  }

  String getGenderText(int? gender) {
    switch (gender) {
      case 0:
        return 'Male';
      case 1:
        return 'Female';
      case 2:
        return 'Other';
      default:
        return 'Unknown';
    }
  }

  @override
  void onClose() {
    membershipTypeController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    companyNameController.dispose();
    currentLocationController.dispose();
    genderController.dispose();
    bioController.dispose();
    super.onClose();
  }
}