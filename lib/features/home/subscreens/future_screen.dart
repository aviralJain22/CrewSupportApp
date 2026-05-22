import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/home/subscreens/shared/trip_card_widget.dart';
import 'package:crew_support/model/trip_model.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'future_controller.dart';

class FutureTripsScreen extends GetView<FutureTripsController> {
  const FutureTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OwnerTripsTabView(
      isLoading: controller.isLoading,
      items: controller.trips,
      selectedProfileType: controller.selectedProfileType,
      onRefresh: controller.fetchTrips,
      ownerEmptyText: 'No future trips',
      nonOwnerText: 'No future trips',
      textStyle: TextStyle(
        fontSize: 11.spV2,
        color: AppColor.secondaryColor2,
      ),
      refreshIndicatorColor: AppColor.secondaryColor1,
      listBuilder: (context) {
        final bool isOwner =
            controller.selectedProfileType.value ==
                MembershipType.ownerOperator;

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          itemCount: controller.trips.length,
          itemBuilder: (_, i) {
            final TripModel trip = controller.trips[i];

            return TripCardWidget(
              trip: trip,
              isOwner: isOwner,
              pulseController: controller.resizableController,
              unreadColorAnimation: controller.unreadColorAnimation,
              onTap: () {

                Get.toNamed(
                  AppRoutes.tripCrewOverview,
                  arguments: {
                    'tripId': trip.objectId,
                    'fromFutureCurrent': true,
                    'trip': trip, // Pass the entire trip object for Add Crew button
                  },
                );

              },
            );
          },
        );
      },
    );
  }
}