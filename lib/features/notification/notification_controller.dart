// ignore_for_file: avoid_print

import 'package:crew_support/mock/mock_requests.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:crew_support/Api/Api_service.dart';
import 'package:crew_support/helper/user_helper.dart';
import 'package:crew_support/model/NotificationResponse.dart';
import 'package:crew_support/model/chat_message_list_model.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/constants.dart';

class NotificationController extends GetxController {
  /// List of notifications
  final RxList<Notifications> notificationData = <Notifications>[].obs;

  /// Loading flag for screen
  final RxBool isLoading = true.obs;

  /// Message badge model (for notification count)
  MessageData chatMessageListModel = MessageData();

  /// App type (live / local) from UserHelper
  // late final String appType;

  @override
  void onInit() {
    super.onInit();
    // appType = UserHelper().getAppType();
    getData();
  }

  Future<NotificationResponse?> getNotification() async {
    // ApiConfig apiConfig = ApiConfig();
    // var str = await apiConfig.geturlString();
    // Uri finalUri = Uri.parse('${str}/Notification');

    // final http.Response response = await client.post(finalUri,
    //     headers: {
    //       'Content-Type': 'application/json',
    //     },
    //     body: jsonEncode(<String, dynamic>{"fkPilotId": pkPilotId}));

    // if (kDebugMode) {}

    // try {
    //   Map<String, dynamic> map = json.decode(response.body);

    //   if (kDebugMode) {
    //     print(map);
    //   }
    //   if (response.statusCode == 200) {
    //     var userModel = NotificationResponse.fromJson(jsonDecode(response.body));
    //     return userModel;
    //   } else {
    //     return null;
    //   }
    // } catch (e) {
    //   if (kDebugMode) {
    //     print(e.toString());
    //   }
    //   return null;
    // }
  }

  /// Main method to fetch notifications and update Firestore notification count
  Future<void> getData() async {

    //TODO:
    notificationData..clear()..addAll(notificationSampleData);
    isLoading.value = false;

    // try {
    //   isLoading.value = true;

    //   final value = await getNotification();

    //   // Always update notification count (badge) regardless of data present
    //   await _getNotiCount();

    //   if (value == null || value.data == null) {
    //     notificationData.clear();
    //   } else {
    //     notificationData
    //       ..clear()
    //       ..addAll(value.data!.notification);
    //   }
    // } catch (e) {
    //   print('Error in getData: $e');
    //   notificationData.clear();
    // } finally {
    //   isLoading.value = false;
    // }
  }

  /// Fetch notification badge count and store it in Firestore
  Future<void> _getNotiCount() async {
    // try {
    //   final value = await getMessageBadge();
    //   if (value != null && value.flag == 1) {
    //     chatMessageListModel = value.data;
    //     final notificationCounter =
    //         chatMessageListModel.messages![0].isUnReadCountNotification!;
    //     print('notification_counter -- $notificationCounter');

    //     final notificationDoc = FirebaseFirestore.instance
    //         .collection(appType == 'live'
    //             ? AppStrings.fireBasenotificationCountlive
    //             : AppStrings.fireBasenotificationCountlocal)
    //         .doc('$pkPilotId');

    //     final notificationJson = {"notificationCount": notificationCounter};
    //     final batch2 = FirebaseFirestore.instance.batch();
    //     batch2.set(notificationDoc, notificationJson);
    //     await batch2.commit();
    //   }
    // } catch (e) {
    //   print('Error in _getNotiCount: $e');
    // }
  }

  /// Delete a notification from API + local list + show dialogs
  ///
  /// This replicates old behaviour:
  /// - showLoadingDialog("Deleting...")
  /// - call deleteNotification API
  /// - close loading + alert dialogs
  /// - showMyDialog("Notification deleted successfully")
  /// - remove item from list
  Future<void> deleteNotificationWithUi({
    required BuildContext context,
    required Notifications notification,
  }) async {
    // try {
    //   showLoadingDialog(context, 'Deleting...');

    //   await deleteNotification(notification.pkNotifyId.toString());

    //   // Close loading dialog
    //   Navigator.pop(context);
    //   // Close confirmation alert dialog
    //   Navigator.pop(context);

    //   await showMyDialog(context, "Notification deleted successfully");

    //   // Remove from list so UI updates
    //   notificationData.removeWhere(
    //     (n) => n.pkNotifyId == notification.pkNotifyId,
    //   );
    // } catch (e) {
    //   print('Error deleting notification: $e');
    //   // Try to close dialogs safely if something went wrong
    //   Navigator.pop(context);
    //   Navigator.pop(context);
    //   await showMyDialog(context, "Failed to delete notification");
    // }
  }

  /// Open the appropriate profile screen based on membership type.
  ///
  /// This keeps the old logic:
  /// 1 -> Owner
  /// 2 -> Instructor
  /// 3 or 5 -> Pilot
  /// else -> Flight Attendant
  ///
  /// Uses GetX named routes instead of MaterialPageRoute.
  Future<void> openProfileForNotification(
    BuildContext context,
    Notifications notification,
  ) async {
    // Show loading dialog (same as old code)
    // showLoadingDialog(context, 'Loading...');

    // try {
    //   final value =
    //       await searchViewProfile(id: notification.oppositePilotId);

    //   // Close loading dialog
    //   Navigator.pop(context);

    //   if (value == null || value.data.pilot == null) {
    //     await showMyDialog(context, "Unable to load profile");
    //     return;
    //   }

    //   final pilotData = value.data.pilot;
    //   final fkMemberShipId = pilotData.fkMemberShipId;

    //   String routeName;

    //   if (fkMemberShipId == 1) {
    //     // Owner
    //     routeName = Routes.ownerSearchProfile;
    //   } else if (fkMemberShipId == 2) {
    //     // Instructor
    //     routeName = Routes.instructorSearchProfile;
    //   } else if (fkMemberShipId == 3 || fkMemberShipId == 5) {
    //     // Pilot
    //     routeName = Routes.pilotSearchProfile;
    //   } else {
    //     // Flight Attendant
    //     routeName = Routes.faSearchProfile;
    //   }

    //   // Pass arguments similar to old constructor params
    //   await Get.toNamed(
    //     routeName,
    //     arguments: {
    //       'pilotId': notification.oppositePilotId,
    //       'requestId': notification.fkRequestId,
    //       'requestStatus': notification.requestStatus.toString(),
    //       'viewProfileResponse': pilotData,
    //       'notificationId': notification.pkNotifyId,
    //     },
    //   );

    //   // After returning from profile, refresh notification list (same behaviour as old getData() in .then)
    //   await getData();
    // } catch (e) {
    //   print('Error in openProfileForNotification: $e');
    //   Navigator.pop(context); // close loading dialog if still open
    //   await showMyDialog(context, "Unable to load profile");
    // }
  }
}