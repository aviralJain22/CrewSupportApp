import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/model/CountryModel.dart';
import 'package:crew_support/model/owner_trip_detail_models.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:crew_support/utils/AppColor.dart';

/// Keys expected in Get.arguments (Map)
class AddBankDetailArgs {
  // static const String tripId = 'tripId';
  static const String oppositionId = 'oppositionId';
  static const String acceptReject = 'acceptReject';
  static const String tripNotificationId = 'tripNotificationId';
  // static const String dayRateAmount = 'dayRateAmount';
  static const String totalAmount = 'totalAmount';
  // static const String navFor = 'navFor'; // membership id string ("1" for owner in old screen)
  // static const String startDate = 'startDate'; // "MM/dd/yyyy"
}

class AddBankDetailController extends GetxController {
  // --------------------------
  // Text Controllers (legacy)
  // --------------------------
  final TextEditingController countryController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController initialEscrowController =
      TextEditingController(text: "50");
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController bicCodeController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController currencyController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController routingNumberController = TextEditingController();

  // Legacy checkbox flag (UI section is commented in old code, but we keep state)
  final RxBool isSaved = false.obs;

  // Country list (filtered)
  final RxList<String> countryTempList = <String>[].obs;

  // --------------------------
  // Args (runtime)
  // --------------------------
  final Rxn<OwnerTripDetailResponse> tripDetails = Rxn<OwnerTripDetailResponse>();
  // late final int tripId;
  late final int oppositionId;
  late final int acceptReject;
  // late final String dayRateAmount;
  String? totalAmount;
  String? tripNotificationId;
  // String? membershipId; // old: widget.navFor
  // String? startDate;

  late final String appType;
  late final DashboardController dash;

  @override
  void onInit() {
    super.onInit();

    // appType = UserHelper().getAppType();
    dash = Get.find<DashboardController>();

    final args =
        (Get.arguments is Map) ? (Get.arguments as Map) : <String, dynamic>{};

    tripDetails.value = args['tripDetails'] as OwnerTripDetailResponse?;
    // tripId = (args[AddBankDetailArgs.tripId] ?? 0) as int;
    oppositionId = (args[AddBankDetailArgs.oppositionId] ?? 0) as int;
    acceptReject = (args[AddBankDetailArgs.acceptReject] ?? 0) as int;
    tripNotificationId = args[AddBankDetailArgs.tripNotificationId]?.toString();
    // dayRateAmount = (args[AddBankDetailArgs.dayRateAmount] ?? '') as String;
    totalAmount = args[AddBankDetailArgs.totalAmount]?.toString();
    // membershipId = args[AddBankDetailArgs.navFor]?.toString();
    // startDate = args[AddBankDetailArgs.startDate]?.toString();

    if (kDebugMode) {
      debugPrint('membership id -- ${dash.selectedProfileType.value}');
      debugPrint('trip Id -- ${tripDetails.value?.trip.objectId}');
      // debugPrint('toId -- ${dash.basic}');
      debugPrint('ownerId -- ${tripDetails.value?.trip.ownerId}');
      debugPrint('dayrate amount -- ${tripDetails.value?.trip.pilotRate}');
      debugPrint('total amount -- $totalAmount');
    }

    // Legacy
    countryTempList.assignAll(citizenshipCountryList);
  }

  @override
  void onClose() {
    countryController.dispose();
    searchController.dispose();
    accountNameController.dispose();
    ifscCodeController.dispose();
    initialEscrowController.dispose();
    confirmPasswordController.dispose();
    bicCodeController.dispose();
    accountNumberController.dispose();
    currencyController.dispose();
    bankNameController.dispose();
    routingNumberController.dispose();
    super.onClose();
  }

  // --------------------------
  // UI Actions (dialogs/sheets)
  // --------------------------

