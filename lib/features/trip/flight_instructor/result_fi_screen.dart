// lib/features/trip/flight_instructor/result_fi_screen.dart
// Screen for "Results - FI" (converted from old ResultFIScreen.dart)

import 'package:crew_support/app/routes.dart';
import 'package:crew_support/model/FilterPilotResponse.dart';
import 'package:crew_support/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'package:crew_support/utils/AppColor.dart'; // NEW path
import 'package:crew_support/utils/sizer_v2_compat.dart'; // for .spV2
import 'package:crew_support/utils/Utility.dart'; // showLoadingDialog, showMyDialog

import '../../../model/FilterFIResponse.dart';
import 'result_fi_controller.dart';

class ResultFiScreen extends GetView<ResultFiController> {
  const ResultFiScreen({super.key});

  /// Convenience to build a properly constructed binding+controller via arguments
  static Route<dynamic> routeFromOldArgs(Map<String, dynamic> args) {
    return GetPageRoute(
      routeName: AppRoutes.resultFI,
      page: () => const ResultFiScreen(),
      binding: BindingsBuilder(() {
        Get.put(ResultFiController(
          //filterData: args['filterData'] as Data?,
          filterData: args['filterData'] as List<AppUser>,
          tripId: args['tripId'] as int,
          airCraftID: args['airCraftID'] as int,
          boolCAP: args['boolCAP'] as bool,
          miles: args['miles'] as String,
          boolSIC: args['boolSIC'] as bool,
          boolFA: args['boolFA'] as bool,
          boolFI: args['boolFI'] as bool,
          rate: args['rate'],
          selectList: (args['selectList'] as List<dynamic>).cast<String>(),
          isTripOutOfDate: args['isTripOutOfDate'] as bool?,
          startDate: args['startDate'] as String?,
          endDate: args['endDate'] as String?,
          oldCrewMemberId: args['oldCrewMemberId'] as String?,
          membershipId: args['membershipId'] as String?,
        ));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available if not injected via route
    final c = Get.isRegistered<ResultFiController>()
        ? controller
        : Get.put(ResultFiController.fromArgs());

    return SafeArea(
      top: false,
      child: WillPopScope(
        onWillPop: () async => !c.backButtonEnabled.value, // match old logic
        child: Scaffold(
          backgroundColor: AppColor.bgColor1,
          appBar: AppBar(
            elevation: 0,
            title: Text("Results -FI",
                style: TextStyle(color: AppColor.secondaryColor1)),
            backgroundColor: AppColor.bgColor1,
            leading: IconButton(
              onPressed: () =>
                  !c.backButtonEnabled.value ? Get.back() : null,
              icon: Icon(
                Icons.adaptive.arrow_back_rounded,
                color: AppColor.secondaryColor1,
              ),
            ),
          ),

          /// ------------------------ BODY ------------------------
          //body: (c.filterData?.fi.isNotEmpty ?? false)
          body: (c.filterData.isNotEmpty)
              ? SingleChildScrollView(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: ListView.builder(
                      //itemCount: c.filterData!.fi.length,
                      itemCount: c.filterData.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        //final item = c.filterData!.fi[index];
                        final item = c.filterData[index];

                        return Container(
                          margin: EdgeInsets.all(3.0.w),
                          decoration: BoxDecoration(color: AppColor.bgColor1),
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
                            padding:
                                EdgeInsets.only(top: 1.0.h, bottom: 1.0.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppColor.secondaryColor1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: SizedBox(
                                      height: 50.0.sp,
                                      width: 50.0.sp,
                                      child: Image.network(
                                        //item.photoPath.toString(),
                                        "",
                                        fit: BoxFit.fill,
                                        height: 4.h,
                                        width: 4.w,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: AppColor.bgColor1,
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, exception,
                                            stackTrace) {
                                          return CircleAvatar(
                                            backgroundColor:
                                                AppColor.secondaryColor1,
                                            child: Icon(
                                              Icons.person,
                                              color: AppColor.bgColor1,
                                            ),
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
                                        //"${item.pilotFname} ${item.pilotLname}",
                                        "${item.firstName} ${item.lastName}",
                                        style: TextStyle(
                                          color: AppColor.secondaryColor1,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11.0.spV2, // spV2!
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    SizedBox(
                                      width: 30.0.w,
                                      child: Row(
                                        children: [
                                          Text(
                                            //"State : ${item.AvailableState}",
                                            "State : ",
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
                                            "City : ",
                                            // "City : ${item.Availablecity}",
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
                                IconButton(
                                  onPressed: () {
                                    // Old: Navigator.push -> PendingInstructorProfileScreen
                                    // New: navigate by name with the full object (or its id)
                                    //TODO:
                                    // Get.toNamed(
                                    //   AppRoutes.pendingInstructorProfile,
                                    //   arguments: {
                                    //     'viewProfileResponse': item,
                                    //   },
                                    // );
                                  },
                                  icon: Icon(
                                    Icons.person,
                                    color: AppColor.secondaryColor1,
                                    size: 18.0.sp,
                                  ),
                                ),
                                Theme(
                                  data: ThemeData(
                                    unselectedWidgetColor: AppColor.textColor1,
                                  ),
                                  child: Obx(
                                    () => Checkbox(
                                      activeColor: AppColor.secondaryColor1,
                                      checkColor: AppColor.textColor2,
                                      // value: c.pilotChecked.contains(
                                      //     item.pkPilotId),
                                      value: c.pilotChecked.contains(
                                          item.id),
                                      onChanged: (bool? value) {
                                        if (value == null) return;
                                        //c.onSelected(value, item.pkPilotId!);
                                        c.onSelected(value, item.id);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              : SizedBox(
                  height: 100.h,
                  child: Center(
                    child: Text(
                      c.isTripOutOfDateRx.value
                          ? "No Crew Members are available on this selected dates\n ${c.startDate} - ${c.endDate}"
                          //: (c.filterData?.fi.isEmpty == true &&
                          : (c.filterData.isEmpty == true &&
                                  c.boolFI == true &&
                                  c.boolFA == false &&
                                  c.boolCAP == false &&
                                  c.boolSIC == false)
                              ? "No result found"
                              : (fromPending == true)
                                  ? "Flight instructor not found! \n\nPlease change the criteria and try again."
                                  : "Flight instructor not found! \n\nYou can add new crew member from pending tab",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColor.secondaryColor2),
                    ),
                  ),
                ),

          /// ------------------------ BOTTOM BAR ------------------------
          bottomNavigationBar: Obx(() {
            // Mirror the old branching exactly
            if (!c.isTripOutOfDateRx.value) {
              // Not out of date
              //if (c.filterData?.fi.isEmpty == true &&
              if (c.filterData.isEmpty == true &&
                  c.boolFI == true &&
                  c.boolFA == false &&
                  c.boolCAP == false &&
                  c.boolSIC == false) {
                // Save Draft | Delete Trip
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
                            color: AppColor.secondaryColor1,
                            width: 0.6.w,
                          ),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        child: Text(
                          "Save as Draft",
                          style: TextStyle(fontSize: 10.spV2),
                        ),
                        onPressed: () {
                          showMyDialog(Get.context!, 'Trip is saved in Draft')
                              .then((_) {
                            Get.offAllNamed(AppRoutes.dashboard);
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
                          side: BorderSide(
                            color: AppColor.deleteColor,
                            width: 0.6.w,
                          ),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        child: Text(
                          "Delete Trip",
                          style: TextStyle(fontSize: 10.spV2),
                        ),
                        onPressed: () => _showCancelDialog(context, c),
                      ),
                    ),
                  ],
                );
              }

              //if (c.filterData?.fi.isEmpty == true &&
              if (c.filterData.isEmpty == true &&
                  c.boolFI == true &&
                  (c.boolCAP == true || c.boolFI == true || c.boolFA == true)) {
                // Go To Home OR Go To Pending Tab (based on fromPending)
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  child: MaterialButton(
                    disabledColor: AppColor.secondaryColor1,
                    disabledTextColor: AppColor.textColor2,
                    textColor: AppColor.textColor2,
                    color: AppColor.secondaryColor1,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: AppColor.secondaryColor1,
                        width: 0.6.w,
                      ),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    onPressed: !c.stopClicking.value
                        ? () {
                            Get.offAllNamed(
                              AppRoutes.dashboard,
                              arguments: {'toPending': fromPending == true},
                            );
                          }
                        : null,
                    child: Text(
                      fromPending == true ? "Go To Home" : "Go To Pending Tab",
                      style: TextStyle(fontSize: 10.spV2),
                    ),
                  ),
                );
              }

              // Default: Send Trip Request (NEW trip)
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 5.w),
                child: MaterialButton(
                  disabledColor: AppColor.secondaryColor1,
                  disabledTextColor: AppColor.textColor2,
                  textColor: AppColor.textColor2,
                  color: AppColor.secondaryColor1,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: AppColor.secondaryColor1,
                      width: 0.6.w,
                    ),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  onPressed: !c.stopClicking.value
                      ? () async {
                          if (c.pilotChecked.isEmpty) {
                            showMyDialog(
                              context,
                              "Please select flight instructor",
                            );
                            return;
                          }

                          showLoadingDialog(context, 'Sending...');
                          c.stopClicking.value = true;

                          await c.sendTripRequestNew(
                            onBefore: () {},
                            onSuccess: (msg) async {
                              Navigator.pop(context); // close loading
                              await showMyDialog(context, msg);
                              c.stopClicking.value = false;
                              c.backButtonEnabled.value = true;
                              Get.offAllNamed(AppRoutes.dashboard);
                            },
                            onError: (e) async {
                              Navigator.pop(context);
                              c.stopClicking.value = false;
                              await showMyDialog(
                                context,
                                e.toString(),
                              );
                            },
                          );
                        }
                      : null,
                  child: Text(
                    "Send Trip Request",
                    style: TextStyle(fontSize: 10.spV2),
                  ),
                ),
              );
            } else {
              // Trip is out of date
              final wantsFI = c.selectList.contains("Flight Instructor") ||
                  c.selectList.contains("Instructor");

              // return (c.filterData?.fi.isEmpty == true && wantsFI)
              return (c.filterData.isEmpty == true && wantsFI)
                  ? Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.w),
                      child: MaterialButton(
                        disabledColor: AppColor.secondaryColor1,
                        disabledTextColor: AppColor.textColor2,
                        textColor: AppColor.textColor2,
                        color: AppColor.secondaryColor1,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: AppColor.secondaryColor1,
                            width: 0.6.w,
                          ),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
                        child: Text(
                          "Go To Home",
                          style: TextStyle(fontSize: 10.spV2),
                        ),
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.w),
                      child: MaterialButton(
                        disabledColor: AppColor.secondaryColor1,
                        disabledTextColor: AppColor.textColor2,
                        textColor: AppColor.textColor2,
                        color: AppColor.secondaryColor1,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: AppColor.secondaryColor1,
                            width: 0.6.w,
                          ),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        onPressed: () async {
                          if (c.pilotChecked.isEmpty) {
                            await showMyDialog(
                                context, "Please select flight instructor");
                            return;
                          }

                          showLoadingDialog(context, 'Sending...');
                          await c.sendTripRequestEdit(
                            onBefore: () {},
                            onSuccess: (msg) async {
                              Navigator.pop(context);
                              await showMyDialog(context, msg);
                              Get.offAllNamed(AppRoutes.dashboard);
                            },
                            onError: (e) async {
                              Navigator.pop(context);
                              await showMyDialog(context, e.toString());
                            },
                          );
                        },
                        child: Text(
                          "Send Trip Request",
                          style: TextStyle(fontSize: 10.spV2),
                        ),
                      ),
                    );
            }
          }),
        ),
      ),
    );
  }

  /// Matches the old Cupertino confirm dialog UI, delegates deletion to controller
  void _showCancelDialog(BuildContext context, ResultFiController c) {
    final cancelButton = TextButton(
      child: Text("No", style: TextStyle(color: AppColor.secondaryColor1)),
      onPressed: () => Navigator.pop(context),
    );
    final yesButton = TextButton(
      child: Text("Yes", style: TextStyle(color: AppColor.secondaryColor1)),
      onPressed: () async {
        Navigator.pop(context);
        showLoadingDialog(context, "Deleting...");
        await c.confirmAndDeleteTrip();
        Navigator.pop(context); // close loading
        await showMyDialog(context, 'Trip deleted successfully');
        Get.offAllNamed(AppRoutes.dashboard);
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