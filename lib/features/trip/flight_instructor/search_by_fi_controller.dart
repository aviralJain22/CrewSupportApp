// ignore_for_file: avoid_print

import 'package:crew_support/app/routes.dart';
import 'package:crew_support/model/FilterPilotResponse.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:get/get.dart';
import 'package:crew_support/Api/Api_service.dart';
import 'package:crew_support/utils/AppColor.dart'; // (kept for parity if colors needed here)
import 'package:crew_support/utils/constants.dart'; // for pkPilotId, etc.
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Controller for "Search by - FI"
/// Mirrors the old screen's behavior while splitting logic out of the UI.
class SearchByFIController extends GetxController {
  // -------- Incoming arguments (copied from old widget constructor) ----------
  late final List<String> selectList;
  late final String totalTime;
  late final String daulGiven;
  late final String complexTime;
  late final String highTime;
  late final String instrumentInstruct;
  late final String multiEngine;
  late final String tailWheel;
  late final String aerobatic;
  late final int tripId;
  late final String rate;
  late final int airCraftID;
  late final int ratingCount;
  late final String radiusValue;
  late final bool isTripOutOfDate;
  final String? startDate;
  final String? endDate;
  final String? oldCrewMemberId;
  final String? membershipId;

  SearchByFIController({
    required this.selectList,
    required this.totalTime,
    required this.daulGiven,
    required this.aerobatic,
    required this.tailWheel,
    required this.complexTime,
    required this.highTime,
    required this.instrumentInstruct,
    required this.multiEngine,
    required this.airCraftID,
    required this.rate,
    required this.tripId,
    required this.ratingCount,
    required this.radiusValue,
    required this.isTripOutOfDate,
    this.startDate,
    this.endDate,
    this.oldCrewMemberId,
    this.membershipId,
  });

  // ------------------------- UI State (reactive) -----------------------------
  final isNear = false.obs;
  final isFavorite = false.obs;
  final isAvailable = false.obs;
  final notAvailable = false.obs;

  // Flags derived from getTripDetail() to pass to Result screen
  final captain = false.obs;
  final sic = false.obs; // second in command
  final fa = false.obs;  // flight attendant
  final fi = false.obs;  // flight instructor

  final dataComplete = false.obs;

  // ----------------------------- Lifecycle ----------------------------------
  @override
  void onInit() {
    super.onInit();
    _getTripData();
  }

  // Fetch trip details (same as old initState->getData)
  void _getTripData() {
    // getTripDetail(tripId: tripId, pilotId: pkPilotId.toString()).then((value) {
    //   if (value?.data?.trip.isNotEmpty == true) {
    //     final t = value!.data!.trip[0];
    //     print("captain -- ${t.captain}");
    //     print("secondInCommand -- ${t.secondInCommand}");
    //     print("flightAttendant -- ${t.flightAttendant}");
    //     print("flightInstructor -- ${t.flightInstructor}");
    //     captain.value = t.captain;
    //     sic.value = t.secondInCommand;
    //     fa.value = t.flightAttendant;
    //     fi.value = t.flightInstructor;
    //     dataComplete.value = true;
    //   } else {
    //     dataComplete.value = false;
    //   }
    // }).catchError((e) {
    //   print("getTripDetail() error: $e");
    //   dataComplete.value = false;
    // });
  }

  // ---------------------------- Actions -------------------------------------
  void toggleNear() => isNear.value = !isNear.value;
  void toggleFavorite() => isFavorite.value = !isFavorite.value;
  void toggleAvailable() => isAvailable.value = !isAvailable.value;
  void toggleNotAvailable() => notAvailable.value = !notAvailable.value;

  Future<List<Map<String, dynamic>>> fetchUsersByMembershipTypeViaCloud() async {
    final function = ParseCloudFunction('getUsersByMembershipType');
    // final resp = await function.execute(parameters: {}); // no params needed here

    final resp = await function.execute(parameters: {
      'membershipType': 2,     // <-- int
      'limit': 10000,            // optional
      'page': 0,               // optional
      // 'order': 'firstName',    // optional; "-firstName" for DESC
    });

    if (resp.success && resp.result is List) {
      return List<Map<String, dynamic>>.from(resp.result);
    }
    // Log error detail for debugging
    print('Cloud function error: ${resp.error?.message}');
    return [];
  }

