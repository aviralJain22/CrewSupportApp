import 'dart:async';
import 'dart:convert';
import 'package:crew_support/database/airport_code_model.dart';
import 'package:crew_support/features/trip/trip_draft_flow_service.dart';
import 'package:crew_support/features/trip/trip_draft_save_service.dart';
import 'package:crew_support/model/trip_draft_payload.dart';
import 'package:crew_support/model/trip_model.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:crew_support/helper/user_helper.dart'; // <- NEW import path
import 'package:crew_support/model/AircraftModel.dart';
import 'package:crew_support/model/TripDetailsResponse.dart';

class CreateTripArgs {
  final List<String> selectList;
  final String tripId;
  final bool isTripOutOfDate;
  final String? crewMembers; // legacy: old selected crew id key (string key)
  final dynamic membershipId; // legacy: was read like a Map for single role

  CreateTripArgs({
    required this.selectList,
    required this.tripId,
    required this.isTripOutOfDate,
    this.crewMembers,
    this.membershipId,
  });
}

class CreateTripController extends GetxController implements DraftCommitter {
  // --------------------------
  // Text controllers
  // --------------------------
  final tripNameController = TextEditingController();
  final departAirportCodeController = TextEditingController();
  final enrouteAirportCodeController = TextEditingController(); // (read-only chip text)
  final destAirportCodeController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final radiusController = TextEditingController();
  final aircraftTypeController = TextEditingController();
  final searchController = TextEditingController(); // aircraft search

  // --------------------------
  // Reactive flags / state
  // --------------------------
  final isLoading = true.obs;
  final isLoadingCode = false.obs;
  final isTripOutOfDate = false.obs;
  final stopClicking = false.obs;
  final stopUpdateBtnClicking = false.obs;
  final isUpdateClicked = false.obs;

  /// Empty-radius popup has already been acknowledged once.
  bool didAcknowledgeEmptyRadius = false;

  /// Loading flag for requirements JSON download (used when opening an existing draft trip)
  final isLoadingRequirements = false.obs;

  /// Non-empty when requirements JSON failed to load
  final requirementsLoadError = ''.obs;

  /// Simple tap guard for primary action buttons to avoid double-taps
  bool isButtonLocked = false;

  // --------------------------
  // Data
  // --------------------------
  final List<String> selectList = <String>[];
  final currentDate = DateTime.now().obs;

  /// persisted copies of original string values to enforce "date changed" check
  String startDateStr = '';
  String endDateStr = '';

  // Airport code selections
  final airportCodeChecked = <String>[].obs; // enroute multi-select
  // final List<AirportCodeDBModel> departureTempList = <AirportCodeDBModel>[];
  // final List<AirportCodeDBModel> enrouteTempList = <AirportCodeDBModel>[];
  // final List<AirportCodeDBModel> destinationTempList = <AirportCodeDBModel>[];

  // // For quick filter lists (if you want to hook typeahead later)
  // final List<AirportCodeDBModel> departureFilterList = <AirportCodeDBModel>[];
  // final List<AirportCodeDBModel> enrouteFilterList = <AirportCodeDBModel>[];
  // final List<AirportCodeDBModel> destinationFilterList = <AirportCodeDBModel>[];

  // // From DB
  // final List<AirportCodeDBModel> airportCodeData = <AirportCodeDBModel>[];
  // final List<AirportCodeDBModel> departureMainList = <AirportCodeDBModel>[];

  // Aircraft data
  List<AircraftTypeList> aircraftTempList = [];
  List<AircraftTypeList> aircraftFilterList = [];
  int? aircraftID;

  // Trip data
  // int? pkTripIdFromApi;
  List<TripDetails> tripData = [];

  String? createdTripId;
  bool? createdCaptain;
  bool? createdSecondInCommand;
  bool? createdFlightAttendant;
  bool? createdFlightInstructor;
  // int? createdFkAircraftId;
  // String? createdAircraftTypeText;

