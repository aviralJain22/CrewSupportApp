// lib/features/auth/otp_screen.dart
// New GetX screen converted from old `otp_generate.dart`.
// UI is kept identical to legacy screen; logic moved to OtpController.
//
// IMPORTANT:
// - All font sizes now use `.spV2` to match the old Sizer behavior.
// - Uses Cupertino where legacy used adaptive icons.
// - Uses showLoadingDialog/showMyDialog where legacy used them.
// - Dismiss/Errors still use EasyLoading to match original UX.

import 'dart:io';

import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:sizer/sizer.dart';

import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/features/auth/otp_controller.dart';

class OtpScreen extends GetView<OtpController> {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return WillPopScope(
      onWillPop: () async => false, // prevent back swipe/back press
      child: Scaffold(
        backgroundColor: AppColor.bgColor1,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              height: size.height,
              width: size.width,
              color: AppColor.disableIconColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        color: AppColor.bgColor1,
                        height: size.height * 0.30,
                        width: size.width,
                        child: Center(
                          child: Hero(
                            tag: 'appLogo',
                            child: SizedBox(
                              width: 40.w,
                              height: 20.h,
                              child: SvgPicture.asset(
                                'assets/logo.svg',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Obx(
                        () => Visibility(
                          visible: controller.isFilled.value,
                          child: IconButton(
                            onPressed: Get.back,
                            icon: Icon(
                              Icons.adaptive.arrow_back_rounded,
                              color: AppColor.textColor1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 2.0.h),
                        child: Text(
                          'Enter Verification Code',
                          style: TextStyle(
                            fontSize: 20.0.spV2,
                            fontWeight: FontWeight.bold,
                            color: AppColor.btnColor1,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 2.0.h),
                        child: Text(
                          'We have sent a verification code on',
                          style: TextStyle(
                            fontSize: 12.0.spV2,
                            fontWeight: FontWeight.w300,
                            color: AppColor.textColor1,
                          ),
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 1.0.h),
                          child: Text(
                            '${controller.dialCode} ${controller.phoneNumber}',
                            // controller.countryCode == '1'
                            //     ? '+${controller.countryCode} ${controller.phoneNumber}'
                            //     : controller.email,
                            style: TextStyle(
                              fontSize: 13.0.spV2,
                              fontWeight: FontWeight.bold,
                              color: AppColor.textColor1,
                            ),
                          ),
                        ),
                      SizedBox(height: 3.h),
                      SizedBox(height: 3.h),
                      _buildPinField(context),
                      Obx(
                        () => controller.showTimer.value
                            ? Visibility(
                                visible: controller.otpPressed.value ? false : true,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          12.0.w, 5.0.h, 2.0.w, 0),
                                      child: Text(
                                        "Didn't receive code?",
                                        style: TextStyle(
                                          color: AppColor.textColor1,
                                          fontSize: 15.0.spV2,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: controller.resendOtp,
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            1.0.w, 5.0.h, 2.0.w, 0),
                                        child: Text(
                                          'Resend OTP',
                                          style: TextStyle(
                                            color: AppColor.btnColor1,
                                            fontSize: 15.0.spV2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        23.0.w, 5.0.h, 2.0.w, 0),
                                    child: Text(
                                      'You can resend after',
                                      style: TextStyle(
                                        color: AppColor.textColor1,
                                        fontSize: 15.0.spV2,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        2.0.w, 5.0.h, 2.0.w, 0),
                                    child: StreamBuilder<int>(
                                      stream: controller.secondTimeStream,
                                      initialData:
                                          controller.initialSecondTime.value,
                                      builder: (context, snap) {
                                        final value = snap.data ?? 0;
                                        return Text(
                                          value.toString(),
                                          style: TextStyle(
                                            color: AppColor.btnColor1,
                                            fontSize: 15.0.spV2,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinField(BuildContext context) {
    return PinCodeTextField(
      autofocus: true,
      controller: controller.otpController,
      hideCharacter: false,
      highlightColor: AppColor.bgColor2,
      defaultBorderColor: AppColor.bgColor2,
      maxLength: controller.otpCodeLength,
      onTextChanged: (text) async {
        if (Platform.isAndroid && text.length == 4) {
          await controller.otpDone();
        }
      },
      onDone: (text) async {
        if (Platform.isIOS == true) {
          await controller.otpDone();
        } else if (Platform.isAndroid == true && text.length == 4) {
          await controller.otpDone();
        }
      },
      pinBoxWidth: 50,
      pinBoxHeight: 64,
      hasUnderline: false,
      wrapAlignment: WrapAlignment.spaceAround,
      pinBoxDecoration: ProvidedPinBoxDecoration.defaultPinBoxDecoration,
      pinTextStyle: TextStyle(fontSize: 22.0.spV2),
      pinTextAnimatedSwitcherTransition:
          ProvidedPinBoxTextAnimation.scalingTransition,
      pinTextAnimatedSwitcherDuration: const Duration(milliseconds: 300),
      highlightAnimationBeginColor: AppColor.textColor2,
      highlightAnimationEndColor: AppColor.textColor1,
      keyboardType: TextInputType.number,
    );
  }
}