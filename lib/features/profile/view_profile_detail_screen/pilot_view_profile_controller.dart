import 'dart:async';
import 'package:crew_support/app/routes.dart';
import 'package:crew_support/database/airport_platform.dart';
import 'package:crew_support/database/airport_display_helper.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/features/trip/create_direct_trip_controller.dart';
import 'package:crew_support/model/FlatUserProfileSafe.dart';
import 'package:crew_support/model/pilot_availability_service.dart';
import 'package:crew_support/model/rating_certification.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crew_support/Api/Api_service.dart';
import 'package:crew_support/helper/user_helper.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class PilotViewProfileController extends GetxController {
  /// Input params (from old widget constructor)
  // final Pilot viewProfileResponse;
  final String? initialProfileId;

  PilotViewProfileController({
    // required this.viewProfileResponse,
    this.initialProfileId,
  });

  // ----------------------------
  // UI/State (reactive)
  // ----------------------------
  final isBusy = true.obs; // page level loading for data loads
  final isFavorite = false.obs;
  /// Current pilotProfile.objectId for the viewed profile.
  ///
  /// This may come directly from navigation arguments, or be resolved by the
  /// backend when the screen is opened using only userId.
  final pilotProfileId = ''.obs;
  final lat = ''.obs;
  final long = ''.obs;

  // final ratingCount = 0.0.obs;
  final ratingData = <RatingCertification>[].obs;

  final availabilityList = <AvailabilityItem>[].obs;
  final airportByCode = <String, AirportLite>{}.obs;

  final userPhoto = RxnString();
  final instagramLink = RxnString();
  final facebookLink = RxnString();
  final linkedinLink = RxnString();

  // Lists shown in "See more"
  final continentSaveList = <String>[].obs;
  final oceanicSaveList = <String>[].obs;
  final citizenshipSaveList = <String>[].obs;

  // Error message to surface loading failures to the UI
  final errorMessage = RxnString();

  // Non-reactive helpers
  // late final String userID;

  // Text controllers (kept to exactly mirror old UI)
  final membershipTypeController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final searchAllController = TextEditingController();
  final passportController = TextEditingController();
  final fullTimeController = TextEditingController();
  final picTimeController = TextEditingController();
  final genderController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final noteController = TextEditingController();
  final totalTimeController = TextEditingController();
  final currentLocationController = TextEditingController();
  final medicalClassController = TextEditingController();
  final passportExpireDateController = TextEditingController();
  final bioController = TextEditingController();

  // Loading
  final isLoading = false.obs;
  final isSendingConnectionRequest = false.obs;
  final isRespondingToConnectionRequest = false.obs;
  final isCancellingConnectionRequest = false.obs;
  final isUnfriendingConnection = false.obs;

  // Files
  final photoPath = ''.obs;
  final resumePath = ''.obs;

  // Identity (read-only: no email/phone)
  final firstName = ''.obs;
  final lastName = ''.obs;
  final RxnInt gender = RxnInt();
  final RxnInt membershipType = RxnInt();

  final userId = ''.obs; // for chat - the pilot's user pointer id (not profile id)

  // Existing profile fields
  final currentLocation = false.obs;
  final rating = ''.obs;
  final ratingCount = '0'.obs;
  final bio = ''.obs;

  final instagram = ''.obs;
  final facebook = ''.obs;
  final linkedIn = ''.obs;

  final isUpdated = false.obs;

  final havePassport = false.obs;
  final isSearchAll = false.obs;
  final isFullTime = false.obs;
  final isResume = false.obs;

  // Numbers (nullable)
  final RxnDouble totalTime = RxnDouble();
  final RxnDouble totalPICTime = RxnDouble();
  final RxnInt faaMedical = RxnInt();

  final citizenCountry = ''.obs;
  final RxnString passportExpDateIso = RxnString();

  final isSpecialTrained = false.obs;
  final specialTrained = ''.obs;
  final specialTrainedOther = ''.obs;

  final continent = ''.obs;
  final oceanicExp = ''.obs;

  final hideDirectTripButton = false.obs; // whether to hide the "Create Direct Trip" button on the profile screen. This is true when navigating from a direct trip flow, to avoid confusion and redundancy.

  // Connection state returned by getReadOnlyPilotProfileViewData.
  // status values: none, self, pending, accepted, denied, cancelled, unfriended.
  // direction values: none, sent, received.
  final connectionStatus = 'none'.obs;
  final connectionDirection = 'none'.obs;
  final connectionObjectId = ''.obs;

  // Local cache
  // final pilots = <Pilot>[].obs;
  final pilots = <FlatUserProfileSafe>[].obs;

  late final DashboardController dash;

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      debugPrint("Pilot Profile Id: $initialProfileId");
      dash = Get.find<DashboardController>();
      await loadReadOnlyPilotProfile();
      // await _seedFromIncoming();
      // await _loadAll();
    } catch (e) {
      errorMessage.value = e.toString();
      isBusy.value = false;
    }
  }

  /// Loads a pilot's profile in READ-ONLY mode (no email/phone).
  ///
  /// Accepts either `profileId` or `userId` from Get.arguments.
  /// If `profileId` is not provided, backend will resolve it using `userId`.
  Future<void> loadReadOnlyPilotProfile() async {
    try {
      isLoading.value = true;

      // Expecting profileId or userId via navigation arguments.
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

      // Keep locally known profileId immediately when it is already available.
      if (profileIdArg.isNotEmpty) {
        pilotProfileId.value = profileIdArg;
      }

      final Map<String, dynamic> params = {
        // The backend uses this to return the connection state from the
        // currently selected profile's point of view.
        'callerProfileType': dash.selectedProfileType.value,
        'callerProfileId': dash.selectedProfileId ?? '',
      };

      if (profileIdArg.isNotEmpty) {
        params['profileId'] = profileIdArg;
      }
      if (userIdArg.isNotEmpty) {
        params['userId'] = userIdArg;
      }

      final result = await ParseCloudFunction('getReadOnlyPilotProfileViewData').execute(
        parameters: params,
      );

      if (result.success != true || result.result == null) {
        throw Exception(result.error?.message ?? 'Failed to load profile');
      }

      final data = Map<String, dynamic>.from(result.result as Map);

      // Extract the _User objectId returned by the cloud function.
      // This represents the Parse _User that owns this pilotProfile.
      userId.value = (data['userId'] ?? '').toString();

      // Store the resolved pilotProfile.objectId for downstream usage such as
      // favourites and any legacy APIs that still expect a profile row id.
      final String resolvedProfileId = (data['profileId'] ?? '').toString().trim();
      if (resolvedProfileId.isNotEmpty) {
        pilotProfileId.value = resolvedProfileId;
      }

      final connectionRaw = data['connection'];
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

      // Files
      photoPath.value = (data['PhotoPath'] ?? '').toString();
      resumePath.value = (data['ResumePath'] ?? '').toString();

      // Identity
      firstName.value = (data['firstName'] ?? '').toString();
      firstNameController.text = firstName.value;
      lastName.value = (data['lastName'] ?? '').toString();
      lastNameController.text = lastName.value;

      final g = data['gender'];
      gender.value = (g is num) ? g.toInt() : null;
      genderController.text = getGenderText(gender.value);

      final mt = data['membershipType'];
      membershipType.value = (mt is num) ? mt.toInt() : null;
      membershipTypeController.text = getMembershipTypeText(membershipType.value);

      // Profile fields
      currentLocation.value = (data['CurrentLocation'] == true);
      currentLocationController.text = currentLocation.value ? "ON" : "OFF";
      rating.value = (data['Rating'] ?? '').toString();
      ratingCount.value = (data['ratingCount'] ?? '0').toString();
      bio.value = (data['Bio'] ?? '').toString();
      bioController.text = bio.value;

      instagram.value = (data['instagram'] ?? '').toString();
      facebook.value = (data['facebook'] ?? '').toString();
      linkedIn.value = (data['linkedIn'] ?? '').toString();

      isUpdated.value = (data['IsUpdated'] == true);

      havePassport.value = (data['HavePassport'] == true);
      passportController.text = havePassport.value ? "Yes" : "No";
      isSearchAll.value = (data['IsSearchAll'] == true);
      isFullTime.value = (data['IsFullTime'] == true);
      fullTimeController.text = isFullTime.value ? "Yes" : "No";
      isResume.value = (data['IsResume'] == true);

      totalTime.value = (data['totalTime'] is num) ? (data['totalTime'] as num).toDouble() : null;
      totalTimeController.text = totalTime.value?.toString() ?? '';
      totalPICTime.value = (data['totalPICTime'] is num) ? (data['totalPICTime'] as num).toDouble() : null;
      picTimeController.text = totalPICTime.value?.toString() ?? '';

      faaMedical.value = (data['FAAMedical'] is num) ? (data['FAAMedical'] as num).toInt() : null;
      medicalClassController.text = faaMedical.value?.toString() ?? '';
      citizenCountry.value = (data['CitizenCountry'] ?? '').toString();
      citizenshipSaveList.assignAll(citizenCountry.value.isEmpty
          ? <String>[]
          : citizenCountry.value.split(',').map((e) => e.trim()).toList());

      passportExpDateIso.value = data['PassportExpDate']?.toString();
      if (passportExpDateIso.value != null) {
        try {
          // Parse ISO string to DateTime
          final DateTime parsedDate = DateTime.parse(passportExpDateIso.value!);

          // Format it the same way as your old code
          passportExpireDateController.text = DateFormat('MM/dd/yyyy').format(parsedDate);
        } catch (_) {
          // If parsing/formatting fails, clear the value
          passportExpireDateController.clear();
        }
      } else {
        // No date stored for this profile
        passportExpireDateController.clear();
      }

      isSpecialTrained.value = (data['IsSpecialTrained'] == true);
      specialTrained.value = (data['SpecialTrained'] ?? '').toString();
      specialTrainedOther.value = (data['SpecialTrainedOther'] ?? '').toString();

      continent.value = (data['Continent'] ?? '').toString();
      continentSaveList.assignAll(continent.value.isEmpty
          ? <String>[]
          : continent.value.split(',').map((e) => e.trim()).toList());
      oceanicExp.value = (data['OceanicExp'] ?? '').toString();
      oceanicSaveList.assignAll(oceanicExp.value.isEmpty
          ? <String>[]
          : oceanicExp.value.split(',').map((e) => e.trim()).toList());

      // --------------------------------------------------
      // Rating Certifications (Type Ratings)
      // --------------------------------------------------
      ratingData.clear();

      final certsRaw = data['ratingCertifications'];
      if (certsRaw is List) {
        final parsed = certsRaw
            .whereType<Map>() // safety
            .map((e) =>
                RatingCertification.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        ratingData.assignAll(parsed);
      }

      final availabilityRaw = data['availability'];
      availabilityList.clear();

      debugPrint('[PendingPilotProfile] availability raw: $availabilityRaw');

      if (availabilityRaw is List) {
        final parsedAvailability = availabilityRaw
            .whereType<Map>()
            .map((e) => AvailabilityItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        availabilityList.assignAll(parsedAvailability);

        final airportMap = await preloadAirportsForCodes(
          parsedAvailability.map((e) => e.airportCode),
        );
        airportByCode.assignAll(airportMap);
      }
      debugPrint('[PendingPilotProfile] availabilityList raw: $availabilityList');

    } catch (e) {
      debugPrint('[PendingPilotProfile] loadReadOnlyPilotProfile ERROR: $e');

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
          profileID: pilotProfileId.value,
          membershipType: MembershipType.pilot,
        ),
      );
  }

  Future<void> _dismissConnectionRequestLoader() async {
    EasyLoading.dismiss();

    closeLoadingDialog();

    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Sends a connection request to the viewed pilot profile.
  Future<void> sendConnectionRequest() async {
    final receiverUserId = userId.value.trim();
    final receiverProfileId = pilotProfileId.value.trim();
    final requesterProfileType = dash.selectedProfileType.value;

    if (receiverUserId.isEmpty || receiverProfileId.isEmpty) {
      await showMyDialogNew('Profile is still loading. Please try again.');
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
      await showMyDialogNew(
        'Unable to identify your active profile. Please reselect your profile and try again.',
      );
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
          'receiverProfileType': MembershipType.pilot,
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

      // Dismiss the custom loading dialog before showing the result dialog.
      await _dismissConnectionRequestLoader();
      isSendingConnectionRequest.value = false;

      await showMyDialogNew(
        alreadyExists
            ? 'Connection request already exists.'
            : '${firstName.value} was sent a friend request.',
      );
    } catch (e) {
      final errorMsg = e is ParseError ? e.message : e.toString();

      // Dismiss the custom loading dialog before showing the error dialog.
      await _dismissConnectionRequestLoader();
      isSendingConnectionRequest.value = false;

      await showMyDialogNew(
        'Unable to send connection request.\n\nReason: $errorMsg',
      );
    } finally {
      // Safe fallback in case execution exits before the success/error dialog paths.
      if (isSendingConnectionRequest.value) {
        await _dismissConnectionRequestLoader();
        isSendingConnectionRequest.value = false;
      }
    }
  }

  Future<void> respondToConnectionRequest({required bool accept}) async {
    final connectionId = connectionObjectId.value.trim();

    if (connectionId.isEmpty) {
      await showMyDialogNew('Connection request is missing. Please reload the profile and try again.');
      return;
    }

    final functionName = accept ? 'acceptConnectionRequest' : 'denyConnectionRequest';

    try {
      isRespondingToConnectionRequest.value = true;
      showLoadingDialogNew(accept ? 'Accepting request...' : 'Denying request...');

      final result = await ParseCloudFunction(functionName).execute(
        parameters: {'connectionId': connectionId},
      );

      if (result.success != true || result.result == null) {
        throw Exception(result.error?.message ?? 'Failed to update connection request');
      }

      final data = Map<String, dynamic>.from(result.result as Map);

      connectionStatus.value = (data['status'] ?? (accept ? 'accepted' : 'denied')).toString();
      connectionDirection.value = (data['direction'] ?? 'received').toString();
      connectionObjectId.value = (data['connectionId'] ?? connectionId).toString();

      await _dismissConnectionRequestLoader();
      isRespondingToConnectionRequest.value = false;

      await showMyDialogNew(
        accept ? 'Connection request accepted.' : 'Connection request denied.',
      );
    } catch (e) {
      await _dismissConnectionRequestLoader();
      isRespondingToConnectionRequest.value = false;

      await showMyDialogNew(
        'Unable to update connection request.\n\nReason: ${e is ParseError ? e.message : e.toString()}',
      );
    }
  }

  Future<void> cancelConnectionRequest() async {
    final connectionId = connectionObjectId.value.trim();

    if (connectionId.isEmpty) {
      await showMyDialogNew('Connection request is missing. Please reload the profile and try again.');
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

      await showMyDialogNew('Connection request cancelled.');
    } catch (e) {
      await _dismissConnectionRequestLoader();
      isCancellingConnectionRequest.value = false;

      await showMyDialogNew(
        'Unable to cancel connection request.\n\nReason: ${e is ParseError ? e.message : e.toString()}',
      );
    }
  }

  Future<void> acceptConnectionRequest() async {
    await respondToConnectionRequest(accept: true);
  }

  Future<void> denyConnectionRequest() async {
    await respondToConnectionRequest(accept: false);
  }

  Future<void> unfriendConnection() async {
    final connectionId = connectionObjectId.value.trim();

    if (connectionId.isEmpty) {
      await showMyDialogNew('Connection is missing. Please reload the profile and try again.');
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

      await showMyDialogNew('Connection removed.');
    } catch (e) {
      await _dismissConnectionRequestLoader();
      isUnfriendingConnection.value = false;

      await showMyDialogNew(
        'Unable to remove connection.\n\nReason: ${e is ParseError ? e.message : e.toString()}',
      );
    }
  }

  /// Public retry to (re)load everything safely
  Future<void> refreshAll() async {
    isBusy.value = true;
    errorMessage.value = null;
    try {
      pilots.clear();
      await _loadAll();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isBusy.value = false;
    }
  }

  /// Batch load network resources
  Future<void> _loadAll() async {
    isBusy.value = true;
    try {
      await Future.wait([
        _loadLatLong(),
        _loadFavouritesAndMark(),
      ]);
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> _loadLatLong() async {
    try {
      final currentProfileId = pilotProfileId.value.trim();
      if (currentProfileId.isEmpty) return;

      final res = await viewProfile(currentProfileId);
      if (res != null) {
        final ll = (res.data.pilot.latlong ?? '');
        if (ll.contains(',')) {
          final parts = ll.split(',');
          lat.value = parts.first.trim();
          long.value = parts.last.trim();
        }
        searchAllController.text =
            (res.data.pilot.IsSearchAll == true) ? "Yes" : "No";
      }
    } catch (e) {
      print("getLatlong error: $e");
    }
  }

  Future<void> _loadFavouritesAndMark() async {
    try {
      final fav = await getFavoriteList();
      if (fav?.datas == null) {
        isFavorite.value = false;
        return;
      }
      final items = fav!.datas.favourites;
      final myPilotId = pilotProfileId.value.trim();
      if (myPilotId.isEmpty) {
        isFavorite.value = false;
        return;
      }
      final match = items.firstWhereOrNull(
          (f) => f.fkPilotid == myPilotId && (f.isFavourite ?? false));
      isFavorite.value = match != null;
    } catch (e) {
      print("getFavoriteList error: $e");
      isFavorite.value = false;
    }
  }

  /// Toggle favourite and call API
  Future<void> toggleFavorite() async {
    final newVal = !isFavorite.value;
    isFavorite.value = newVal;

    // try {
    //   await insertUpdateFavourite(
    //     isFavourite: newVal,
    //     userId: userID.toString(),
    //     // Always use the resolved/current pilotProfile.objectId for this
    //     // read-only profile screen.
    //     pilotID: pilotProfileId.value,
    //   );
    // } catch (e) {
    //   // revert on failure
    //   isFavorite.value = !newVal;
    //   print("insertUpdateFavourite error: $e");
    // }
  }

  @override
  void onClose() {
    EasyLoading.dismiss();

    membershipTypeController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    searchAllController.dispose();
    passportController.dispose();
    fullTimeController.dispose();
    picTimeController.dispose();
    genderController.dispose();
    phoneNumberController.dispose();
    noteController.dispose();
    totalTimeController.dispose();
    currentLocationController.dispose();
    medicalClassController.dispose();
    passportExpireDateController.dispose();
    bioController.dispose();

    super.onClose();
  }
}

class PilotViewProfileBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>?;

    Get.put(PilotViewProfileController(
      // viewProfileResponse: args['pilot'] as Pilot,
      initialProfileId: args?['profileId'] as String?,
    ));
  }
}