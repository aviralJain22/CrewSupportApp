import 'package:crew_support/database/airport_platform.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/model/owner_trip_detail_models.dart';
import 'package:crew_support/model/trip_notification.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:crew_support/utils/notification_constants.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:sizer/sizer.dart';

class TripSummaryController extends GetxController {
  /// ===== Args (same as old widget fields) =====
  // late final TripDetailsData tripSummary;
  // late final String oppositeId;

  final Rxn<OwnerTripDetailResponse> tripDetails = Rxn<OwnerTripDetailResponse>();

  /// Values read from tripOperation (for this trip + current user + membershipType)
  ///
  /// If the tripOperation row exists but a value is undefined in Parse,
  /// the cloud function normalizes it to `null`.
  final RxBool isCrewTripOpLoaded = false.obs;
  final RxnBool isCrewAccepted = RxnBool();
  final RxnBool isOwnerAccepted = RxnBool();

  /// Optional rate stored on tripOperation (normalized to null if missing)
  final RxnDouble ownerRate = RxnDouble();

  /// If we fail to load tripOperation for any reason, keep the error for debugging/UI.
  final RxnString tripOpLoadError = RxnString();

  // String notificationId = "";
  /// Local flag to avoid calling the cloud function multiple times per screen open.
  final RxBool _didMarkNotificationRead = false.obs;

  // int? index;
  // bool? tripAccepted;
  bool? fromFutureCurrent;
  // bool? indexZero;
  // int? indexOfScreen;
  // String? rate;

  /// ===== Text controllers (same as old) =====
  final tripNameController = TextEditingController();
  final departAirportCodeController = TextEditingController();
  final destAirportCodeController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final dayRateController = TextEditingController();
  final aircraftTypeController = TextEditingController();
  final totalController = TextEditingController();
  final negotiateController = TextEditingController();

  /// ===== Local state =====
  final enrouteTempList = <String>[].obs;

  final Cancelstopclikcing = false.obs;
  final Acceptstopclikcing = false.obs;

  late final String appType;
  String? totalAmt;

  /// Old code used this to decide ACCEPT/DECLINE in some flows.
  int acceptReject = 0;

  double totalAmount = 0;

  /// Owner read/unread check (old code did getOwnerReadUnReadTrip then used isOwnerRead)
  // MessageData getOwnerRead = MessageData();

  late final DashboardController dash;
  late final TripNotification notification;

  @override
  Future<void> onInit() async {
    super.onInit();

    dash = Get.find<DashboardController>();

    // Read args from Get.arguments (Map).
    final args = (Get.arguments ?? {}) as Map;

    tripDetails.value = args['tripDetails'] as OwnerTripDetailResponse?;
    notification = args['notification'] as TripNotification;

    // tripSummary = args['tripSummary'] as TripDetailsData;
    // oppositeId = (args['oppositeId'] ?? '') as String;

    // index = args['index'] as int?;
    // tripAccepted = args['tripAccepted'] as bool?;
    fromFutureCurrent = args['fromFutureCurrent'] as bool?;
    // indexZero = args['index_zero'] as bool?;
    // indexOfScreen = args['indexOfScreen'] as int?;
    // rate = args['rate']?.toString();

    // appType = UserHelper().getAppType();

    _fillData();

    // Mark this notification as read for the current crew user (best-effort, no loader).
    // This should not block the UI or throw if it fails.
    _markNotificationReadIfNeeded();

    // Load tripOperation status (isCrewAccepted / isOwnerAccepted) if we have enough info.
    await _loadCrewTripOperation(
      tripIdArg: tripDetails.value?.trip.objectId,
      //todo: deduce profileType via tripOperation for this crew on cloud code
      membershipTypeArg: dash.selectedProfileType.value,
    );

    debugPrint("isCrewAccepted: $isCrewAccepted, isOwnerAccepted: $isOwnerAccepted");
    debugPrint("notificationType: ${notification.type}");
  }

  @override
  void onClose() {
    // Old code: EasyLoading.dismiss() in dispose
    EasyLoading.dismiss();

    tripNameController.dispose();
    departAirportCodeController.dispose();
    destAirportCodeController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    dayRateController.dispose();
    aircraftTypeController.dispose();
    totalController.dispose();
    negotiateController.dispose();
    super.onClose();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    // IMPORTANT:
    // Start/End are DATE-ONLY fields. Do NOT convert to local time here,
    // because that can shift the calendar day for timezones behind UTC (e.g. EST).
    // We always format using the UTC calendar date so everyone sees the same day.
    final d = dt.toUtc();
    return DateFormat('MM/dd/yyyy').format(DateTime.utc(d.year, d.month, d.day));
  }

  Future<String> _resolveAirportIdent(int? sourceId) async {
    if (sourceId == null || sourceId <= 0) return '-';
    try {
      final a = await AirportCache.instance.getBySourceId(sourceId);
      return (a?.ident.isNotEmpty == true) ? a!.ident : '-';
    } catch (_) {
      return '-';
    }
  }

