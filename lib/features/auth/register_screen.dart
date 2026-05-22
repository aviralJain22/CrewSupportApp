import 'package:country_list_pick/country_list_pick.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/legal_urls.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart'; // 10.spV2 fix
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'register_controller.dart';

/// GetX view for Register screen:
/// - No setState; all reactive via Obx/controller
/// - Keeps original layout & styling
/// - Uses spV2 everywhere for legacy Sizer UI parity
class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColor.bgColor1,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Create an Account",
          style: TextStyle(fontSize: 15.spV2, color: AppColor.secondaryColor1),
        ),
        centerTitle: true,
        backgroundColor: AppColor.bgColor1,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColor.secondaryColor1,
          ),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                // ── Membership Type ───────────────────────────────────────────
                _RowField(
                  label: "Membership Type",
                  child: TextFormField(
                    controller: controller.membershipTypeController,
                    readOnly: true,
                    style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Membership Type",
                      hintStyle: TextStyle(color: AppColor.textColor1),
                      suffixIcon: Icon(Icons.arrow_drop_down, color: AppColor.textColor1),
                    ),
                    onTap: () => controller.showMembershipPickerCupertino(context),
                    validator: (v) => controller.validateNonEmpty(v, 'membership type'),
                  ),
                ),
                _Divider(),

                // ── Gender ────────────────────────────────────────────────────
                _RowField(
                  label: "Gender",
                  child: TextFormField(
                    controller: controller.genderController,
                    readOnly: true,
                    style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Select Gender",
                      hintStyle: TextStyle(color: AppColor.textColor1),
                      suffixIcon: Icon(Icons.arrow_drop_down, color: AppColor.textColor1),
                    ),
                    onTap: () => controller.showGenderPickerCupertino(context),
                    validator: (v) => controller.validateNonEmpty(v, 'gender'),
                  ),
                ),
                _Divider(),

                // ── First Name ────────────────────────────────────────────────
                _RowField(
                  label: "First Name",
                  child: TextFormField(
                    controller: controller.firstNameController,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1),
                    cursorColor: AppColor.btnColor1,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "First Name",
                      hintStyle: TextStyle(color: AppColor.textColor1),
                    ),
                    validator: (v) => controller.validateNonEmpty(v, 'first name'),
                  ),
                ),
                _Divider(),

                // ── Last Name ─────────────────────────────────────────────────
                _RowField(
                  label: "Last Name",
                  child: TextFormField(
                    controller: controller.lastNameController,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1),
                    cursorColor: AppColor.btnColor1,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Last Name",
                      hintStyle: TextStyle(color: AppColor.textColor1),
                    ),
                    validator: (v) => controller.validateNonEmpty(v, 'last name'),
                  ),
                ),
                // Your old code had a full-width grey bar here:
                Container(height: 0.15.h, width: 100.w, color: Colors.grey),

                // ── Email Address ─────────────────────────────────────────────
                _RowField(
                  label: "Email Address",
                  child: TextFormField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1),
                    cursorColor: AppColor.btnColor1,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Email",
                      hintStyle: TextStyle(color: AppColor.textColor1),
                    ),
                    validator: controller.validateEmail,
                  ),
                ),
                _Divider(),

                // ── Country Code ──────────────────────────────────────────────
                _RowField(
                  label: "Country Code",
                  child: CountryListPick(
                    appBar: AppBar(
                      backgroundColor: AppColor.btnColor1,
                      leading: IconButton(
                        onPressed: Get.back,
                        icon: Icon(Icons.adaptive.arrow_back_rounded, color: AppColor.textColor2),
                      ),
                      title: Text('Pick your country', style: TextStyle(color: AppColor.textColor2)),
                    ),
                    pickerBuilder: (context, countryCode) {
                      return Row(
                        children: [
                          Image.asset(
                            countryCode!.flagUri.toString(),
                            package: 'country_list_pick',
                            width: 5.w,
                            height: 5.h,
                          ),
                          const SizedBox(width: 10),
                          Text(countryCode.code.toString(),
                              style: TextStyle(fontSize: 8.spV2, color: AppColor.textColor1)),
                          Text(countryCode.dialCode.toString(),
                              style: TextStyle(fontSize: 8.spV2, color: AppColor.textColor1)),
                          Icon(Icons.arrow_drop_down, color: AppColor.textColor1),
                        ],
                      );
                    },
                    theme: CountryTheme(
                      isShowFlag: true,
                      isShowTitle: true,
                      isShowCode: true,
                      isDownIcon: true,
                      showEnglishName: true,
                      labelColor: AppColor.textColor2,
                    ),
                    initialSelection: 'US',
                    onChanged: controller.onCountryChanged,
                  ),
                ),
                _Divider(),

                // ── Phone Number ──────────────────────────────────────────────
                _RowField(
                  label: "Phone Number",
                  child: TextFormField(
                    controller: controller.phoneNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    cursorColor: AppColor.btnColor1,
                    style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Phone Number",
                      hintStyle: TextStyle(color: AppColor.textColor1),
                    ),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return 'Please enter phone number';
                      if (t.length < 10) return 'Please enter a valid phone number';
                      return null;
                    },
                  ),
                ),
                _Divider(),

                // ── Password ──────────────────────────────────────────────────
                _RowField(
                  label: "Password",
                  child: Obx(
                    () => TextFormField(
                      controller: controller.passwordController,
                      obscureText: controller.obscurePass.value,
                      keyboardType: TextInputType.visiblePassword,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1),
                      cursorColor: AppColor.btnColor1,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: " Password",
                        hintStyle: TextStyle(color: AppColor.textColor1),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscurePass.value ? Icons.visibility_off : Icons.visibility,
                            color: controller.obscurePass.value
                                ? AppColor.disableIconColor
                                : AppColor.textColor1,
                            size: 17.spV2,
                          ),
                          onPressed: controller.togglePassVisibility,
                        ),
                      ),
                      validator: controller.validatePassword,
                    ),
                  ),
                ),
                _Divider(),

                // ── Confirm Password ──────────────────────────────────────────
                _RowField(
                  label: "Confirm Password",
                  child: Obx(
                    () => TextFormField(
                      controller: controller.confirmPasswordController,
                      obscureText: controller.obscureConfirmPass.value,
                      keyboardType: TextInputType.visiblePassword,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: " Confirm Password",
                        hintStyle: TextStyle(color: AppColor.textColor1),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscureConfirmPass.value ? Icons.visibility_off : Icons.visibility,
                            color: controller.obscureConfirmPass.value
                                ? AppColor.disableIconColor
                                : AppColor.textColor1,
                            size: 17.spV2,
                          ),
                          onPressed: controller.toggleConfirmPassVisibility,
                        ),
                      ),
                      validator: controller.validateConfirmPassword,
                    ),
                  ),
                ),
                _Divider(),
                SizedBox(height: 3.h),

                // ── Terms ─────────────────────────────────────────────────────
                Theme(
                  data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                  child: Obx(
                    () => CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColor.btnColor1,
                      checkColor: AppColor.textColor2,
                      title: _TermsText(),
                      value: controller.acceptedTerms.value,
                      onChanged: (v) => controller.setAcceptedTerms(v ?? false),
                    ),
                  ),
                ),
                SizedBox(height: 1.h),

                // ── Submit button ─────────────────────────────────────────────
                Obx(
                  () => SizedBox(
                    width: 85.w,
                    height: 5.0.h,
                    child: MaterialButton(
                      disabledColor: AppColor.goldenColor2,
                      disabledTextColor: AppColor.bgColor1,
                      textColor: AppColor.bgColor1,
                      color: AppColor.goldenColor2,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: AppColor.goldenColor2, width: 0.6.w),
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      onPressed: controller.loading.value ? null : controller.submit,
                      child: controller.loading.value
                          ? const SizedBox(
                              height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text("Submit", style: TextStyle(fontSize: 10.spV2)),
                    ),
                  ),
                ),

                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?",
                        style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1)),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "Sign In",
                        style: TextStyle(fontSize: 10.spV2, color: AppColor.secondaryColor1),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────── Helpers / Widgets ─────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 0.15.h, width: 94.w, color: AppColor.dividerColor);
}