  // Business flags
  String? radiusFinal;
  bool _isPopUpClicked = false;
  String? _oldCrewMembersKey;
  String? singleRoleMembershipId; // derived from membershipId if single select

  // Raw constructor args holder
  late final CreateTripArgs args;

  // Store selected airports (source-of-truth for saving)
  AirportLite? selectedDeparture;
  AirportLite? selectedDestination;

  // For enroute, store selected airports by sourceId (or full objects)
  final selectedEnrouteById = <int, AirportLite>{}.obs;

  late final TripDraftFlowService _flow;
  late final TripDraftSaveService _saveService;

  TripDraftPayload get draft => _flow.draft.value;

  /// Expose whether this flow is editing a draft (opened from Drafts tab).
  bool get isFromDraftTab => _flow.isFromDraftTab;

  // --------------------------
  // Lifecycle
  // --------------------------
  @override
  Future<void> onInit() async {
    super.onInit();

    // Accept either a typed CreateTripArgs or a legacy Map via Get.arguments.
    final dynamic passed = Get.arguments;
    if (passed is CreateTripArgs) {
      args = passed;
    } else if (passed is Map) {
      // Support old code that sends a plain Map.
      final List<String> sel = (passed['selectList'] as List?)?.cast<String>() ?? const [];
      final String tripId = (passed['tripid'] ?? passed['tripId'] ?? '0') as String;
      final bool ood = (passed['isTripOutOfDate'] as bool?) ?? false;
      args = CreateTripArgs(
        selectList: sel,
        tripId: tripId,
        isTripOutOfDate: ood,
        crewMembers: passed['crewMembers'] as String?,
        membershipId: passed['membershipId'],
      );
    } else {
      args = CreateTripArgs(selectList: const [], tripId: "0", isTripOutOfDate: false);
    }

    final bool openedFromDraftTab =
        (passed is Map) ? ((passed['fromDraftTab'] as bool?) ?? false) : false;

    // Ensure flow service exists
    _flow = Get.isRegistered<TripDraftFlowService>()
        ? Get.find<TripDraftFlowService>()
        : Get.put(TripDraftFlowService(), permanent: false);

    _saveService = TripDraftSaveService(_flow);

    if (openedFromDraftTab) {
      debugPrint('CreateTripController initialized from Drafts tab with args: $args');
      final TripModel? tripModel = passed['trip'] as TripModel?;

      if (tripModel != null) {
        // Start EDIT-DRAFT mode and preload draft from trip model
        _flow.startEditDraft(tripModel.toDraftPayload());

        // Load roleRequirements JSON from the trip.requirements File URL (if present)
        await _loadRequirementsFromTripModel(tripModel);

        // Prefill CreateTripScreen fields from the shared draft
        await _applyDraftToFields();

        // Mark the trip as read when opening from Drafts tab
        if (tripModel.objectId.isNotEmpty) {
          _markAsRead(tripModel.objectId);
        }
      } else {
        debugPrint(
          'Warning: CreateTripController opened from Drafts tab without a valid trip model. Trip editing will not work properly.',
        );
        // Still mark this flow as editDraft to allow downstream screens to behave consistently.
        _flow.mode.value = TripFlowMode.editDraft;
      }
    } else {
      debugPrint('CreateTripController initialized without Drafts tab (new trip flow).');

      // Only initialize a new empty draft if this is truly a fresh entry.
      // If user returned back from later screens, the service is already registered and should be preserved.
      if (_flow.draft.value.tripObjectId == null &&
          (_flow.draft.value.tripName == null || _flow.draft.value.tripName!.isEmpty) &&
          _flow.draft.value.roleRequirements.isEmpty) {
        _flow.startNew(TripDraftPayload());
      }
    }

    isTripOutOfDate.value = args.isTripOutOfDate;

    // Initialize selected roles list.
    // When opening from Drafts tab, selectList is not passed, so rebuild it from the draft role flags.
    selectList.clear();
    if (openedFromDraftTab && args.selectList.isEmpty) {
      if (draft.isCaptain == true) selectList.add('Captain');
      if (draft.isSIC == true) selectList.add('Second In Command');
      if (draft.isAttendant == true) selectList.add('Flight Attendant');
      if (draft.isInstructor == true) selectList.add('Flight Instructor');
      debugPrint('Rebuilt selectList from draft (Drafts tab): $selectList');
    } else {
      selectList.addAll(args.selectList);
      debugPrint('Loaded selectList from args: $selectList');
    }

    _oldCrewMembersKey = args.crewMembers;

    // Legacy: when only one member type is selected, membershipId was accessed like a map.
    if (selectList.length == 1 && args.membershipId != null && _oldCrewMembersKey != null) {
      try {
        final val = args.membershipId[_oldCrewMembersKey].toString();
        singleRoleMembershipId = val;
      } catch (_) {
        // If not a map, ignore gracefully
      }
    }

    debugPrint("selectList: $selectList");

    // Mirror old init: set aircraft list first
    aircraftTempList = aircraftTypeList;

    // Clear "pending" flags (legacy behavior)
    _clearPendingFlags();

    //stop loading spinner after all initial data is set up (including async draft load if from Drafts tab)
    isLoading.value = false;

  }

