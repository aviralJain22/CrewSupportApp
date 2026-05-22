import 'package:crew_support/app/routes.dart';
import 'package:crew_support/database/airport_code_model.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/features/home/subscreens/trip_crew_overview_controller.dart';
import 'package:crew_support/features/message/chat_service.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/model/owner_trip_detail_models.dart';

class TripCrewOverviewScreen extends GetWidget<TripCrewOverviewController> {
  const TripCrewOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            // UX: show a tiny blocking loader because we are waiting on a network refresh.
            // Otherwise the back button can feel "dead" on slow connections.
            //
            // If you prefer instant navigation, remove the dialog and do NOT await refresh.
            try {
              // Show loader dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColor.secondaryColor1,
                    ),
                  );
                },
              );

              // closes the loader dialog
              Get.back();

              final dash = Get.find<DashboardController>();

              debugPrint('TripCrewOverviewScreen: back pressed → refreshing dashboard');
              dash.goBackToDashboardAndReloadTrips();

              // Refresh trips + badge counts based on selected profile
              // await dash.refreshForSelectedProfile();
            } catch (e) {
              // closes the loader dialog
              Get.back();
              debugPrint('TripCrewOverviewScreen: error refreshing dashboard on back: $e');
            } finally {
              
              // Now pop this screen
              // Get.back();
            }
          },
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColor.secondaryColor1,
          ),
        ),
        backgroundColor: AppColor.bgColor1,
        elevation: 0,
        title: Obx(
          () => Text(
            controller.title.value,
            style: TextStyle(color: AppColor.secondaryColor1),
          ),
        ),
      ),
      floatingActionButton: Obx(() {
        if (controller.isLoading.value) {
          return Container();
        }

        // Same visibility logic as old code:
        // visible only for owner, and only if not all roles are filled
        final dash = Get.find<DashboardController>();
        final isOwner = dash.selectedProfileType.value == MembershipType.ownerOperator;
        final hasAllRoles = (controller.selectedMembers.contains("Captain") || controller.selectedMembers.contains("pilot")) &&
            controller.selectedMembers.contains("Second In Command") &&
            // controller.selectedMembers.contains("Instructor") &&
            controller.selectedMembers.contains("Flight Attendant");

        if (!isOwner || (controller.fromFutureCurrent != null && controller.fromFutureCurrent == false)) {
          return Container();
        }

        final tripDetails = controller.tripDetails.value;
        if (tripDetails == null) {
          return Container();
        }

        // final trip = tripDetails.trip[0];

        final trip = tripDetails.trip;

        // Disable Add Crew if all roles are filled or the trip has already ended.
        // endDate is date-only, so compare only calendar dates.
        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);

        final tripEnd = trip.endDate;
        final tripEndOnly = tripEnd == null
            ? null
            : DateTime(tripEnd.year, tripEnd.month, tripEnd.day);

        final hasTripEnded =
            tripEndOnly != null && tripEndOnly.isBefore(todayOnly);

        final shouldDisableAddCrew = hasAllRoles || hasTripEnded;

        return Opacity(
          // Disabled state: reduce opacity so the button clearly looks inactive.
          opacity: shouldDisableAddCrew ? 0.45 : 1.0,
          child: RawMaterialButton(
            onPressed: shouldDisableAddCrew
                ? null
                : () {
                    Get.toNamed(AppRoutes.selectProfile, arguments: {
                      'fromAddCrew': true,
                      'tripId': controller.tripDetails.value!.trip.objectId,
                      'trip': controller.tripModel,
                    });
                  },
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: shouldDisableAddCrew ? Colors.grey : AppColor.secondaryColor1,
                width: 0.6.w,
              ),
              borderRadius: BorderRadius.circular(2.w),
            ),
            fillColor: shouldDisableAddCrew ? Colors.grey : AppColor.secondaryColor1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: shouldDisableAddCrew ? AppColor.textColor1 : AppColor.textColor2,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Add Crew',
                    style: TextStyle(
                      color: shouldDisableAddCrew ? AppColor.textColor1 : AppColor.textColor2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      }),
      body: Obx(() {
        final tripDetails = controller.tripDetails.value;

        if (controller.isLoading.value || tripDetails == null) {
          // Loading state
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LoadingAnimationWidget.threeRotatingDots(
                  color: AppColor.secondaryColor1,
                  size: 50.spV2,
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

        return Column(
          children: [
            _buildTripHeader(tripDetails.trip),
            _buildCrewList(context),
          ],
        );
      }),
    );
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

  Widget _buildTripHeader(OwnerTripDetailModel trip) {
    return SizedBox(
      height: 18.h,
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.all(5.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 40.w,
                          child: Text(
                            "Destination : ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColor.textColor1,
                              fontSize: 10.spV2,
                            ),
                          ),
                        ),
                        FutureBuilder<String>(
                          future: _resolveAirportIdent(trip.destinationSourceId),
                          builder: (context, snap) {
                            final dest = snap.data ?? '-';
                            return Text(
                              dest,
                              style: TextStyle(
                                color: AppColor.secondaryColor1,
                                fontSize: 10.spV2,
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
                          trip.aircraft,
                          style: TextStyle(
                            color: AppColor.secondaryColor1,
                            fontSize: 10.spV2,
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
                          _formatDate(trip.startDate),
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
                              color: AppColor.textColor1,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.spV2,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 25.w,
                          child: Text(
                            _formatDate(trip.endDate),
                            style: TextStyle(
                              color: AppColor.secondaryColor1,
                              fontSize: 10.spV2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
        ],
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    // IMPORTANT:
    // Start/End are DATE-ONLY fields. Do NOT convert to local time here,
    // because that can shift the calendar day for timezones behind UTC (e.g. EST).
    // We always format using the UTC calendar date so everyone sees the same day.
    final d = dt.toUtc();
    return DateFormat('MM/dd/yyyy').format(DateTime.utc(d.year, d.month, d.day));
  }

  Widget _buildCrewList(BuildContext context) {
    return Obx(() {
      final list = controller.crewList;

      if (list.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Center(
            child: Text(
              'No crew yet',
              style: TextStyle(
                fontSize: 10.spV2,
                color: AppColor.secondaryColor1,
              ),
            ),
          ),
        );
      }

      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: list.length,
        itemBuilder: (context, index) {
          final member = list[index];

          return GestureDetector(
            onTap: () {
              Get.toNamed(
                AppRoutes.tripNotificationTimeline,
                arguments: {
                  'tripDetails': controller.tripDetails.value, // OwnerTripDetailResponse
                  'member': member, //TripCrewMemberModel
                  'fromFutureCurrent': controller.fromFutureCurrent,
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Card(
                elevation: 5.0,
                color: AppColor.textColor2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    width: 2.spV2,
                    color: AppColor.secondaryColor1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        controller.openCrewProfile(member);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColor.secondaryColor1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: (member.profilePictureUrl.isEmpty)
                                ? CircleAvatar(
                                    backgroundColor: AppColor.secondaryColor1,
                                    child: Icon(
                                      Icons.person,
                                      color: AppColor.textColor2,
                                    ),
                                  )
                                : Image.network(
                                    member.profilePictureUrl,
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
                                          color: AppColor.textColor2,
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
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
                                          color: AppColor.textColor2,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ),
                    trailing: SizedBox(
                    width: 20.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 🔔 Notification badge (legacy UI behaviour)
                        Visibility(
                          visible: member.badgeCount > 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.secondaryColor1,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              member.badgeCount.toString(),
                              style: TextStyle(
                                color: AppColor.textColor2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 5.w),
                        GestureDetector(
                          onTap: () {
                            String fullName =
                                "${member.firstName} ${member.lastName}".trim();

                            // Safety check: chat requires the backing Parse _User objectId.
                            // If it is missing, block navigation and inform the user.
                            if (member.userId.trim().isEmpty) {
                              debugPrint(
                                "Chat blocked: member.userId is empty for profileId=${member.profileId}, membershipType=${member.membershipType}",
                              );
                              Get.snackbar(
                                "Unable to open chat",
                                "This crew member's user data is not available yet.",
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            debugPrint(
                              "Tapped chat icon for userId: ${member.userId}, membershipType: ${member.membershipType}, receiverName: $fullName",
                            );

                            final ChatService chatService = ChatService();
                            chatService.openChatForProfile(
                              otherUserId: member.userId,
                              otherProfileType: member.membershipType,
                              receiverName: fullName,
                              photoPath: member.profilePictureUrl,
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/message.svg',
                            height: 2.5.h,
                            color: AppColor.secondaryColor2,
                            cacheColorFilter: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        member.roleLabel,
                        style: TextStyle(color: AppColor.secondaryColor2),
                      ),
                    ),
                    title: Text(
                      member.fullName,
                      style: const TextStyle(
                        color: AppColor.secondaryColor1,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}