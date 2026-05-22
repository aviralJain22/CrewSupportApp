import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'forgot_controller.dart';

/// Forgot Screen (GetX View) converted from legacy `ForgotPasswordScreen`.
/// ✅ UI is kept identical (labels, dividers, spacing, fonts using 10.spV2),
/// ✅ Uses Cupertino picker for membership type,
/// ✅ Uses EasyLoading for messages & showLoadingDialog for the loader.
class ForgotScreen extends GetView<ForgotController> {
  const ForgotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: Get.back,
          child: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColor.secondaryColor1,
            size: 24,
          ),
        ),
        title: Text(
          'Forgot Password',
          style: TextStyle(color: AppColor.secondaryColor1),
        ),
        backgroundColor: AppColor.bgColor1,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  // Email row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.w),
                          child: Text(
                            'Email',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColor.textColor1,
                              fontSize: 10.spV2,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(200),
                          ],
                          cursorColor: AppColor.btnColor1,
                          style: TextStyle(
                            fontSize: 10.spV2,
                            color: AppColor.textColor1,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: ' Email',
                            hintStyle: TextStyle(color: AppColor.textColor1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    indent: 10,
                    endIndent: 10,
                    thickness: 1,
                    color: AppColor.dividerColor,
                  ),

                  SizedBox(height: 5.h),

                  // Submit
                  SizedBox(
                    width: 85.w,
                    child: Obx(
                      () => MaterialButton(
                        disabledColor: AppColor.secondaryColor1,
                        disabledTextColor: AppColor.textColor2,
                        textColor: AppColor.textColor2,
                        color: AppColor.btnColor1,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: AppColor.btnColor1,
                            width: 0.6.w,
                          ),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        onPressed: controller.loading.value
                            ? null
                            : controller.submitForgot,
                        child: Text(
                          'Submit',
                          style: TextStyle(fontSize: 10.spV2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}