  @override
  void commitToDraft() {
    // Get current shared draft (may already contain roleRequirements/rates from other screens)
    final TripDraftPayload current = _flow.draft.value;

    // --- Safe date parsing (avoid DateFormat.parse throwing) ---
    DateTime? _tryParseMMDDYYYY(String s) {
      final t = s.trim();
      if (t.isEmpty) return null;
      try {
        // IMPORTANT:
        // Treat Start/End dates as DATE-ONLY values (no time zone semantics).
        // We normalize to UTC midnight so the date stays identical for all users
        // regardless of their local timezone.
        final localParsed = DateFormat('MM/dd/yyyy').parseStrict(t);
        return DateTime.utc(localParsed.year, localParsed.month, localParsed.day);
      } catch (_) {
        return null;
      }
    }

    // Radius normalization
    final int r = int.tryParse((radiusFinal ?? '0').toString()) ?? 0;

    // Build updated trip-level portion from this screen
    final TripDraftPayload updatedTripPart = TripDraftPayload(
      tripObjectId: createdTripId, // usually null at this stage
      tripName: tripNameController.text.trim(),
      departureSourceId: selectedDeparture?.sourceId,
      destinationSourceId: selectedDestination?.sourceId,
      enrouteSourceIds: selectedEnrouteById.keys.toList(),
      startDate: _tryParseMMDDYYYY(startDateController.text),
      endDate: _tryParseMMDDYYYY(endDateController.text),
      aircraftId: aircraftID,
      aircraftName: aircraftTypeController.text.trim(),
      radius: r,

      // Role flags derived from selected roles on CreateTripScreen
      isCaptain: selectList.contains('Captain'),
      isSIC: selectList.contains('Second In Command'),
      isAttendant: selectList.contains('Flight Attendant'),
      isInstructor: selectList.contains('Flight Instructor') || selectList.contains('Instructor'),
    );

    // Merge into current shared draft WITHOUT wiping roleRequirements/rates
    final TripDraftPayload merged = current.copyWith(
      // Keep server object id if already created, otherwise take from this screen
      tripObjectId: current.tripObjectId ?? updatedTripPart.tripObjectId,

      tripName: updatedTripPart.tripName,
      departureSourceId: updatedTripPart.departureSourceId,
      destinationSourceId: updatedTripPart.destinationSourceId,
      enrouteSourceIds: updatedTripPart.enrouteSourceIds,
      startDate: updatedTripPart.startDate,
      endDate: updatedTripPart.endDate,
      aircraftId: updatedTripPart.aircraftId,
      aircraftName: updatedTripPart.aircraftName,
      radius: updatedTripPart.radius,

      isCaptain: updatedTripPart.isCaptain,
      isSIC: updatedTripPart.isSIC,
      isAttendant: updatedTripPart.isAttendant,
      isInstructor: updatedTripPart.isInstructor,

      // IMPORTANT: do NOT overwrite roleRequirements here
      // IMPORTANT: do NOT overwrite rates here
      // (those are filled on later screens and should remain intact)
    );

    _flow.updateDraft(merged);
  }