  Future<List<String>> _resolveEnrouteIdents(List<int> sourceIds) async {
    if (sourceIds.isEmpty) return <String>[];
    try {
      final futures = sourceIds.map((id) => _resolveAirportIdent(id));
      final results = await Future.wait(futures);
      // Keep only valid idents
      return results.where((e) => e != '-').toList(growable: false);
    } catch (_) {
      return <String>[];
    }
  }

  Future<void> _resolveAndFillAirports() async {
    final trip = tripDetails.value?.trip;
    if (trip == null) return;

    final dep = await _resolveAirportIdent(trip.departureSourceId);
    final dest = await _resolveAirportIdent(trip.destinationSourceId);
    final enroute = await _resolveEnrouteIdents(trip.enrouteSourceIds);

    departAirportCodeController.text = dep;
    destAirportCodeController.text = dest;
    enrouteTempList.assignAll(enroute);
  }

  void _fillData() {
    // Mirrors old getData()
    // final trip0 = tripSummary.trip[0];

    tripNameController.text = tripDetails.value?.trip.tripName ?? "";
    
    // Airports are now stored as sourceIds. Resolve idents from local cache.
    departAirportCodeController.text = "-";
    destAirportCodeController.text = "-";
    enrouteTempList.assignAll(const <String>[]);

    _resolveAndFillAirports();

    startDateController.text =
        _formatDate(tripDetails.value?.trip.startDate);
    endDateController.text =
        _formatDate(tripDetails.value?.trip.endDate);

    aircraftTypeController.text = tripDetails.value?.trip.aircraft ?? "";

    if (notification.type == NotificationType.tripRequestSent){
      //use rate from tripDetails
      _applyDayRateAndTotal(_computeTripRateFromTripDetails());
    } else if (notification.type == NotificationType.crewNegotiates || notification.type == NotificationType.ownerNegotiates){
      //use amount from tripNotification
      final requestedRatePerDay = notification.amount ?? 0;
      _applyDayRateAndTotal(requestedRatePerDay);
    } else {
      //we'll fetch ownerRate from tripOperation
      dayRateController.text = "";
      totalController.text = "";
      totalAmt = null;
      totalAmount = 0;
    }
  }

  /// Computes the day rate from tripDetails based on the notification membershipType.
  /// This mirrors the previous logic that lived inside `_fillData()`.
  double _computeTripRateFromTripDetails() {
    var r = (tripDetails.value?.trip.pilotRate is num
        ? (tripDetails.value?.trip.pilotRate as num).toDouble()
        : 0.0);

    if (notification.membershipType == MembershipType.pilot) {
      r = (tripDetails.value?.trip.pilotRate is num
          ? (tripDetails.value?.trip.pilotRate as num).toDouble()
          : 0.0);
    } else if (notification.membershipType == 5) {
      r = (tripDetails.value?.trip.sicRate is num
          ? (tripDetails.value?.trip.sicRate as num).toDouble()
          : 0.0);
    } else if (notification.membershipType == MembershipType.flightAttendant) {
      r = (tripDetails.value?.trip.attendantRate is num
          ? (tripDetails.value?.trip.attendantRate as num).toDouble()
          : 0.0);
    } else if (notification.membershipType == MembershipType.instructor) {
      r = (tripDetails.value?.trip.instructorRate is num
          ? (tripDetails.value?.trip.instructorRate as num).toDouble()
          : 0.0);
    } else {
      debugPrint("No matching membershipType found");
    }

    return r;
  }

  /// Applies the chosen day rate to controllers and recomputes totals.
  void _applyDayRateAndTotal(double dayRate) {
    dayRateController.text = _formatNumber(dayRate);

    final dt1 = tripDetails.value?.trip.endDate;
    final dt2 = tripDetails.value?.trip.startDate;
    final diffDaysInclusive =
        (dt1 != null && dt2 != null) ? dt1.difference(dt2).inDays + 1 : 0;

    totalAmount = diffDaysInclusive * dayRate;
    totalController.text = _formatNumber(totalAmount);
    totalAmt = _formatNumber(totalAmount);
  }

