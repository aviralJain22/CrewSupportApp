// lib/features/trip/flight_instructor/day_rate_fi_screen.dart
//
// Pixel-identical UI merged from DayRateFIScreen & DayRateFIScreen2.
// Fonts use .spV2; .w/.h are unchanged. Uses AppColor palette.
// Only the loading region is wrapped in Obx to avoid broad reactive rebuilds.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart'; // for .spV2

import 'day_rate_fi_controller.dart';

class DayRateFIScreen extends GetWidget<DayRateFIController> {
  const DayRateFIScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Day Rate - FI",
          style: TextStyle(color: AppColor.secondaryColor1),
        ),
        backgroundColor: AppColor.bgColor1,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColor.secondaryColor1,
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Obx(() {
            if (controller.isLoading.value) {
              // Loading block matches original (threeRotatingDots + "Loading...")
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingAnimationWidget.threeRotatingDots(
                      color: AppColor.secondaryColor1,
                      size: 50.sp, // size was .sp in original; visual OK to keep
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

            // Main body (same as original layout)
            return Column(
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
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.textColor1,
                                  fontSize: 10.spV2, // sp -> spV2
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
                          onPressed: () {
                            // Same dialog UI as original
                            int selectedOption = 0;
                            showDialog(
                              context: context,
                              builder: (BuildContext ctx) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: AppColor.secondaryColor1,
                                      width: 0.6.w,
                                    ),
                                    borderRadius: BorderRadius.circular(5.w),
                                  ),
                                  backgroundColor: AppColor.bgColor1,
                                  content: StatefulBuilder(
                                    builder: (BuildContext _, StateSetter setState) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColor.bgColor1,
                                                width: 1.0,
                                              ),
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
                                                onChanged: (val) {
                                                  setState(() => selectedOption = val ?? 0);
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColor.bgColor1,
                                                width: 1.0,
                                              ),
                                            ),
                                            child: ListTile(
                                              title: Text(
                                                'Post trip for crew to apply',
                                                style: TextStyle(
                                                  color: AppColor.secondaryColor1,
                                                  fontSize: 13.spV2,
                                                ),
                                              ),
                                              leading: Radio<int>(
                                                value: 1,
                                                groupValue: selectedOption,
                                                fillColor: MaterialStateColor.resolveWith(
                                                  (states) => AppColor.secondaryColor1,
                                                ),
                                                onChanged: (val) {
                                                  setState(() => selectedOption = val ?? 1);
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColor.secondaryColor1,
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(color: AppColor.bgColor1),
                                      ),
                                      onPressed: () => Navigator.of(ctx).pop(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColor.secondaryColor1,
                                        ),
                                        child: Text(
                                          'OK',
                                          style: TextStyle(color: AppColor.bgColor1),
                                        ),
                                        onPressed: () {
                                          if (selectedOption == 0) {
                                            // Go to search screen (named route)
                                            Navigator.of(ctx).pop();
                                            controller.goToSearchByFI();
                                          } else {
                                            // Post trip to Uncrewed with the same UX as your "1" screen
                                            Navigator.of(ctx).pop();
                                            _showPostedToUncrewedDialog(context);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            "Next",
                            style: TextStyle(fontSize: 10.spV2),
                          ),
                        ),
                      ),

                      // Save as draft
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
                          onPressed: controller.saveAsDraft,
                          child: Text(
                            "Save as draft",
                            style: TextStyle(fontSize: 10.spV2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Matches the "Trip has been added to uncrewed tab." dialog UX from the original.
  void _showPostedToUncrewedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
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
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.secondaryColor1,
                ),
                child: Text(
                  'OK',
                  style: TextStyle(color: AppColor.bgColor1),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // Then actually post + pop to root
                  controller.postTripToUncrewedAndPopToRoot();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}