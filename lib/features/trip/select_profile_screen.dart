import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart'; // for .spV2
import 'select_profile_controller.dart';

class SelectProfileScreen extends GetWidget<SelectProfileController> {
  const SelectProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Select Profile',
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
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final requirementsLoadError = controller.requirementsLoadError.value;

        return Stack(
          children: [
            SafeArea(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Column(
                  children: [
                    // Show a visible error message when saved requirements JSON fails to load.
                    // This is mainly useful for Add Crew flow because the next screen depends on those saved requirements.
                    if (requirementsLoadError.isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.bgColor1,
                          border: Border.all(
                            color: AppColor.secondaryColor1,
                            width: 0.3.w,
                          ),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        child: Text(
                          requirementsLoadError,
                          style: TextStyle(
                            fontSize: 9.5.spV2,
                            color: AppColor.secondaryColor1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    // Profile list: checkboxes for normal flow, radio buttons for Add Crew flow.
                    Obx(() {
                      final itemCount = controller.profileList.length;
                      return SizedBox(
                        height: itemCount * 10.h,
                        child: ListView(
                          physics: BouncingScrollPhysics(),
                          children: controller.profileList.keys.map((key) {
                            return Theme(
                              data: ThemeData(
                                unselectedWidgetColor: AppColor.textColor1,
                              ),
                              child: Obx(() {
                                final checked = controller.profileList[key] ?? false;

                                // Add Crew flow should allow only one missing role to be selected.
                                // Use RadioListTile here, while keeping CheckboxListTile for normal flow.
                                if (controller.fromAddCrew == true) {
                                  return RadioListTile<String>(
                                    title: Text(
                                      key,
                                      style: TextStyle(
                                        fontSize: 12.0.spV2, // sp → spV2 for legacy match
                                        color: AppColor.secondaryColor1,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    value: key,
                                    groupValue: checked ? key : null,
                                    activeColor: AppColor.secondaryColor1,
                                    onChanged: isLoading
                                        ? null
                                        : (_) => controller.toggleProfile(key, true),
                                  );
                                }

                                return CheckboxListTile(
                                  title: Text(
                                    key,
                                    style: TextStyle(
                                      fontSize: 12.0.spV2, // sp → spV2 for legacy match
                                      color: AppColor.secondaryColor1,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  value: checked,
                                  activeColor: AppColor.secondaryColor1,
                                  checkColor: AppColor.bgColor1,
                                  onChanged: isLoading
                                      ? null
                                      : (v) {
                                          if (v == null) return;
                                          controller.toggleProfile(key, v);
                                        },
                                );
                              }),
                            );
                          }).toList(),
                        ),
                      );
                    }),

                    // NEXT button: exact styling (width, border, colors, text size)
                    SizedBox(
                      width: 85.w,
                      child: MaterialButton(
                        disabledColor: AppColor.secondaryColor1.withOpacity(0.5),
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
                        onPressed: isLoading
                            ? null
                            : () => controller.handleNext(context),
                        child: Text(
                          isLoading ? 'LOADING...' : 'NEXT',
                          style: TextStyle(fontSize: 10.spV2), // sp → spV2
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Block taps and show a centered spinner while saved requirements are being loaded.
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.15),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColor.secondaryColor1,
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}