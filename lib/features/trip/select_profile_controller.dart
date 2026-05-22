import 'dart:convert';
import 'package:crew_support/api/api_service.dart';
import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/trip/second_in_command/required_experience_sic_controller.dart';
import 'package:crew_support/features/trip/create_trip_controller.dart' show CreateTripArgs;
import 'package:crew_support/features/trip/trip_draft_flow_service.dart';
import 'package:crew_support/helper/user_helper.dart';
import 'package:crew_support/model/trip_draft_payload.dart';
import 'package:crew_support/model/trip_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:crew_support/utils/Utility.dart'; // showLoadingDialog, showMyDialog
import 'package:crew_support/utils/constants.dart';
import 'package:http/http.dart' as http; // pkPilotId, isCreateTrip

class SelectProfileController extends GetxController {
  // ---------------------------------------------------------------------------
  // Incoming arguments (mirrors legacy constructor parameters)
  // ---------------------------------------------------------------------------
  bool? fromPendingTab;
  String? selectedMember;
  String? tripId;
  String? miles;
  String? departure;
  String? destination;
  String? enrout;
  int? airCraftID;
  String? ratingAirCraftType;
  bool? isDirectTrip;
  bool? fromAddCrew;

  // ---------------------------------------------------------------------------
  // Reactive state (GetX)
  // ---------------------------------------------------------------------------

  /// Available profile options & their checkbox state.
  final RxMap<String, bool> profileList = <String, bool>{
    'Captain': false,
    'Second In Command': false,
    'Flight Attendant': false,
    // 'Flight Instructor': false,
  }.obs;

  /// Selected profiles for the normal flow.
  final RxList<String> profileSaveList = <String>[].obs;

  /// Selected profiles when coming from the Pending tab.
  final RxList<String> profileSaveListFromPending = <String>[].obs;

  TripModel? tripModel; // For Add Crew flow, to filter out already-selected roles in the UI

  // Lazily resolved shared draft flow service.
  // Do not store this as `late final` because Add Crew can navigate forward,
  // come back to this same controller, and tap NEXT again. Assigning a `late final`
  // a second time causes LateError._throwFieldAlreadyInitialized.
  TripDraftFlowService get _flow => Get.isRegistered<TripDraftFlowService>()
      ? Get.find<TripDraftFlowService>()
      : Get.put(TripDraftFlowService(), permanent: false);

  TripDraftPayload get draft => _flow.draft.value;

  /// Non-empty when requirements JSON failed to load
  final requirementsLoadError = ''.obs;
  final isLoading = false.obs;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();

    // Read all incoming args from previous screen to keep parity with legacy.
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      fromPendingTab = args['fromPendingTab'] as bool?;
      selectedMember = args['selectedMember'] as String?;
      tripId = args['tripId'] as String?;
      miles = args['miles'] as String?;
      departure = args['departure'] as String?;
      destination = args['destination'] as String?;
      enrout = args['enrout'] as String?;
      airCraftID = args['airCraftID'] as int?;
      ratingAirCraftType = args['ratingAirCraftType'] as String?;
      isDirectTrip = args['isDirectTrip'] as bool?;
      fromAddCrew = args['fromAddCrew'] as bool?;
      tripModel = args['trip'] as TripModel?;

