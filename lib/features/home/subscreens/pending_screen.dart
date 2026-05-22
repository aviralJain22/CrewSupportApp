import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/home/subscreens/shared/trip_card_widget.dart';
import 'package:crew_support/model/trip_model.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'pending_controller.dart';

class PendingScreen extends GetView<PendingController> {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OwnerTripsTabView(
      isLoading: controller.isLoading,
      items: controller.trips,
      selectedProfileType: controller.selectedProfileType,
      onRefresh: controller.refreshPendingTrips,
      // Current tab uses owner vs non-owner empty texts.
      ownerEmptyText: 'No pending trips',
      nonOwnerText: 'No pending trips',
      textStyle: TextStyle(
        fontSize: 11.spV2,
        color: AppColor.secondaryColor2,
      ),
      refreshIndicatorColor: AppColor.secondaryColor1,
      listBuilder: (context) {
        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          itemBuilder: (_, i) {
            final TripModel trip = controller.trips[i];
            final bool isOwner = controller.selectedProfileType.value ==
                MembershipType.ownerOperator;

            return TripCardWidget(
              trip: trip,
              isOwner: isOwner,
              pulseController: controller.resizableController,
              unreadColorAnimation: controller.unreadColorAnimation,
              onTap: () {
                //Navigate to trip detail screen
                Get.toNamed(
                  AppRoutes.tripCrewOverview,
                  arguments: {
                    'tripId': trip.objectId,
                    'fromFutureCurrent': false,
                  },
                );
              },
            );
          },
          separatorBuilder: (_, __) => SizedBox(height: 1.2.h),
          itemCount: controller.trips.length,
        );
      },
    );
  }
}
