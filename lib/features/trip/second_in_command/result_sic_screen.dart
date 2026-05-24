import 'package:crew_support/api/api_service.dart';
import 'package:crew_support/app/routes.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart'; // <- spV2
import 'result_sic_controller.dart';

class ResultSICScreen extends GetWidget<ResultSICController> {
  const ResultSICScreen({super.key});

  // Helper: build single SIC row item exactly like legacy UI
  Widget _sicTile(BuildContext context, int index) {
    //final sic = controller.filterData!.sic[index];
    final sic = controller.filterData[index];

    return Container(
      margin: EdgeInsets.all(3.0.w),
      decoration: BoxDecoration(color: AppColor.bgColor1),
      child: InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.pilotViewProfile, arguments: {
            'profileId': sic.id,
            'userId': sic.userId,
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
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColor.secondaryColor1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: SizedBox(
                    height: 50.0.spV2,
                    width: 50.0.spV2,
                    child: Image.network(
                      sic.profilePictureUrl.toString(),
                      fit: BoxFit.fill,
                      height: 4.h,
                      width: 4.w,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColor.bgColor1,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
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
              Column(
                children: [
                  SizedBox(
                    width: 30.0.w,
                    child: Text(
                      //"${sic.pilotFname} ${sic.pilotLname}",
                      "${sic.firstName} ${sic.lastName}",
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
                    child: Text(
                      "State : ${sic.state}",
                      // "State : ${sic.AvailableState}",
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(
                        color: AppColor.secondaryColor2,
                        fontSize: 9.0.spV2,
                      ),
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  SizedBox(
                    width: 30.0.w,
                    child: Row(
                      children: [
                        Text(
                          //"City : ${sic.Availablecity}",
                          "City : ${sic.city}",
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
              // IconButton removed
              Theme(
                data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {}, // consume tap so parent InkWell doesn't fire
                  child: Obx(
                    () => Checkbox(
                      activeColor: AppColor.secondaryColor1,
                      checkColor: AppColor.textColor2,
                      onChanged: (bool? value) {
                        controller.onSelected(value ?? false, sic.id);
                      },
                      value: controller.pilotChecked.contains(sic.id),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bottom bar builder to mirror all legacy branches precisely
  Widget _buildBottomBar(BuildContext context) {
    final isOutOfDate = controller.isTripOutOfDate == true;
    //final noSIC = controller.filterData?.sic.isEmpty == true;
    final noSIC = controller.filterData.isEmpty == true;
    final fromPending = controller.fromPendingComputed;

    if (!isOutOfDate) {
      // ===== Legacy: _isTripOutOfDate == false branches =====
      if (noSIC &&
          fromPending == true &&
          controller.boolSIC == true &&
          (controller.boolFA == false || controller.boolFI == false)) {
        return _oneButtonBar(
          label: "Go To Home",
          onPressed: () => controller.goBackToDashboardAndReloadTrips(),
        );
      }

      if (noSIC &&
          fromPending == false &&
          controller.boolCAP == true &&
          controller.boolSIC == true &&
          controller.boolFI == false &&
          controller.boolFA == false) {
        return _oneButtonBar(
          label: "Go To Pending Tab",
          onPressed: () => controller.goBackToDashboardAndReloadTrips(),
        );
      }

      if (noSIC &&
          controller.boolCAP == false &&
          controller.boolSIC == true &&
          controller.boolFA == false &&
          controller.boolFI == false) {
        // Two buttons: Save draft / Delete trip
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 2.w),
              child: MaterialButton(
                minWidth: 42.w,
                disabledColor: AppColor.secondaryColor1,
                disabledTextColor: AppColor.textColor2,
                textColor: AppColor.textColor2,
                color: AppColor.secondaryColor1,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: AppColor.secondaryColor1, width: 0.6.w),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Text("Save as Draft",
                    style: TextStyle(fontSize: 10.spV2)),
                onPressed: () {
                  showMyDialog(context, 'Trip is saved in Draft').then((_) {
                    controller.goBackToDashboardAndReloadTrips();
                  });
                },
              ),
            ),
            SizedBox(width: 2.w),
            Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: MaterialButton(
                minWidth: 42.w,
                disabledColor: AppColor.deleteColor,
                disabledTextColor: AppColor.textColor1,
                textColor: AppColor.textColor1,
                color: AppColor.deleteColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: AppColor.deleteColor, width: 0.6.w),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child:
                    Text("Delete Trip", style: TextStyle(fontSize: 10.spV2)),
                onPressed: () {
                  _showDeleteDialog(context);
                },
              ),
            ),
          ],
        );
      }

      // Default primary button for create-flow
      final label = ((controller.boolFA || controller.boolFI) && noSIC)
          ? "Search for Next"
          : "Send Trip Request";

      return Obx(
        () => _oneButtonBar(
          label: label,
          onPressed: controller.stopClicking.value
              ? null
              : () => controller.handlePrimaryActionCreate(
                    showLoading: () => showLoadingDialog(context, 'Sending...'),
                    hideLoading: () => Navigator.of(context).maybePop(),
                    showDialog: (msg) async => showMyDialog(context, msg),
                  ),
        ),
      );
    } else {
      // ===== Legacy: _isTripOutOfDate == true branches =====
      if (noSIC &&
          controller.selectList.contains("Second In Command") == true &&
          (controller.selectList.contains("Flight Attendant") == false ||
              (controller.selectList.contains("Flight Instructor") == false ||
                  controller.selectList.contains("Instructor") == false))) {
        return _oneButtonBar(
          label: "Go To Home",
          onPressed: () => controller.goBackToDashboardAndReloadTrips(),
        );
      }

      final label = (noSIC &&
              controller.selectList.contains("Second In Command") == true &&
              (controller.selectList.contains("Flight Attendant") == true ||
                  controller.selectList.contains("Flight Instructor") == true ||
                  controller.selectList.contains("Instructor") == true))
          ? "Search For Next"
          : "Send Trip Request";

      return _oneButtonBar(
        label: label,
        onPressed: () async {
          await controller.handlePrimaryActionEdit(
            showLoading: () => showLoadingDialog(context, "Please Wait..."),
            hideLoading: () => Navigator.of(context).maybePop(),
            showDialog: (msg) async => showMyDialog(context, msg),
          );
        },
      );
    }
  }

  Widget _oneButtonBar({required String label, VoidCallback? onPressed}) {
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

  void _showDeleteDialog(BuildContext context) {
    final cancelButton = TextButton(
      child: Text("No", style: TextStyle(color: AppColor.secondaryColor1)),
      onPressed: () => Navigator.pop(context),
    );

    final yesButton = TextButton(
      child: Text("Yes", style: TextStyle(color: AppColor.secondaryColor1)),
      onPressed: () {
        Navigator.pop(context);
        showLoadingDialog(context, "Deleting...");
        deleteDraft(controller.tripId).then((_) {
          Navigator.pop(context);
          showMyDialog(context, 'Trip deleted successfully').then((_) {
            controller.goBackToDashboardAndReloadTrips();
          });
        });
      },
    );

    final alert = CupertinoAlertDialog(
      content: const Text("Are you sure you want to delete trip?"),
      actions: [cancelButton, yesButton],
    );

    showDialog(
      context: context,
      builder: (ctx) => Theme(data: ThemeData.dark(), child: alert),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.bgColor1,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Obx(
          () => WillPopScope(
            onWillPop: () async => controller.backButtonLocked.value == false,
            child: Scaffold(
              backgroundColor: AppColor.bgColor1,
              appBar: AppBar(
                elevation: 0,
                title: Text(
                  "Results - SIC",
                  style: TextStyle(color: AppColor.secondaryColor1),
                ),
                backgroundColor: AppColor.bgColor1,
                leading: IconButton(
                  onPressed: controller.backButtonLocked.value == false
                      ? () => Get.back()
                      : null,
                  icon: Icon(
                    Icons.adaptive.arrow_back_rounded,
                    color: AppColor.secondaryColor1,
                  ),
                ),
              ),
              //body: (controller.filterData?.sic.isNotEmpty == true)
              body: (controller.filterData.isNotEmpty == true)
                  ? SingleChildScrollView(
                      child: GestureDetector(
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: ListView.builder(
                          //itemCount: controller.filterData!.sic.length,
                          itemCount: controller.filterData.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: _sicTile,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 100.h,
                      child: Center(
                        child: Text(
                          controller.isTripOutOfDate == true
                              ? "No Crew Members are available on this selected dates\n ${controller.startDate} - ${controller.endDate}"
                              //: (controller.filterData?.sic.isEmpty == true &&
                              : (controller.filterData.isEmpty == true &&
                                      controller.fromPendingComputed == true &&
                                      controller.boolSIC == true &&
                                      (controller.boolFA == false ||
                                          controller.boolFI == false))
                                  ? "Second in command not found! \n\nPlease change the criteria and try again."
                                  //: (controller.filterData?.sic.isEmpty == true &&
                                  : (controller.filterData.isEmpty == true &&
                                          controller.fromPendingComputed == false &&
                                          controller.boolCAP == true &&
                                          controller.boolSIC == true &&
                                          controller.boolFI == false &&
                                          controller.boolFA == false)
                                      ? "Second in command not found! \n\nYou can add new crew member from pending tab."
                                      : "No result found",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColor.secondaryColor2),
                        ),
                      ),
                    ),
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
}