class _RowField extends StatelessWidget {
  final String label;
  final Widget child;
  const _RowField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(left: 5.w),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColor.textColor1,
                  fontSize: 10.spV2,
                ),
              ),
            ),
          ),
          Expanded(flex: 3, child: child),
        ],
      ),
    );
  }
}

class _TermsText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text('I accept', style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1)),
            const SizedBox(width: 5),
            _Link('Terms of use', LegalUrls.terms),
            Text(',', style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1)),
            const SizedBox(width: 2),
            _Link('Privacy Policy', LegalUrls.privacy),
            const SizedBox(width: 5),
            Text('and', style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Link('Disclaimer', LegalUrls.disclaimer),
            Text('.', style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1)),
          ],
        ),
      ],
    );
  }
}

class _Link extends StatelessWidget {
  final String text;
  final String url;
  const _Link(this.text, this.url);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar('Error', 'Could not launch $url',
              snackPosition: SnackPosition.BOTTOM);
        }
      },
      child: Text(text,
          style: TextStyle(color: AppColor.secondaryColor1, fontSize: 10.spV2)),
    );
  }
}


  // @override
  // Widget build(BuildContext context) {
  //   final c = Get.put(RegisterController());
  //   return Scaffold(
  //     appBar: AppBar(title: const Text('Register')),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: SingleChildScrollView(
  //         child: Column(
  //           children: [
  //             TextField(
  //               controller: c.name,
  //               decoration: const InputDecoration(labelText: 'Full name (optional)'),
  //             ),
  //             const SizedBox(height: 12),
  //             TextField(
  //               controller: c.email,
  //               keyboardType: TextInputType.emailAddress,
  //               decoration: const InputDecoration(labelText: 'Email'),
  //             ),
  //             const SizedBox(height: 12),
  //             TextField(
  //               controller: c.password,
  //               obscureText: true,
  //               decoration: const InputDecoration(labelText: 'Password'),
  //             ),
  //             const SizedBox(height: 12),
  //             TextField(
  //               controller: c.confirm,
  //               obscureText: true,
  //               decoration: const InputDecoration(labelText: 'Confirm password'),
  //             ),
  //             const SizedBox(height: 20),
  //             Obx(() => ElevatedButton(
  //               onPressed: c.loading.value ? null : c.submit,
  //               child: c.loading.value
  //                   ? const CircularProgressIndicator()
  //                   : const Text('Create account'),
  //             )),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );