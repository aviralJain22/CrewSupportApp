import 'dart:async';
import 'package:crew_support/Api/Api_service.dart';
import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/features/trip/create_direct_trip_controller.dart';
import 'package:crew_support/helper/user_helper.dart';
import 'package:crew_support/model/AircraftModel.dart';
import 'package:crew_support/model/get_favorite_list_model.dart';
import 'package:crew_support/model/pilot_availability_service.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:crew_support/utils/Utility.dart';

class FlightAttendantViewProfileController extends GetxController {
  FlightAttendantViewProfileController({
    // required this.viewProfileResponse,
    this.initialProfileId,
    this.showGender,
    this.showProfile,
  });

  /// Passed-in data (from old screen’s constructor)
  final String? initialProfileId;
  // final Pilot viewProfileResponse;
  final bool? showGender;
  final bool? showProfile;

  /// Raw profile map returned by the read-only cloud function.
  /// We intentionally avoid using FlatUserProfileSafe on this screen.
  Map<String, dynamic>? profileMap;

  /// Convenience values extracted from profileMap (used by UI visibility rules)
  final RxInt membershipType = 0.obs; // 1=Owner, 4=Attendant, etc.
  final RxBool currentLocation = false.obs;
  final RxBool isResumeFlag = false.obs;
  final RxString photoPath = ''.obs;
  final RxString resumeUrl = ''.obs;
  final RxDouble ratingAvg = 0.0.obs;
  final RxString linkedInUrl = ''.obs;

   final userId = ''.obs; // for chat - the attendant's user pointer id (not profile id)
  /// Current attendantProfile.objectId (resolved or passed)
  final attendantProfileId = ''.obs;

  final RxString aircraftExpStr = ''.obs;
  final RxString continentExpStr = ''.obs;
  final RxString internationalVisasHeldStr = ''.obs;
  final RxString languagesStr = ''.obs;
  final RxString specialTrainingStr = ''.obs;
  final RxString otherTrainingStr = ''.obs;

  /// Text controllers (kept for exact UI)
  final membershipTypeController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final searchAllController = TextEditingController();
  final emailController = TextEditingController();
  final passportController = TextEditingController();
  final fullTimeController = TextEditingController();
  final aircraftSpecificTrainingController = TextEditingController();
  final genderController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final dayDomesticController = TextEditingController();
  final unrestrictedController = TextEditingController();
  final internationalController = TextEditingController();
  final dayInternationalController = TextEditingController();
  final yrExperienceController = TextEditingController();
  final specialTrainingController = TextEditingController();
  final otherTrainingController = TextEditingController();
  final currentLocationController = TextEditingController();
  final bioController = TextEditingController();

  /// Simple values
  final RxBool isLoading = true.obs;
  final RxString userPhoto = ''.obs;
  final isSendingConnectionRequest = false.obs;
  final isRespondingToConnectionRequest = false.obs;
  final isCancellingConnectionRequest = false.obs;
  final isUnfriendingConnection = false.obs;

  // -----------------------------
  // Social links (from API)
  // -----------------------------
  final RxString instagramLink = ''.obs;
  final RxString facebookLink = ''.obs;
  final RxString linkedinLink = ''.obs;

  bool get hasAnySocialLink =>
      instagramLink.value.trim().isNotEmpty ||
      facebookLink.value.trim().isNotEmpty ||
      linkedinLink.value.trim().isNotEmpty;

  final RxString lat = ''.obs;
  final RxString long = ''.obs;

  final RxBool isFavorite = false.obs;

  final RxList<AvailabilityItem> availList = <AvailabilityItem>[].obs;

  // Lists that back “See More” bottom sheets, etc.
  final List<String> continentSaveList = [];
  final List<String> continentFinalList = [];
  final List<String> languageSaveList = [];
  final List<String> languageFinalList = [];
  final List<String> specialTrainingSaveList = [];
  final List<String> otherTrainingSaveList = [];
  final List<String> selectTrainingFinalList = [];
  final List<AircraftTypeList> aircraftExpSaveList = [];
  final List<AircraftTypeList> aircraftExpFinalList = [];
  final List<String> aircraftTypeExp = [];
  final List<int> aircraftTypeExpId = [];
  // Kept for legacy parity; no longer used as we avoid FlatUserProfileSafe.
  final List<Map<String, dynamic>> pilotList = [];
  final List<String> internationalVisaSaveList = [];
  final List<String> internationalVisaFinalList = [];
  final List<String> continentExpSaveList = [];
  final List<String> continentExpFinalList = [];

  final RxDouble ratingCount = 0.0.obs;

  // -----------------------------
  // Photos (from API)
  // -----------------------------
  final RxnString image1 = RxnString(null);
  final RxnString image2 = RxnString(null);
  final RxnString image3 = RxnString(null);
  final RxnString image4 = RxnString(null);
  final RxnString image5 = RxnString(null);
  final RxnString image6 = RxnString(null);

  String? resumePath;
  bool? isResumeDisplayed;

  // late String userID;
  List<Favourite> _favoriteRows = [];

  /// Checkboxes (kept as simple bools because they are read-only on this screen)
  bool checkbox12MonthNo = false;
  bool checkbox12MonthYes = false;

  /// Convenience flags from user helper
  // String? get fkMemberShipId => UserHelper.fkMemberShipId;
  // String? get pkPilotId => UserHelper.pkPilotId;
  // String? get pilotFname => UserHelper.PilotFname;

  late final DashboardController dash;

  final hideDirectTripButton = false.obs; // whether to hide the "Create Direct Trip" button on the profile screen. This is true when navigating from a direct trip flow, to avoid confusion and redundancy.

