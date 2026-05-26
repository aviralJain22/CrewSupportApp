import 'dart:io';

import 'package:badges/badges.dart' as BadgeIcon;
import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/helper/user_helper.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'home_controller.dart';

import 'package:crew_support/features/home/subscreens/current_screen.dart';
import 'package:crew_support/features/home/subscreens/current_controller.dart';
import 'package:crew_support/features/home/subscreens/future_screen.dart';
import 'package:crew_support/features/home/subscreens/future_controller.dart';
import 'package:crew_support/features/home/subscreens/history_screen.dart';
import 'package:crew_support/features/home/subscreens/history_controller.dart';
import 'package:crew_support/features/home/subscreens/pending_screen.dart';
import 'package:crew_support/features/home/subscreens/pending_controller.dart';
import 'package:crew_support/features/home/subscreens/uncrewed_screen.dart';
import 'package:crew_support/features/home/subscreens/uncrewed_controller.dart';
import 'package:crew_support/features/home/subscreens/draft_screen.dart';
import 'package:crew_support/features/home/subscreens/draft_controller.dart';

/// HomeScreen (GetX)
/// -----------------
/// Pixel-matched recreation of the legacy Home layout header row with 6 pills.
/// - Uses spV2 for fonts to match old Sizer behavior.
/// - Keeps legacy-like color helpers.
/// - Badge counts are reactive and can be fed from Firebase later.
class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  Color _boxColor(bool selected) =>
      selected ? AppColor.secondaryColor1 : AppColor.bgColor1;

  Color _textColor(bool selected) =>
      selected ? AppColor.textColor2 : AppColor.secondaryColor2;

  Widget _pill({
    required bool selected,
    required String label,
    required int count,
    required VoidCallback onTap,
    double widthW = 15.0,
  }) {
    // Legacy “99+” behavior
    final String badgeText =
        (count <= 0) ? '' : (count <= 99 ? count.toString() : '99+');

    final pill = Container(
      width: widthW.w,
      height: 3.5.h,
      decoration: BoxDecoration(
        color: _boxColor(selected),
        borderRadius: BorderRadius.circular(5.sp),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: _textColor(selected),
            fontSize: 10.spV2,
          ),
        ),
      ),
    );

    // Show badge only when not selected (legacy behavior)
    final withBadge = (badgeText.isNotEmpty && !selected)
        ? BadgeIcon.Badge(
            position: BadgeIcon.BadgePosition.topEnd(top: -15, end: -5),
            badgeStyle: BadgeIcon.BadgeStyle(
              shape: BadgeIcon.BadgeShape.square,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              borderRadius: BorderRadius.circular(10.sp),
              elevation: 8.0,
              badgeColor: AppColor.secondaryColor1,
            ),
            badgeContent: Text(
              badgeText,
              style: TextStyle(
                color: AppColor.textColor2,
                fontSize: 8.spV2,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: pill,
          )
        : pill;

    return GestureDetector(onTap: onTap, child: withBadge);
  }

  @override
  Widget build(BuildContext context) {

    debugPrint("building home screen");

    // Ensure each sub-controller exists; if it was deleted, it will be recreated.
    if (!Get.isRegistered<CurrentController>()) {
      Get.put<CurrentController>(CurrentController(), permanent: true);
    }
    if (!Get.isRegistered<FutureTripsController>()) {
      Get.put<FutureTripsController>(FutureTripsController(), permanent: true);
    }
    if (!Get.isRegistered<HistoryController>()) {
      Get.put<HistoryController>(HistoryController(), permanent: true);
    }
    if (!Get.isRegistered<PendingController>()) {
      Get.put<PendingController>(PendingController(), permanent: true);
    }
    if (!Get.isRegistered<UncrewedController>()) {
      Get.put<UncrewedController>(UncrewedController(), permanent: true);
    }
    if (!Get.isRegistered<DraftController>()) {
      Get.put<DraftController>(DraftController(), permanent: true);
    }


    // Background + the 6-pill row, like legacy
return Stack(
  children: [
    // --- your existing Container body (unchanged) ---
    Container(
      width: 100.w,
      decoration: BoxDecoration(
        color: AppColor.bgColor1,
        image: DecorationImage(
          image: const AssetImage("assets/logoNewGolden.png"),
          colorFilter: ColorFilter.mode(
            AppColor.bgColor1.withOpacity(0.9),
            BlendMode.srcOver,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ====== Six-pill row (mirrors legacy) ======
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox.shrink(),
                  _pill(
                    selected: controller.isClickedCurrent.value,
                    label: 'Current',
                    count: Get.find<DashboardController>().currentBadgeCount.value,
                    onTap: () => controller.selectTab(0),
                  ),
                  _pill(
                    selected: controller.isClickedFuture.value,
                    label: 'Future',
                    count: Get.find<DashboardController>().futureBadgeCount.value,
                    onTap: () => controller.selectTab(1),
                  ),
                  _pill(
                    selected: controller.isClickedHistory.value,
                    label: 'History',
                    count: Get.find<DashboardController>().historyBadgeCount.value,
                    onTap: () => controller.selectTab(2),
                  ),
                  _pill(
                    selected: controller.isPending.value,
                    label: 'Pending',
                    count: Get.find<DashboardController>().pendingBadgeCount.value,
                    onTap: () => controller.selectTab(3),
                  ),
                  // if (Get.find<DashboardController>().selectedProfileType.value != MembershipType.ownerOperator)
                  //   _pill(
                  //     selected: controller.isUncrewedTrips.value,
                  //     label: 'Uncrewed',
                  //     count: controller.uncrewedCount.value,
                  //     onTap: () => controller.selectTab(4),
                  //     widthW: 18.0,
                  //   ),
                  if (Get.find<DashboardController>().selectedProfileType.value == MembershipType.ownerOperator)
                    _pill(
                      selected: controller.isClickedFinished.value,
                      label: 'Draft',
                      count: Get.find<DashboardController>().draftBadgeCount.value,
                      onTap: () => controller.selectTab(5),
                    ),
                ],
              );
            }),

            SizedBox(height: 0.8.h),
            Container(
              width: 100.w,
              height: 0.30.h, // thin line like legacy
              color: AppColor.secondaryColor2,
            ),
            SizedBox(height: 0.8.h),

            // ====== Body (below pills) ======
            Expanded(
              child: Obx(() {
                switch (controller.currentPage.value) {
                  case 0:
                    return const CurrentScreen();
                  case 1:
                    return const FutureTripsScreen();
                  case 2:
                    return const HistoryScreen();
                  case 3:
                    return const PendingScreen();
                  case 4:
                    final dash = Get.find<DashboardController>();
                    if (dash.selectedProfileType.value != MembershipType.ownerOperator) {
                      return const UncrewedScreen();
                    }
                    return const SizedBox.shrink();
                  case 5:
                    final dash = Get.find<DashboardController>();
                    if (dash.selectedProfileType.value == MembershipType.ownerOperator) {
                      return const DraftScreen();
                    }
                    return const SizedBox.shrink();
                  default:
                    return const SizedBox.shrink();
                }
              }),
            ),
          ],
        ),
      ),
    ),

    // ====== Create Trip button (legacy placement) ======
    Obx(() {
      // Read fkMembershipId from DashboardController; show button only when it's "1"
      final dash = Get.isRegistered<DashboardController>() ? Get.find<DashboardController>() : null;
      final show = dash != null && dash.selectedProfileType.value == MembershipType.ownerOperator;
      if (!show) return const SizedBox.shrink();

      final double safeBottom = MediaQuery.of(context).padding.bottom;

      return Positioned(
        bottom: Platform.isAndroid ? safeBottom + 2.h : 2.h,
        left: 9.w,
        right: 9.w,
        child: SizedBox(
          width: 85.w,
          child: MaterialButton(
            disabledColor: AppColor.secondaryColor1,
            disabledTextColor: AppColor.textColor2,
            textColor: AppColor.textColor2,
            color: AppColor.secondaryColor1,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
              borderRadius: BorderRadius.circular(2.w),
            ),
            onPressed: () {
              // LEGACY:
              UserHelper().clearCurrent();
              UserHelper().setIsCreateTripFlag(true);
              // Navigator.push(context, MaterialPageRoute(builder: (context) => SelectProfileScreen()));

              // NEW PROJECT:
              // Route to your SelectProfile screen when it's available.
              // Replace with your actual route or widget:
              Get.toNamed(AppRoutes.selectProfile);
            },
            child: Text(
              'CREATE TRIP',
              style: TextStyle(fontSize: 10.spV2),
            ),
          ),
        ),
      );
    }),
  ],
);
}
}