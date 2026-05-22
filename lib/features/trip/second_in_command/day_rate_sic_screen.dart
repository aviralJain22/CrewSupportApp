import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart'; // <-- spV2
import 'day_rate_sic_controller.dart';

class DayRateSICScreen extends GetWidget<DayRateSicController> {
  const DayRateSICScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor.bgColor1,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.adaptive.arrow_back_rounded, color: AppColor.secondaryColor1),
        ),
        title: Text('Day Rate - SIC', style: TextStyle(color: AppColor.secondaryColor1, fontSize: 12.spV2)),
      ),

      // Only the parts that depend on Rx should be inside Obx to avoid the "improper use of Obx" warning.
      body: Obx(() {
        if (controller.isLoading.value) {
          return _LoadingPane();
        }
        return SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
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
                              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                              child: Text(
                                'Per Day',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.textColor1,
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
                                  controller.currencySymbol,
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
                                    cursorColor: AppColor.secondaryColor1,
                                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
                                    style: TextStyle(
                                      fontSize: 10.spV2,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.secondaryColor1,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter Rate',
                                      hintStyle: TextStyle(color: AppColor.secondaryColor2, fontSize: 10.spV2),
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
                            side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                          onPressed: () => controller.onTapNext(context),
                          child: Text('Next', style: TextStyle(fontSize: 10.spV2)),
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
                              side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                              borderRadius: BorderRadius.circular(2.w),
                            ),
                            onPressed: controller.onTapSaveDraft,
                            child: Text('Save as draft', style: TextStyle(fontSize: 10.spV2)),
                          ),
                        ),
                      ]
                      
                    ],
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

class _LoadingPane extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // To keep it lightweight without the external loading_animation_widget package here,
    // we’ll mimic the same layout; if you’re already using that package globally,
    // you can swap back to LoadingAnimationWidget.threeRotatingDots(...) like the legacy.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simple CircularProgressIndicator; replace with your loader widget if needed.
          SizedBox(
            width: 50.spV2,
            height: 50.spV2,
            child: CircularProgressIndicator(color: AppColor.secondaryColor1, strokeWidth: 3),
          ),
          SizedBox(height: 2.h),
          Text('Loading...', style: TextStyle(color: AppColor.textColor1, fontSize: 10.spV2)),
        ],
      ),
    );
  }
}