// lib/features/trip/flight_instructor/result_fi_controller.dart
// Controller for "Results - FI" screen (converted from old ResultFIScreen.dart)

import 'package:crew_support/model/FilterPilotResponse.dart';
import 'package:get/get.dart';

import 'package:crew_support/Api/Api_service.dart'; // NEW path
import 'package:crew_support/utils/Utility.dart'; // for showLoadingDialog, showMyDialog
import 'package:crew_support/helper/user_helper.dart'; // NEW path
import 'package:crew_support/utils/constants.dart';

import '../../../model/FilterFIResponse.dart';
import '../../../model/TripDetailsResponse.dart';

class ResultFiController extends GetxController {
  /// --------- INPUTS (from navigation arguments) ----------
  /// All values map 1:1 with the old StatefulWidget fields
  // final Data? filterData;
  final List<AppUser> filterData;
  final int tripId;
  final int airCraftID;
  final bool boolCAP;
  final String miles;
  final bool boolSIC;
  final bool boolFA;
  final bool boolFI;
  final dynamic rate;
  final List<String> selectList;
  final bool? isTripOutOfDate;
  final String? startDate;
  final String? endDate;
  final String? oldCrewMemberId;
  final String? membershipId;

  /// --------- STATE ----------
  final RxList<String> pilotChecked = <String>[].obs;
  final RxBool stopClicking = false.obs;
  final RxBool backButtonEnabled = false.obs;
  final RxBool isTripOutOfDateRx = false.obs;

  TripDetailsData? tripDetails;

  /// live/local app type (used for Firebase collection names)
  final String appType = UserHelper().getAppType().toString();

  ResultFiController({
    required this.filterData,
    required this.tripId,
    required this.airCraftID,
    required this.boolCAP,
    required this.miles,
    required this.boolSIC,
    required this.boolFA,
    required this.boolFI,
    required this.rate,
    required this.selectList,
    this.isTripOutOfDate,
    this.startDate,
    this.endDate,
    this.oldCrewMemberId,
    this.membershipId,
  });

