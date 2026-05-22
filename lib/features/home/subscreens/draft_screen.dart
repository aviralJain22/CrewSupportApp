import 'package:crew_support/features/home/subscreens/shared/trip_card_widget.dart';
import 'package:crew_support/model/trip_model.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'draft_controller.dart';

class DraftScreen extends GetView<DraftController> {
  const DraftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OwnerTripsTabView(
      isLoading: controller.isLoading,
      items: controller.trips,
      selectedProfileType: controller.selectedProfileType,
      onRefresh: controller.refreshDraftTrips,
      // Current tab uses owner vs non-owner empty texts.
      ownerEmptyText: 'No drafts',
      nonOwnerText: 'No drafts',
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

            return Dismissible(
              key: ValueKey('draft-trip-${trip.objectId}'),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) => controller.confirmAndDeleteDraftTrip(trip),
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                ),
              ),
              child: TripCardWidget(
                trip: trip,
                isOwner: isOwner,
                pulseController: controller.resizableController,
                unreadColorAnimation: controller.unreadColorAnimation,
                onTap: () {
                  // TODO: Navigate to draft Trip Detail screen
                  controller.navigateToCreateTrip(trip);
                },
              ),
            );
          },
          separatorBuilder: (_, __) => SizedBox(height: 1.2.h),
          itemCount: controller.trips.length,
        );
      },
    );
  }
}
