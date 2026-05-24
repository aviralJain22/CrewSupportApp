import 'dart:io';

import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/dashboard_screen.dart';
import 'package:crew_support/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:crew_support/utils/Utility.dart';
import 'result_captain_controller.dart';

class ResultCaptainScreen extends GetWidget<ResultCaptainController> {
  const ResultCaptainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      color: AppColor.bgColor1,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Obx(
          () => WillPopScope(
            onWillPop: () async => !controller.backButtonLocked.value,
            child: Scaffold(
              backgroundColor: AppColor.bgColor1,
              appBar: AppBar(
                elevation: 0,
                title: Text(
                  "Results - Captain",
                  style: TextStyle(color: AppColor.secondaryColor1, fontSize: 12.spV2),
                ),
                backgroundColor: AppColor.bgColor1,
                leading: IconButton(
                  onPressed: () => controller.backButtonLocked.value ? null : Navigator.pop(context),
                  icon: Icon(
                    Icons.adaptive.arrow_back_rounded,
                    color: AppColor.secondaryColor1,
                  ),
                ),
              ),

              // ---------------- Bottom Bar (logic mirrors the old file) ----------------
              bottomNavigationBar: _buildBottomBar(context),

              // ---------------- Body ----------------
              //body: (controller.filterData?.pilots.isNotEmpty ?? false)
              body: (controller.filterData.isNotEmpty)
                  ? _buildPilotList(context)
                  : _buildEmptyState(context),
            ),
          ),
        ),
      ),
    );
  }

  // ======================== Widgets ========================

  Widget _buildBottomBar(BuildContext context) {
    //final hasPilots = controller.filterData?.pilots.isNotEmpty ?? false;
    final hasPilots = controller.filterData.isNotEmpty;
    final double safeBottom = MediaQuery.of(context).padding.bottom;
    final double bottomBarVertical = Platform.isAndroid ? safeBottom + 1.5.h : 1.5.h;

    // Mirror the sprawling legacy if/else tree, but keep readable.
    if (!controller.isTripOutOfDateComputed) {
      // ---- Trip NOT out of date ----
      if (!hasPilots &&
          fromPending == true &&
          controller.boolCAP == true &&
          (controller.boolSIC == false || controller.boolFA == false || controller.boolFI == false)) {
        return _wideButton(
          context,
          label: fromPending == true ? "Go To Home" : "Go To Pending Tab",
          color: AppColor.secondaryColor1,
          textColor: AppColor.textColor2,
          onPressed: controller.stopClicking.value
              ? null
              : () {
                  Get.offNamed(AppRoutes.dashboard);
                },
        );
      }

      if (!hasPilots &&
          controller.boolCAP == true &&
          controller.boolSIC == false &&
          controller.boolFA == false &&
          controller.boolFI == false) {
        // Row with "Save as Draft" & "Delete Trip"
        return Padding(
          padding: EdgeInsets.fromLTRB(2.w, 1.5.h, 2.w, bottomBarVertical),
          child: Row(
            children: [
              Expanded(
                child: _outlinedButton(
                  context,
                  label: "Save as Draft",
                  color: AppColor.secondaryColor1,
                  textColor: AppColor.textColor2,
                  borderColor: AppColor.secondaryColor1,
                  onPressed: controller.onTapSaveDraft,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _outlinedButton(
                  context,
                  label: "Delete Trip",
                  color: AppColor.deleteColor,
                  textColor: AppColor.textColor1,
                  borderColor: AppColor.deleteColor,
                  onPressed: () => _showDeleteDialog(context),
                ),
              ),
            ],
          ),
        );
      }

      // Default bar (either "Search for Next" or "Send Trip Request")
      final nextLabel = (controller.boolSIC == true || controller.boolFA == true || controller.boolFI == true) && !hasPilots
          ? "Search for Next"
          : "Send Trip Request";

      return _wideButton(
        context,
        label: nextLabel,
        color: AppColor.secondaryColor1,
        textColor: AppColor.textColor2,
        onPressed: controller.stopClicking.value
            ? null
            : () async {
                if (!hasPilots &&
                    (controller.boolSIC == true || controller.boolFA == true || controller.boolFI == true)) {
                  // when no captains found but next roles exist
                  controller.goToNextStepAfterSend(context);
                } else {
                  await controller.sendTripRequest(context);
                }
              },
      );
    } else {
      // ---- Trip OUT of date ----
      if (!hasPilots &&
          controller.selectList.contains("Captain") == true &&
          (controller.selectList.contains("Second In Command") == false ||
              controller.selectList.contains("Flight Attendant") == false ||
              (controller.selectList.contains("Flight Instructor") == false ||
                  controller.selectList.contains("Instructor") == false))) {
        // Only Captain selected -> Go Home
        return _wideButton(
          context,
          label: "Go To Home",
          color: AppColor.secondaryColor1,
          textColor: AppColor.textColor2,
          onPressed: () {
            Get.offAllNamed(AppRoutes.dashboard);
          },
        );
      }

      if (!hasPilots &&
          controller.selectList.contains("Captain") == true &&
          (controller.selectList.contains("Second In Command") == true ||
              controller.selectList.contains("Flight Attendant") == true ||
              controller.selectList.contains("Flight Instructor") == true ||
              controller.selectList.contains("Instructor") == true)) {
        // Captain + someone else -> "Search for next"
        return _wideButton(
          context,
          label: "Search for next",
          color: AppColor.secondaryColor1,
          textColor: AppColor.textColor2,
          onPressed: () async => controller.goToNextStepAfterSend(context),
        );
      }

      // Default (edit flow) -> "Send Trip Request"
      return _wideButton(
        context,
        label: "Send Trip Request",
        color: AppColor.secondaryColor1,
        textColor: AppColor.textColor2,
        onPressed: () async => controller.sendTripRequestEdit(context),
      );
    }
  }

  Widget _buildPilotList(BuildContext context) {
    // final pilots = controller.filterData!.pilots;
    final pilots = controller.filterData;

    return SingleChildScrollView(
      child: Column(
        children: [
          // "Select All"
          Container(
            margin: EdgeInsets.only(left: 4.0.w, right: 7.5.w, top: 1.5.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select All",
                  style: TextStyle(
                    color: AppColor.secondaryColor1,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0.spV2,
                  ),
                ),
                Theme(
                  data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                  child: Obx(
                    () => Checkbox(
                      activeColor: AppColor.secondaryColor1,
                      checkColor: AppColor.textColor2,
                      value: controller.selectAll.value,
                      onChanged: (val) => controller.toggleSelectAll(val ?? false),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List of pilots
          ListView.builder(
            itemCount: pilots.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final p = pilots[index];

              return Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(3.0.w),
                    decoration: BoxDecoration(color: AppColor.bgColor1),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(AppRoutes.pilotViewProfile, arguments: {
                            'profileId': p.id,
                            'userId': p.userId,
                            'hideDirectTripButton': true, // we hide the "Create Direct Trip" button on the profile screen when navigating from the result screen, because it would be redundant (user is already in a direct trip flow) and could cause confusion if they try to create another direct trip from there. The profile can still be viewed in full, just without that one button.
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(0.7.w),
                          decoration: BoxDecoration(
                            color: AppColor.bgColor1,
                            border: Border.all(
                              color: AppColor.secondaryColor1,
                              width: 3.0,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(10.sp),
                          ),
                          padding: EdgeInsets.only(top: 1.0.h, bottom: 1.0.h, left: 1.0.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColor.secondaryColor1,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: SizedBox(
                                    height: 50.0.sp,
                                    width: 50.0.sp,
                                    child: Image.network(
                                      p.profilePictureUrl.toString(),
                                      fit: BoxFit.fill,
                                      height: 4.h,
                                      width: 4.w,
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            color: AppColor.bgColor1,
                                            value: progress.expectedTotalBytes != null
                                                ? progress.cumulativeBytesLoaded /
                                                    progress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, _, __) {
                                        return CircleAvatar(
                                          backgroundColor: AppColor.secondaryColor1,
                                          child: Icon(Icons.person, color: AppColor.bgColor1),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: 3.w),

                              // Middle text area (takes remaining width)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${p.firstName} ${p.lastName}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColor.secondaryColor1,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11.0.spV2,
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      "State : ${p.state}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColor.secondaryColor2,
                                        fontSize: 9.0.spV2,
                                      ),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      "City : ${p.city}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColor.secondaryColor2,
                                        fontSize: 9.0.spV2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Checkbox
                              Theme(
                                data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                                child: Obx(
                                  () => Checkbox(
                                    activeColor: AppColor.secondaryColor1,
                                    checkColor: AppColor.textColor2,
                                    value: controller.pilotChecked.contains(p.id),
                                    onChanged: (val) =>
                                        controller.togglePilotSelection(val ?? false, p.id),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isOutOfDate = controller.isTripOutOfDateComputed;
    final hasNoCaptainOnly = (fromPending == true &&
        controller.boolCAP == true &&
        controller.boolSIC == false &&
        controller.boolFA == false &&
        controller.boolFI == false);

    final text = isOutOfDate
        ? "No Crew Members are available on this selected dates\n ${controller.startDate} - ${controller.endDate}"
        : hasNoCaptainOnly
            ? "Captain Not found! \n\nPlease change the criteria and try again."
            : "No result found";

    return SizedBox(
      height: 100.h,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColor.secondaryColor2, fontSize: 10.spV2),
        ),
      ),
    );
  }

  // ======================== Buttons ========================

  Widget _wideButton(
    BuildContext context, {
    required String label,
    required Color color,
    required Color textColor,
    VoidCallback? onPressed,
  }) {

    final double safeBottom = MediaQuery.of(context).padding.bottom;
    final double bottomMargin = Platform.isAndroid ? safeBottom + 1.5.h : 1.5.h;

    return Container(
      margin: EdgeInsets.fromLTRB(5.w, 1.5.h, 5.w, bottomMargin),
      child: MaterialButton(
        disabledColor: color,
        disabledTextColor: textColor,
        textColor: textColor,
        color: color,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: color, width: 0.6.w),
          borderRadius: BorderRadius.circular(2.w),
        ),
        onPressed: onPressed,
        child: Text(label, style: TextStyle(fontSize: 10.spV2)),
      ),
    );
  }

  Widget _outlinedButton(
    BuildContext context, {
    required String label,
    required Color color,
    required Color textColor,
    required Color borderColor,
    VoidCallback? onPressed,
  }) {
    return MaterialButton(
      minWidth: 42.w,
      disabledColor: color,
      disabledTextColor: textColor,
      textColor: textColor,
      color: color,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: 0.6.w),
        borderRadius: BorderRadius.circular(2.w),
      ),
      onPressed: onPressed,
      child: Text(label, style: TextStyle(fontSize: 10.spV2)),
    );
  }

  // ======================== Dialogs ========================

  void _showDeleteDialog(BuildContext context) {
    // Matches old CupertinoAlertDialog usage and colors
    final cancelBtn = TextButton(
      child: Text("No", style: TextStyle(color: AppColor.secondaryColor1, fontSize: 10.spV2)),
      onPressed: () => Navigator.pop(context),
    );

    final yesBtn = TextButton(
      child: Text("Yes", style: TextStyle(color: AppColor.secondaryColor1, fontSize: 10.spV2)),
      onPressed: () async {
        Navigator.pop(context);
        await controller.deleteDraftAndExit(context);
        await showMyDialog(context, 'Trip deleted successfully');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardScreen()),
        );
      },
    );

    final alert = CupertinoAlertDialog(
      content: const Text("Are you sure you want to delete trip?"),
      actions: [cancelBtn, yesBtn],
    );

    showDialog(
      context: context,
      builder: (_) => Theme(data: ThemeData.dark(), child: alert),
    );
  }
}