import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:crew_support/utils/notification_constants.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'trip_summary_controller.dart';

class TripSummaryScreen extends GetWidget<TripSummaryController> {
  const TripSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Trip Summary",
          style: TextStyle(color: AppColor.secondaryColor1),
        ),
        backgroundColor: AppColor.bgColor1,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.adaptive.arrow_back_rounded, color: AppColor.secondaryColor1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _rowReadOnlyField(
                    label: "Trip Name",
                    controller: controller.tripNameController,
                    leftPadding: EdgeInsets.only(left: 5.w),
                  ),
                  _divider(),

                  _rowReadOnlyField(
                    label: "Departure Airport Code",
                    controller: controller.departAirportCodeController,
                    leftPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  ),
                  _divider(),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                          child: Text(
                            "Enroute Airports",
                            style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Obx(
                          () => Text(
                            controller.enrouteTempList.join(","),
                            style: TextStyle(fontSize: 10.spV2, color: AppColor.secondaryColor1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _divider(),

                  _rowReadOnlyField(
                    label: "Destination Airport Code",
                    controller: controller.destAirportCodeController,
                    leftPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  ),
                  _divider(),

                  _rowReadOnlyField(
                    label: "Start Date",
                    controller: controller.startDateController,
                    leftPadding: EdgeInsets.only(left: 5.w),
                  ),
                  _divider(),

                  _rowReadOnlyField(
                    label: "End Date",
                    controller: controller.endDateController,
                    leftPadding: EdgeInsets.only(left: 5.w),
                  ),
                  _divider(),

                  _rowReadOnlyField(
                    label: "Aircraft Type",
                    controller: controller.aircraftTypeController,
                    leftPadding: EdgeInsets.only(left: 5.w),
                  ),
                  _divider(),

                  // Rate / Day row (same layout)
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.w),
                          child: Text(
                            "Rate / Day",
                            style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Text(
                              "\$",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColor.secondaryColor1,
                              ),
                            ),
                            Container(
                              width: 42.w,
                              margin: EdgeInsets.only(left: 3.w),
                              child: TextFormField(
                                controller: controller.dayRateController,
                                readOnly: true,
                                style: TextStyle(fontSize: 10.spV2, color: AppColor.secondaryColor1),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Rate",
                                  hintStyle: TextStyle(
                                    fontSize: 9.spV2,
                                    color: AppColor.secondaryColor2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  _divider(),

                  // Total row (same layout)
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.w),
                          child: Text(
                            "Total",
                            style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Text(
                              "\$",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColor.secondaryColor1,
                              ),
                            ),
                            Container(
                              width: 42.w,
                              margin: EdgeInsets.only(left: 3.w),
                              child: TextFormField(
                                controller: controller.totalController,
                                readOnly: true,
                                style: TextStyle(fontSize: 10.spV2, color: AppColor.secondaryColor1),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Total Rate",
                                  hintStyle: TextStyle(color: AppColor.secondaryColor2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  _divider(),

                  SizedBox(height: 2.h),

                  /// ===== Buttons section (ported conditions as-is) =====
                  Obx(() => _actionButtons(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButtons(BuildContext context) {
    // final ts = controller.tripDetails;
    // final idx = controller.index ?? 0;

    // While tripOperation (isCrewAccepted / isOwnerAccepted) is being fetched,
    // keep the space stable and avoid showing the wrong action buttons.
    if (!controller.isCrewTripOpLoaded.value) {
      // You can swap this for SizedBox.shrink() if you prefer no placeholder.
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
        child: Center(
          child: SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // If there was an error loading tripOperation, show nothing (or you can show a small label).
    if (controller.tripOpLoadError.value != null) {
      return const SizedBox.shrink();
    }

    // NOTE: These conditions mirror the old nested ternary blocks.
    // Keep them as close as possible for identical UI behavior.

    // 0) For Owner: Cancel Trip
    if (controller.isCrewAccepted.value != true &&
        controller.dash.selectedProfileType.value == MembershipType.ownerOperator &&
        controller.notification.type == NotificationType.tripRequestSent) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        child: Obx(
          () => MaterialButton(
            disabledColor: AppColor.secondaryColor1,
            disabledTextColor: AppColor.textColor2,
            textColor: AppColor.textColor2,
            color: AppColor.secondaryColor1,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
              borderRadius: BorderRadius.circular(2.w),
            ),
            onPressed: controller.Cancelstopclikcing.value == false
                ? () {
                    controller.Cancelstopclikcing.value = true;
                    controller.showOwnerTripCancelDialog();
                  }
                : null,
            child: Text("Cancel Trip", style: TextStyle(fontSize: 10.spV2)),
          ),
        ),
      );
    }

    // 1) Request Cancellation by crew
    if (controller.isCrewAccepted.value == true &&
        controller.dash.selectedProfileType.value != MembershipType.ownerOperator &&
        controller.notification.type == NotificationType.ownerApprovedCrewAcceptance) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        child: Obx(
          () => MaterialButton(
            disabledColor: AppColor.secondaryColor1,
            disabledTextColor: AppColor.textColor2,
            textColor: AppColor.textColor2,
            color: AppColor.secondaryColor1,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
              borderRadius: BorderRadius.circular(2.w),
            ),
            onPressed: controller.Cancelstopclikcing.value == false
                ? () {
                    controller.Cancelstopclikcing.value = true;
                    controller.showRequestCancellationByCrewDialog();
                  }
                : null,
            child: Text("Request Cancellation", style: TextStyle(fontSize: 12.spV2)),
          ),
        ),
      );
    }
    
    // 1b) Cancellation Already Requested By Crew:
    if (controller.isCrewAccepted.value == true &&
        controller.dash.selectedProfileType.value != MembershipType.ownerOperator &&
        controller.notification.type == NotificationType.crewRequestsTripCancellation) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        child: MaterialButton(
            disabledColor: AppColor.secondaryColor1,
            disabledTextColor: AppColor.textColor2,
            textColor: AppColor.textColor2,
            color: AppColor.secondaryColor1,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
              borderRadius: BorderRadius.circular(2.w),
            ),
            onPressed: null,
            child: Text("Cancellation Requested", style: TextStyle(fontSize: 12.spV2)),
          ),
      );
    }

    // 1c) ACCEPT CANCEL REQUEST by crew
    if (controller.isCrewAccepted.value == true &&
    controller.dash.selectedProfileType.value != MembershipType.ownerOperator &&
    controller.notification.type == NotificationType.ownerRequestsTripCancellation) {
      return Container(
        width: 40.w,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        child: MaterialButton(
          disabledColor: AppColor.secondaryColor1,
          disabledTextColor: AppColor.textColor2,
          textColor: AppColor.textColor2,
          color: AppColor.secondaryColor1,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
            borderRadius: BorderRadius.circular(2.w),
          ),
          onPressed: () => controller.acceptTripCancellationRequestAsCrew(),
          child: Text("ACCEPT CANCEL REQUEST", style: TextStyle(fontSize: 12.spV2)),
        ),
      );
    }

    // 2) ACCEPT CANCEL REQUEST by owner
    if (controller.isCrewAccepted.value == true &&
    controller.dash.selectedProfileType.value == MembershipType.ownerOperator &&
    controller.notification.type == NotificationType.crewRequestsTripCancellation) {
      return Container(
        width: 40.w,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        child: MaterialButton(
          disabledColor: AppColor.secondaryColor1,
          disabledTextColor: AppColor.textColor2,
          textColor: AppColor.textColor2,
          color: AppColor.secondaryColor1,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
            borderRadius: BorderRadius.circular(2.w),
          ),
          onPressed: () => controller.acceptTripCancellationRequestAsOwner(),
          child: Text("ACCEPT CANCEL REQUEST", style: TextStyle(fontSize: 12.spV2)),
        ),
      );
    }

    // 3) ACCEPT / DECLINE / NEGOTIATE row
    // if (ts.summary[0].isAlreadyAccepted == false &&
    //     ts.summary[idx].type != 6 &&
    //     controller.fromFutureCurrent == false &&
    //     controller.tripAccepted == false &&
    //     controller.indexZero == true) {
    if (controller.isCrewAccepted.value != true &&
        controller.dash.selectedProfileType.value != MembershipType.ownerOperator &&
        // ts.summary[idx].type != 6 &&
        (controller.notification.type == NotificationType.tripRequestSent ||
         controller.notification.type == NotificationType.ownerNegotiates )) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 30.w,
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
                controller.acceptReject = 1;
                controller.showAlertDialogAccept("Are you sure you want to accept?");
              },
              child: Text("ACCEPT", style: TextStyle(fontSize: 10.spV2)),
            ),
          ),
          SizedBox(
            width: 30.w,
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
                controller.acceptReject = 0;
                controller.showAlertDialogReject();
              },
              child: Text("DECLINE", style: TextStyle(fontSize: 10.spV2)),
            ),
          ),
          SizedBox(
            width: 30.w,
            child: MaterialButton(
              disabledColor: AppColor.secondaryColor1,
              disabledTextColor: AppColor.textColor2,
              textColor: AppColor.textColor2,
              color: AppColor.secondaryColor1,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                borderRadius: BorderRadius.circular(2.w),
              ),
              onPressed: () => controller.showAlertNegotiation(),
              child: Text("NEGOTIATE", style: TextStyle(fontSize: 10.spV2)),
            ),
          ),
        ],
      );
    }

    // 3b) Negotiation Already Requested By Crew:
    if (controller.isCrewAccepted.value != true &&
        controller.dash.selectedProfileType.value != MembershipType.ownerOperator &&
        controller.notification.type == NotificationType.crewNegotiates && 
        controller.notification.responded != true
    ) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        child: MaterialButton(
            disabledColor: AppColor.secondaryColor1,
            disabledTextColor: AppColor.textColor2,
            textColor: AppColor.textColor2,
            color: AppColor.secondaryColor1,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
              borderRadius: BorderRadius.circular(2.w),
            ),
            onPressed: null,
            child: Text("Negotiation Requested", style: TextStyle(fontSize: 12.spV2)),
          ),
      );
    }

    // 4) FOR OWNER: Accept Offer / Negotiate row (type == 5)
    if (controller.isOwnerAccepted.value != true &&
        controller.dash.selectedProfileType.value == MembershipType.ownerOperator &&
        controller.notification.type == NotificationType.crewAcceptedTrip ) {
        // controller.fromFutureCurrent == false) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 90.w,
            child: Obx(
              () => MaterialButton(
                disabledColor: AppColor.secondaryColor1,
                disabledTextColor: AppColor.textColor2,
                textColor: AppColor.textColor2,
                color: AppColor.secondaryColor1,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                onPressed: controller.Acceptstopclikcing.value == false
                    ? () {
                        controller.acceptReject = 1;
                        controller.Acceptstopclikcing.value = true;
                        controller.showAlertDialogOwnerAcceptOffer("Are you sure you want to accept?");
                      }
                    : null,
                child: Text("Accept Offer", style: TextStyle(fontSize: 10.spV2)),
              ),
            ),
          ),
          // SizedBox(
          //   width: 40.w,
          //   child: MaterialButton(
          //     disabledColor: AppColor.secondaryColor1,
          //     disabledTextColor: AppColor.textColor2,
          //     textColor: AppColor.textColor2,
          //     color: AppColor.secondaryColor1,
          //     shape: RoundedRectangleBorder(
          //       side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
          //       borderRadius: BorderRadius.circular(2.w),
          //     ),
          //     onPressed: () {
          //       // controller.acceptReject = 0;
          //       // controller.showAlertDialogReject();
          //     },
          //     child: Text("Negotiate", style: TextStyle(fontSize: 10.spV2)),
          //   ),
          // ),
        ],
      );
    }

    // 4) FOR OWNER: Accept Offer / Negotiate row when crew sends a negotiation request
    if (controller.isOwnerAccepted.value != true &&
        controller.dash.selectedProfileType.value == MembershipType.ownerOperator &&
        controller.isCrewAccepted.value != true &&
        controller.notification.type == NotificationType.crewNegotiates) {
        // controller.fromFutureCurrent == false) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 40.w,
            child: Obx(
              () => MaterialButton(
                disabledColor: AppColor.secondaryColor1,
                disabledTextColor: AppColor.textColor2,
                textColor: AppColor.textColor2,
                color: AppColor.secondaryColor1,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                onPressed: controller.Acceptstopclikcing.value == false
                    ? () {
                        controller.acceptReject = 1;
                        controller.Acceptstopclikcing.value = true;
                        controller.showAlertDialogOwnerAcceptOffer("Are you sure you want to accept?");
                      }
                    : null,
                child: Text("Accept Offer", style: TextStyle(fontSize: 10.spV2)),
              ),
            ),
          ),
          SizedBox(
            width: 40.w,
            child: MaterialButton(
              disabledColor: AppColor.secondaryColor1,
              disabledTextColor: AppColor.textColor2,
              textColor: AppColor.textColor2,
              color: AppColor.secondaryColor1,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                borderRadius: BorderRadius.circular(2.w),
              ),
              onPressed: () => controller.showAlertNegotiation(),
              child: Text("Negotiate", style: TextStyle(fontSize: 10.spV2)),
            ),
          ),
        ],
      );
    }

    // 4b) Negotiation Already Requested By Owner:
    if (controller.isCrewAccepted.value != true &&
        controller.dash.selectedProfileType.value == MembershipType.ownerOperator &&
        controller.notification.type == NotificationType.ownerNegotiates && 
        controller.notification.responded != true
    ) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        child: MaterialButton(
            disabledColor: AppColor.secondaryColor1,
            disabledTextColor: AppColor.textColor2,
            textColor: AppColor.textColor2,
            color: AppColor.secondaryColor1,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
              borderRadius: BorderRadius.circular(2.w),
            ),
            onPressed: null,
            child: Text("Negotiation Requested", style: TextStyle(fontSize: 12.spV2)),
          ),
      );
    }

    // 6) FOR OWNER: Complete Trip / Request Cancellation (type == 1)
    //controller.isOwnerAccepted.value == true &&
    if (controller.dash.selectedProfileType.value == MembershipType.ownerOperator &&
        controller.notification.type == NotificationType.ownerApprovedCrewAcceptance && controller.tripDetails.value?.trip.isCompleted != true) {
        // controller.fromFutureCurrent == false) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 90.w,
            child: Obx(
              () => MaterialButton(
                disabledColor: AppColor.secondaryColor1,
                disabledTextColor: AppColor.textColor2,
                textColor: AppColor.textColor2,
                color: AppColor.secondaryColor1,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                onPressed: controller.Acceptstopclikcing.value == false
                    ? () {
                        controller.acceptReject = 1;
                        controller.Acceptstopclikcing.value = true;
                        controller.showAlertDialogOwnerCompleteTrip("Are you sure you want to complete trip?");
                      }
                    : null,
                child: Text("Complete Trip", style: TextStyle(fontSize: 12.spV2)),
              ),
            ),
          ),
          SizedBox(
            width: 90.w,
            child: MaterialButton(
              disabledColor: AppColor.secondaryColor1,
              disabledTextColor: AppColor.textColor2,
              textColor: AppColor.textColor2,
              color: AppColor.secondaryColor1,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                borderRadius: BorderRadius.circular(2.w),
              ),
              onPressed: controller.Cancelstopclikcing.value == false
                ? () {
                    controller.Cancelstopclikcing.value = true;
                    controller.showRequestCancellationByOwnerDialog();
                  }
                : null,
              child: Text("Request Cancellation", style: TextStyle(fontSize: 12.spV2)),
            ),
          ),
        ],
      );
    }

    // Cancellation Already Requested By Crew:
    if (controller.isCrewAccepted.value == true &&
        controller.dash.selectedProfileType.value == MembershipType.ownerOperator &&
        controller.notification.type == NotificationType.ownerRequestsTripCancellation) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        child: MaterialButton(
            disabledColor: AppColor.secondaryColor1,
            disabledTextColor: AppColor.textColor2,
            textColor: AppColor.textColor2,
            color: AppColor.secondaryColor1,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
              borderRadius: BorderRadius.circular(2.w),
            ),
            onPressed: null,
            child: Text("Cancellation Requested", style: TextStyle(fontSize: 12.spV2)),
          ),
      );
    }

    // 4) ACCEPT / DECLINE row (type == 6)
    // if (ts.summary[0].isAlreadyAccepted == false &&
    //     ts.summary[idx].type == 6 &&
    //     controller.indexZero == true) {
    //   return Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //     children: [
    //       SizedBox(
    //         width: 40.w,
    //         child: Obx(
    //           () => MaterialButton(
    //             disabledColor: AppColor.secondaryColor1,
    //             disabledTextColor: AppColor.textColor2,
    //             textColor: AppColor.textColor2,
    //             color: AppColor.secondaryColor1,
    //             shape: RoundedRectangleBorder(
    //               side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
    //               borderRadius: BorderRadius.circular(2.w),
    //             ),
    //             onPressed: controller.Acceptstopclikcing.value == false
    //                 ? () {
    //                     controller.acceptReject = 1;
    //                     controller.Acceptstopclikcing.value = true;
    //                     controller.showAlertDialogAccept("Are you sure you want to accept ?");
    //                   }
    //                 : null,
    //             child: Text("ACCEPT", style: TextStyle(fontSize: 10.spV2)),
    //           ),
    //         ),
    //       ),
    //       SizedBox(
    //         width: 40.w,
    //         child: MaterialButton(
    //           disabledColor: AppColor.secondaryColor1,
    //           disabledTextColor: AppColor.textColor2,
    //           textColor: AppColor.textColor2,
    //           color: AppColor.secondaryColor1,
    //           shape: RoundedRectangleBorder(
    //             side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
    //             borderRadius: BorderRadius.circular(2.w),
    //           ),
    //           onPressed: () {
    //             controller.acceptReject = 0;
    //             controller.showAlertDialogReject();
    //           },
    //           child: Text("DECLINE", style: TextStyle(fontSize: 10.spV2)),
    //         ),
    //       ),
    //     ],
    //   );
    // }

    // 5) Accepted info button
    return Visibility(
      // visible: controller.tripAccepted == true,
      visible: controller.isCrewAccepted.value == true && controller.dash.selectedProfileType.value != MembershipType.ownerOperator,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.w),
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
            showMyDialog(context, "You have already accepted the trip")
                .then((_) => Get.back());
          },
          child: Text("Accepted", style: TextStyle(fontSize: 10.spV2)),
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      indent: 10,
      endIndent: 10,
      thickness: 1,
      color: AppColor.secondaryColor1,
    );
  }

  Widget _rowReadOnlyField({
    required String label,
    required TextEditingController controller,
    required EdgeInsets leftPadding,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: leftPadding,
            child: Text(
              label,
              style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: controller,
            readOnly: true,
            style: TextStyle(fontSize: 10.spV2, color: AppColor.secondaryColor1),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: label,
              hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
            ),
          ),
        ),
      ],
    );
  }
}