  /// Validates selection and performs the API call from the old onTapNext()
  Future<void> onTapNext() async {
    if (!isNear.value && !isFavorite.value && !isAvailable.value && !notAvailable.value) {
      await showMyDialog(Get.context!, "Please select atleast one option");
      return;
    }

    showLoadingDialog(Get.context!, 'Searching...');
    try {
      //TODO:
      // final resp = await filterFlightInstructor(
      //   searchAll: notAvailable.value,
      //   tripId: tripId,
      //   totalTime: totalTime,
      //   daulGiven: daulGiven,
      //   instrumentInstruct: instrumentInstruct,
      //   tailWheel: tailWheel,
      //   aerobatic: aerobatic,
      //   multiEngine: multiEngine,
      //   complexTime: complexTime,
      //   highTime: highTime,
      //   airCraftId: airCraftID,
      //   rate: rate,
      //   miles: radiusValue.toString(),
      //   isFavorite: isFavorite.value,
      //   isAvailable: isAvailable.value,
      //   ratingCount: ratingCount.toString(),
      //   isNearest: isNear.value,
      //   startDate: startDate,
      //   endDate: endDate,
      // );

      List<Map<String, dynamic>> users = await fetchUsersByMembershipTypeViaCloud();
      List<AppUser> userList = users.map((e) => AppUser.fromMap(e)).toList();
      debugPrint("users fetched: ${userList.length}");

      // Close loading dialog
      if (Get.isDialogOpen == true) Get.back();

      //Uncomment this if else statement
      // if (resp?.msg != null && dataComplete.value == true) {

        //TODO:
        // Navigate to Result (named route recommended)
        Get.toNamed(
          AppRoutes.resultFI, // <-- define in routes
          arguments: {
            'miles': radiusValue,
            'selectList': selectList,
            'boolFA': fa.value,
            'boolSIC': sic.value,
            'boolCAP': captain.value,
            'boolFI': fi.value,
            //TODO: Uncomment this:
            // 'filterData': resp?.data,
            'filterData': userList,
            'rate': rate,
            'tripId': tripId,
            'airCraftID': airCraftID,
            'isTripOutOfDate': isTripOutOfDate,
            'startDate': startDate,
            'endDate': endDate,
            'membershipId': membershipId,
            'oldCrewMemberId': oldCrewMemberId,
          },
        );
      // } else {
      //   await showMyDialog(Get.context!, 'Please change the data and try again.');
      // }
    } catch (e) {
      // Close loading if still open, then show error dialog
      if (Get.isDialogOpen == true) Get.back();
      print("filterFlightInstructor() error: $e");
      await showMyDialog(Get.context!, 'Something went wrong. Please try again.');
    }
  }
}

/// Binding to lazily put the controller from route arguments
class SearchByFIBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;

    Get.lazyPut<SearchByFIController>(() => SearchByFIController(
          selectList: (args['selectList'] as List<dynamic>).cast<String>(),
          totalTime: args['totalTime'] as String,
          daulGiven: args['daulGiven'] as String,
          aerobatic: args['aerobatic'] as String,
          tailWheel: args['tailWheel'] as String,
          complexTime: args['complexTime'] as String,
          highTime: args['highTime'] as String,
          instrumentInstruct: args['instrumentInstruct'] as String,
          multiEngine: args['multiEngine'] as String,
          airCraftID: args['airCraftID'] as int,
          rate: args['rate'] as String,
          tripId: args['tripId'] as int,
          ratingCount: args['ratingCount'] as int,
          radiusValue: args['radiusValue'] as String,
          isTripOutOfDate: (args['isTripOutOfDate'] as bool?) ?? false,
          startDate: args['startDate'] as String?,
          endDate: args['endDate'] as String?,
          membershipId: args['membershipId'] as String?,
          oldCrewMemberId: args['oldCrewMemberId'] as String?,
        ));
  }
}