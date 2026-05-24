import 'package:crew_support/app/routes.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart'; // for .spV2
import 'result_fa_controller.dart';

class ResultFAScreen extends GetWidget<ResultFAController> {
  const ResultFAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.bgColor1,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Obx(
          () => PopScope(
            canPop: controller.backButton.value == true ? false : true,
            onPopInvokedWithResult: (didPop, result) {
              // No-op. `canPop` controls whether system back can pop.
            },
            child: Scaffold(
              backgroundColor: AppColor.bgColor1,
              appBar: AppBar(
                elevation: 0,
                title: Text(
                  "Results - FA",
                  style: TextStyle(color: AppColor.secondaryColor1),
                ),
                backgroundColor: AppColor.bgColor1,
                leading: IconButton(
                  onPressed: () => controller.backButton.isFalse ? Get.back() : null,
                  icon: Icon(
                    Icons.adaptive.arrow_back_rounded,
                    color: AppColor.secondaryColor1,
                  ),
                ),
              ),

              // ------------------ BODY ------------------
              body: _buildBody(context),

              // ------------------ BOTTOM BAR ------------------
              // Prevent rounded corners from getting clipped by the system gesture/home indicator area.
              bottomNavigationBar: SafeArea(
                top: false,
                child: _buildBottomBar(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final data = controller.filterData;

    if ((data.isNotEmpty)) {
      // List of FAs
      return SingleChildScrollView(
        child: ListView.builder(
          itemCount: data.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final fa = data[index];
            return Container(
              margin: EdgeInsets.all(3.0.w),
              decoration: BoxDecoration(color: AppColor.bgColor1),
              child: Material(
                color: AppColor.bgColor1,
                borderRadius: BorderRadius.circular(10.spV2),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10.spV2),
                  onTap: () {
                    Get.toNamed(AppRoutes.fAViewProfile, arguments: {
                      'showGender': controller.hideGender,
                      'showProfile': controller.hideProfilePicture,
                      'profileId': fa.id,
                      'userId': fa.userId,
                      'hideDirectTripButton': true, // we hide the "Create Direct Trip" button on the profile screen
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
                      borderRadius: BorderRadius.circular(10.spV2),
                    ),
                    padding: EdgeInsets.only(top: 1.0.h, bottom: 1.0.h),
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Profile Image (CircleAvatar)
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColor.secondaryColor1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: SizedBox(
                          height: 50.0.spV2,
                          width: 50.0.spV2,
                          child: Image.network(
                            controller.hideProfilePicture == true ? ("") : fa.profilePictureUrl.toString(),
                            fit: BoxFit.fill,
                            height: 4.h,
                            width: 4.w,
                            loadingBuilder: (ctx, child, progress) {
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
                            errorBuilder: (ctx, exception, stackTrace) {
                              return CircleAvatar(
                                backgroundColor: AppColor.secondaryColor1,
                                child: Icon(Icons.person, color: AppColor.bgColor1),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // Name + State + City
                    Column(
                      children: [
                        SizedBox(
                          width: 30.0.w,
                          child: Text(
                            "${fa.firstName} ${fa.lastName}",
                            style: TextStyle(
                              color: AppColor.secondaryColor1,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.0.spV2,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        SizedBox(
                          width: 30.0.w,
                          child: Row(
                            children: [
                              Text(
                                "State : ${fa.state}",
                                style: TextStyle(
                                  color: AppColor.secondaryColor2,
                                  fontSize: 9.0.spV2,
                                ),
                              ),
                              SizedBox(width: 2.w),
                            ],
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        SizedBox(
                          width: 30.0.w,
                          child: Row(
                            children: [
                              Text(
                                "City : ${fa.city}",
                                style: TextStyle(
                                  color: AppColor.secondaryColor2,
                                  fontSize: 9.0.spV2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // View Profile (hidden because the whole row is tappable)
                    SizedBox.shrink(),

                    // Checkbox (reactive)
                    Obx(() => Theme(
                          data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                          child: Checkbox(
                            activeColor: AppColor.secondaryColor1,
                            checkColor: AppColor.textColor2,
                            onChanged: (value) {
                              controller.onSelectAttendant(value ?? false, fa.id);
                            },
                            value: controller.pilotChecked.contains(fa.id),
                          ),
                        )),
                  ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // Empty state messages (match legacy branching)
    final isOut = controller.isOutOfDate;
    // final faEmpty = (data?.fa.isEmpty ?? true);
    final faEmpty = (data.isEmpty);
    // final fromPending = fromPending; // legacy global/static

    final text = isOut
        ? "No Crew Members are available on this selected dates\n ${controller.startDate} - ${controller.endDate}"
        : faEmpty &&
                fromPending == true &&
                controller.boolFA == true &&
                (controller.boolCAP == true || controller.boolSIC == true)
            ? "Flight attendant not found! \n\nPlease change the criteria and try again."
            : faEmpty &&
                    controller.boolFA == true &&
                    (controller.boolCAP == true || controller.boolSIC == true) &&
                    controller.boolFI == false
                ? "Flight attendant not found! \n\nYou can add new crew member from pending tab."
                : "No result found";

    return SizedBox(
      height: 100.h,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColor.secondaryColor2),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final data = controller.filterData;
    final isOut = controller.isOutOfDate;
    //final faEmpty = (data?.fa.isEmpty ?? true);
    final faEmpty = (data.isEmpty);
    // final fromPending = UserHelper.fromPending; // legacy global/static

    // ========== isTripOutOfDate == false branch ==========
    if (!isOut) {
      // Case: Go To Home (FA empty, FA selected, (CAP||SIC), fromPending==true)
      if (faEmpty &&
          controller.boolFA == true &&
          (controller.boolCAP == true || controller.boolSIC == true) &&
          fromPending == true) {
        return _primaryButton(
          label: "Go To Home",
          onPressed: controller.stopClicking.isFalse ? () => Get.offAllNamed('/home') : null,
        );
      }

      // Case: Go To Pending Tab (FA empty, FA selected, CAP||SIC, FI==false)
      if (faEmpty &&
          controller.boolFA == true &&
          (controller.boolCAP == true || controller.boolSIC == true) &&
          controller.boolFI == false) {
        return _primaryButton(
          label: "Go To Pending Tab",
          onPressed: controller.stopClicking.isFalse
              ? () => Get.offAllNamed('/home', arguments: {'toPending': true}) // pass flag
              : null,
        );
      }

      // Case: FA empty & FI==false => Save as Draft / Delete Trip row
      if (faEmpty && (controller.boolFI == false)) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 2.w),
              child: _secondaryButton(
                label: "Save as Draft",
                onPressed: () async {
                  await showMyDialog(context, 'Trip is saved in Draft');
                  Get.offAllNamed('/home'); // legacy took user home
                },
              ),
            ),
            SizedBox(width: 2.w),
            Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: _destructiveButton(
                label: "Delete Trip",
                onPressed: () {
                  _showDeleteConfirm(context);
                },
              ),
            ),
          ],
        );
      }

      // Default: main action -> "Send Trip Request" OR "Search for Next"
      return _primaryButton(
        label: (controller.boolFI == true && faEmpty) ? "Search for Next" : "Send Trip Request",
        onPressed: controller.stopClicking.isFalse
            ? () => controller.handlePrimaryActionWhenInDate(
                  // Legacy used a global isCreateTrip; expose however you track it now
                  isCreateTrip: isCreateTrip, // TODO: wire up correctly
                )
            : null,
      );
    }

    // ========== isTripOutOfDate == true branch ==========
    // FA empty + only FA requested (no FI) -> Go To Home
    final onlyFARequested = controller.selectList.contains("Flight Attendant") == true &&
        !(controller.selectList.contains("Flight Instructor") || controller.selectList.contains("Instructor"));

    if (faEmpty && onlyFARequested) {
      return _primaryButton(
        label: "Go To Home",
        onPressed: () => Get.offAllNamed('/home'),
      );
    }

    // Else: main action -> "Search For Next" (when FA empty and FI also requested) or "Send Trip Request"
    final faEmptyHasFI =
        faEmpty && controller.selectList.contains("Flight Attendant") == true &&
            (controller.selectList.contains("Flight Instructor") || controller.selectList.contains("Instructor"));

    return _primaryButton(
      label: faEmptyHasFI ? "Search For Next" : "Send Trip Request",
      onPressed: () => controller.handlePrimaryActionOutOfDateFlow(),
    );
  }

  // ---------- Buttons (styled to match legacy) ----------
  Widget _primaryButton({required String label, VoidCallback? onPressed}) {
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
        onPressed: onPressed,
        child: Text(label, style: TextStyle(fontSize: 10.spV2)),
      ),
    );
  }

  Widget _secondaryButton({required String label, required VoidCallback onPressed}) {
    return MaterialButton(
      minWidth: 42.w,
      disabledColor: AppColor.secondaryColor1,
      disabledTextColor: AppColor.textColor2,
      textColor: AppColor.textColor2,
      color: AppColor.secondaryColor1,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Text(label, style: TextStyle(fontSize: 10.spV2)),
      onPressed: onPressed,
    );
  }

  Widget _destructiveButton({required String label, required VoidCallback onPressed}) {
    return MaterialButton(
      minWidth: 42.w,
      disabledColor: AppColor.deleteColor,
      disabledTextColor: AppColor.textColor1,
      textColor: AppColor.textColor1,
      color: AppColor.deleteColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColor.deleteColor, width: 0.6.w),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Text(label, style: TextStyle(fontSize: 10.spV2)),
      onPressed: onPressed,
    );
  }

  // ---------- Cupertino Delete Dialog ----------
  void _showDeleteConfirm(BuildContext context) {
    final cancelButton = TextButton(
      child: Text("No", style: TextStyle(color: AppColor.secondaryColor1)),
      onPressed: () => Get.back(),
    );

    final yesButton = TextButton(
      child: Text("Yes", style: TextStyle(color: AppColor.secondaryColor1)),
      onPressed: () async {
        Get.back(); // close alert
        await controller.deleteDraftTrip();
      },
    );

    final alert = CupertinoAlertDialog(
      content: const Text("Are you sure you want to delete trip?"),
      actions: [cancelButton, yesButton],
    );

    showDialog(
      context: context,
      builder: (_) => Theme(data: ThemeData.dark(), child: alert),
    );
  }
}