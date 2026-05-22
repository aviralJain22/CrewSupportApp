// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:crew_support/model/NotificationResponse.dart';

import 'notification_controller.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Obx(
        () {
          final bool isLoading = controller.isLoading.value;
          final List<Notifications> notificationData =
              controller.notificationData;

          // Loading state (same UI as old)
          if (isLoading) {
            return SizedBox(
              height: 55.h,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LoadingAnimationWidget.threeRotatingDots(
                      color: AppColor.secondaryColor1,
                      size: 50.sp, // not a font, keep as .sp
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: AppColor.textColor1,
                        fontSize: 10.spV2, // FONT -> use spV2
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // No data state (same UI as old)
          if (notificationData.isEmpty) {
            return Container(
              height: 81.h,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/logoNewGolden.png"),
                  colorFilter: ColorFilter.mode(
                    AppColor.bgColor1.withOpacity(0.9),
                    BlendMode.srcOver,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  "No data available",
                  style: TextStyle(
                    fontSize: 10.spV2, // FONT -> spV2
                    color: AppColor.secondaryColor1,
                  ),
                ),
              ),
            );
          }

          // Data list (same UI as old)
          return SizedBox(
            height: 81.h,
            child: ListView.builder(
              itemCount: notificationData.length,
              itemBuilder: (context, index) {
                final item = notificationData[index];

                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: AppColor.historyRead,
                  ),
                  secondaryBackground: Container(
                    color: AppColor.textColor1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.delete,
                          color: AppColor.deleteColor,
                        ),
                      ),
                    ),
                  ),

                  /// We replicate the old behaviour:
                  /// - Show Cupertino alert
                  /// - On "Delete", call controller.deleteNotificationWithUi(...)
                  /// - We do NOT rely on Dismissible's internal removal, we remove from list manually
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      final res = await showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return Theme(
                            data: ThemeData.dark(),
                            child: CupertinoAlertDialog(
                              content: const Text(
                                "Are you sure you want to delete ?",
                              ),
                              actions: <Widget>[
                                MaterialButton(
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: AppColor.secondaryColor1,
                                      fontSize: 10.spV2, // FONT
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  },
                                ),
                                MaterialButton(
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(
                                      color: AppColor.secondaryColor1,
                                      fontSize: 10.spV2, // FONT
                                    ),
                                  ),
                                  onPressed: () {
                                    // Let controller handle API + removal and dialog pops
                                    controller.deleteNotificationWithUi(
                                      context: dialogContext,
                                      notification: item,
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                      // We don't want Dismissible to auto-remove,
                      // the controller already updates the list.
                      return res;
                    }
                    return null;
                  },

                  child: Container(
                    margin: EdgeInsets.all(3.0.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color:
                          // old: AppColor.secondaryColor1 (animation commented)
                          AppColor.secondaryColor1,
                    ),
                    child: Container(
                      margin: EdgeInsets.all(0.4.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: item.IsRead == true
                            ? AppColor.bgColor1
                            : AppColor.highlightColor,
                      ),
                      padding: EdgeInsets.only(
                        top: 1.0.h,
                        bottom: 1.0.h,
                        left: 2.0.w,
                        right: 2.0.w,
                      ),
                      child: ListTile(
                        title: Text(
                          item.oppositePilotName,
                          style: TextStyle(
                            fontSize: 11.spV2, // FONT
                            fontWeight: FontWeight.bold,
                            color: AppColor.secondaryColor1,
                          ),
                        ),
                        subtitle: Text(
                          item.summary,
                          style: TextStyle(
                            fontSize: 9.spV2, // FONT
                            color: item.IsRead == true
                                ? AppColor.secondaryColor2
                                : AppColor.bgColor1,
                          ),
                        ),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColor.secondaryColor1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: SizedBox(
                              height: 65.0.sp, // dimensions, keep as .sp
                              width: 65.0.sp,
                              child: Image.network(
                                item.photoPath,
                                fit: BoxFit.fill,
                                loadingBuilder: (
                                  BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress,
                                ) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: AppColor.bgColor1,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                errorBuilder: (
                                  BuildContext context,
                                  Object exception,
                                  StackTrace? stackTrace,
                                ) {
                                  return CircleAvatar(
                                    backgroundColor: AppColor.secondaryColor1,
                                    child: Icon(
                                      Icons.person,
                                      color: AppColor.bgColor1,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          // Uses GetX controller method - internally shows loading dialog etc.
                          controller.openProfileForNotification(context, item);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}