      // Add Crew flow: only show roles that are not already part of the trip.
      if (fromAddCrew == true && tripModel != null) {
        _configureProfilesForAddCrew(tripModel!);
      }
    }

    // Legacy debug prints preserved
    debugPrint('select profile  $SelectProfile');
    debugPrint('from Pending  $fromPendingTab');
    debugPrint('selectedMember  $selectedMember');
    debugPrint('trip  $tripId');
    debugPrint('miles  $miles');
    debugPrint('aircraftid  $airCraftID');
    debugPrint('aircraft type  $ratingAirCraftType');

    if (fromAddCrew == true) {
      debugPrint('from Add Crew  $fromAddCrew');
      debugPrint('tripModel: $tripModel');
    }

    // NOTE: Old file had commented logic to remove already-selected roles
    // when coming from Pending; we keep parity with the latest legacy: do nothing.
  }

  @override
  Future<void> onReady() async {
    // Mirrors legacy didChangeDependencies: fetch and log isCreateTrip
    // await UserHelper().getIsCreateTrip();
    // print('++++$isCreateTrip');
    super.onReady();
  }

  @override
  void onClose() {
    // Dismiss any loaders if present (legacy dispose)
    EasyLoading.dismiss();
    super.onClose();
  }

  /// In Add Crew flow, hide roles already present in tripModel.
  void _configureProfilesForAddCrew(TripModel trip) {
    profileList.clear();

    if (!trip.isCaptain) {
      profileList['Captain'] = false;
    }

    if (!trip.isSIC) {
      profileList['Second In Command'] = false;
    }

    if (!trip.isAttendant) {
      profileList['Flight Attendant'] = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Intent handlers
  // ---------------------------------------------------------------------------

  /// Toggle selection for a given profile key.
  void toggleProfile(String key, bool value) {
    if (fromAddCrew == true) {
      // Add Crew behaves like radio buttons: only one selection allowed.
      if (!value) return;

      for (final profileKey in profileList.keys.toList()) {
        profileList[profileKey] = profileKey == key;
      }

      profileSaveList
        ..clear()
        ..add(key);

      profileSaveListFromPending
        ..clear()
        ..add(key);
    } else {
      profileList[key] = value;

      if (value) {
        if (!profileSaveList.contains(key)) profileSaveList.add(key);
        if (!profileSaveListFromPending.contains(key)) {
          profileSaveListFromPending.add(key);
        }
      } else {
        profileSaveList.remove(key);
        profileSaveListFromPending.remove(key);
      }
    }

    // debugPrint(profileSaveList as String?);
    // debugPrint(profileSaveListFromPending as String?);
  }

  /// Handle "NEXT" button press.
  ///
  /// - If from Pending tab:
  ///   - showLoadingDialog
  ///   - getTripDetail → insertTrip
  ///   - route to appropriate RequiredExperience screen by priority
  /// - Else:
  ///   - store selection count
  ///   - navigate to CreateTrip screen
  Future<void> handleNext(BuildContext context) async {
    final selected = profileSaveList.toList();
    print("selected: $selected");

    if (selected.isEmpty) {
      showMyDialog(context, 'Select profile first !');
      return;
    }

    if (fromPendingTab == true) {
      showLoadingDialog(context, 'Loading...');

      try {
        final trip = await getTripDetail(
          tripId: tripId!,
          pilotId: pkPilotId.toString(),
        );

        await insertTrip(
          enroutCode: enrout,
          departureCode: departure,
          destinationCode: destination,
          tripName: trip!.data!.trip[0].tripName,
          tripStartDate: trip.data!.trip[0].tripStartDate,
          tripEndDate: trip.data!.trip[0].tripEndDate,
          fkAircraftType: trip.data!.trip[0].aircraftType,
          radius: trip.data!.trip[0].radius,
          captain: profileSaveListFromPending.contains('Captain'),
          secondInCommand:
              profileSaveListFromPending.contains('Second In Command'),
          flightAttendant:
              profileSaveListFromPending.contains('Flight Attendant'),
          flightInstructor:
              profileSaveListFromPending.contains('Flight Instructor'),
          fkAircraftId: airCraftID,
          isDirectTrip: isDirectTrip,
          pkTripId: tripId,
        );

        // Close the loader dialog (Navigator.pop in legacy)
        if (Get.isDialogOpen == true) Get.back();

        // Route based on priority order (exact parity with legacy)
        if (selected.contains('Captain')) {
          Get.toNamed(
            AppRoutes.requiredExperienceCaptain,
            arguments: {
              'fromAddCrew': fromAddCrew,
              'boolCAP': profileSaveList.contains('Captain'),
              'selectList': profileSaveList.toList(),
              'tripId': tripId!,
              'miles': miles.toString(),
              'boolSIC': profileSaveList.contains('Second In Command'),
              'boolFA': profileSaveList.contains('Flight Attendant'),
              'boolFI': profileSaveList.contains('Flight Instructor'),
              'airCraftID': airCraftID!,
              'ratingAirCraftType': ratingAirCraftType.toString(),
            },
          );
        } else if (selected.contains('Second In Command')) {
          Get.toNamed(
            AppRoutes.requiredExperienceSIC,
            arguments: RequiredExperienceSICArgs(
              // fromAddCrew: fromAddCrew,
              boolSIC: profileSaveList.contains('Second In Command'),
              selectList: profileSaveList.toList(),
              tripId: tripId!,
              miles: miles.toString(),
              airCraftID: airCraftID!,
              boolFA: profileSaveList.contains('Flight Attendant'),
              boolFI: profileSaveList.contains('Flight Instructor'),
              ratingAirCraftType: ratingAirCraftType.toString(),
              // lockBackButton: false, // or true
              loadDraft: false, // Screen1
            ),
          );
        } else if (selected.contains('Flight Attendant')) {
          Get.toNamed(
            AppRoutes.requiredExperienceFA,
            arguments: {
              'fromAddCrew': fromAddCrew,
              'radiusValue': miles.toString(),
              'selectList': profileSaveList.toList(),
              'tripId': tripId!,
              'airCraftID': airCraftID!,
              'boolFI': profileSaveList.contains('Flight Instructor'),
            },
          );
        } else if (selected.contains('Flight Instructor')) {
          //TODO:
          // Get.to(() => _requiredExperienceFi());
        }
      } catch (e) {
        if (Get.isDialogOpen == true) Get.back();
        showMyDialog(context, e.toString());
      }

    } else if (fromAddCrew == true) {
      // Add Crew flow: navigate straight to the appropriate RequiredExperience screen based on the single selected role.
      // Add Crew allows only one radio selection
      final selectedRole = selected.first;

      if (tripModel != null) {
        // Start EDIT-DRAFT mode and preload draft from trip model
        _flow.startAddCrew(tripModel!.toDraftPayload());

        // Load roleRequirements JSON from the trip.requirements File URL (if present)
        await _loadRequirementsFromTripModel(tripModel!);

      } else {
        debugPrint(
          'Warning: SelectProfileController opened from Add Crew without a valid trip model. Trip flow will not work properly.',
        );
        // Still mark this flow as addCrew to allow downstream screens to behave consistently.
        _flow.mode.value = TripFlowMode.addCrew;
      }

      if (selectedRole == 'Captain') {
        // route Captain
        // not passing arguments like fromAddCrew, boolCAP, etc. because downstream RequiredExperience screens should be able to infer everything they need from the shared TripDraftFlowService's draft and mode.
        Get.toNamed(
              AppRoutes.requiredExperienceCaptain,
              arguments: {
              },
            );
      } else if (selectedRole == 'Second In Command') {
        // route SIC
        Get.toNamed(
              AppRoutes.requiredExperienceSIC,
              arguments: {
              },
            );
      } else if (selectedRole == 'Flight Attendant') {
        // route FA
        Get.toNamed(
              AppRoutes.requiredExperienceFA,
              arguments: {
              },
            );
      }

    } else {
      await UserHelper().setSelectProfile(selected.length);
      // debugPrint(selected.length);
      Get.toNamed(
        AppRoutes.createTrip,
        arguments: CreateTripArgs(
          selectList: profileSaveList.toList(),
          tripId: "0",
          isTripOutOfDate: false,
        ),
      );

    }
  }

  /// Downloads the requirements JSON from the trip.requirements file URL and merges it into the shared draft.
  Future<void> _loadRequirementsFromTripModel(TripModel tripModel) async {
    final String? url = tripModel.requirementsUrl;
    if (url == null || url.trim().isEmpty) {
      debugPrint('No requirementsUrl on trip ${tripModel.objectId}; skipping requirements load.');
      return;
    }

    requirementsLoadError.value = '';
    // Also raise the main loading flag so UI can show an overlay/spinner.
    isLoading.value = true;

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('HTTP ${res.statusCode}');
      }

      // Decode bytes as UTF-8 (safer than res.body for non-ascii)
      final body = utf8.decode(res.bodyBytes);
      final decoded = jsonDecode(body);

      if (decoded is! Map) {
        throw Exception('Invalid requirements JSON (expected object).');
      }

      final Map<String, dynamic> reqMap = decoded.cast<String, dynamic>();

      // Merge into current shared draft without wiping other fields
      final updated = draft.copyWith(
        roleRequirements: <String, dynamic>{
          ...draft.roleRequirements,
          ...reqMap,
        },
      );

      _flow.updateDraft(updated);

      debugPrint('Loaded requirements JSON for trip ${tripModel.objectId} (${reqMap.keys.length} keys).');
    } catch (e) {
      final msg = 'Failed to load requirements: $e';
      requirementsLoadError.value = msg;
      debugPrint(msg);

      // Optional: surface a lightweight toast/snackbar without needing BuildContext
      try {
        Get.snackbar('Requirements', 'Failed to load saved requirements');
      } catch (_) {}
    } finally {
      // Leave isLoading=false only if we are not in the middle of another load.
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Screen factories (kept here so constructors/params match legacy exactly)
  // Adjust these imports/paths below as needed in your project structure.
  // ---------------------------------------------------------------------------

//TODO:
  // Widget _requiredExperienceFi() {
  //   return RequiredExperienceFIScreen(
  //     radiusValue: miles.toString(),
  //     selectList: profileSaveList.toList(),
  //     tripId: tripId!,
  //     airCraftID: airCraftID!,
  //   );
  // }
}