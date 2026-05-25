import 'package:crew_support/theme/app_theme.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:crew_support/widgets/shared/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../app/routes.dart';
import 'login_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.bg0,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   leading: Visibility(
      //       // visible: widget.isSwitch == false ? false : true,
      //       child: IconButton(
      //           onPressed: () => Navigator.pop(context),
      //           icon: Icon(
      //             Icons.adaptive.arrow_back_rounded,
      //             color: AppColor.btnColor1,
      //           ))),
      // ),
      body: SafeArea(
        // bottom: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: 
              Container(
            color: AppColors.bg1,
            height: size.height,
            width: size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.bg1,
                  ),
                  height: size.height * 0.35,
                  width: size.width,
                  child: Center(
                    child: Hero(
                      tag: 'appLogo',
                      child: SizedBox(
                        width: 50.w,
                        height: 30.h,
                        child: SvgPicture.asset(
                          "assets/logo.svg",
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 3.h,
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       flex: 2,
                      //       child: Padding(
                      //         padding: EdgeInsets.only(left: 5.w),
                      //         child: Text(
                      //           "Membership Type",
                      //           style: TextStyle(
                      //               fontWeight: FontWeight.w500,
                      //               color: AppColor.textColor1,
                      //               fontSize: 10.spV2),
                      //         ),
                      //       ),
                      //     ),
                      //     Expanded(
                      //       flex: 3,
                      //       child: TextFormField(
                      //         controller: controller.membershipType,
                      //         readOnly: true,
                      //         style: TextStyle(
                      //             fontSize: 10.spV2, color: AppColor.textColor1),
                      //         decoration: InputDecoration(
                      //           border: InputBorder.none,
                      //           hintText: " Select Type",
                      //           hintStyle:
                      //               TextStyle(color: AppColor.textColor1),
                      //           suffixIcon: Icon(Icons.arrow_drop_down,
                      //               color: AppColor.textColor1),
                      //         ),
                      //         onTap: () => controller.showMembershipPicker(context),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // Container(
                      //   height: 0.15.h,
                      //   width: 94.w,
                      //   color: AppColor.dividerColor,
                      // ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.only(left: 5.w),
                              child: Text(
                                "Email/Phone",
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
                              controller: controller.email,
                              style: TextStyle(
                                  fontSize: 10.spV2, color: AppColor.textColor1),
                              cursorColor: AppColor.btnColor1,
                              decoration: InputDecoration(
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppColor.btnColor1),
                                ),
                                border: InputBorder.none,
                                hintStyle:
                                    TextStyle(color: AppColor.textColor1),
                                hintText: " Email/Phone",
                              ),
                            ),
                          ),
                        ],
                      ),
                      // ),
                      Container(
                        height: 0.15.h,
                        width: 94.w,
                        color: AppColor.dividerColor,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.only(left: 5.w),
                              child: Text(
                                "Password",
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
                            child: Obx(() => TextFormField(
                              cursorColor: AppColor.btnColor1,
                              controller: controller.password,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: controller.obscureText.value,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                              ],
                              style: TextStyle(
                                fontSize: 10.spV2,
                                color: AppColor.textColor1,
                              ),
                              decoration: InputDecoration(
                                hintText: " Password",
                                hintStyle: TextStyle(
                                  color: AppColor.textColor1,
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppColor.btnColor1),
                                ),
                                suffixIcon: IconButton(
                                  icon: controller.obscureText.value
                                      ? const Icon(
                                          Icons.visibility_off,
                                          color: AppColor.disableIconColor,
                                        )
                                      : Icon(
                                          Icons.visibility,
                                          color: AppColor.textColor1,
                                        ),
                                  onPressed: () {
                                    controller.toggleObscureText();
                                  },
                                ),
                              ),
                            ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 0.15.h,
                        width: 94.w,
                        color: AppColor.dividerColor,
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.forgot),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text('Forgot Password ?',
                                    style: TextStyle(
                                        color: AppColor.textColor3,
                                        fontSize: 11.0.spV2)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 7.5.w),
                        child: Obx(() => AppButton(
                          label: 'Sign In',
                          onPressed: controller.submit,
                          loading: controller.loading.value,
                          variant: AppButtonVariant.primary,
                          expanded: true,
                        )),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 1.0.h, 0, 1.0.h),
                        child: Text(
                          'OR',
                          style: TextStyle(
                              color: AppColor.textColor1,
                              fontSize: 11.0.spV2,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 7.5.w),
                        child: AppButton(
                          label: 'Join Now',
                          onPressed: () => Get.toNamed(AppRoutes.register),
                          variant: AppButtonVariant.secondary,
                          expanded: true,
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.help);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 2.w, bottom: 1.5.h),
                          child: Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: Text(
                              "Help Center",
                              style: TextStyle(
                                fontSize: 10.spV2,
                                color: AppColor.textColor3,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColor.textColor3,
                                decorationThickness: 1.4,
                                decorationStyle: TextDecorationStyle.solid,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  //   return Scaffold(
  //     appBar: AppBar(title: const Text('Login')),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,

  //           TextField(
  //             controller: c.email,
  //             keyboardType: TextInputType.emailAddress,
  //             decoration: const InputDecoration(labelText: 'Email'),
  //           ),
  //           const SizedBox(height: 12),
  //           TextField(
  //             controller: c.password,
  //             obscureText: true,
  //             decoration: const InputDecoration(labelText: 'Password'),
  //           ),
  //           const SizedBox(height: 20),
  //           Obx(() => ElevatedButton(
  //             onPressed: c.loading.value ? null : c.submit,
  //             child: c.loading.value
  //                 ? const CircularProgressIndicator()
  //                 : const Text('Login'),
  //           )),
  //           const SizedBox(height: 12),
  //           Row(
  //             children: [
  //               TextButton(
  //                 onPressed: () => Get.toNamed(AppRoutes.register),
  //                 child: const Text('Create account'),
  //               ),
  //               const Spacer(),
  //               TextButton(
  //                 onPressed: () => Get.toNamed(AppRoutes.forgot),
  //                 child: const Text('Forgot password'),
  //               ),
  //             ],
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  }
}