  /// Quick factory to build controller from Get.arguments safely
  factory ResultFiController.fromArgs() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    return ResultFiController(
      filterData: args['filterData'] as List<AppUser>,
      // filterData: args['filterData'] as Data?,
      tripId: args['tripId'] as int,
      airCraftID: args['airCraftID'] as int,
      boolCAP: args['boolCAP'] as bool,
      miles: args['miles'] as String,
      boolSIC: args['boolSIC'] as bool,
      boolFA: args['boolFA'] as bool,
      boolFI: args['boolFI'] as bool,
      rate: args['rate'],
      selectList: (args['selectList'] as List<dynamic>).cast<String>(),
      isTripOutOfDate: args['isTripOutOfDate'] as bool?,
      startDate: args['startDate'] as String?,
      endDate: args['endDate'] as String?,
      oldCrewMemberId: args['oldCrewMemberId'] as String?,
      membershipId: args['membershipId'] as String?,
    );
  }

  @override
  void onInit() {
    super.onInit();
    isTripOutOfDateRx.value = isTripOutOfDate ?? false;

    // Old code called UserHelper().getPendingDetail() in didChangeDependencies
    // We can safely do it here once.
    UserHelper().getPendingDetail();
  }

  /// Toggle a pilot selection (checkbox)
  void onSelected(bool selected, String id) {
    if (selected) {
      if (!pilotChecked.contains(id)) pilotChecked.add(id);
    } else {
      pilotChecked.remove(id);
    }
  }

  /// Bottom bar "Delete Trip" flow → shows confirm, then calls deleteDraft
  Future<void> confirmAndDeleteTrip() async {
    // The actual CupertinoAlertDialog UI lives in the screen (to match old code),
    // but the API call is handled here.
    await deleteDraft(tripId);
  }

  //TODO:
  /// Build the Firebase collection name based on appType
  // String get usersCollection =>
  //     appType == 'live' ? AppStrings.fireBaseUserlive : AppStrings.fireBaseUserlocal;

  // String get tripsCollection =>
  //     appType == 'live' ? AppStrings.fireBaseTripslive : AppStrings.fireBaseTripslocal;

  /// Common Firestore increments for notifications/pending counts
  Future<void> _bumpCountersFor(int pilotId) async {
    //TODO;
    // Increment pending count for the *receiver* (pilot)
    // await FirebaseFirestore.instance
    //     .collection(usersCollection)
    //     .doc('$pilotId')
    //     .update({'pendingCount': FieldValue.increment(1)});

    // // Trip count: "<receiver> - <sender>"
    // try {
    //   final docTrip = FirebaseFirestore.instance
    //       .collection(tripsCollection)
    //       .doc('$tripId')
    //       .collection('tripCount')
    //       .doc('$pilotId - $pkPilotId');

    //   final snap = await docTrip.get();
    //   if (snap.exists) {
    //     await docTrip.update({'notificationCount': FieldValue.increment(1)});
    //   } else {
    //     await docTrip.set({'notificationCount': 1});
    //   }
    // } on FirebaseException catch (e) {
    //   // ignore: avoid_print
    //   print(e);
    // }

    // Reverse doc: "<sender> - <receiver>" set 0
    // try {
    //   final docTrip = FirebaseFirestore.instance
    //       .collection(tripsCollection)
    //       .doc('$tripId')
    //       .collection('tripCount')
    //       .doc('$pkPilotId - $pilotId');

    //   final snap = await docTrip.get();
    //   if (snap.exists) {
    //     await docTrip.update({'notificationCount': 0});
    //   } else {
    //     await docTrip.set({'notificationCount': 0});
    //   }
    // } on FirebaseException catch (e) {
    //   // ignore: avoid_print
    //   print(e);
    // }
  }

  /// After sending notification, also increment pending for *sender* (you)
  Future<void> _bumpSenderPending() async {
    //TODO:
    // await FirebaseFirestore.instance
    //     .collection(usersCollection)
    //     .doc('$pkPilotId')
    //     .update({'pendingCount': FieldValue.increment(1)});
  }

  /// Fetch trip details and mark notification as updated
  Future<void> _updateTripNotificationFor(int oppositeId) async {
    final res = await getTripDetailMultiplePilot(
      MemberType: "Pilot",
      tripId: tripId,
      oppositeId: oppositeId,
    );
    tripDetails = res?.data;
    if (tripDetails?.summary.isNotEmpty == true) {
      final notifId = tripDetails!.summary[0].pkTripNotificationId.toString();
      await updateTripNotification(TripId: tripId, NotificationId: notifId);
    }
  }

  /// Main action: Send Trip Request (new trip)
  Future<void> sendTripRequestNew({
    required void Function() onBefore,
    required void Function(String msg) onSuccess,
    required void Function(Object e) onError,
  }) async {
    // if (pilotChecked.isEmpty) throw 'Please select flight instructor';

    // onBefore();
    // try {
    //   final value = await sendNotification(
    //     SICNumber: "",
    //     filterPilotId: pilotChecked.join(","),
    //     tripId: tripId,
    //     rate: rate,
    //   );

    //   // for (final pid in pilotChecked) {
    //   //   await _updateTripNotificationFor(pid);
    //   //   await _bumpCountersFor(pid);
    //   // }
    //   await _bumpSenderPending();

    //   onSuccess(value?.msg ?? 'Request sent');
    // } catch (e) {
    //   onError(e);
    // }
  }

  /// Main action: Send Trip Request (edit flow)
  Future<void> sendTripRequestEdit({
    required void Function() onBefore,
    required void Function(String msg) onSuccess,
    required void Function(Object e) onError,
  }) async {
    if (pilotChecked.isEmpty) throw 'Please select flight instructor';

    // onBefore();
    // try {
    //   final value = await sendNotification(
    //     SICNumber: "",
    //     filterPilotId: pilotChecked.join(","),
    //     tripId: tripId,
    //     membershipId: membershipId,
    //     isEdit: true,
    //     startDate: startDate,
    //     endDate: endDate,
    //     oldCrewMemberId: oldCrewMemberId,
    //     rate: rate,
    //   );

    //   // for (final pid in pilotChecked) {
    //   //   await _updateTripNotificationFor(pid);
    //   //   await _bumpCountersFor(pid);
    //   // }
    //   await _bumpSenderPending();

    //   onSuccess(value?.msg ?? 'Request sent');
    // } catch (e) {
    //   onError(e);
    // }
  }
}

class ResultFiBinding extends Bindings {
  @override
  void dependencies() {
    // Build controller from Get.arguments
    Get.put(ResultFiController.fromArgs());
  }
}