  /// Loads isCrewAccepted / isOwnerAccepted from tripOperation for:
  /// - trip == tripId
  /// - crewUser == current user
  /// - membershipType == input
  ///
  /// Requires cloud function: `getCrewTripOperation`.
  Future<void> _loadCrewTripOperation({
    String? tripIdArg,
    int? membershipTypeArg,
  }) async {
    // Reset state each time screen opens.
    isCrewTripOpLoaded.value = false;
    tripOpLoadError.value = null;
    isCrewAccepted.value = null;
    isOwnerAccepted.value = null;
    ownerRate.value = null;

    // If membershipType wasn't passed, we cannot query reliably.
    // (TripOperation schema requires membershipType filter.)
    final membershipType = membershipTypeArg;
    if (membershipType == null) {
      // Not an error; some flows may not need it.
      return;
    }

    final tripId = tripIdArg?.trim();

    if (tripId == null || tripId.isEmpty) {
      tripOpLoadError.value =
          'Missing tripId. Pass tripId in Get.arguments as {"tripId": "..."}.';
      return;
    }

    try {

      String functionName = 'getCrewTripOperation';
      Map<String, dynamic> parameters = {
        'tripId': tripId,
        'membershipType': notification.membershipType,
      };

      if (dash.selectedProfileType.value == MembershipType.ownerOperator){
        functionName = 'getOwnerTripOperation';
        parameters = {
          'tripNotificationId': notification.objectId,
        };
      }

      // Call Parse Cloud Function.
      final func = ParseCloudFunction(functionName);
      final res = await func.execute(parameters: parameters);

      if (res.success != true) {
        tripOpLoadError.value =
            res.error?.message ?? 'Failed to load tripOperation';
        return;
      }

      final data = res.result;
      if (data is Map) {
        // Cloud function returns:
        // { found: bool, isCrewAccepted: bool|null, isOwnerAccepted: bool|null }
        final crew = data['isCrewAccepted'];
        final owner = data['isOwnerAccepted'];

        final oRate = data['ownerRate'];

        isCrewAccepted.value = (crew is bool) ? crew : null;
        isOwnerAccepted.value = (owner is bool) ? owner : null;

        ownerRate.value = (oRate is num) ? oRate.toDouble() : null;

        if (notification.type != NotificationType.tripRequestSent &&
          notification.type != NotificationType.crewNegotiates &&
          notification.type != NotificationType.ownerNegotiates ) {
          // If ownerRate is NOT null -> use it for dayRate + total
          // Else -> use the same logic as old _fillData (from tripDetails)
          final chosenRate = ownerRate.value ?? _computeTripRateFromTripDetails();
          _applyDayRateAndTotal(chosenRate);
        }
      }

      isCrewTripOpLoaded.value = true;
    } catch (e) {
      tripOpLoadError.value = e.toString();
    }
  }

  Future<void> acceptTripCancellationRequestAsOwner() async {
    final ctx = Get.context;

    // Defensive checks
    final tripId = (tripDetails.value?.trip.objectId ?? '').trim();
    final tripNotificationId = notification.objectId.trim();

    if (tripId.isEmpty) {
      if (ctx != null) {
        await showMyDialog(ctx, 'Missing tripId');
      }
      return;
    }

    if (tripNotificationId.isEmpty) {
      if (ctx != null) {
        await showMyDialog(ctx, 'Missing tripNotificationId');
      }
      return;
    }

    // Prevent accidental double-taps
    if (Acceptstopclikcing.value == true) return;
    Acceptstopclikcing.value = true;

    showLoadingDialog(ctx!, "Cancelling...");

    try {
      debugPrint("[TripSummary] tripCancellationRequestAcceptedByOwner START");
      debugPrint("[TripSummary] tripId=$tripId, tripNotificationId=$tripNotificationId");

      // Call Parse Cloud Function: tripCancellationRequestAcceptedByOwner
      final fn = ParseCloudFunction('tripCancellationRequestAcceptedByOwner');
      final res = await fn.execute(parameters: {
        'tripId': tripId,
        'tripNotificationId': tripNotificationId,
      });

      // Close loader dialog
      Navigator.pop(ctx);

      if (res.success != true) {
        final msg = res.error?.message ?? 'tripCancellationRequestAcceptedByOwner failed';
        debugPrint("[TripSummary] tripCancellationRequestAcceptedByOwner ERROR: $msg");
        await showMyDialog(ctx, msg);
        return;
      }

      final result = res.result;
      debugPrint("[TripSummary] tripCancellationRequestAcceptedByOwner RESULT: $result");

      // Cloud function returns { success: bool, message: String, ... }
      if (result is Map && result['success'] == false) {
        final msg = result['message']?.toString() ?? 'Unable to accept cancellation request.';
        await showMyDialog(ctx, msg);
        return;
      }

      final successMsg = (result is Map && result['message'] is String)
          ? (result['message'] as String)
          : 'Cancellation accepted successfully';

      await showMyDialog(ctx, successMsg);

      dash.goBackToDashboardAndReloadTrips();
    } catch (e) {
      // Close loader if still open
      if (Get.isOverlaysOpen) {
        Get.back();
      }
      debugPrint("[TripSummary] tripCancellationRequestAcceptedByOwner EXCEPTION: $e");
      await showMyDialog(ctx, e.toString());
        } finally {
      Acceptstopclikcing.value = false;
    }
  }