  @override
  void onClose() {
    // dispose controllers
    tripNameController.dispose();
    departAirportCodeController.dispose();
    enrouteAirportCodeController.dispose();
    destAirportCodeController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    radiusController.dispose();
    aircraftTypeController.dispose();
    searchController.dispose();
    super.onClose();
  }

  /// Prefills CreateTripScreen controllers and selected airport state from the shared draft.
  /// Used when opening an existing Draft trip from the Drafts tab.
  Future<void> _applyDraftToFields() async {
    final d = draft;

    // Trip name
    tripNameController.text = (d.tripName ?? '').trim();

    // Dates
    if (d.startDate != null) {
      // IMPORTANT: start/end are DATE-ONLY fields stored as UTC.
      // Do not format using local time, otherwise timezones behind UTC (e.g. EST)
      // can see the previous calendar day.
      final u = d.startDate!.toUtc();
      final dateOnlyLocal = DateTime(u.year, u.month, u.day); // local date-only for pickers
      final sd = DateFormat('MM/dd/yyyy').format(dateOnlyLocal);
      startDateController.text = sd;
      startDateStr = sd;
      currentDate.value = dateOnlyLocal;
    } else {
      startDateController.clear();
    }

    if (d.endDate != null) {
      // Same DATE-ONLY handling as startDate
      final u = d.endDate!.toUtc();
      final dateOnlyLocal = DateTime(u.year, u.month, u.day);
      final ed = DateFormat('MM/dd/yyyy').format(dateOnlyLocal);
      endDateController.text = ed;
      endDateStr = ed;
    } else {
      endDateController.clear();
    }

    // Aircraft
    aircraftTypeController.text = (d.aircraftName ?? '').trim();
    aircraftID = d.aircraftId;

    // Radius
    final int r = (d.radius ?? 0);
    radiusFinal = r.toString();

    // Keep draft-prefill display text aligned with the radius picker options.
    // The picker uses labels like "<10 miles", so saved drafts should show the same format.
    switch (r) {
      case 10:
        radiusController.text = '<10 miles';
        break;
      case 50:
        radiusController.text = '<50 miles';
        break;
      case 100:
        radiusController.text = '<100 miles';
        break;
      case 150:
        radiusController.text = '<150 miles';
        break;
      case 200:
        radiusController.text = '<200 miles';
        break;
      default:
        radiusFinal = '0';
        radiusController.text = 'Any distance';
        break;
    }

    // Airports: resolve sourceIds to AirportLite for proper dialog preselection.
    // We attempt to use AirportCache if it has a getBySourceId method; otherwise we fall back gracefully.
    Future<AirportLite?> _tryResolveAirport(int sourceId) async {
      try {
        final dynamic cache = AirportCache.instance;
        final dynamic res = await cache.getBySourceId(sourceId);
        if (res is AirportLite) return res;
      } catch (e) {
        debugPrint('AirportCache resolution failed for sourceId $sourceId; leaving airport unset. Error: $e');
        // ignore - method may not exist or failed
      }
      debugPrint('Could not resolve airport for sourceId $sourceId; leaving it unset.');
      // If not resolved from cache, leave as unset
      return null;
    }

    // Departure
    final depId = d.departureSourceId;
    if (depId != null) {
      final a = await _tryResolveAirport(depId);
      if (a != null) {
        setDepartureAirport(a);
      } else {
        // Not resolved; leave departure unset
        selectedDeparture = null;
        departAirportCodeController.clear();
        update(['depDestEnroute']);
      }
    } else {
      selectedDeparture = null;
      departAirportCodeController.clear();
    }

    // Destination
    final destId = d.destinationSourceId;
    if (destId != null) {
      final a = await _tryResolveAirport(destId);
      if (a != null) {
        setDestinationAirport(a);
      } else {
        // Not resolved; leave destination unset
        selectedDestination = null;
        destAirportCodeController.clear();
        update(['depDestEnroute']);
      }
    } else {
      selectedDestination = null;
      destAirportCodeController.clear();
    }

    // Enroute
    selectedEnrouteById.clear();
    final ids = d.enrouteSourceIds;
    for (final id in ids) {
      final a = await _tryResolveAirport(id);
      if (a != null) {
        selectedEnrouteById[id] = a;
      }
      // If not resolved, skip and leave it unset
    }

    // Keep legacy string list in sync (ident list may be empty if we couldn't resolve)
    airportCodeChecked.assignAll(selectedEnrouteById.values.map((e) => e.ident).where((s) => s.isNotEmpty));
    enrouteAirportCodeController.text =
        selectedEnrouteById.values.map((e) => e.ident).where((s) => s.isNotEmpty).join(', ');

    update(['depDestEnroute', 'dates', 'radius', 'aircraftPicker']);
  }

