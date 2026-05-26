import 'package:crew_support/model/pilot_availability_service.dart';
import 'package:crew_support/database/airport_platform.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/AppColor.dart';

class AddAvailabilityController extends GetxController {
  /// Text controllers (kept in controller so state persists on navigation)
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final commentController = TextEditingController();
  final nearestAirportController = TextEditingController();
  final airportSearchController = TextEditingController();

  /// Reactive state
  final showCalendar = false.obs;
  final isLoading = false.obs;
  final currentDate = DateTime.now().obs;
  final selectedAirport = Rxn<AirportLite>();

  /// Data lists
  final airportResults = <AirportLite>[].obs;

  /// If needed later to block double-submit
  final stopClicking = false.obs;

  /// Keep a reference if you decide to use custom dismiss logic
  BuildContext? _dialogContext;

  @override
  void onInit() {
    super.onInit();
    _loadAirports();
  }

  // ---------------------------
  // Local airport search
  // ---------------------------
  Future<void> _loadAirports() async {
    isLoading.value = true;
    try {
      final all = await AirportCache.instance.searchByIdent('', limit: 200);
      airportResults.assignAll(all);
    } catch (e, st) {
      debugPrint('loadAirports error: $e');
      debugPrint('$st');

      // Optional if Crashlytics is enabled:
      await FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'AddAvailabilityScreen airport load failed',
      );

      showMyDialog(
        Get.context!,
        "Failed to load airports.\n\nDiagnostic: $e",
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchAirports(String query) async {
    try {
      final results = await AirportCache.instance.searchByIdent(query, limit: 200);
      airportResults.assignAll(results);
    } catch (e) {
      debugPrint('searchAirports error: $e');
      showMyDialog(Get.context!, "Failed to search airports. Please try again.");
    }
  }

  // ---------------------------
  // Date pickers
  // ---------------------------
  Future<void> selectFromDate() async {
    final ctx = Get.context!;
    final pickedDate = await showDatePicker(
      context: ctx,
      initialDate: currentDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (c, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColor.secondaryColor1,
              onPrimary: AppColor.textColor1,
              onSurface: AppColor.textColor1,
              surface: AppColor.bgColor2,
              background: AppColor.bgColor2,
            ),
            dialogBackgroundColor: AppColor.bgColor2,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      currentDate.value = pickedDate;
      final pickedStr = DateFormat('MM/dd/yyyy').format(pickedDate);
      fromController.text = pickedStr;
      // ensure "To" is cleared if now earlier than "From"
      toController.clear();
    }
  }

  Future<void> selectToDate() async {
    if (fromController.text.isEmpty) {
      showMyDialog(Get.context!, "Please select From date first!");
      return;
    }

    final base = currentDate.value;
    final ctx = Get.context!;
    final pickedDate = await showDatePicker(
      context: ctx,
      initialDate: base.add(const Duration(days: 1)),
      firstDate: base.add(const Duration(days: 1)),
      lastDate: DateTime(2050),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (c, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColor.secondaryColor1,
              onPrimary: AppColor.textColor1,
              onSurface: AppColor.textColor1,
              surface: AppColor.bgColor2,
              background: AppColor.bgColor2,
            ),
            dialogBackgroundColor: AppColor.bgColor2,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      currentDate.value = pickedDate;
      final pickedStr = DateFormat('MM/dd/yyyy').format(pickedDate);
      toController.text = pickedStr;
    }
  }

  // ---------------------------
  // Dialog helpers (optional)
  // ---------------------------
  void setDialogContext(BuildContext c) => _dialogContext = c;
  void dismissDialogIfAny() {
    if (_dialogContext != null) {
      Navigator.pop(_dialogContext!);
      _dialogContext = null;
    }
  }

  final DateFormat availabilityDateFormat = DateFormat("MM/dd/yyyy");

  DateTime? parseAvailabilityDate(String input) {
    if (input.trim().isEmpty) return null;
    try {
      return availabilityDateFormat.parseStrict(input);
    } catch (e) {
      print("Date parsing failed for '$input': $e");
      return null;
    }
  }

  // ---------------------------
  // Validation + Submit
  // ---------------------------
  Future<void> onSubmit() async {
    // ---------------------------
    // 1) Basic field validation BEFORE showing loader
    // ---------------------------
    if (fromController.text.isEmpty) {
      showMyDialog(Get.context!, "Please select from date");
      return;
    }
    if (toController.text.isEmpty) {
      showMyDialog(Get.context!, "Please select to date");
      return;
    }
    if (nearestAirportController.text.isEmpty || selectedAirport.value == null) {
      showMyDialog(Get.context!, "Please select nearest airport");
      return;
    }

    // ---------------------------
    // 2) Date parsing + logical checks (still BEFORE loader)
    // ---------------------------

    final fromText = fromController.text.trim();
    final toText = toController.text.trim();

    final from = parseAvailabilityDate(fromText);
    final to = parseAvailabilityDate(toText);

    if (from == null || to == null) {
      showMyDialog(Get.context!, "Invalid date format. Please use MM/dd/yyyy.");
      return;
    }

    if (from.isAfter(to)) {
      showMyDialog(Get.context!, "From Date cannot be after To Date.");
      return;
    }

    // ---------------------------
    // 3) All checks passed → now show loader
    // ---------------------------

    showLoadingDialog(Get.context!, 'Submitting...');
    try {
      final result = await AvailabilityService.createAvailability(
        isAvailability: showCalendar.value,
        fromDate: from,
        toDate: to,
        comment: commentController.text,
        airportCode: selectedAirport.value?.ident ?? '',
        latLong: selectedAirport.value != null
          ? LatLngValue(
              selectedAirport.value!.latitude,
              selectedAirport.value!.longitude,
            )
          : null,
      );

      // Always close loader here (no Get.isDialogOpen check,
      // because loader was opened with showDialog)
      Get.back();

      if (result.isSuccess) {
        // Optionally reload schedule or insert locally
        await showMyDialog(Get.context!, 'Availability saved successfully!').then((value){
          Get.back(); // pop AddAvailability screen
        });
      } else {
        // Overlap or logical issue → show result.message
        // CLOSE LOADING DIALOG FIRST
        if (Get.isDialogOpen ?? false) Get.back();
        debugPrint('Failed to create availability: ${result.message}');
        await showMyDialog(Get.context!, 'Failed to create availability: ${result.message}');
      }
      

      // if (kDebugMode) print(resp?.msg);

      // if (resp?.flag == 1) {
      //   // Keep legacy switchList update identical to old behavior
      //   for (int i = 0; i < switchList.length; i++) {
      //     if (switchList[i].pkPilotId.toString() == pkPilotId) {
      //       switchList.remove(switchList[i]);
      //     }
      //   }
      //   final p = resp!.data!.pilot!;
      //   switchList.add(Userdatum(
      //     pilotMname: p.pilotMname.toString(),
      //     emailId: p.emailId.toString(),
      //     workNumber: p.workNumber.toString(),
      //     newPassword: p.newPassword.toString(),
      //     pilotNname: p.pilotNname.toString(),
      //     photoPath: p.photoPath.toString(),
      //     cellNumber: p.cellNumber.toString(),
      //     timeOfInstruct: p.timeOfInstruct.toString(),
      //     companyName: p.companyName.toString(),
      //     fkMemberShipId: p.fkMemberShipId,
      //     currentLocation: p.currentLocation,
      //     pkPilotId: p.pkPilotId,
      //     memberShipType: p.memberShipType,
      //     totalTime: p.totalTime.toString(),
      //     pilotLname: p.pilotLname.toString(),
      //     oldPssword: p.oldPssword.toString(),
      //     pilotFname: p.pilotFname.toString(),
      //     cuLocCountry: p.cuLocCountry.toString(),
      //     availability: p.availability,
      //   ));

      //   // Persist updated switch list (same as legacy)
      //   await persistSwitchList(switchList);
      // }

    } catch (e) {
      // Ensure loader is closed even on error
      Get.back();
      debugPrint('insertAvailability error: $e');
      showMyDialog(Get.context!, "Something went wrong. Please try again.");
    }
  }

  /// Legacy-compatible persistence extracted into helper for clarity
  // Future<void> persistSwitchList(List<Userdatum> list) async {
  //   // In the old screen this used SharedPreferences directly.
  //   // Keep the identical behavior so other legacy parts work unchanged.
  //   // NOTE: If you already centralize this, feel free to replace with your helper.
  //   // We can't import SharedPreferences here to keep controller slim for tests.
  //   //TODO:
  //   // await saveSwitchListToPrefs(list);
  // }

  @override
  void onClose() {
    fromController.dispose();
    toController.dispose();
    commentController.dispose();
    nearestAirportController.dispose();
    airportSearchController.dispose();
    super.onClose();
  }
}

class AddAvailabilityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddAvailabilityController>(() => AddAvailabilityController());
  }
}