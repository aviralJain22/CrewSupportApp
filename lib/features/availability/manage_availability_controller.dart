// lib/features/availability/manage_availability_controller.dart
// Converts old manage_available_screen.dart logic into a GetX controller.
// Keeps UI behaviour identical while moving logic/state here.

import 'package:crew_support/app/routes.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:crew_support/database/airport_code_model.dart';


import '../../model/pilot_availability_service.dart'; // showLoadingDialog, showMyDialog

class ManageAvailabilityController extends GetxController {
  /// Tabs + loading
  final isLoading = true.obs;
  final isCurrent = true.obs;
  final isFuture = false.obs;

  /// Server data holder
  final availabilityList = <AvailabilityItem>[].obs;
  final airportByCode = <String, AirportLite>{}.obs;

  /// Convenience getters to avoid null checks in UI
  List<AvailabilityItem> get all => availabilityList;
  List<AvailabilityItem> get currentList =>
      all.where((e) => (e.isCurrent) == true).toList();
  List<AvailabilityItem> get futureList =>
      all.where((e) => (e.isFuture) == true).toList();

  @override
  void onInit() {
    super.onInit();
    getAvailData();
  }

  /// Fetch availability for logged-in pilot
  Future<void> getAvailData() async {
    isLoading.value = true;
    try {
      final list = await AvailabilityService.getPilotAvailabilitySchedule();
      debugPrint("list: $list");
      debugPrint("availabilityList before: $availabilityList");
      debugPrint("all before: $all");
      debugPrint("currentList before: $currentList");
      debugPrint("futureList before: $futureList");
      availabilityList.assignAll(list);
      await _preloadAirportsForAvailability(list);
      // debugPrint("item: ${all[0].toString()}");
      debugPrint("availabilityList after: $availabilityList");
      debugPrint("all after: $all");
      debugPrint("currentList after: $currentList");
      debugPrint("futureList after: $futureList");
    } catch (e) {
      // handle error (snackbar, dialog, etc.)
      debugPrint('getAvailData error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _preloadAirportsForAvailability(List<AvailabilityItem> items) async {
    final uniqueCodes = items
        .map((e) => e.airportCode?.trim() ?? '')
        .where((code) => code.isNotEmpty)
        .toSet();

    for (final code in uniqueCodes) {
      if (airportByCode.containsKey(code)) continue;

      try {
        final airport = await getAirportFromCode(code);
        if (airport != null) {
          airportByCode[code] = airport;
        }
      } catch (e) {
        debugPrint('preload airport failed for code=$code error=$e');
      }
    }
  }

  Future<AirportLite?> getAirportFromCode(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return null;

    final results = await AirportCache.instance.searchByIdent(trimmed, limit: 10);
    try {
      return results.firstWhere(
        (a) => a.ident.toLowerCase() == trimmed.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Switch tabs (exactly like legacy two-segment toggle)
  void setTab(bool toCurrent) {
    isCurrent.value = toCurrent;
    isFuture.value = !toCurrent;
  }

  /// Compute min(fromDate) and max(toDate) across all items.
  /// The legacy code used 1700-* sentinel dates when empty;
  /// keep identical behaviour so Add/Edit date limits remain the same.
  ({DateTime minDate, DateTime maxDate}) computeMinMaxDates() {
    final maxDateList = <DateTime>[];
    final minDateList = <DateTime>[];

    // Collect all non-null from/to dates
    for (final a in all) {
      if (a.toDate != null) {
        maxDateList.add(DateTime.parse(a.toDate.toString()));
      }
      if (a.fromDate != null) {
        minDateList.add(DateTime.parse(a.fromDate.toString()));
      }
    }

    // If there are no dates (either because list is empty or all dates are null),
    // fall back to the legacy sentinel dates so Add/Edit limits behave the same.
    if (maxDateList.isEmpty) {
      maxDateList.add(DateTime.parse("1700-02-02"));
    }
    if (minDateList.isEmpty) {
      minDateList.add(DateTime.parse("1700-02-03"));
    }

    final maxDates = maxDateList.reduce((a, b) => a.isAfter(b) ? a : b);
    final minDates = minDateList.reduce((a, b) => a.isBefore(b) ? a : b);

    return (minDate: minDates, maxDate: maxDates);
  }

  /// Navigate to Add Availability (named route) with legacy arguments
  Future<void> goToAddAvailability() async {
    final limits = computeMinMaxDates();
    await Get.toNamed(
      AppRoutes.addAvailability, // define in your routes.dart
      arguments: {
        'maxDate': limits.maxDate,
        'minDate': limits.minDate,
      },
    );
    await getAvailData(); // refresh after return
  }

  /// Navigate to Edit Availability (named route) with legacy arguments
  Future<void> goToEditAvailability(AvailabilityItem item) async {
    // compute limits exactly like legacy before pushing Edit
    final limits = computeMinMaxDates();
    await Get.toNamed(
      AppRoutes.editAvailability, // define in your routes.dart
      arguments: {
        'maxDate': limits.maxDate,
        'minDate': limits.minDate,
        'availability': item,
      },
    );
    await getAvailData(); // refresh after return
  }

  /// Delete availability with the same API + switchList update flow
  Future<void> confirmAndDelete(AvailabilityItem item) async {
    // We keep the dialog UI in the screen; this method does the work
    // after user taps "Yes"—so that controller can be unit-tested easily.
    final ctx = Get.context!;
    showLoadingDialog(ctx, "Deleting...");
    try {
      
      final result = await AvailabilityService.deletePilotAvailability(item.id);

      // Close loading
      Get.back();

      if (!result.isSuccess) {
        showMyDialog(Get.context!, result.message ?? "Could not delete entry.");
        return;
      }

      await showMyDialog(ctx, "Availability deleted successfully");
      await getAvailData();

    } catch (e) {
      // Close loading
      Get.back();
      debugPrint("deleteAvailability error: $e");
      showMyDialog(Get.context!, "Something went wrong while deleting.");
      rethrow;
    }
  }

}

/// Binding for this feature
class ManageAvailabilityBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ManageAvailabilityController());
  }
}