import 'package:crew_support/app/routes.dart';
import 'package:crew_support/database/airport_code_model.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/Utility.dart';

import 'trip_notification_timeline_controller.dart';

class TripNotificationTimelineScreen extends StatelessWidget {
  const TripNotificationTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create controller for this screen instance
    final TripNotificationTimelineController controller = Get.put(
      TripNotificationTimelineController(
      ),
      // Important: if you open this screen multiple times, do NOT reuse old controller instance
      // to avoid stale data issues.
      // tag: '$tripDetailId-$pilotId',
    );

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

    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColor.secondaryColor1,
          ),
        ),
        backgroundColor: AppColor.bgColor1,
        elevation: 0,
        title: Obx(
          () => Text(
            controller.title.value ?? "",
            style: TextStyle(color: AppColor.secondaryColor1),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LoadingAnimationWidget.threeRotatingDots(
                  color: AppColor.secondaryColor1,
                  size: 50.sp,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Loading...',
                  style: TextStyle(color: AppColor.textColor1),
                ),
              ],
            ),
          );
        }
        final details = controller.tripDetails.value;
        if (details == null) {
          return Center(
            child: Text(
              "No data available",
              style: TextStyle(
                fontSize: 10.spV2,
                color: AppColor.secondaryColor1,
              ),
            ),
          );
        }
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            // Trip header info (Destination, Aircraft, Start/End)
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Padding(
                    padding: EdgeInsets.all(3.0.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 40.w,
                              child: Text(
                                "Destination : ",
                                style: TextStyle(
                                  color: AppColor.textColor1,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.spV2,
                                ),
                              ),
                            ),
                            FutureBuilder<String>(
                              future: _resolveAirportIdent(details.trip.destinationSourceId),
                              builder: (context, snap) {
                                final dest = snap.data ?? '-';
                                return Text(
                                  dest,
                                  style: TextStyle(
                                    fontSize: 10.spV2,
                                    color: AppColor.secondaryColor1,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            SizedBox(
                              width: 40.w,
                              child: Text(
                                "Aircraft : ",
                                style: TextStyle(
                                  color: AppColor.textColor1,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.spV2,
                                ),
                              ),
                            ),
                            Text(
                              details.trip.aircraft,
                              style: TextStyle(
                                fontSize: 10.spV2,
                                color: AppColor.secondaryColor1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            SizedBox(
                              width: 40.w,
                              child: Text(
                                "Trip Start Date : ",
                                style: TextStyle(
                                  color: AppColor.textColor1,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.spV2,
                                ),
                              ),
                            ),
                            Text(
                              _formatDate(details.trip.startDate),
                              style: TextStyle(
                                fontSize: 10.spV2,
                                color: AppColor.secondaryColor1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            SizedBox(
                              width: 40.w,
                              child: Text(
                                "Trip End Date : ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.textColor1,
                                  fontSize: 10.spV2,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 25.w,
                              child: Text(
                                _formatDate(details.trip.endDate),
                                style: TextStyle(
                                  color: AppColor.secondaryColor1,
                                  fontSize: 10.spV2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              indent: 10,
              endIndent: 10,
              thickness: 1,
              color: AppColor.secondaryColor1,
            ),
            // Notification list
            controller.notifications.isEmpty
                ? Container()
                : SizedBox(
                    height: 70.h,
                    width: 100.w,
                    child: ListView.builder(
                      itemCount: controller.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = controller.notifications[index];
                        final dateStr = DateFormat('dd MMMM yyyy').format(notification.date);
                        return GestureDetector(
                          onTap: () {
                            // TODO: Navigate to the appropriate detail screen based on notification id/type if needed.

                            if (notification.type == 3){
                              Get.toNamed(
                                AppRoutes.rateTrip,
                                arguments: {
                                'title': controller.dash.selectedProfileType.value == MembershipType.ownerOperator ? membershipLabelFromType(notification.membershipType) : "Owner/Operator",
                              },
                              );

                            } else {
                              Get.toNamed(
                                AppRoutes.tripSummary,
                                arguments: {
                                'tripDetails': controller.tripDetails.value,
                                'notification': notification,
                                // 'oppositeId': oppositeId,
                                // 'index': index,
                                // 'index_zero': indexZero,
                                // 'tripAccepted': tripAccepted,
                                'fromFutureCurrent': controller.fromFutureCurrent,
                                // 'indexOfScreen': indexOfScreen,
                                // 'rate': rate,
                              },
                              );
                            }

                          },
                          child: Container(
                            margin: EdgeInsets.all(3.0.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.spV2),
                              border: Border.all(
                                color: AppColor.secondaryColor1,
                                width: 3.spV2,
                              ),
                            ),
                            child: Container(
                              margin: EdgeInsets.all(0.7.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColor.textColor2,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(
                                      left: 5.0.w,
                                      right: 5.0.w,
                                      top: 1.0.h,
                                      bottom: 1.0.h,
                                    ),
                                    width: 60.0.w,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          dateStr,
                                          style: TextStyle(
                                            fontSize: 10.spV2,
                                            color: AppColor.secondaryColor1,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 0.5.h),
                                        Text(
                                          notification.text,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10.spV2,
                                            fontWeight: FontWeight.w400,
                                            color: AppColor.secondaryColor2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: AppColor.textColor2,
                                      border: Border.all(width: 1, color: AppColor.secondaryColor1),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "View",
                                        style: TextStyle(
                                          color: AppColor.secondaryColor1,
                                          fontSize: 9.0.spV2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Visibility(
                                    // visible: controller.pilotName.value != null &&
                                    //     controller.pilotName.value!.isNotEmpty &&
                                    //     notification.text.contains(controller.pilotName.value!),
                                    visible: true,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.person_pin,
                                        color: AppColor.secondaryColor1,
                                      ),
                                      onPressed: () {
                                        // final pid = controller.pilotId.value;
                                        // if (pid == null) return;
                                        showLoadingDialog(context, 'Loading...');
                                        // searchViewProfile(id: pid).then((value) {
                                        //   if (Get.isDialogOpen == true) Get.back();
                                        //   if (value == null) return;
                                        //   Get.to(() => _getScreen(value.data.pilot.fkMemberShipId!, value));
                                        // });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        );
      }),
    );
  }

  // Widget _getScreen(int index, ViewProfileResponse viewProfileResponse) {
  //   if (index == 1) {
  //     return PendingOwnerProfileScreen(viewProfileResponse: viewProfileResponse.data.pilot);
  //   } else if (index == 2) {
  //     return PendingInstructorProfileScreen(viewProfileResponse: viewProfileResponse.data.pilot);
  //   } else if (index == 3 || index == 5) {
  //     return PendingPilotProfileScreen(viewProfileResponse: viewProfileResponse.data.pilot);
  //   } else {
  //     return PendingFlightProfileScreen(viewProfileResponse: viewProfileResponse.data.pilot);
  //   }
  // }
}