  Future<void> _markAsRead(String tripId) async {
    debugPrint('Marking draft trip $tripId as read (CreateTripController)');
    try {
      final res = await ParseCloudFunction('setOwnerTripReadFlag').execute(
          parameters: {
            'isRead': true,
            'tripId': tripId,
          },
        );

        if (res.success != true) {
          final msg = res.error?.message ?? 'Unknown error';
          throw Exception('setOwnerTripReadFlag failed: $msg');
        }

        debugPrint('CreateTripController draft trip marked read.');
    } catch (e) {
      debugPrint('Error in draft _markAsRead (CreateTripController): $e');
    }
  }

  /// Saves the current CreateTripScreen state into the shared draft and persists it on server.
  /// This method does NOT pop the current screen; callers can decide whether to exit.
  Future<void> saveDraft({required BuildContext ctx, bool showSuccessDialog = true}) async {
    showLoadingDialog(ctx, 'Saving...');
    try {
      // Always merge the latest CreateTrip fields into the shared draft before saving.
      commitToDraft();

      await _saveService.saveDraft(committer: this);

      Navigator.pop(ctx); // close loader

      if (showSuccessDialog) {
        await showMyDialog(ctx, 'Draft updated successfully');
      }
    } catch (e) {
      // Close loader if still open
      Navigator.pop(ctx);
      showMyDialog(ctx, e.toString());
      rethrow;
    }
  }

  /// Default handler for the Save as Draft button on CreateTripScreen.
  /// Saves draft and then exits the screen.
  Future<void> onTapSaveDraft() async {
    final ctx = Get.context!;
    await saveDraft(ctx: ctx, showSuccessDialog: true);
    Get.back();
  }

  // --------------------------
  // Legacy helper mirrors
  // --------------------------

  void _clearPendingFlags() {
    UserHelper().clearPending();
    UserHelper().fromPendingDetail(false);
  }

  // --------------------------
  // UI helpers (called by Screen)
  // --------------------------

  /// Called by screen’s search TextField in Aircraft picker
  void filterAircraft(String text) {
    debugPrint('filter: $text -> ${aircraftTempList.length}');
    if (text.isEmpty) {
      aircraftTempList = aircraftTypeList;
      update(['aircraftPicker']); // Update specific GetBuilder
      return;
    }
    final out = <AircraftTypeList>[];
    for (final it in aircraftTypeList) {
      if (it.name.toLowerCase().contains(text.toLowerCase())) {
        out.add(it);
      }
    }
    aircraftTempList = out;
    aircraftFilterList = out;
    update(['aircraftPicker']);
  }

  /// Setters used by screen
  
  void setDepartureAirport(AirportLite a) {
    selectedDeparture = a;
    departAirportCodeController.text = a.ident; // UI still shows code
    didAcknowledgeEmptyRadius = false;
    update(['depDestEnroute']);
  }

