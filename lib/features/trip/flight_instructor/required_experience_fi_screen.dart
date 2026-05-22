// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart'; // for .spV2
import 'package:sizer/sizer.dart';

import 'required_experience_fi_controller.dart';

class RequiredExperienceFIScreen extends GetWidget<RequiredExperienceFIController> {
  const RequiredExperienceFIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Bind controller (so we can use named routes with bindings or put manually)
    // If you aren’t using bindings, uncomment next line:
    // final controller = Get.put(RequiredExperienceFIController());

    return WillPopScope(
      onWillPop: () async => controller.backBlocked ? false : true,
      child: Scaffold(
        backgroundColor: AppColor.bgColor1,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "Required Experience - FI ",
            style: TextStyle(color: AppColor.secondaryColor1),
          ),
          backgroundColor: AppColor.bgColor1,
          leading: IconButton(
            onPressed: () => controller.backBlocked ? null : Get.back(),
            icon: Icon(Icons.adaptive.arrow_back_rounded, color: AppColor.secondaryColor1),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            // Match the old “Loading...” look & sizing (use your dialog colors)
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // You used LoadingAnimationWidget in old code; here we keep the UX minimal.
                  SizedBox(
                    height: 50.spV2, width: 50.spV2,
                    child: CupertinoActivityIndicator(),
                  ),
                  SizedBox(height: 2.h),
                  Text('Loading...', style: TextStyle(color: AppColor.textColor1)),
                ],
              ),
            );
          }

          // Main form
          return SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        // ─────────────────────────────────────────────
                        // Total Time
                        // ─────────────────────────────────────────────
                        _rowLabelAndField(
                          label: "Total Time",
                          controller: controller.totalTimeController,
                          hint: "Enter Total Time",
                        ),
                        _divider(),
                        // ─────────────────────────────────────────────
                        // Dual Given Time
                        // ─────────────────────────────────────────────
                        _rowLabelAndField(
                          label: "Dual Given Time",
                          controller: controller.dualGivenController,
                          hint: "Enter Dual Given",
                        ),
                        _divider(),
                        // ─────────────────────────────────────────────
                        // Instrument Instructor (Yes/No)
                        // ─────────────────────────────────────────────
                        _rowYesNo(
                          label: "Instrument Instructor",
                          valueObs: controller.checkboxInstrumentYes,
                        ),
                        _divider(),
                        // ─────────────────────────────────────────────
                        // Multi Engine Instructor (Yes/No)
                        // ─────────────────────────────────────────────
                        _rowYesNo(
                          label: " Multi Engine Instructor",
                          valueObs: controller.checkboxEngineYes,
                        ),
                        _divider(),
                        // ─────────────────────────────────────────────
                        // Complex Time
                        // ─────────────────────────────────────────────
                        _rowLabelAndField(
                          label: " Complex Time",
                          controller: controller.complexTimeController,
                          hint: "Enter Complex Time",
                        ),
                        _divider(),
                        // ─────────────────────────────────────────────
                        // High Performance Time
                        // ─────────────────────────────────────────────
                        _rowLabelAndField(
                          label: " High Performance Time",
                          controller: controller.highPerformanceController,
                          hint: "Enter H.P. Time",
                        ),
                        _divider(),
                        // ─────────────────────────────────────────────
                        // Select Desired Rating
                        // ─────────────────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: EdgeInsets.only(left: 5.h),
                                child: Text(
                                  "Select Desired Rating",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.textColor1,
                                    fontSize: 9.5.spV2,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Obx(() {
                                return RatingBar.builder(
                                  itemSize: 18.0.spV2,
                                  unratedColor: AppColor.secondaryColor2,
                                  initialRating: controller.rating.value.toDouble(),
                                  minRating: 0,
                                  direction: Axis.horizontal,
                                  allowHalfRating: false,
                                  itemCount: 5,
                                  itemPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 10.0),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: AppColor.goldenColorNew,
                                    size: 17.0.spV2,
                                  ),
                                  onRatingUpdate: (ratings) => controller.rating.value = ratings.toInt(),
                                );
                              }),
                            ),
                          ],
                        ),
                        _divider(),
                        // ─────────────────────────────────────────────
                        // Tail Wheel Instructor (Yes/No)
                        // ─────────────────────────────────────────────
                        _rowYesNo(
                          label: " Tail Wheel Instructor",
                          valueObs: controller.checkboxWheelYes,
                        ),
                        _divider(),
                        // ─────────────────────────────────────────────
                        // Aerobatic Instructor (Yes/No)
                        // ─────────────────────────────────────────────
                        _rowYesNo(
                          label: " Aerobatic Instructor",
                          valueObs: controller.checkboxAcrobaticYes,
                        ),
                        _divider(),
                        SizedBox(height: 2.h),

                        // ─────────────────────────────────────────────
                        // Buttons: Next & Save as draft
                        // ─────────────────────────────────────────────
                        _primaryButton(
                          title: "Next",
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            if (controller.validateAndWarn(context)) {
                              controller.onNext();
                            }
                          },
                        ),
                        _primaryButton(
                          title: "Save as draft",
                          onPressed: () => controller.onSaveDraft(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // UI Helpers - keep layout 1:1 with legacy (spacing, sizes, styles)
  // ──────────────────────────────────────────────────────────────────────

  Widget _rowLabelAndField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.only(left: 5.h),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColor.textColor1,
                fontSize: 9.5.spV2,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontSize: 10.spV2,
              fontWeight: FontWeight.bold,
              color: AppColor.secondaryColor1,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _rowYesNo({
    required String label,
    required RxBool valueObs,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.only(left: 5.h),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColor.textColor1,
                fontSize: 9.5.spV2,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Obx(() {
            final val = valueObs.value;
            return Row(
              children: [
                Theme(
                  data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                  child: Checkbox(
                    checkColor: AppColor.textColor2,
                    activeColor: AppColor.secondaryColor1,
                    value: val,
                    onChanged: (_) => valueObs.value = true,
                  ),
                ),
                Text(
                  "Yes",
                  style: TextStyle(
                    fontSize: 10.spV2,
                    fontWeight: FontWeight.bold,
                    color: AppColor.secondaryColor1,
                  ),
                ),
                const SizedBox(width: 20),
                Theme(
                  data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                  child: Checkbox(
                    checkColor: AppColor.textColor2,
                    activeColor: AppColor.secondaryColor1,
                    value: !val,
                    onChanged: (_) => valueObs.value = false,
                  ),
                ),
                Text(
                  "No",
                  style: TextStyle(
                    fontSize: 10.spV2,
                    fontWeight: FontWeight.bold,
                    color: AppColor.secondaryColor1,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _divider() => Divider(
        indent: 10,
        endIndent: 10,
        thickness: 1,
        color: AppColor.secondaryColor1,
      );

  Widget _primaryButton({
    required String title,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 85.h,
      child: MaterialButton(
        disabledColor: AppColor.secondaryColor1,
        disabledTextColor: AppColor.textColor2,
        textColor: AppColor.textColor2,
        color: AppColor.secondaryColor1,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.h),
          borderRadius: BorderRadius.circular(2.h),
        ),
        onPressed: onPressed,
        child: Text(title, style: TextStyle(fontSize: 10.spV2)),
      ),
    );
  }
}