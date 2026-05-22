// rate_trip_screen.dart
//
// GetX view for the legacy PilotRatingScreen UI.
// UI kept the same:
// - AppBar title: "{OppMemberShipType} Rating Screen"
// - Loading spinner in center
// - Rating bar + "Your Comment:" + bordered TextField
// - Bottom button: SUBMITTED (disabled) if already rated, else SUBMIT

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';

import 'rate_trip_controller.dart';

class RateTripScreen extends GetWidget<RateTripController> {
  const RateTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor.bgColor1,
        leading: IconButton(
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColor.secondaryColor1,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "${controller.title} Rating Screen",
          style: TextStyle(color: AppColor.secondaryColor1),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
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

        return SafeArea(
          bottom: true,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                SizedBox(
                  width: 100.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RatingBar.builder(
                        itemSize: 20.0.spV2,
                        unratedColor: AppColor.secondaryColor2,
                        initialRating: controller.rating.value.toDouble(),
                        minRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(
                          horizontal: 1.0,
                          vertical: 20.0,
                        ),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: AppColor.goldenColorNew,
                          size: 20.0.spV2,
                        ),
                        onRatingUpdate: (ratings) {
                          controller.rating.value = ratings;
                        },
                        ignoreGestures: controller.isRating,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        "Your Comment:",
                        style: TextStyle(color: AppColor.textColor1),
                      ),
                      SizedBox(height: 2.h),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 3.w),
                        height: 10.h,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColor.secondaryColor2,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          spellCheckConfiguration: SpellCheckConfiguration(
                            misspelledTextStyle: TextStyle(
                              decorationStyle: TextDecorationStyle.wavy,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColor.deleteColor,
                            ),
                            spellCheckService: DefaultSpellCheckService(),
                          ),
                          controller: controller.commentController,
                          cursorColor: AppColor.secondaryColor1,
                          readOnly: controller.isEditable,
                          style: TextStyle(
                            fontSize: 10.spV2,
                            color: AppColor.secondaryColor1,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom button (same behavior as old)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 85.w,
                    child: MaterialButton(
                      textColor: AppColor.textColor2,
                      color: AppColor.secondaryColor1,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: AppColor.secondaryColor1,
                          width: 0.6.w,
                        ),
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      onPressed: controller.hasSubmitted
                          ? () {} // SUBMITTED (disabled-ish)
                          : () => controller.onSubmitPressed(),
                      child: Text(controller.hasSubmitted
                          ? "SUBMITTED"
                          : "SUBMIT"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}