  void setDestinationAirport(AirportLite a) {
    selectedDestination = a;
    destAirportCodeController.text = a.ident;
    update(['depDestEnroute']);
  }

  void toggleEnrouteAirport(AirportLite a) {
    if (selectedEnrouteById.containsKey(a.sourceId)) {
      selectedEnrouteById.remove(a.sourceId);
    } else {
      selectedEnrouteById[a.sourceId] = a;
    }

    // Keep legacy string list in sync (in case any other UI still uses it)
    airportCodeChecked.assignAll(selectedEnrouteById.values.map((e) => e.ident));

    // Keep the read-only text field updated
    enrouteAirportCodeController.text =
        selectedEnrouteById.values.map((e) => e.ident).join(', ');

    update(['depDestEnroute']);
  }

  /// Apply a complete enroute selection (used by the Enroute dialog so Cancel can discard changes).
  void setEnrouteSelection(Map<int, AirportLite> selectionById) {
    selectedEnrouteById.assignAll(selectionById);

    // Keep legacy string list in sync (in case any other UI still uses it)
    airportCodeChecked.assignAll(selectedEnrouteById.values.map((e) => e.ident));

    // Keep the read-only text field updated
    enrouteAirportCodeController.text =
        selectedEnrouteById.values.map((e) => e.ident).join(', ');

    update(['depDestEnroute']);
  }

  void setDeparture(String code) {
    departAirportCodeController.text = code;
    update(['depDestEnroute']);
  }

  void setDestination(String code) {
    destAirportCodeController.text = code;
    update(['depDestEnroute']);
  }

  void toggleEnrouteCode(String code) {
    if (airportCodeChecked.contains(code)) {
      airportCodeChecked.remove(code);
    } else {
      airportCodeChecked.add(code);
    }
    update(['depDestEnroute']);
  }

  void setRadiusDisplayAndValue(String? value) {
    if (value == null || value == "Any distance") {
      radiusFinal = "0";
      radiusController.text = "Any distance";
    } else if (value == "<10 miles") {
      radiusFinal = "10";
      radiusController.text = value;
    } else if (value == "<50 miles") {
      radiusFinal = "50";
      radiusController.text = value;
    } else if (value == "<100 miles") {
      radiusFinal = "100";
      radiusController.text = value;
    } else if (value == "<150 miles") {
      radiusFinal = "150";
      radiusController.text = value;
    } else if (value == "<200 miles") {
      radiusFinal = "200";
      radiusController.text = value;
    } else {
      radiusFinal = "0";
      radiusController.text = "Any distance";
    }

    didAcknowledgeEmptyRadius = false;
    update(['radius']);
  }

  bool shouldShowEmptyRadiusWarning() {
    final isUnset = radiusController.text.trim().isEmpty;
    if (!isUnset) return false;

    if (!didAcknowledgeEmptyRadius) {
      didAcknowledgeEmptyRadius = true;
      return true;
    }

    return false;
  }

  void setStartDate(DateTime picked) {
    currentDate.value = picked;
    final date = DateFormat('MM/dd/yyyy').format(picked);
    startDateController.text = date;
    // Reset end date if start changed (legacy behavior from onTap)
    endDateController.clear();
    update(['dates']);
  }

  void setEndDate(DateTime picked) {
    // Do not update currentDate here.
    // currentDate should track Start Date for End Date picker's minimum date.
    final date = DateFormat('MM/dd/yyyy').format(picked);
    endDateController.text = date;
    update(['dates']);
  }

  // --------------------------
  // Navigation to “SearchBy*Screen” (called by screen)
  // --------------------------

  /// Validate dates and navigate exactly like the legacy Update button flow (for out-of-date trips).
  /// Returns a string error to show via showMyDialog if validation fails; otherwise null.
  String? validateDatesForUpdate() {
    if (startDateController.text.isEmpty) {
      return "Please select start date";
    }
    if (endDateController.text.isEmpty) {
      return "Please select end date";
    }
    if (startDateStr == startDateController.text &&
        endDateStr == endDateController.text) {
      return "Please select different start and end dates";
    }
    return null;
  }

