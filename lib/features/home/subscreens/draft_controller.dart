import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/home/subscreens/shared/owner_trips_tab_controller.dart';
import 'package:crew_support/model/trip_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// DraftController
/// --------------
/// Owner trips tab controller bound to DashboardController.ownerDraftTrips.
class DraftController extends OwnerTripsTabController {
  @override
  String get tabName => 'DraftController';

  @override
  RxList<TripModel> get dashboardTrips => dash.draftTrips;

  /// Backwards-compatible name used by DraftScreen
  Future<void> refreshDraftTrips() => refreshTrips();

  /// Confirms and deletes a draft trip from the Draft tab.
  ///
  /// Returning `false` keeps the Dismissible item in place. Returning `true`
  /// allows the row to animate out after the draft has been removed locally.
  ///
  /// The row is removed locally only after the server confirms that the draft
  /// trip and its related rows/files were deleted successfully.
  Future<bool> confirmAndDeleteDraftTrip(TripModel trip) async {
    final bool shouldDelete = await showCupertinoDialog<bool>(
          context: Get.context!,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Delete draft?'),
              content: const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'This draft trip will be removed from your drafts.',
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete) return false;

    final String? tripId = trip.objectId;

    if (tripId == null || tripId.isEmpty) {
      showMyDialog(Get.context!, 'Unable to delete this draft trip. Trip ID is missing.');
      return false;
    }

    final BuildContext? loaderContext = Get.context;
    bool loaderShown = false;

    if (loaderContext != null) {
      // Show a blocking loader while the Cloud Function deletes the draft,
      // its related rows, and its requirements file from Parse.
      showLoadingDialog(loaderContext, 'Deleting draft...');
      loaderShown = true;
    }

    try {
      final ParseCloudFunction function = ParseCloudFunction('deleteDraftTrip');
      final ParseResponse response = await function.execute(
        parameters: <String, dynamic>{
          'tripId': tripId,
        },
      );

      if (response.success != true) {
        final String errorMessage = response.error?.message ??
            'Unable to delete this draft trip. Please try again.';
        showMyDialog(Get.context!, errorMessage);
        return false;
      }

      dashboardTrips.removeWhere((item) => item.objectId == tripId);
      trips.removeWhere((item) => item.objectId == tripId);

      return true;
    } catch (e) {
      showMyDialog(Get.context!, 'Unable to delete this draft trip. Please try again.');
      debugPrint('[DraftController] deleteDraftTrip failed: $e');
      return false;
    } finally {
      if (loaderShown) {
        // Do not depend on Get.isDialogOpen here because showLoadingDialog may
        // use Flutter's root Navigator instead of a Get-tracked dialog.
        Navigator.of(loaderContext!, rootNavigator: true).pop();
      }
    }
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

  void navigateToCreateTrip(TripModel? trip) {
    Get.toNamed(
      AppRoutes.createTrip,
      arguments: {
        'fromDraftTab': true,
        'trip': trip, // null for new trip, else edit existing
      },
    );
  }

  void navigateToRequiredExperience(TripModel trip){

    List<String> roles = <String>[];

    if (trip.isCaptain) {
      roles.add("Captain");
    }
    if (trip.isSIC){
      roles.add("Second In Command");
    }
    if (trip.isAttendant){
      roles.add("Flight Attendant");
    }
    if (trip.isInstructor){
      roles.add("Flight Instructor");
    }

          if (trip.isCaptain) {
            Get.toNamed(
              AppRoutes.requiredExperienceCaptain,
              arguments: {
                'boolCAP': trip.isCaptain,
                'miles': trip.radius.toString(),
                'selectList': roles,
                'tripId': trip.objectId,
                'boolSIC': trip.isSIC,
                'boolFA': trip.isAttendant,
                'boolFI': trip.isInstructor,
                // 'airCraftID': airId,
                'ratingAirCraftType': trip.aircraft,
                'startDate': _formatDate(trip.startDate),
                'endDate': _formatDate(trip.endDate),
              },
            );
          } else if (trip.isSIC) {
            Get.toNamed(
              AppRoutes.requiredExperienceSIC,
              arguments: {
                'miles': trip.radius.toString(),
                'selectList': roles,
                'tripId': trip.objectId,
                'boolSIC': trip.isSIC,
                'boolFA': trip.isAttendant,
                'boolFI': trip.isInstructor,
                // 'airCraftID': airId,
                'ratingAirCraftType': trip.aircraft,
                'startDate': _formatDate(trip.startDate),
                'endDate': _formatDate(trip.endDate),
              },
            );
          } else if (trip.isAttendant) {
            Get.toNamed(
              AppRoutes.requiredExperienceFA,
              arguments: {
                'selectList': roles,
                'radiusValue': trip.radius,
                'tripId': trip.objectId,
                // 'airCraftID': airId,
                'boolFI': trip.isInstructor,
                'startDate': _formatDate(trip.startDate),
                'endDate': _formatDate(trip.endDate),
              },
            );
          } else if (trip.isInstructor) {
            // Get.toNamed(
            //   AppRoutes.requiredExperienceFI,
            //   arguments: RequiredExperienceFIArgs(
            //     selectList: roles,      // as per your flow
            //     tripId: tripIdArg,                   // 0 => new, else => edit
            //     airCraftID: airId ?? 0,
            //     radiusValue: milesArg,         // string
            //     backbutton: false,                // or true to lock back
            //   ),
            // );


            // Get.toNamed(
            //   AppRoutes.requiredExperienceFI,
            //   arguments: {
            //     'radiusValue': milesArg,
            //     'selectList': roles,
            //     'airCraftID': airId,
            //     'tripId': tripIdArg,
            //   },
            // );
          } else {
            showMyDialog(Get.context!, "No matching role found!");
          }
  }
}