  void openCountryListDialog() {
    final context = Get.context;
    if (context == null) return;

    searchController.clear();
    countryTempList.assignAll(citizenshipCountryList);

    showDialog(
      context: context,
      builder: (BuildContext dialogCtx) {
        return StatefulBuilder(
          builder: (BuildContext dialogCtx,
              void Function(void Function()) setStates) {
            return Theme(
              data: ThemeData.dark(),
              child: AlertDialog(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                title: Text(
                  "Select Country",
                  style: TextStyle(color: AppColor.secondaryColor1),
                ),
                content: SizedBox(
                  height: MediaQuery.of(dialogCtx).size.height * 0.80,
                  width: MediaQuery.of(dialogCtx).size.width * 0.80,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 48,
                        child: TextField(
                          controller: searchController,
                          onChanged: (text) {
                            setStates(() {
                              if (text.isEmpty) {
                                countryTempList.assignAll(
                                    citizenshipCountryList);
                              } else {
                                countryTempList.assignAll(
                                  citizenshipCountryList
                                      .where((c) => c
                                          .toLowerCase()
                                          .contains(text.toLowerCase()))
                                      .toList(),
                                );
                              }
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Search",
                            contentPadding: const EdgeInsets.all(5),
                            prefixIcon: Icon(Icons.search,
                                color: AppColor.secondaryColor1),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 1,
                                  color: AppColor.secondaryColor1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 1,
                                  color: AppColor.secondaryColor1),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Obx(
                          () => ListView.builder(
                            shrinkWrap: true,
                            itemCount: countryTempList.length,
                            itemBuilder: (context, index) {
                              final item = countryTempList[index];
                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(item),
                                    onTap: () {
                                      countryController.text = item;
                                      Navigator.pop(dialogCtx);
                                    },
                                  ),
                                  const Divider(
                                      indent: 10,
                                      endIndent: 10,
                                      thickness: 1),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  MaterialButton(
                    color: AppColor.secondaryColor1,
                    textColor: AppColor.textColor2,
                    onPressed: () {
                      setStates(() => searchController.clear());
                      Navigator.pop(dialogCtx);
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void openCurrencySheet() {
    final context = Get.context;
    if (context == null) return;

    final action = Theme(
      data: ThemeData.dark(),
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            isDefaultAction: false,
            onPressed: () {
              currencyController.text = "USD";
              Navigator.pop(context);
            },
            child: Text("USD", style: TextStyle(color: AppColor.textColor1)),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: false,
            onPressed: () {
              currencyController.text = "EURO";
              Navigator.pop(context);
            },
            child:
                Text("EURO", style: TextStyle(color: AppColor.textColor1)),
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text("Cancel",
              style: TextStyle(color: AppColor.secondaryColor1)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );

    showCupertinoModalPopup(context: context, builder: (_) => action);
  }

  void showSkipDialog() {
    final context = Get.context;
    if (context == null) return;

    Widget cancelButton = TextButton(
      child: Text("Disagree",
          style: TextStyle(color: AppColor.secondaryColor1)),
      onPressed: () => Navigator.pop(context),
    );

    Widget yesButton = TextButton(
      child: Text("Agree", style: TextStyle(color: AppColor.secondaryColor1)),
      onPressed: () async {
        Navigator.pop(context);
        showLoadingDialog(context, "Accepting...");
        if (dash.selectedProfileType.value == MembershipType.ownerOperator) {
          await onAcceptDeclineOwner();
        } else {
          await onAcceptDecline();
        }
      },
    );

    CupertinoAlertDialog alert = CupertinoAlertDialog(
      content: Text(
        "Escrow keeps both pilot and operator protected. By skipping escrow you understand and accept the risk associated with it.",
        textAlign: TextAlign.justify,
        style: TextStyle(color: AppColor.textColor1),
      ),
      actions: [cancelButton, yesButton],
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Theme(data: ThemeData.dark(), child: alert),
    );
  }

  // --------------------------
  // Submit + Legacy flows
  // --------------------------

  Future<void> submitBankDetails() async {
    final context = Get.context;
    if (context == null) return;

    // Legacy validations (kept identical)
    if (countryController.text.isEmpty) {
      showMyDialog(context, "Please select country");
      return;
    } else if (currencyController.text.isEmpty) {
      showMyDialog(context, "Please select currency");
      return;
    } else if (bankNameController.text.isEmpty) {
      showMyDialog(context, "Please enter bank name");
      return;
    } else if (accountNameController.text.isEmpty) {
      showMyDialog(context, "Please enter account name");
      return;
    } else if (bicCodeController.text.isEmpty) {
      showMyDialog(context, "Please enter BIC code");
      return;
    } else if (accountNumberController.text.isEmpty) {
      showMyDialog(context, "Please enter account number");
      return;
    } else if (ifscCodeController.text.isEmpty) {
      showMyDialog(context, "Please enter IFSC code");
      return;
    }

    if (kDebugMode) {
      // debugPrint('pkPilotId - ${pkPilotId.toString()}');
      debugPrint('tripId - ${tripDetails.value?.trip.objectId}');
      debugPrint('country - ${countryController.text}');
      debugPrint('currency - ${currencyController.text}');
      debugPrint('bankName - ${bankNameController.text}');
      debugPrint('accountName - ${accountNameController.text}');
      debugPrint('bicCode - ${bicCodeController.text}');
      debugPrint('accountNumber - ${accountNumberController.text}');
      debugPrint('ifscCode - ${ifscCodeController.text}');
    }

    // showLoadingDialog(context, "Accepting...");

    // try {
      // await addBankDetail(
      //   pkPilotId.toString(),
      //   tripId.toString(),
      //   countryController.text,
      //   currencyController.text,
      //   bankNameController.text,
      //   accountNameController.text,
      //   bicCodeController.text,
      //   accountNumberController.text,
      //   ifscCodeController.text,
      //   routingNumberController.text,
      //   isSaved.value ? 1 : 0,
      // );

      // After saving, legacy goes into accept flows
      if (dash.selectedProfileType.value == MembershipType.ownerOperator) {
        await onAcceptDeclineOwner();
      } else {
        await onAcceptDecline();
      }
    // } catch (e) {
    //   // Get.back(); //hide loader
    //   if (kDebugMode) debugPrint("submitBankDetails error: $e");
    //   showMyDialog(context, "Something went wrong. Please try again.");
    // }
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

  Future<void> onAcceptDecline() async {
    final context = Get.context;
    if (context == null) return;

    try {
      showLoadingDialog(context, "Accepting...");
      // We expect this screen to be opened from a notification context.
      // If the id is missing, we fail fast to avoid silently navigating.
      final id = tripNotificationId;
      if (id == null || id.trim().isEmpty) {
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

  Future<void> onAcceptDeclineOwner() async {
    // final context = Get.context;
    // if (context == null) return;

    // final value = await acceptRejectFromOwner(
    //   tripId: tripId,
    //   oppositionId: oppositionId,
    //   dayRateAmount: dayRateAmount,
    //   acceptReject: acceptReject,
    // );

    // final today = DateTime.now();
    // final start = startDate; // MM/dd/yyyy
    // final isStartToday =
    //     (start != null && DateFormat("MM/dd/yyyy").format(today) == start);

    // if (isStartToday) {
    //   await FirebaseFirestore.instance
    //       .collection(appType.toString() == 'live'
    //           ? AppStrings.fireBaseUserlive
    //           : AppStrings.fireBaseUserlocal)
    //       .doc('$oppositionId')
    //       .update({'currentCount': FieldValue.increment(1)});

    //   await FirebaseFirestore.instance
    //       .collection(appType.toString() == 'live'
    //           ? AppStrings.fireBaseUserlive
    //           : AppStrings.fireBaseUserlocal)
    //       .doc('$pkPilotId')
    //       .update({'currentCount': FieldValue.increment(1)});

    //   await FirebaseFirestore.instance
    //       .collection(appType.toString() == 'live'
    //           ? AppStrings.fireBaseTripslive
    //           : AppStrings.fireBaseTripslocal)
    //       .doc('$tripId')
    //       .collection('tripCount')
    //       .doc('$oppositionId - $pkPilotId')
    //       .update({'notificationCount': FieldValue.increment(1)});
    // } else {
    //   await FirebaseFirestore.instance
    //       .collection(appType.toString() == 'live'
    //           ? AppStrings.fireBaseUserlive
    //           : AppStrings.fireBaseUserlocal)
    //       .doc('$oppositionId')
    //       .update({'futureCount': FieldValue.increment(1)});

    //   await FirebaseFirestore.instance
    //       .collection(appType.toString() == 'live'
    //           ? AppStrings.fireBaseUserlive
    //           : AppStrings.fireBaseUserlocal)
    //       .doc('$pkPilotId')
    //       .update({'futureCount': FieldValue.increment(1)});

    //   try {
    //     final docTrip = FirebaseFirestore.instance
    //         .collection(appType.toString() == 'live'
    //             ? AppStrings.fireBaseTripslive
    //             : AppStrings.fireBaseTripslocal)
    //         .doc('$tripId')
    //         .collection('tripCount')
    //         .doc('$oppositionId - $pkPilotId');

    //     final snap = await docTrip.get();
    //     if (snap.exists) {
    //       await docTrip.update(
    //           {'notificationCount': FieldValue.increment(1)});
    //     } else {
    //       await docTrip.set({'notificationCount': 1});
    //     }
    //   } on FirebaseException catch (e) {
    //     if (kDebugMode) debugPrint(e.toString());
    //   }
    // }

    // // close loader that was shown earlier (Accepting...)
    // if (Get.isDialogOpen == true) Get.back();

    // await showMyDialog(context, value?.msg ?? '').then((_) async {
    //   updateReadUnreadTrip(TripId: tripId, IsRead: false);

    //   showLoadingDialog(context, "Creating Transaction...");

    //   final total = double.tryParse(totalAmount ?? "0")?.toInt() ?? 0;
    //   final percent = int.tryParse(initialEscrowController.text) ?? 0;
    //   final ammount = ((percent / 100) * total).toString();

    //   await createTransction(
    //     tripId: tripId,
    //     ownerId: pkPilotId.toString(),
    //     oppositeId: oppositionId,
    //     ammount: ammount,
    //   );

    //   if (Get.isDialogOpen == true) Get.back();

    //   await showMyDialog(context, "Transaction created successfully.");

    //   // Adjust if your route differs
    //   Get.offAllNamed('/landingOwner');
    // });
  }
}