  /// Returns whether the info-only "You can only edit Start Date and End Date." pop-up should be shown.
  bool get shouldShowOutdatedInfoOnce => isTripOutOfDate.value && !_isPopUpClicked;

  void markOutdatedInfoShown() {
    _isPopUpClicked = true;
  }

  // For consumers that need single-role membership id (legacy)
  String? get derivedSingleRoleMembershipId => singleRoleMembershipId;

  // Expose the legacy crew member key for read-only access outside this file
  String? get oldCrewMembersKey => _oldCrewMembersKey;

  // Accessors for trip first (null-safe)
  TripDetails? get firstTrip => tripData.isEmpty ? null : tripData.first;

  Future<void> createTrip() async {
    // ------------------------------
    // 1) Derive role booleans (Captain / SIC / FA / FI)
    // ------------------------------
    // Prefer any existing draft flags if present, otherwise infer from selectList.
    final TripDetails? first = firstTrip;
    final bool cap = first?.captain ?? selectList.contains('Captain');
    final bool sic = first?.secondInCommand ?? selectList.contains('Second In Command');
    final bool fa = first?.flightAttendant ?? selectList.contains('Flight Attendant');
    final bool fi = first?.flightInstructor ??
        (selectList.contains('Flight Instructor') || selectList.contains('Instructor'));

    // ------------------------------
    // 2) Aircraft and radius normalization
    // ------------------------------
    // Fallback aircraft id to draft if not chosen in UI.

    // Match legacy radius semantics: "Search All" was sent as 0 / empty.
    final String? radiusValue =
        (radiusFinal == null || radiusFinal == '0') ? null : radiusFinal!.toString();

    // ------------------------------
    // 3) Convert UI dates (MM/dd/yyyy) to ISO strings for Cloud Code
    // ------------------------------
    // IMPORTANT:
    // Start/End are DATE-ONLY fields. Normalize to UTC midnight and send explicit UTC ISO strings
    // so the date never shifts for users in timezones behind UTC (e.g. EST).
    DateTime? _tryParseMMDDYYYYToUtc(String s) {
      final t = s.trim();
      if (t.isEmpty) return null;
      try {
        final localParsed = DateFormat('MM/dd/yyyy').parseStrict(t);
        return DateTime.utc(localParsed.year, localParsed.month, localParsed.day);
      } catch (_) {
        return null;
      }
    }

    final DateTime? startDtUtc = _tryParseMMDDYYYYToUtc(startDateController.text);
    final DateTime? endDtUtc = _tryParseMMDDYYYYToUtc(endDateController.text);

    final String? startIso = startDtUtc?.toUtc().toIso8601String();
    final String? endIso = endDtUtc?.toUtc().toIso8601String();

    // ------------------------------
    // 4) Prepare parameters for Back4App Cloud Function `createTrip`
    // ------------------------------
    // NOTE: This function is for creating a new trip only, so we do NOT send any trip id.
    final Map<String, dynamic> params = {
      'tripName': tripNameController.text.trim(),

      // NEW: store IDs
      'departureSourceId': selectedDeparture?.sourceId,
      'destinationSourceId': selectedDestination?.sourceId,
      'enrouteSourceIds': selectedEnrouteById.keys.toList(),

      // 'departure': departAirportCodeController.text.trim(),
      // 'enroute': airportCodeChecked.join(','),
      // 'destination': destAirportCodeController.text.trim(),
      
      'startDate': startIso,
      'endDate': endIso,
      'aircraft': aircraftTypeController.text.trim(),

      // Role flags
      'isCaptain': cap,
      'isSIC': sic,
      'isAttendant': fa,
      'isInstructor': fi,

      // Currently we do not have rate fields wired from UI; set them null/omit.
      // Add them here when you expose corresponding inputs on the screen.
      // 'pilotRate': ..., 'SICRate': ..., 'attendantRate': ..., 'instructorRate': ...,

      // Trip status flags
      'isStarted': false,
      'isCompleted': false,
      'isVoid': false,
      'isRead': false,
      'isDirect': false,

      // Radius (null => Search All)
      'radius': radiusValue == null ? 0 : int.tryParse(radiusValue) ?? 0,
    };

    // Remove any null entries so we do not send meaningless values to Cloud Code.
    params.removeWhere((key, value) => value == null);

    // ------------------------------
    // 5) Call Back4App Cloud Function
    // ------------------------------
    final function = ParseCloudFunction('createTrip');
    final ParseResponse response = await function.execute(parameters: params);

    if (!response.success || response.result == null) {
      throw 'Failed to create trip.';
    }

    // Expected Cloud Code return: { success: true, objectId: 'xxxx' }
    final result = response.result as Map<String, dynamic>;
    final bool ok = result['success'] == true;
    if (!ok) {
      // If server sent an error message, surface it; otherwise generic.
      final serverMsg = result['message']?.toString();
      throw (serverMsg?.isNotEmpty == true) ? serverMsg! : 'Failed to create trip.';
    }

    final String? objectId = result['objectId']?.toString();

    // ------------------------------
    // 6) Populate controller fields used by navigation logic
    // ------------------------------
    // Keep parity with legacy code: mark which roles were created and store aircraft info.
    createdCaptain = cap;
    createdSecondInCommand = sic;
    createdFlightAttendant = fa;
    createdFlightInstructor = fi;
    // createdFkAircraftId = fkAircraftIdFinal;
    // createdAircraftTypeText = aircraftTypeController.text.trim();

    // For Back4App, the trip identifier is the objectId string. You can
    // add a new String field (e.g. createdTripObjectId) if you want to
    // pass it to subsequent screens.
    // Example (uncomment after adding field to controller):
    createdTripId = objectId;

    debugPrint('Trip created with objectId=$objectId');
  }