  Future<void> acceptTripCancellationRequestAsCrew() async {
    final ctx = Get.context;

    // Defensive checks
    final tripId = (tripDetails.value?.trip.objectId ?? '').trim();
    final tripNotificationId = notification.objectId.trim();

    if (tripId.isEmpty) {
      if (ctx != null) {
        await showMyDialog(ctx, 'Missing tripId');
      }
      return;
    }

    if (tripNotificationId.isEmpty) {
      if (ctx != null) {
        await showMyDialog(ctx, 'Missing tripNotificationId');
      }
      return;
    }

    // Prevent accidental double-taps
    if (Acceptstopclikcing.value == true) return;
    Acceptstopclikcing.value = true;

    showLoadingDialog(ctx!, "Cancelling...");

    try {
      debugPrint("[TripSummary] tripCancellationRequestAcceptedByCrew START");
      debugPrint("[TripSummary] tripId=$tripId, tripNotificationId=$tripNotificationId");

      // Call Parse Cloud Function: tripCancellationRequestAcceptedByCrew
      final fn = ParseCloudFunction('tripCancellationRequestAcceptedByCrew');
      final res = await fn.execute(parameters: {
        'tripId': tripId,
        'tripNotificationId': tripNotificationId,
      });

      // Close loader dialog
      Navigator.pop(ctx);

      if (res.success != true) {
        final msg = res.error?.message ?? 'tripCancellationRequestAcceptedByCrew failed';
        debugPrint("[TripSummary] tripCancellationRequestAcceptedByCrew ERROR: $msg");
        await showMyDialog(ctx, msg);
        return;
      }

      final result = res.result;
      debugPrint("[TripSummary] tripCancellationRequestAcceptedByCrew RESULT: $result");

      // Cloud function returns { success: bool, message: String, ... }
      if (result is Map && result['success'] == false) {
        final msg = result['message']?.toString() ?? 'Unable to accept cancellation request.';
        await showMyDialog(ctx, msg);
        return;
      }

      final successMsg = (result is Map && result['message'] is String)
          ? (result['message'] as String)
          : 'Cancellation accepted successfully';

      await showMyDialog(ctx, successMsg);

      dash.goBackToDashboardAndReloadTrips();
    } catch (e) {
      // Close loader if still open
      if (Get.isOverlaysOpen) {
        Get.back();
      }
      debugPrint("[TripSummary] tripCancellationRequestAcceptedByCrew EXCEPTION: $e");
      await showMyDialog(ctx, e.toString());
        } finally {
      Acceptstopclikcing.value = false;
    }
  }

  Future<void> onCrewDecline() async {
    final ctx = Get.context;

    // Defensive checks
    final tripNotificationId = notification.objectId.trim();

    if (tripNotificationId.isEmpty) {
      if (ctx != null) {
        await showMyDialog(ctx, 'Missing tripNotificationId');
      }
      return;
    }

    // Prevent accidental double-taps
    if (Cancelstopclikcing.value == true) return;
    Cancelstopclikcing.value = true;

    showLoadingDialog(ctx!, "Declining...");

    try {
      debugPrint("[TripSummary] denyTripByCrew START");
      debugPrint("[TripSummary] tripNotificationId=$tripNotificationId");

      // Call Parse Cloud Function: denyTripByCrew
      final fn = ParseCloudFunction('denyTripByCrew');
      final res = await fn.execute(parameters: {
        'tripNotificationId': tripNotificationId,
      });

      // Close loader dialog
      Navigator.pop(ctx);

      if (res.success != true) {
        final msg = res.error?.message ?? 'denyTripByCrew failed';
        debugPrint("[TripSummary] denyTripByCrew ERROR: $msg");
        await showMyDialog(ctx, msg);
        return;
      }

      final result = res.result;
      debugPrint("[TripSummary] denyTripByCrew RESULT: $result");

      // Optional success message
      await showMyDialog(ctx, 'Trip declined successfully');

      // Navigate back and refresh trips
      dash.goBackToDashboardAndReloadTrips();
    } catch (e) {
      // Close loader if still open
      if (Get.isOverlaysOpen) {
        Get.back();
      }
      debugPrint("[TripSummary] denyTripByCrew EXCEPTION: $e");
      await showMyDialog(ctx, e.toString());
        } finally {
      Cancelstopclikcing.value = false;
    }
  }

  Future<void> onNegotiation() async {
    final ctx = Get.context;

    // Defensive: context must exist to show dialogs
    if (ctx == null) {
      debugPrint('[TripSummary] onNegotiation: context is null');
      return;
    }

    // 1) Validate entered amount (rate per day)
    final raw = negotiateController.text.trim();
    if (raw.isEmpty) {
      await showMyDialog(ctx, 'Please Enter Amount');
      return;
    }

    // Allow integers or decimals (even though keyboard uses decimal:false, user can paste)
    final rate = double.tryParse(raw);
    if (rate == null || rate.isNaN || rate.isInfinite) {
      await showMyDialog(ctx, 'Please enter a valid number');
      return;
    }

    if (rate <= 0) {
      await showMyDialog(ctx, 'Amount must be greater than 0');
      return;
    }

    // 2) tripNotificationId is required for this cloud function
    final notificationId = notification.objectId.trim();
    if (notificationId.isEmpty) {
      await showMyDialog(ctx, 'Missing tripNotificationId');
      return;
    }

    // 3) Call cloud function
    showLoadingDialog(ctx, 'Negotiating...');

    String functionName = 'negotiationRequestByCrew';
    String defaultFailMessage = 'You have already sent a negotiation request. Please wait for the owner operator to respond.';
    if (dash.selectedProfileType.value == MembershipType.ownerOperator){
      functionName = 'negotiationRequestByOwner';
      defaultFailMessage = 'You have already sent a negotiation request. Please wait for the crew member to respond.';
    }

    try {
      debugPrint('[TripSummary] $functionName START');
      debugPrint('[TripSummary] tripNotificationId=$notificationId, rate=$rate');

      final fn = ParseCloudFunction(functionName);

      final res = await fn.execute(parameters: {
        'tripNotificationId': notificationId,
        // Backend accepts number or numeric string; we send num.
        'rate': rate,
      });

      // Close loading dialog
      Navigator.pop(ctx);

      if (res.success != true) {
        final msg = res.error?.message ?? '$functionName failed';
        debugPrint('[TripSummary] $functionName ERROR: $msg');
        await showMyDialog(ctx, msg);
        return;
      }

      final result = res.result;
      debugPrint('[TripSummary] $functionName RESULT: $result');

      // Cloud function may throw for duplicates; if it returns a structured response, honor it.
      if (result is Map && result['success'] == false) {
        final msg = result['message']?.toString() ??
            defaultFailMessage;
        await showMyDialog(ctx, msg);
        return;
      }

      await showMyDialog(ctx, 'Negotiation request sent successfully');
      dash.goBackToDashboardAndReloadTrips();
    } catch (e) {
      // Close loader if still open
      if (Get.isOverlaysOpen) {
        Get.back();
      }
      debugPrint('[TripSummary] $functionName EXCEPTION: $e');
      await showMyDialog(ctx, e.toString());
    }
  }