  // Connection state returned by getReadOnlyAttendantProfileViewData.
  // status values: none, self, pending, accepted, denied, cancelled, unfriended.
  // direction values: none, sent, received.
  final connectionStatus = 'none'.obs;
  final connectionDirection = 'none'.obs;
  final connectionObjectId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint("Attendant Profile Id: $initialProfileId");
    dash = Get.find<DashboardController>();
    _loadReadOnlyAttendantProfileViewData();
    _loadFavoriteListThenMark();
    _loadLatLongAndExperience(); // keeps lat/long + "Years of experience" mapping parity
  }

  @override
  void onClose() {
    // Dispose text controllers to avoid leaks
    membershipTypeController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    searchAllController.dispose();
    emailController.dispose();
    passportController.dispose();
    fullTimeController.dispose();
    aircraftSpecificTrainingController.dispose();
    genderController.dispose();
    phoneNumberController.dispose();
    dayDomesticController.dispose();
    unrestrictedController.dispose();
    internationalController.dispose();
    dayInternationalController.dispose();
    yrExperienceController.dispose();
    specialTrainingController.dispose();
    otherTrainingController.dispose();
    currentLocationController.dispose();
    bioController.dispose();
    super.onClose();
  }

  /// 1) Load read-only Flight Attendant profile view data (Parse CF)
  Future<void> _loadReadOnlyAttendantProfileViewData() async {
    try {
      isLoading.value = true;

      final args = Get.arguments;

      String profileIdArg = initialProfileId?.trim() ?? '';
      String userIdArg = '';

      if (args is String) {
        profileIdArg = args.trim();
      } else if (args is Map) {
        profileIdArg = (args['profileId'] ?? profileIdArg).toString().trim();
        userIdArg = (args['userId'] ?? '').toString().trim();
        hideDirectTripButton.value = (args['hideDirectTripButton'] ?? false) as bool;
      }

      if (profileIdArg.isEmpty && userIdArg.isEmpty) {
        throw Exception('Either profileId or userId is required');
      }

      // Store known profileId immediately if available
      if (profileIdArg.isNotEmpty) {
        attendantProfileId.value = profileIdArg;
      }

      final fn = ParseCloudFunction('getReadOnlyAttendantProfileViewData');

      final Map<String, dynamic> params = {
        // The backend uses this to return the connection state from the
        // currently selected profile's point of view.
        'callerProfileType': dash.selectedProfileType.value,
        'callerProfileId': dash.selectedProfileId ?? ''
      };
      if (profileIdArg.isNotEmpty) params['profileId'] = profileIdArg;
      if (userIdArg.isNotEmpty) params['userId'] = userIdArg;

      final resp = await fn.execute(parameters: params);

      if (!resp.success || resp.result == null) {
        throw Exception('CF failed: ${resp.error?.message ?? "Unknown error"}');
      }

      final result = resp.result as Map<String, dynamic>;
      profileMap = result;

      // Extract the _User objectId returned by the cloud function
      // This represents the Parse _User that owns this attendantProfile
      userId.value = (result['userId'] ?? '').toString();

      // Store resolved attendantProfile.objectId
      final resolvedProfileId = (result['profileId'] ?? '').toString().trim();
      if (resolvedProfileId.isNotEmpty) {
        attendantProfileId.value = resolvedProfileId;
      }

      // Connection state between the current user and the viewed attendant profile.
      final connectionRaw = result['connection'];
      if (connectionRaw is Map) {
        final connection = Map<String, dynamic>.from(connectionRaw);
        connectionStatus.value = (connection['status'] ?? 'none').toString();
        connectionDirection.value = (connection['direction'] ?? 'none').toString();
        connectionObjectId.value = (connection['objectId'] ?? '').toString();
      } else {
        connectionStatus.value = 'none';
        connectionDirection.value = 'none';
        connectionObjectId.value = '';
      }

      // --- Basic identity / visibility flags ----------------------------
      membershipType.value = (result['membershipType'] is num)
          ? (result['membershipType'] as num).toInt()
          : 0;
      currentLocation.value = result['CurrentLocation'] == true;
      isResumeFlag.value = result['IsResume'] == true;

      // Photo / resume urls
      photoPath.value = (result['PhotoPath'] ?? '').toString().trim();
      resumeUrl.value = (result['ResumePath'] ?? '').toString().trim();

      // Some API paths historically returned junk placeholders; keep guard
      final rawPhoto = photoPath.value;
      if (rawPhoto.isEmpty ||
          rawPhoto == 'http' ||
          rawPhoto == 'http://' ||
          rawPhoto == 'https://' ||
          rawPhoto == 'file:///') {
        userPhoto.value = '';
      } else {
        userPhoto.value = rawPhoto;
      }

      resumePath = resumeUrl.value;

      // --- Text controllers used by the legacy UI ----------------------
      membershipTypeController.text = getMembershipTypeText(membershipType.value);
      firstNameController.text = (result['firstName'] ?? '').toString();
      lastNameController.text = (result['lastName'] ?? '').toString();

      // NOTE: By design, this CF does NOT return phone/email.
      phoneNumberController.text = '';
      emailController.text = '';

      genderController.text = getGenderText(
        (result['gender'] is num) ? (result['gender'] as num).toInt() : null,
      );

      passportController.text = (result['HavePassport'] == false) ? 'No' : 'Yes';
      fullTimeController.text = (result['IsFullTime'] == false) ? 'No' : 'Yes';

      // Rates (Num can arrive as int/double)
      final domRate = (result['DomPDRate'] is num) ? (result['DomPDRate'] as num).toDouble() : 0.0;
      final intlRate = (result['InterPDRate'] is num) ? (result['InterPDRate'] as num).toDouble() : 0.0;
      dayDomesticController.text = domRate.toStringAsFixed(2);
      dayInternationalController.text = intlRate.toStringAsFixed(2);

      // Years of experience (stored as code; map to label)
      final yrCode = (result['yearOfExperiance'] ?? '').toString().trim();
      yrExperienceController.text = _mapYearsOfExperience(yrCode);

      currentLocationController.text = (currentLocation.value == false) ? 'OFF' : 'ON';
      unrestrictedController.text = (result['CurrentUnrestrictedUSPass'] == true) ? 'Yes' : 'No';

      specialTrainingController.text = (result['IsSpecialTrained'] == true) ? 'Yes' : 'No';

      // Social
      instagramLink.value = (result['instagram'] ?? '').toString().trim();
      facebookLink.value = (result['facebook'] ?? '').toString().trim();
      linkedInUrl.value = (result['linkedIn'] ?? '').toString().trim();
      linkedinLink.value = linkedInUrl.value;

      // Bio
      bioController.text = (result['Bio'] ?? '').toString();

      // Gallery
      image1.value = (result['FAImage1'] ?? '').toString().trim();
      image2.value = (result['FAImage2'] ?? '').toString().trim();
      image3.value = (result['FAImage3'] ?? '').toString().trim();
      image4.value = (result['FAImage4'] ?? '').toString().trim();
      image5.value = (result['FAImage5'] ?? '').toString().trim();
      image6.value = (result['FAImage6'] ?? '').toString().trim();

      // Rating count in CF is currently returned as string "0" (legacy).
      final rc = (result['ratingCount'] ?? '0').toString().trim();
      ratingAvg.value = rc.isEmpty ? 0.0 : (double.tryParse(rc) ?? 0.0);
      ratingCount.value = ratingAvg.value;

      // Lists
      internationalVisaSaveList
        ..clear()
        ..addAll(
          (result['InternationalVisas'] ?? '')
              .toString()
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );

      internationalVisasHeldStr.value = internationalVisaSaveList.join(', ');

      languageSaveList
        ..clear()
        ..addAll(
          (result['LanguagesSpoken'] ?? '')
              .toString()
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );

      languagesStr.value = languageSaveList.join(', ');

      specialTrainingSaveList
        ..clear()
        ..addAll(
          (result['SpecialTrained'] ?? '')
              .toString()
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );

      specialTrainingStr.value = specialTrainingSaveList.join(', ');

      otherTrainingSaveList
        ..clear()
        ..addAll(
          (result['SpecialTrainedOther'] ?? '')
              .toString()
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );

      otherTrainingStr.value = otherTrainingSaveList.join(', ');

      continentExpSaveList
        ..clear()
        ..addAll(
          (result['RegionExp'] ?? '')
              .toString()
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );

      continentExpStr.value = continentExpSaveList.join(', ');

      continentSaveList
        ..clear()
        ..addAll((result['Continent'] ?? '').toString().split(','));

      aircraftSpecificTrainingController.text =
          (result['isAircraftSpecificTraining'] == true) ? 'Yes' : 'No';

      // 12-month training flags (if present)
      if (result['IsReqPrev12MonthTraining'] == true) {
        checkbox12MonthNo = false;
        checkbox12MonthYes = true;
      } else {
        checkbox12MonthNo = true;
        checkbox12MonthYes = false;
      }

      // --------------------------------------------------
      // Aircraft Experience (read-only)
      // --------------------------------------------------
      // TrainAircraftList is stored as a comma-separated string
      // Saved from ProfileFlightAttendantController as:
      // aircraftTypeExp.join(', ')
      aircraftTypeExp
        ..clear()
        ..addAll(
          (result['TrainAircraftList'] ?? '')
              .toString()
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );

        // Single display string used by the screen
        aircraftExpStr.value = aircraftTypeExp.join(', ');

      // --------------------------------------------------
      // Availability
      // --------------------------------------------------
      // CF returns only "availability" where IsAvailability==true and IsVoid==false
      // and keeps current first, then future.
      final availRaw = (result['availability'] is List)
          ? (result['availability'] as List)
          : <dynamic>[];

      // Convert each JSON map into AvailabilityItem (shared model)
      final mapped = <AvailabilityItem>[];
      for (final item in availRaw) {
        if (item is! Map) continue;
        try {
          final m = Map<String, dynamic>.from(item);
          mapped.add(AvailabilityItem.fromJson(m));
        } catch (_) {
          // Ignore malformed row; keep UI stable
        }
      }

      // Keep order as returned by CF (current first, then future)
      availList.assignAll(mapped);

      debugPrint('Avail count: ${availList.length}');

      // --------------------------------------------------
      // Fallback: resolve viewed user's objectId for favorites
      // --------------------------------------------------
      // In legacy flow, `userID` is the viewed user's Parse _User.objectId.
      // This CF may or may not return it, so we fallback to querying the profile.
      // await _ensureUserIdFromProfile(profileId!);
    } catch (e) {
      debugPrint('getReadOnlyAttendantProfileViewData failed: $e');

      // Hide loader first so the dialog is visible
      isLoading.value = false;

      // Build a readable error message for the user
      String errorMsg = 'Unknown error';
      if (e is ParseError) {
        errorMsg = e.message;
      } else {
        errorMsg = e.toString();
      }

      await showMyDialogNew(
        'Unable to load profile.\n\nReason: $errorMsg\n\nPlease try again later.'
      );

      // Navigate back after dialog dismissal
      if (Get.key.currentState?.canPop() == true) {
        Get.back();
      }

      return; // prevent finally from re-running logic
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to Create Direct Trip screen
  void goToCreateDirectTrip() {
    Get.toNamed(
        AppRoutes.createDirectTrip,
        arguments: CreateDirectTripArgs(
          selectList: <String>['Captain'].toList(),
          tripId: "0",
          isTripOutOfDate: false,
          profileID: attendantProfileId.value,
          membershipType: MembershipType.flightAttendant,
        ),
      );
  }


  /// Closes the custom loading dialog shown by showLoadingDialogNew().
  ///
  /// This flow must use showLoadingDialogNew() + closeLoadingDialog()
  /// together. Do not mix Flutter showDialog() with Get.dialog(), otherwise
  /// the loader route can remain open behind the success/error alert.
  Future<void> _dismissConnectionRequestLoader() async {
    EasyLoading.dismiss();
    closeLoadingDialog();

    // Give GetX one frame to remove the loader route before showing
    // the success/error dialog. This prevents stacked dialogs.
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Sends a connection request to the viewed flight attendant profile.
  Future<void> sendConnectionRequest() async {
    final receiverUserId = userId.value.trim();
    final receiverProfileId = attendantProfileId.value.trim();
    final requesterProfileType = dash.selectedProfileType.value;

    if (receiverUserId.isEmpty || receiverProfileId.isEmpty) {
      await showMyDialogNew('Profile is still loading. Please try again.');
      return;
    }

    if (connectionStatus.value == 'self') {
      return;
    }

    if (connectionStatus.value == 'pending') {
      await showMyDialogNew('Connection request is already pending.');
      return;
    }

    if (connectionStatus.value == 'accepted') {
      await showMyDialogNew('You are already connected with this user.');
      return;
    }

    final requesterProfileId =
        (dash.selectedProfileId ?? '').toString().trim();

    if (requesterProfileId.isEmpty) {
      await showMyDialogNew('Unable to identify your active profile. Please reselect your profile and try again.');
      return;
    }

    try {
      isSendingConnectionRequest.value = true;
      showLoadingDialogNew('Sending request...');

      final result = await ParseCloudFunction('sendConnectionRequest').execute(
        parameters: {
          'receiverUserId': receiverUserId,
          'requesterProfileId': requesterProfileId,
          'requesterProfileType': requesterProfileType,
          'receiverProfileId': receiverProfileId,
          'receiverProfileType': MembershipType.flightAttendant,
        },
      );

      if (result.success != true || result.result == null) {
        throw Exception(result.error?.message ?? 'Failed to send connection request');
      }

      final data = Map<String, dynamic>.from(result.result as Map);

      connectionStatus.value = (data['status'] ?? 'pending').toString();
      connectionDirection.value = (data['direction'] ?? 'sent').toString();
      connectionObjectId.value = (data['connectionId'] ?? '').toString();

      final alreadyExists = data['alreadyExists'] == true;

      await _dismissConnectionRequestLoader();
      isSendingConnectionRequest.value = false;

      await showMyDialogNew(
        alreadyExists
            ? 'Connection request already exists.'
            : '${firstNameController.text} was sent a friend request.',
      );
    } catch (e) {
      final errorMsg = e is ParseError ? e.message : e.toString();

      await _dismissConnectionRequestLoader();
      isSendingConnectionRequest.value = false;

      await showMyDialogNew(
        'Unable to send connection request.\n\nReason: $errorMsg',
      );
    } finally {
      if (isSendingConnectionRequest.value) {
        await _dismissConnectionRequestLoader();
        isSendingConnectionRequest.value = false;
      }
    }
  }

  /// Accepts or denies a pending connection request received from the viewed user.
  Future<void> respondToConnectionRequest({required bool accept}) async {
    final connectionId = connectionObjectId.value.trim();

    if (connectionId.isEmpty) {
      await showMyDialogNew('Connection request is missing. Please reload the profile and try again.');
      return;
    }

    if (connectionStatus.value != 'pending' || connectionDirection.value != 'received') {
      await showMyDialogNew('This connection request is no longer pending.');
      return;
    }

    final functionName = accept ? 'acceptConnectionRequest' : 'denyConnectionRequest';
    final loadingText = accept ? 'Accepting request...' : 'Denying request...';

    try {
      isRespondingToConnectionRequest.value = true;
      showLoadingDialogNew(loadingText);

      final result = await ParseCloudFunction(functionName).execute(
        parameters: {'connectionId': connectionId},
      );

      if (result.success != true || result.result == null) {
        throw Exception(result.error?.message ?? 'Failed to update connection request');
      }

      final data = Map<String, dynamic>.from(result.result as Map);
      final success = data['success'] == true;

      connectionStatus.value = (data['status'] ?? (accept ? 'accepted' : 'denied')).toString();
      connectionDirection.value = (data['direction'] ?? 'received').toString();
      connectionObjectId.value = (data['connectionId'] ?? connectionId).toString();

      await _dismissConnectionRequestLoader();
      isRespondingToConnectionRequest.value = false;

      if (success) {
        await showMyDialogNew(
          accept ? 'Connection request accepted.' : 'Connection request denied.',
        );
      } else {
        await showMyDialogNew(
          (data['message'] ?? 'Connection request could not be updated.').toString(),
        );
      }
    } catch (e) {
      final errorMsg = e is ParseError ? e.message : e.toString();

      await _dismissConnectionRequestLoader();
      isRespondingToConnectionRequest.value = false;

      await showMyDialogNew(
        'Unable to update connection request.\n\nReason: $errorMsg',
      );
    } finally {
      if (isRespondingToConnectionRequest.value) {
        await _dismissConnectionRequestLoader();
        isRespondingToConnectionRequest.value = false;
      }
    }
  }

  Future<void> acceptConnectionRequest() async {
    await respondToConnectionRequest(accept: true);
  }

  Future<void> denyConnectionRequest() async {
    await respondToConnectionRequest(accept: false);
  }

  /// Cancels a pending connection request sent by the current user.
  Future<void> cancelConnectionRequest() async {
    final connectionId = connectionObjectId.value.trim();

    if (connectionId.isEmpty) {
      await showMyDialogNew('Connection request is missing. Please reload the profile and try again.');
      return;
    }

    if (connectionStatus.value != 'pending' || connectionDirection.value != 'sent') {
      await showMyDialogNew('This connection request can no longer be cancelled.');
      return;
    }

    try {
      isCancellingConnectionRequest.value = true;
      showLoadingDialogNew('Cancelling request...');

      final result = await ParseCloudFunction('cancelConnectionRequest').execute(
        parameters: {'connectionId': connectionId},
      );

      if (result.success != true || result.result == null) {
        throw Exception(result.error?.message ?? 'Failed to cancel connection request');
      }

      final data = Map<String, dynamic>.from(result.result as Map);

      connectionStatus.value = (data['status'] ?? 'cancelled').toString();
      connectionDirection.value = (data['direction'] ?? 'sent').toString();
      connectionObjectId.value = (data['connectionId'] ?? connectionId).toString();

      await _dismissConnectionRequestLoader();
      isCancellingConnectionRequest.value = false;

      final success = data['success'] == true;
      if (success) {
        await showMyDialogNew('Connection request cancelled.');
      } else {
        await showMyDialogNew(
          (data['message'] ?? 'Connection request could not be cancelled.').toString(),
        );
      }
    } catch (e) {
      await _dismissConnectionRequestLoader();
      isCancellingConnectionRequest.value = false;

      await showMyDialogNew(
        'Unable to cancel connection request.\n\nReason: ${e is ParseError ? e.message : e.toString()}',
      );
    } finally {
      if (isCancellingConnectionRequest.value) {
        await _dismissConnectionRequestLoader();
        isCancellingConnectionRequest.value = false;
      }
    }
  }

  /// Removes an accepted connection between the current user and the viewed user.
  Future<void> unfriendConnection() async {
    final connectionId = connectionObjectId.value.trim();

    if (connectionId.isEmpty) {
      await showMyDialogNew('Connection is missing. Please reload the profile and try again.');
      return;
    }

    if (connectionStatus.value != 'accepted') {
      await showMyDialogNew('This user is no longer connected with you.');
      return;
    }

    try {
      isUnfriendingConnection.value = true;
      showLoadingDialogNew('Removing connection...');

      final result = await ParseCloudFunction('unfriendConnection').execute(
        parameters: {'connectionId': connectionId},
      );

      if (result.success != true || result.result == null) {
        throw Exception(result.error?.message ?? 'Failed to remove connection');
      }

      final data = Map<String, dynamic>.from(result.result as Map);

      connectionStatus.value = (data['status'] ?? 'unfriended').toString();
      connectionDirection.value = (data['direction'] ?? connectionDirection.value).toString();
      connectionObjectId.value = (data['connectionId'] ?? connectionId).toString();

      await _dismissConnectionRequestLoader();
      isUnfriendingConnection.value = false;

      final success = data['success'] == true;
      if (success) {
        await showMyDialogNew('Connection removed.');
      } else {
        await showMyDialogNew(
          (data['message'] ?? 'Connection could not be removed.').toString(),
        );
      }
    } catch (e) {
      await _dismissConnectionRequestLoader();
      isUnfriendingConnection.value = false;

      await showMyDialogNew(
        'Unable to remove connection.\n\nReason: ${e is ParseError ? e.message : e.toString()}',
      );
    } finally {
      if (isUnfriendingConnection.value) {
        await _dismissConnectionRequestLoader();
        isUnfriendingConnection.value = false;
      }
    }
  }

  /// Call this when you parse your profile response.
  /// Keep the mapping EXACTLY as your backend returns fields.
  void setSocialAndPhotosFromApi({
    String? instagram,
    String? facebook,
    String? linkedin,
    String? img1,
    String? img2,
    String? img3,
    String? img4,
    String? img5,
    String? img6,
  }) {
    instagramLink.value = (instagram ?? '').trim();
    facebookLink.value = (facebook ?? '').trim();
    linkedinLink.value = (linkedin ?? '').trim();

    image1.value = (img1?.trim().isNotEmpty == true) ? img1!.trim() : null;
    image2.value = (img2?.trim().isNotEmpty == true) ? img2!.trim() : null;
    image3.value = (img3?.trim().isNotEmpty == true) ? img3!.trim() : null;
    image4.value = (img4?.trim().isNotEmpty == true) ? img4!.trim() : null;
    image5.value = (img5?.trim().isNotEmpty == true) ? img5!.trim() : null;
    image6.value = (img6?.trim().isNotEmpty == true) ? img6!.trim() : null;
  }

  // -----------------------------
  // Actions
  // -----------------------------

  /// Keeps the old behavior: tapping any photo opens ImageViewScreen with all URLs.
  void openImageViewer({
    required String? selectedImage,
    required BuildContext context,
  }) {
    if (selectedImage == null || selectedImage.trim().isEmpty) return;

    // If you already have a named route for ImageViewScreen, replace this with Get.toNamed(...)
    //TODO:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => ImageViewScreen(
    //       imageUrl: selectedImage,
    //       imageUrl2: image1.value,
    //       imageUrl3: image2.value,
    //       imageUrl4: image3.value,
    //       imageUrl5: image4.value,
    //       imageUrl6: image5.value,
    //       // NOTE: old code passes 6 params; ensure your ImageViewScreen matches.
    //       // If your ImageViewScreen expects exactly imageUrl..imageUrl6, map accordingly.
    //     ),
    //   ),
    // );
  // }
}

  /// 2) Load detailed profile to refresh lat/long + derived fields (old getLatlong)
  Future<void> _loadLatLongAndExperience() async {
    try {
      final currentProfileId = attendantProfileId.value.trim();
      if (currentProfileId.isEmpty) return;

      final res = await viewProfile(currentProfileId);
      if (res?.data.pilot == null) return;

      final pilot = res!.data.pilot;

      final parts = (pilot.latlong ?? '').split(',');
      lat.value = parts.firstOrNull ?? '';
      long.value = parts.length > 1 ? parts.last : '';

      // (years of experience now set by cloud function; do not overwrite)

      fullTimeController.text = (pilot.IsFullTime == true) ? 'Yes' : 'No';
    } catch (e) {
      // Keep the UI stable if the fallback API fails
      debugPrint('_loadLatLongAndExperience failed: $e');
    }
  }


  /// 4) Get favorites and mark current state (old getD/geta)
  Future<void> _loadFavoriteListThenMark() async {
    try {
      final favRes = await getFavoriteList();
      _favoriteRows = favRes?.datas?.favourites ?? <Favourite>[];

      // Old code had a small delay before marking; keep behavior to avoid flicker
      Future.delayed(const Duration(milliseconds: 300), _markFavoriteFromRows);
    } catch (_) {
      _favoriteRows = <Favourite>[];
    }
  }

//TODO:
  void _markFavoriteFromRows() {
    for (final f in _favoriteRows) {
      if (f.fkPilotid == attendantProfileId.value) {
        isFavorite.value = f.isFavourite ?? false;
        break;
      }
    }
  }

  // --- Actions ---------------------------------------------------------------

  Future<void> toggleFavorite() async {
    final newVal = !isFavorite.value;
    isFavorite.value = newVal;

  }

  bool get canShowResume {
    // Mirrors old nested visibility:
    // - show for operators (membershipType == 1) only when resumePath valid & fullTime == Yes
    // - if isResume == false, show for non-operators too (keeping parity)
    final resumeOk = (resumePath != null &&
        resumePath!.isNotEmpty &&
        resumePath != 'http' &&
        fullTimeController.text == 'Yes');

    if (isResumeFlag.value == true && membershipType.value == 1) {
      return resumeOk;
    }
    if (isResumeFlag.value == false) {
      return resumeOk;
    }
    return false;
  }
}

// --- Small safe helper on List<String> splitting ---
extension _Safe on List<String> {
  String? get firstOrNull => isEmpty ? null : first;
}

class FlightAttendantViewProfileBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;
    final profileId = args['profileId'] as String?;
    final bool? showGender = args['showGender'] as bool?;
    final bool? showProfile = args['showProfile'] as bool?;
    Get.put(FlightAttendantViewProfileController(
      // viewProfileResponse: p,
      showGender: showGender,
      showProfile: showProfile,
      initialProfileId: profileId,
    ));
  }
}
  /// Maps server-stored yearOfExperiance codes into the UI labels.
  /// Must stay consistent with ProfileFlightAttendantController (yearsOfExpLabelToCode / reverse mapping).
  String _mapYearsOfExperience(String yr) {
    switch (yr) {
      case '0':
      case '0-1':
        return 'Less than 1 year';
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