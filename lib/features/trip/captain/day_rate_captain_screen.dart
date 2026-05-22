import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'day_rate_captain_controller.dart';

class DayRateCaptainScreen extends GetWidget<DayRateCaptainController> {
  const DayRateCaptainScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColor.secondaryColor1,
          ),
        ),
        title: Text(
          "Day Rate - Captain",
          style: TextStyle(color: AppColor.secondaryColor1),
        ),
        backgroundColor: AppColor.bgColor1,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          // Legacy Screen2 inlined a loader while fetching drafts
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50.sp,
                  height: 50.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColor.secondaryColor1,
                  ),
                ),
                SizedBox(height: 2.h),
                Text("Loading...", style: TextStyle(color: AppColor.textColor1)),
              ],
            ),
          );
        }

        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.0.w,
                              vertical: 2.h,
                            ),
                            child: Text(
                              "Per Day",
                              style: TextStyle(
                                color: AppColor.textColor1,
                                fontWeight: FontWeight.w500,
                                fontSize: 10.spV2,
                              ),
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
                                  fontSize: 10.spV2,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.secondaryColor1,
                                ),
                              ),
                              Container(
                                width: 42.w,
                                margin: EdgeInsets.only(left: 3.w),
                                child: TextFormField(
                                  cursorColor: AppColor.secondaryColor1,
                                  controller: controller.dayRateController,
                                  keyboardType: const TextInputType.numberWithOptions(
                                    signed: true,
                                    decimal: false,
                                  ),
                                  style: TextStyle(
                                    fontSize: 10.spV2,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.secondaryColor1,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Enter Rate",
                                    hintStyle: TextStyle(
                                      color: AppColor.secondaryColor2,
                                      fontSize: 9.spV2,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
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
                    SizedBox(height: 4.h),

                    // Next
                    SizedBox(
                      width: 85.w,
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
                        onPressed: () => _showChoiceDialog(context),
                        child: Text(
                          "Next",
                          style: TextStyle(fontSize: 10.spV2),
                        ),
                      ),
                    ),

                    // Save as draft
                    if (!controller.isFromAddCrew) ...[
                      SizedBox(
                        width: 85.w,
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
                          onPressed: controller.onTapSaveDraft,
                          child: Text(
                            "Save as draft",
                            style: TextStyle(fontSize: 10.spV2),
                          ),
                        ),
                      ),
                    ]
                    
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Mirrors legacy AlertDialog: choose Search Crew vs Post Trip.
  void _showChoiceDialog(BuildContext context) {
    int selectedOption = 0; // 0: Search crew, 1: Post trip

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
            borderRadius: BorderRadius.circular(5.w),
          ),
          backgroundColor: AppColor.bgColor1,
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColor.bgColor1, width: 1.0),
                    ),
                    child: ListTile(
                      title: Text(
                        'Search for crew matching your criteria.',
                        style: TextStyle(
                          color: AppColor.secondaryColor1,
                          fontSize: 13.spV2,
                        ),
                      ),
                      leading: Radio<int>(
                        value: 0,
                        groupValue: selectedOption,
                        fillColor: MaterialStateColor.resolveWith(
                          (states) => AppColor.secondaryColor1,
                        ),
                        onChanged: (int? value) {
                          setState(() => selectedOption = value ?? 0);
                        },
                      ),
                    ),
                  ),
                  // SizedBox(height: 10),
                  // Container(
                  //   decoration: BoxDecoration(
                  //     border: Border.all(color: AppColor.bgColor1, width: 1.0),
                  //   ),
                  //   child: ListTile(
                  //     title: Text(
                  //       'Post trip for crew to apply',
                  //       style: TextStyle(
                  //         color: AppColor.secondaryColor1,
                  //         fontSize: 13.spV2,
                  //       ),
                  //     ),
                  //     leading: Radio<int>(
                  //       value: 1,
                  //       groupValue: selectedOption,
                  //       fillColor: MaterialStateColor.resolveWith(
                  //         (states) => AppColor.secondaryColor1,
                  //       ),
                  //       onChanged: (int? value) {
                  //         setState(() => selectedOption = value ?? 1);
                  //       },
                  //     ),
                  //   ),
                  // ),
                ],
              );
            },
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.secondaryColor1,
              ),
              child: Text('Cancel', style: TextStyle(color: AppColor.bgColor1)),
              onPressed: () => Get.back(),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.secondaryColor1,
                ),
                child: Text('OK', style: TextStyle(color: AppColor.bgColor1)),
                onPressed: () async {
                  if (selectedOption == 0) {
                    // Update pilotRate first, then navigate
                    Get.back(); // close choice dialog
                    // showLoadingDialogNew('Loading...');
                    try {
                      await controller.goToDayRateCaptain();
                    } catch (e) {
                      // debugPrint("closing Dialog");
                      // closeLoadingDialog();
                      showMyDialogNew(e.toString().replaceFirst('Exception: ', '') );
                      debugPrint('updateTrip/pilotRate error: $e');
                    }

                  } else {
                    // Post to Uncrewed
                    Get.back(); // close choice dialog
                    showLoadingDialog(context, 'Loading...');
                    try {
                      await controller.postToUncrewed();
                      Get.back(); // close loading

                      // Show confirmation (same copy as legacy)
                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: AppColor.secondaryColor1,
                              width: 0.6.w,
                            ),
                            borderRadius: BorderRadius.circular(5.w),
                          ),
                          backgroundColor: AppColor.bgColor1,
                          title: Text(
                            'Trip has been added to uncrewed tab.',
                            style: TextStyle(
                              color: AppColor.secondaryColor1,
                              fontSize: 12.spV2,
                            ),
                          ),
                          actions: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.secondaryColor1,
                                ),
                                child: Text('OK',
                                    style: TextStyle(color: AppColor.bgColor1)),
                                onPressed: () => Get.back(),
                              ),
                            ),
                          ],
                        ),
                      );

                      // Pop to first (legacy: Navigator.popUntil(...isFirst))
                      Get.until((route) => route.isFirst);
                    } catch (e) {
                      Get.back(); // close loading
                      showMyDialog(context, 'Failed to post trip');
                      print('postToUncrewed error: $e');
                    }
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}