import 'package:crew_support/database/airport_code_model.dart';
import 'package:crew_support/model/pilot_availability_service.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EditAvailabilityController extends GetxController {
  /// Text controllers for all fields
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final TextEditingController nearestAirportController = TextEditingController();
  final TextEditingController airportSearchController = TextEditingController();

  /// Date related fields
  DateTime currentDate = DateTime.now();
  late DateTime minDate;
  late DateTime maxDate;
  late DateTime forDate;
  late DateTime toDate;

  /// Availability item passed from previous screen
  late AvailabilityItem availability;

  /// Lists and flags for states and cities
  final RxList<AirportLite> airportResults = <AirportLite>[].obs;
  final selectedAirport = Rxn<AirportLite>();

  /// Reactive flags
  final RxBool isLoading = false.obs;
  final RxBool isDefault = false
      .obs; // Show calendar to operators? (true = Yes, false = No) (same as old isAvailability)
  final RxBool isPressed = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Expecting arguments from Get.toNamed:
    // {
    //   'minDate': DateTime,
    //   'maxDate': DateTime,
    //   'availability': AllAvailList
    // }
    final args = Get.arguments as Map<String, dynamic>? ?? {};

    minDate = args['minDate'] as DateTime? ?? DateTime.now();
    maxDate = args['maxDate'] as DateTime? ?? DateTime(2050);
    availability = args['availability'] as AvailabilityItem;

    _initFromAvailability();
    _loadAirports();
  }

  /// Initialise controller fields from the passed availability object
  void _initFromAvailability() {
    forDate = DateTime.parse(availability.fromDate.toString());
    toDate = DateTime.parse(availability.toDate.toString());

    // fromController.text = DateFormat('MM/dd/yyyy')
    //     .format(DateTime.parse(availability.fromDate!.split("T").first));
    // toController.text = DateFormat('MM/dd/yyyy')
    //     .format(DateTime.parse(availability.toDate!.split("T").first));

    fromController.text = DateFormat('MM/dd/yyyy').format(DateTime.parse(availability.fromDate.toString()));
    toController.text = DateFormat('MM/dd/yyyy').format(DateTime.parse(availability.toDate.toString()));

    commentController.text = availability.comment?.toString() ?? "";
    nearestAirportController.text = availability.airportCode?.toString() ?? "";

    // Old code: isDefault = widget.availability.isAvailability as bool;
    isDefault.value = availability.isAvailability ?? false;

    print('Edit availability -> pkAvailabilityId: ${availability.id}');
    print('Edit availability -> fromDate: ${availability.fromDate}');
    print('Edit availability -> toDate: ${availability.toDate}');

    currentDate = forDate;

    final initialAirportCode = availability.airportCode?.trim() ?? '';
    if (initialAirportCode.isNotEmpty) {
      AirportCache.instance.searchByIdent(initialAirportCode, limit: 50).then((results) {
        try {
          final match = results.firstWhere(
            (a) => a.ident.toLowerCase() == initialAirportCode.toLowerCase(),
          );
          selectedAirport.value = match;
          nearestAirportController.text =
              '${match.ident} ${match.name}, ${match.municipality}, ${match.region}';
        } catch (_) {
          nearestAirportController.text = initialAirportCode;
        }
      });
    }
  }

  /// Date picker for "From" date
  Future<void> selectFromDate() async {
    final ctx = Get.context;
    if (ctx == null) return;

    final DateTime? pickedDate = await showDatePicker(
      context: ctx,
      initialDate: forDate.isBefore(DateTime.now()) ? DateTime.now() : forDate,
      firstDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      lastDate: DateTime(2050),
      builder: (dialogContext, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.dark(
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

    if (pickedDate != null && pickedDate != currentDate) {
      currentDate = pickedDate;
      fromController.text =
          DateFormat('MM/dd/yyyy').format(DateTime.parse(pickedDate.toString()));
      // When from date changes, to date should be cleared
      toController.clear();
    }
  }

  /// Date picker for "To" date
  Future<void> selectToDate() async {
    final ctx = Get.context;
    if (ctx == null) return;

    final DateTime? pickedDate = await showDatePicker(
      context: ctx,
      initialDate: toDate,
      firstDate: currentDate,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      lastDate: DateTime(2050),
      builder: (dialogContext, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.dark(
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

    if (pickedDate != null && pickedDate != currentDate) {
      currentDate = pickedDate;
      toController.text =
          DateFormat('MM/dd/yyyy').format(DateTime.parse(pickedDate.toString()));
    }
  }

  Future<void> _loadAirports() async {
    isLoading.value = true;
    try {
      final all = await AirportCache.instance.searchByIdent('', limit: 200);
      airportResults.assignAll(all);
    } catch (e) {
      debugPrint('loadAirports error: $e');
      final ctx = Get.context;
      if (ctx != null) {
        showMyDialog(ctx, "Failed to load airports. Please try again.");
      }
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
      final ctx = Get.context;
      if (ctx != null) {
        showMyDialog(ctx, "Failed to search airports. Please try again.");
      }
    }
  }

  /// Toggle show-calendar flag (Yes / No)
  void setShowCalendar(bool value) {
    isDefault.value = value;
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

  /// Submit handler (corresponds to old SUBMIT button onPressed)
  Future<void> submit() async {
    final ctx = Get.context;
    if (ctx == null) return;

    // Validation logic is kept identical to old code
    if (fromController.text.isEmpty) {
      showMyDialog(ctx, "Please select from date");
      return;
    } else if (toController.text.isEmpty) {
      showMyDialog(ctx, "Please select to date");
      return;
    } else if (nearestAirportController.text.isEmpty) {
      showMyDialog(ctx, "Please select nearest airport");
      return;
    }

    debugPrint('availableId ${availability.id}');
    debugPrint('fkPilotid $pkPilotId');
    debugPrint('commentText ${commentController.text}');
    debugPrint('fromDate ${fromController.text}');
    debugPrint('toDate ${toController.text}');
    debugPrint('airportCode ${selectedAirport.value?.ident ?? nearestAirportController.text}');
    debugPrint('isAvailability ${isDefault.value}');
    debugPrint('isUpdate ${true}');
    debugPrint('isDelete ${false}');

    try {

      // Parse dates back from text fields
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

      // Show "Submitting..." dialog (same as old code)
      showLoadingDialog(ctx, 'Submitting...');

      final result = await AvailabilityService.updatePilotAvailability(
        availabilityId: availability.id,
        fromDate: from,
        toDate: to,
        // Use the current UI toggle value (Yes/No) instead of the original availability value.
        isAvailability: isDefault.value,
        comment: commentController.text.trim(),
        airportCode: selectedAirport.value?.ident ?? nearestAirportController.text.trim(),
        latLong: selectedAirport.value != null
            ? LatLngValue(
                selectedAirport.value!.latitude,
                selectedAirport.value!.longitude,
              )
            : availability.latLong,
      );

      // final value = await updateAvailability(
      //   fromDate: fromController.text,
      //   toDate: toController.text,
      //   city: cityController.text,
      //   State: stateController.text,
      //   commentText: commentController.text,
      //   availableId: 1,
      //   isUpdate: true,
      //   isDelete: false,
      //   available: isDefault.value,
      //   zip: zipCodeController.text.toString(),
      // );

      // print(value?.msg);

      EasyLoading
          .dismiss(); // In case EasyLoading is used anywhere else globally

      // Dismiss "Submitting..." dialog
      Get.back();

      if (!result.isSuccess) {
        showMyDialog(
          Get.context!,
          result.message ?? "Failed to update availability.",
        );
        return;
      }

      // Show message and then pop this screen (same behaviour)
      await showMyDialog(Get.context!, "Availability updated successfully!").then((value){
        Get.back(); // pop EditAvailability screen
      });
    } catch (e) {
      print('Error updating availability: $e');
      EasyLoading.dismiss();
      // Ensure dialog is closed if something failed after opening it
      // if (Get.isOverlaysOpen) {
        Get.back();
      // }
      await showMyDialog(ctx, "Failed to update availability: $e");
    }
  }

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

class EditAvailabilityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditAvailabilityController>(() => EditAvailabilityController());
  }
}