  // TripDraftPayload buildDraftPayload(){

  //   // Radius normalization
  //   final int r = int.tryParse((radiusFinal ?? '0').toString()) ?? 0;

  //   return TripDraftPayload(
  //     tripObjectId: createdTripId,
  //     tripName: tripNameController.text.trim(),
  //     departureSourceId: selectedDeparture?.sourceId,
  //     destinationSourceId: selectedDestination?.sourceId,
  //     enrouteSourceIds: selectedEnrouteById.keys.toList(),
  //     startDate: startDateController.text.trim().isEmpty ? null : DateFormat('MM/dd/yyyy').parse(startDateController.text.trim()),
  //     endDate: endDateController.text.trim().isEmpty ? null : DateFormat('MM/dd/yyyy').parse(endDateController.text.trim()),
  //     aircraftId: aircraftID,
  //     aircraftName: aircraftTypeController.text.trim(),
  //     radius: r,
  //     isCaptain: selectList.contains('Captain'),
  //     isSIC: selectList.contains('Second In Command'),
  //     isAttendant: selectList.contains('Flight Attendant'),
  //     isInstructor: selectList.contains('Flight Instructor') || selectList.contains('Instructor'),
  //     // Status flags default to false for a new trip; no need to set them here.
  //     // Role requirements are not currently captured in the UI; set to empty for now.
  //     roleRequirements: {},
  //   );
  // }

  /// Downloads the requirements JSON from the trip.requirements file URL and merges it into the shared draft.
  Future<void> _loadRequirementsFromTripModel(TripModel tripModel) async {
    final String? url = tripModel.requirementsUrl;
    if (url == null || url.trim().isEmpty) {
      debugPrint('No requirementsUrl on trip ${tripModel.objectId}; skipping requirements load.');
      return;
    }

    isLoadingRequirements.value = true;
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
      isLoadingRequirements.value = false;
      // Leave isLoading=false only if we are not in the middle of another load.
      isLoading.value = false;
    }
  }
}