  /// ===== Dialogs (Cupertino, same text/buttons as old) =====

  void showAlertDialogAccept(String msg) {
    final ctx = Get.context!;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) {
        return Theme(
          data: ThemeData.dark(),
          child: CupertinoAlertDialog(
            content: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                msg,
                style: TextStyle(fontSize: 10.0.spV2, color: AppColor.textColor1),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("CANCEL", style: TextStyle(color: AppColor.secondaryColor1)),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  // showLoadingDialog(ctx, 'Loading...');

                  // Get.toNamed('/addBankDetail', arguments: {
                  //   'tripDetails': tripDetails.value,
                  //   // AddBankDetailArgs.tripId: tripId,
                  //   // AddBankDetailArgs.oppositionId: oppositionId,
                  //   AddBankDetailArgs.acceptReject: acceptReject,
                  //   // AddBankDetailArgs.dayRateAmount: dayRateAmount,
                  //   AddBankDetailArgs.totalAmount: totalAmount,
                  //   // AddBankDetailArgs.navFor: navFor,
                  //   // AddBankDetailArgs.startDate: startDate,
                  //   AddBankDetailArgs.tripNotificationId: notification.objectId,
                  // });

                  await acceptTrip();

                },
                child: Text("YES", style: TextStyle(color: AppColor.secondaryColor1)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> acceptTrip() async {
    if (dash.selectedProfileType.value == MembershipType.ownerOperator) {
        await onAcceptDeclineOwner();
    } else {
        await onAcceptDecline();
    }
  }

  Future<void> onAcceptDeclineOwner() async {
  }

  Future<void> onAcceptDecline() async {
    final context = Get.context;
    if (context == null) return;

    try {
      showLoadingDialog(context, "Accepting...");
      // We expect this screen to be opened from a notification context.
      // If the id is missing, we fail fast to avoid silently navigating.
      final id = notification.objectId;
      if (id.trim().isEmpty) {
        throw Exception('Missing tripNotificationId');
      }

      // 1) Call backend accept flow.
      await _callAcceptTripByCrew(tripNotificationId: id.trim());

      // 2) Close loader (shown by submitBankDetails/showSkipDialog).
      // if (Get.isDialogOpen == true) {
        Get.back();
      // }

      // 3) Navigate back to dashboard.
      // Get.offNamed(AppRoutes.dashboard);
      Get.find<DashboardController>().goBackToDashboardAndReloadTrips();
      // Get.back();
    } catch (e) {
      // Close loader if any.
      // if (Get.isDialogOpen == true) {
        Get.back();
      // }

      if (kDebugMode) {
        debugPrint('onAcceptDecline error: $e');
      }

      showMyDialog(context, 'Unable to accept. Please try again.');
    }
  }

  /// Calls the Parse Cloud Function `acceptTripByCrew`.
  ///
  /// Expected cloud function contract:
  /// - Input: { tripNotificationId: <String> }
  /// - Authorization: must be logged-in; server validates the notification belongs to current user.
  Future<void> _callAcceptTripByCrew({required String tripNotificationId}) async {
    final fn = ParseCloudFunction('acceptTripByCrew');

    final res = await fn.execute(parameters: {
      'tripNotificationId': tripNotificationId,
    });

    if (res.success != true) {
      // Parse returns error details via res.error.
      final msg = res.error?.message ?? 'Unable to accept trip. Please try again.';
      throw Exception(msg);
    }
  }

  void showAlertNegotiation() {
    final ctx = Get.context!;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) {
        return Theme(
          data: ThemeData.dark(),
          child: CupertinoAlertDialog(
            title: Text("Enter Negotiate amount", style: TextStyle(color: AppColor.textColor1)),
            content: TextFormField(
              controller: negotiateController,
              cursorColor: AppColor.secondaryColor1,
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
              style: TextStyle(fontSize: 10.spV2, color: AppColor.secondaryColor1),
              decoration: InputDecoration(
                prefixText: "\$",
                prefixStyle: TextStyle(color: AppColor.secondaryColor1),
                hintText: "Enter Negotiate Amount Per/Day",
                hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColor.secondaryColor1),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColor.secondaryColor1),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("CANCEL", style: TextStyle(color: AppColor.secondaryColor1)),
              ),
              TextButton(
                onPressed: () {
                  if (negotiateController.text.isEmpty) {
                    showMyDialog(ctx, "Please Enter Amount");
                  } else {
                    Navigator.pop(ctx);
                    onNegotiation();
                  }
                },
                child: Text("SUBMIT", style: TextStyle(color: AppColor.secondaryColor1)),
              ),
            ],
          ),
        );
      },
    );
  }

  void showOwnerTripCancelDialog() {
    final ctx = Get.context!;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) {
        return Theme(
          data: ThemeData.dark(),
          child: CupertinoAlertDialog(
            content: Text(
              "Are you sure you want to cancel this trip?",
              style: TextStyle(color: AppColor.textColor1),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Cancelstopclikcing.value = false;
                },
                child: Text("No", style: TextStyle(color: AppColor.secondaryColor1)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Cancelstopclikcing.value = false;
                  cancelTripByOwner();
                },
                child: Text("Yes", style: TextStyle(color: AppColor.secondaryColor1)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> cancelTripByOwner() async {
    final ctx = Get.context;

    // TripId is already available from tripDetails
    final tripId = (tripDetails.value?.trip.objectId ?? '').trim();
    if (tripId.isEmpty) {
      if (ctx != null) {
        await showMyDialog(ctx, 'Missing tripId');
      }
      return;
    }

    showLoadingDialog(ctx!, 'Cancelling Trip...');

    try {
      // Call Parse Cloud Function: cancelTripByOwner
      final fn = ParseCloudFunction('cancelTripByOwner');
      final res = await fn.execute(parameters: {
        'tripId': tripId,
      });

      // Close loading dialog
      Navigator.pop(ctx);

      if (res.success != true) {
        final msg = res.error?.message ?? 'cancelTripByOwner failed';
        await showMyDialog(ctx, msg);
        return;
      }

      final result = res.result;

      // Cloud function returns { success: bool, message: String, ... }
      if (result is Map && result['success'] == false) {
        final msg = result['message']?.toString() ??
            'This trip cannot be cancelled as crew member(s) have already shown interest.';
        await showMyDialog(ctx, msg);
        return;
      }

      final successMsg = (result is Map && result['message'] is String)
          ? result['message'] as String
          : 'Trip cancelled successfully';

      await showMyDialog(ctx, successMsg);

      dash.goBackToDashboardAndReloadTrips();
    } catch (e) {
      // Close loader if still open
      if (Get.isOverlaysOpen) {
        Get.back();
      }
      await showMyDialog(ctx, e.toString());
    }
  }

  void showRequestCancellationByCrewDialog() {
    final ctx = Get.context!;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) {
        return Theme(
          data: ThemeData.dark(),
          child: CupertinoAlertDialog(
            content: Text(
              "Are you sure you want to request trip cancellation?",
              style: TextStyle(color: AppColor.textColor1),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Cancelstopclikcing.value = false;
                },
                child: Text("No", style: TextStyle(color: AppColor.secondaryColor1)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Cancelstopclikcing.value = false;
                  requestCancellationByCrewMember();
                },
                child: Text("Yes", style: TextStyle(color: AppColor.secondaryColor1)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> requestCancellationByCrewMember() async {
    final ctx = Get.context;

    final notificationId = notification.objectId.trim();
    if (notificationId.isEmpty) {
      Cancelstopclikcing.value = false;
      if (ctx != null) {
        await showMyDialog(ctx, "Missing tripNotificationId");
      }
      return;
    }

    showLoadingDialog(Get.context!, "Requesting Cancellation...");

    try {
      debugPrint("[TripSummary] cancellationRequestByCrew START");
      debugPrint("[TripSummary] tripNotificationId=$notificationId");

      // Call Parse Cloud Function: cancellationRequestByCrew
      // This creates a new tripNotification (type=15) and marks tripOperation.isRead=false and trip.isRead=false.
      final fn = ParseCloudFunction('cancellationRequestByCrew');
      final res = await fn.execute(parameters: {
        'tripNotificationId': notificationId,
      });

      // Close loading dialog
      Navigator.pop(Get.context!);

      if (res.success != true) {
        final msg = res.error?.message ?? 'cancellationRequestByCrew failed';
        debugPrint("[TripSummary] cancellationRequestByCrew ERROR: $msg");
        if (ctx != null) await showMyDialog(ctx, msg);
        return;
      }

      final result = res.result;
      debugPrint("[TripSummary] cancellationRequestByCrew RESULT: $result");

      // Show a user-friendly message
      if (ctx != null) {
        await showMyDialog(ctx, "Cancellation request sent successfully");
      }

      dash.goBackToDashboardAndReloadTrips();
    } catch (e) {
      // Close loader if still open
      if (Get.isOverlaysOpen) {
        Get.back();
      }
      debugPrint("[TripSummary] cancellationRequestByCrew EXCEPTION: $e");
      if (ctx != null) {
        await showMyDialog(ctx, e.toString());
      }
    } finally {
      Cancelstopclikcing.value = false;
    }
  }

  void showRequestCancellationByOwnerDialog() {
    final ctx = Get.context!;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) {
        return Theme(
          data: ThemeData.dark(),
          child: CupertinoAlertDialog(
            content: Text(
              "Are you sure you want to request trip cancellation?",
              style: TextStyle(color: AppColor.textColor1),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Cancelstopclikcing.value = false;
                },
                child: Text("No", style: TextStyle(color: AppColor.secondaryColor1)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Cancelstopclikcing.value = false;
                  requestCancellationByOwner();
                },
                child: Text("Yes", style: TextStyle(color: AppColor.secondaryColor1)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> requestCancellationByOwner() async {
    final ctx = Get.context;

    final notificationId = notification.objectId.trim();
    if (notificationId.isEmpty) {
      Cancelstopclikcing.value = false;
      if (ctx != null) {
        await showMyDialog(ctx, "Missing tripNotificationId");
      }
      return;
    }

    showLoadingDialog(Get.context!, "Requesting Cancellation...");

    try {
      debugPrint("[TripSummary] cancellationRequestByOwner START");
      debugPrint("[TripSummary] tripNotificationId=$notificationId");

      // Call Parse Cloud Function: cancellationRequestByOwner
      // This creates a new tripNotification (type=16) and marks tripOperation.isRead=false and trip.isRead=false.
      final fn = ParseCloudFunction('cancellationRequestByOwner');
      final res = await fn.execute(parameters: {
        'tripNotificationId': notificationId,
      });

      // Close loading dialog
      Navigator.pop(Get.context!);

      if (res.success != true) {
        final msg = res.error?.message ?? 'cancellationRequestByOwner failed';
        debugPrint("[TripSummary] cancellationRequestByOwner ERROR: $msg");
        if (ctx != null) await showMyDialog(ctx, msg);
        return;
      }

      final result = res.result;
      debugPrint("[TripSummary] cancellationRequestByOwner RESULT: $result");

      // Show a user-friendly message
      if (ctx != null) {
        await showMyDialog(ctx, "Cancellation request sent successfully");
      }

      dash.goBackToDashboardAndReloadTrips();
    } catch (e) {
      // Close loader if still open
      if (Get.isOverlaysOpen) {
        Get.back();
      }
      debugPrint("[TripSummary] cancellationRequestByOwner EXCEPTION: $e");
      if (ctx != null) {
        await showMyDialog(ctx, e.toString());
      }
    } finally {
      Cancelstopclikcing.value = false;
    }
  }

  void showAlertDialogReject() {
    final ctx = Get.context!;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) {
        return Theme(
          data: ThemeData.dark(),
          child: CupertinoAlertDialog(
            content: Text(
              "Are you sure you want to decline offer?",
              style: TextStyle(fontSize: 11.0.spV2, color: AppColor.textColor1),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("CANCEL", style: TextStyle(color: AppColor.secondaryColor1)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onCrewDecline();
                },
                child: Text("YES", style: TextStyle(color: AppColor.secondaryColor1)),
              ),
            ],
          ),
        );
      },
    );
  }

  void showAlertDialogOwnerAcceptOffer(String msg) {
    final ctx = Get.context!;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) {
        return Theme(
          data: ThemeData.dark(),
          child: CupertinoAlertDialog(
            content: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                msg,
                style: TextStyle(fontSize: 10.0.spV2, color: AppColor.textColor1),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("CANCEL", style: TextStyle(color: AppColor.secondaryColor1)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  showLoadingDialog(ctx, 'Loading...');
                  _acceptTripByOwner();
                },
                child: Text("YES", style: TextStyle(color: AppColor.secondaryColor1)),
              ),
            ],
          ),
        );
      },
    );
  }

/// Calls cloud function: acceptTripByOwner
///
/// Backend should handle:
/// - updating tripOperation / notification flags
/// - setting trip.isRead = false
/// - stamping trip.captain / trip.SIC / trip.attendant / trip.instructor (String)
///   based on membershipType (as per your recent Cloud Code change)
Future<void> _acceptTripByOwner() async {
  final ctx = Get.context;

  final notificationId = notification.objectId.trim();
  if (notificationId.isEmpty) {
    if (ctx != null) {
      await showMyDialog(ctx, "Missing tripNotificationId");
    }
    return;
  }

  try {
    // Call Parse Cloud Function
    final fn = ParseCloudFunction('acceptTripByOwner');

    final res = await fn.execute(parameters: {
      // IMPORTANT: use the param name your Cloud Code expects
      // If your cloud function expects `notificationId` instead, rename this key.
      'tripNotificationId': notificationId,
    });

    // Close loading loader
    Get.back();

    if (res.success != true) {
      final msg = res.error?.message ?? 'acceptTripByOwner failed';
      if (ctx != null) await showMyDialog(ctx, msg);
      return;
    }

    // Show success message if backend returns one
    final result = res.result;
    final successMsg = (result is Map && result['msg'] is String)
        ? (result['msg'] as String)
        : 'Trip accepted successfully';

    if (ctx != null) {
      await showMyDialog(ctx, successMsg);
    }

    dash.goBackToDashboardAndReloadTrips();
    // Go back to previous screen
    // Get.back();
  } catch (e) {
    // Close loader
    Get.back();
    if (ctx != null) {
      await showMyDialog(ctx, e.toString());
    }
  } finally {
    Acceptstopclikcing.value = false;
  }
}

void showAlertDialogOwnerCompleteTrip(String msg) {
    final ctx = Get.context!;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) {
        return Theme(
          data: ThemeData.dark(),
          child: CupertinoAlertDialog(
            content: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                msg,
                style: TextStyle(fontSize: 10.0.spV2, color: AppColor.textColor1),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("CANCEL", style: TextStyle(color: AppColor.secondaryColor1)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  showLoadingDialog(ctx, 'Completing...');
                  _completeTripByOwner();
                },
                child: Text("YES", style: TextStyle(color: AppColor.secondaryColor1)),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Calls cloud function: completeTrip
///
/// Cloud code will:
/// - Verify current user is the owner of the trip (via trip.ownerProfile.user)
/// - Set trip.isCompleted = true
/// - Find accepted tripOperation (isCrewAccepted == true AND isOwnerAccepted == true)
/// - Insert a tripNotification row (membershipType=3, type=3, message="Trip is completed.")
Future<void> _completeTripByOwner() async {
  final ctx = Get.context;

  // TripId is already available from tripDetails
  final tripId = (tripDetails.value?.trip.objectId ?? '').trim();
  if (tripId.isEmpty) {
    // Close loader (showLoadingDialog) if open
    Get.back();
    if (ctx != null) {
      await showMyDialog(ctx, "Missing tripId");
    }
    Acceptstopclikcing.value = false;
    return;
  }

  try {
    // Call Parse Cloud Function
    final fn = ParseCloudFunction('completeTrip');

    final res = await fn.execute(parameters: {
      'tripId': tripId,
    });

    // Close loading dialog
    Get.back();

    if (res.success != true) {
      final msg = res.error?.message ?? 'completeTrip failed';
      if (ctx != null) await showMyDialog(ctx, msg);
      return;
    }

    // Optional: show a success message
    if (ctx != null) {
      await showMyDialog(ctx, "Trip completed successfully");
    }

    // Optional: go back from Trip Summary screen
    Get.back();
  } catch (e) {
    // Close loader if still open
    if (Get.isOverlaysOpen) {
      Get.back();
    }
    if (ctx != null) {
      await showMyDialog(ctx, e.toString());
    }
  } finally {
    // Re-enable button taps
    Acceptstopclikcing.value = false;
  }
}

  /// ===== Firebase helpers =====
  // Future<void> _incUserCount(dynamic userId, String field) async {
  //   await FirebaseFirestore.instance
  //       .collection(appType.toString() == 'live'
  //           ? AppStrings.fireBaseUserlive
  //           : AppStrings.fireBaseUserlocal)
  //       .doc('$userId')
  //       .update({field: FieldValue.increment(1)});
  // }

  // Future<void> _decUserCount(dynamic userId, String field) async {
  //   await FirebaseFirestore.instance
  //       .collection(appType.toString() == 'live'
  //           ? AppStrings.fireBaseUserlive
  //           : AppStrings.fireBaseUserlocal)
  //       .doc('$userId')
  //       .update({field: FieldValue.increment(-1)});
  // }

  /// Best-effort: marks the passed notification as crew-read for the current user.
  /// - No loaders
  /// - No exceptions propagated
  /// - Safe to call even if notificationId is empty
  Future<void> _markNotificationReadIfNeeded() async {
    if (_didMarkNotificationRead.value == true) return;
    
    if (dash.selectedProfileType.value == MembershipType.ownerOperator){
      if (notification.isOwnerRead){
        debugPrint("_markNotificationReadIfNeeded: already read by owner, skipping");
        return;
      }
    } else {
      if (notification.isCrewRead){
        debugPrint("_markNotificationReadIfNeeded: already read by crew, skipping");
        return;
      }
    }

    final nid = notification.objectId.trim();
    if (nid.isEmpty) return;

    _didMarkNotificationRead.value = true;

    String functionName = 'markNotificationCrewRead';

    if (dash.selectedProfileType.value == MembershipType.ownerOperator){
      functionName = 'markNotificationOwnerRead';
    }

    try {
      final fn = ParseCloudFunction(functionName);
      final res = await fn.execute(parameters: {
        'notificationId': nid,
      });

      // Silent failure: do not show loader/snackbar here as per requirement.
      if (res.success != true) {
        debugPrint(
          'markNotificationCRead failed: ${res.error?.message ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      debugPrint('markNotificationRead exception: $e');
    }
  }
}
  String _formatNumber(double value) {
    // If whole number, remove decimal
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    // Otherwise, trim unnecessary trailing zeros
    return value.toStringAsFixed(2).replaceAll(RegExp(r"\.?0+$"), '');
  }