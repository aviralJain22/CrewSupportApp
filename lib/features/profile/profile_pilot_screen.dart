// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:crew_support/utils/AppColor.dart';               // ✅ new path
import 'package:crew_support/utils/sizer_v2_compat.dart';        // ✅ spV2
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'profile_pilot_controller.dart';

class ProfilePilotScreen extends GetView<ProfilePilotController> {
  const ProfilePilotScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Obx(() => controller.isLoadingPage.value
        ? SizedBox(
            height: 55.h,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Use your existing loader or keep as-is:
                  CupertinoActivityIndicator(),
                  SizedBox(height: 2.h),
                  Text('Loading...', style: TextStyle(color: AppColor.textColor1, fontSize: 11.spV2)),
                ],
              ),
            ),
          )
        : SafeArea(
            child: Scaffold(
              backgroundColor: AppColor.bgColor1,
              bottomNavigationBar: Obx(() {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1.0,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: controller.hasAnyChange
                      ? Container(
                          key: const ValueKey('pilot_update_bar'),
                          margin: EdgeInsets.only(left: 5.0.w, right: 5.0.w),
                          // child: SizedBox(
                          //   width: 85.w,
                            child: MaterialButton(
                              disabledColor: AppColor.secondaryColor1,
                              disabledTextColor: AppColor.textColor2,
                              textColor: AppColor.textColor2,
                              color: AppColor.secondaryColor1,
                              minWidth: double.infinity,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                                borderRadius: BorderRadius.circular(2.w),
                              ),
                              onPressed: () => controller.onUpdatePressed(context),
                              child: Text("Update", style: TextStyle(fontSize: 10.spV2)),
                            ),
                          // ),
                        )
                      : const SizedBox(
                          key: ValueKey('pilot_update_bar_empty'),
                          height: 0,
                        ),
                );
              }),
              body: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView(
                  children: [
                    // ---------- Avatar + Edit (Cupertino sheet) ----------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 1.h),
                          child: Obx(() => CircleAvatar(
                                radius: 55.spV2,
                                backgroundColor: AppColor.secondaryColor1,
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(55.spV2),
                                      child: SizedBox(
                                        height: 110.0.spV2,
                                        width: 110.0.spV2,
                                        child: Image.network(
                                          controller.selectedImage.value,
                                          fit: BoxFit.fill,
                                          loadingBuilder: (context, child, progress) {
                                            if (progress == null) return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                color: AppColor.bgColor1,
                                                value: progress.expectedTotalBytes != null
                                                    ? progress.cumulativeBytesLoaded /
                                                        (progress.expectedTotalBytes ?? 1)
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, _, __) => CircleAvatar(
                                            backgroundColor: AppColor.secondaryColor1,
                                            child: Icon(Icons.account_circle, color: AppColor.bgColor1, size: 60),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      right: 5,
                                      child: GestureDetector(
                                        onTap: () => controller.showChoiceDialog(context),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(width: 3, color: AppColor.bgColor1),
                                            borderRadius: const BorderRadius.all(Radius.circular(50)),
                                            color: AppColor.secondaryColor1,
                                            boxShadow: const [BoxShadow(blurRadius: 3)],
                                          ),
                                          child: Icon(Icons.edit, color: AppColor.bgColor1),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      ],
                    ),
                    Divider(
                      indent: 10,
                      endIndent: 10,
                      thickness: 2,
                      color: AppColor.secondaryColor1,
                    ),

                    // ---------- Row: Membership Type | Gender ----------
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _LabeledBox(
                            label: "Membership Type",
                            child: TextField(
                              controller: controller.membershipTypeController,
                              readOnly: true,
                              style: TextStyle(
                                fontSize: 11.spV2,
                                fontWeight: FontWeight.bold,
                                color: AppColor.secondaryColor2,
                              ),
                              decoration: const InputDecoration(border: InputBorder.none),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: _LabeledBox(
                            label: "Gender",
                            child: Obx(
                              () => DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: controller.safeGenderValue(),
                                  hint: Text(
                                    'Select Gender',
                                    style: TextStyle(color: AppColor.secondaryColor2, fontSize: 9.spV2),
                                  ),
                                  dropdownColor: AppColor.bgColor1,
                                  icon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.keyboard_arrow_down),
                                      // legacy "update" tick UI:
                                      _updateMarker(visible: controller.genderBool.value),
                                    ],
                                  ),
                                  style: TextStyle(
                                    fontSize: 11.spV2,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.secondaryColor1,
                                  ),
                                  isExpanded: true,
                                  items: controller.itemsGender
                                      .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                                      .toList(),
                                  onChanged: (newValue) {
                                    final old = controller.gender;
                                    controller.genderController.text = newValue ?? "";
                                    controller.gender = controller.genderController.text;
                                    controller.genderBool.value = (controller.gender != old);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    // ---------- First Name ----------
                    _Label("First Name"),
                    _BoxedField(
                      controller: controller.firstNameController,
                      textCapitalization: TextCapitalization.words,
                      hint: "Enter First Name",
                      onChanged: (_) {
                        controller.firstNameBool.value =
                            controller.firstNameController.text != controller.firstName;
                      },
                    ),
                    SizedBox(height: 2.h),

                    // ---------- Last Name ----------
                    _Label("Last Name"),
                    _BoxedField(
                      controller: controller.lastNameController,
                      textCapitalization: TextCapitalization.words,
                      hint: "Enter Last Name",
                      onChanged: (_) {
                        controller.lastNameBool.value =
                            controller.lastNameController.text != controller.lastName;
                      },
                    ),
                    SizedBox(height: 2.h),

                    // ---------- Email ----------
                    _Label("Email Address"),
                    _BoxedField(
                      controller: controller.emailController,
                      hint: "Enter Email",
                      maxLines: 2,
                      readOnly: true,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) {
                        controller.emailBool.value =
                            controller.emailController.text != controller.email;
                      },
                    ),
                    SizedBox(height: 2.h),

                    // ---------- Row: Phone | Current Location ----------
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _LabeledBox(
                            label: "Phone Number",
                            child: Obx(
                              () => TextField(
                                readOnly: true,
                                controller: controller.phoneNumberController,
                                keyboardType: const TextInputType.numberWithOptions(
                                  signed: true, decimal: true,
                                ),
                                onChanged: (_) {
                                  controller.phoneBool.value =
                                      controller.phoneNumberController.text != controller.phoneNumber;
                                },
                                inputFormatters: [
                                  // same as old (numeric only)
                                  FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                                ],
                                style: TextStyle(
                                  fontSize: 10.spV2,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.secondaryColor1,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  suffixIcon: _updateMarker(visible: controller.phoneBool.value),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: _LabeledBox(
                            label: "Current Location",
                            child: Obx(
                              () => DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  dropdownColor: AppColor.bgColor1,
                                  value: controller.safeLocationValue(),
                                  icon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.keyboard_arrow_down),
                                      _updateMarker(visible: controller.currentLocaBool.value),
                                    ],
                                  ),
                                  style: TextStyle(
                                    fontSize: 10.spV2,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.secondaryColor1,
                                  ),
                                  items: controller.itemsLocation
                                      .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                                      .toList(),
                                  onChanged: (newValue) async {
                                    FocusScope.of(context).unfocus();

                                    // Start the dedicated permission flow only when the
                                    // user explicitly changes the Current Location field.
                                    // The controller will automatically revert the value
                                    // if permission is not sufficient.
                                    await controller.onCurrentLocationChanged(context, newValue);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    // ---------- Row: Rating (read-only) | Passport ----------
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _LabeledBox(
                            label: "Rating",
                            child: Padding(
                              padding: EdgeInsets.only(left: 1.0.w, top: 0.2.h, bottom: 0.6.h),
                              child: Obx(
                                () => IgnorePointer(
                                  ignoring: true,
                                  child: Row(
                                    children: List.generate(5, (idx) {
                                      final star = controller.ratingCount.value.clamp(0, 5);
                                      final isFilled = idx + 1 <= star;
                                      final isHalf = !isFilled &&
                                          (idx + 1 - star).abs() < 1 &&
                                          (star - idx) > 0 &&
                                          (star - idx) < 1;
                                      return Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 1.0.w),
                                        child: Icon(
                                          isFilled
                                              ? Icons.star
                                              : (isHalf ? Icons.star_half : Icons.star_border),
                                          size: 16.spV2,
                                          color: AppColor.goldenColorNew,
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: _LabeledBox(
                            label: "Passport",
                            child: Obx(
                              () => DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: controller.safePassportValue(),
                                  dropdownColor: AppColor.bgColor1,
                                  icon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.keyboard_arrow_down),
                                      _updateMarker(visible: controller.passportBool.value),
                                    ],
                                  ),
                                  style: TextStyle(
                                    fontSize: 10.spV2,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.secondaryColor1,
                                  ),
                                  isExpanded: true,
                                  items: controller.itemsPassport
                                      .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                                      .toList(),
                                  onChanged: (newValue) {
                                    final old = controller.passport;
                                    controller.passportController.text = newValue ?? "";
                                    controller.passport = controller.passportController.text;
                                    controller.passportBool.value = (controller.passport != old);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // …existing Row: Rating | Passport ends here…

SizedBox(height: 2.h),
Container(
  margin: EdgeInsets.only(left: 3.w, right: 3.w),
  decoration: BoxDecoration(
    border: Border.all(color: AppColor.secondaryColor1, width: 3.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(10.sp),
  ),
  child: Row(
    children: [
      Expanded(
        flex: 2,
        child: Padding(
          padding: EdgeInsets.all(8.0.sp),
          child: Text(
            "Allow operator to send trip requests regardless of availability?",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColor.secondaryColor1,
              fontSize: 9.5.spV2,
            ),
          ),
        ),
      ),
      Expanded(
        flex: 2,
        child: Obx(() => Row(
          children: [
            Theme(
              data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
              child: Checkbox(
                checkColor: AppColor.bgColor1,
                activeColor: AppColor.secondaryColor1,
                value: controller.isIgnoreAvailability,
                onChanged: (v) {
                  FocusScope.of(context).unfocus();
                  controller.allowBool.value = true;
                  controller.isIgnoreAvailability = true;
                  if (controller.isIgnoreAvailabilityCheck == controller.isIgnoreAvailability) {
                    controller.allowBool.value = false;
                  }
                },
              ),
            ),
            Text("Yes", style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1)),
            Theme(
              data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
              child: Checkbox(
                checkColor: AppColor.bgColor1,
                activeColor: AppColor.secondaryColor1,
                value: !controller.isIgnoreAvailability,
                onChanged: (v) {
                  FocusScope.of(context).unfocus();
                  controller.allowBool.value = true;
                  controller.isIgnoreAvailability = false;
                  if (controller.isIgnoreAvailabilityCheck == controller.isIgnoreAvailability) {
                    controller.allowBool.value = false;
                  }
                },
              ),
            ),
            Text("No", style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1)),
            SizedBox(width: 2.w),
            _updateMarker(visible: controller.allowBool.value),
          ],
        )),
      ),
    ],
  ),
),

SizedBox(height: 2.h),
Container(
  margin: EdgeInsets.only(left: 3.w, right: 3.w),
  decoration: BoxDecoration(
    border: Border.all(color: AppColor.secondaryColor1, width: 3.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(10.sp),
  ),
  child: Row(
    children: [
      Expanded(
        flex: 2,
        child: Padding(
          padding: EdgeInsets.all(8.0.sp),
          child: Text(
            "Only display resume to operators?",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColor.secondaryColor1,
              fontSize: 9.5.spV2,
            ),
          ),
        ),
      ),
      Expanded(
        flex: 2,
        child: Obx(() => Row(
          children: [
            Theme(
              data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
              child: Checkbox(
                checkColor: AppColor.bgColor1,
                activeColor: AppColor.secondaryColor1,
                value: controller.isShowResume,
                onChanged: (v) {
                  FocusScope.of(context).unfocus();
                  controller.showResume.value = true;
                  controller.isShowResume = true;
                  if (controller.isShowResumeCheck == controller.isShowResume) {
                    controller.showResume.value = false;
                  }
                },
              ),
            ),
            Text("Yes", style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1)),
            Theme(
              data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
              child: Checkbox(
                checkColor: AppColor.bgColor1,
                activeColor: AppColor.secondaryColor1,
                value: !controller.isShowResume,
                onChanged: (v) {
                  FocusScope.of(context).unfocus();
                  controller.showResume.value = true;
                  controller.isShowResume = false;
                  if (controller.isShowResumeCheck == controller.isShowResume) {
                    controller.showResume.value = false;
                  }
                },
              ),
            ),
            Text("No", style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1)),
            SizedBox(width: 2.w),
            _updateMarker(visible: controller.showResume.value),
          ],
        )),
      ),
    ],
  ),
),

SizedBox(height: 2.h),
Container(
  margin: EdgeInsets.only(left: 3.w, right: 3.w),
  decoration: BoxDecoration(
    border: Border.all(color: AppColor.secondaryColor1, width: 3.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(10.sp),
  ),
  child: Row(
    children: [
      Expanded(
        flex: 2,
        child: Padding(
          padding: EdgeInsets.all(8.0.sp),
          child: Text(
            "Are you looking for full time work?",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColor.secondaryColor1,
              fontSize: 9.5.spV2,
            ),
          ),
        ),
      ),
      Expanded(
        flex: 2,
        child: Obx(() => Row(
          children: [
            Theme(
              data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
              child: Checkbox(
                checkColor: AppColor.bgColor1,
                activeColor: AppColor.secondaryColor1,
                value: controller.isFullTime,
                onChanged: (v) {
                  FocusScope.of(context).unfocus();
                  controller.fullTime.value = true;
                  controller.isFullTime = true;
                  if (controller.isFullTimeCheck == controller.isFullTime) {
                    controller.fullTime.value = false;
                  }
                },
              ),
            ),
            Text("Yes", style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1)),
            Theme(
              data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
              child: Checkbox(
                checkColor: AppColor.bgColor1,
                activeColor: AppColor.secondaryColor1,
                value: !controller.isFullTime,
                onChanged: (v) {
                  FocusScope.of(context).unfocus();
                  controller.fullTime.value = true;
                  controller.isFullTime = false;
                  if (controller.isFullTimeCheck == controller.isFullTime) {
                    controller.fullTime.value = false;
                  }
                },
              ),
            ),
            Text("No", style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1)),
            SizedBox(width: 2.w),
            _updateMarker(visible: controller.fullTime.value),
          ],
        )),
      ),
    ],
  ),
),

SizedBox(height: 2.h),
Obx(() {
  final path = controller.resumePathRx.value.trim().isEmpty
      ? (controller.resumePath ?? '').trim()
      : controller.resumePathRx.value.trim();
  final hasResume = path.isNotEmpty && path != "http";

  if (hasResume) {
    // Legacy 'Your Resume' tile with View / Edit / Delete actions
    return Container(
      margin: EdgeInsets.only(left: 3.w, right: 3.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColor.secondaryColor1,
          width: 3.0,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(10.sp),
      ),
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: ListTile(
        title: Text(
          'Your Resume',
          style: TextStyle(
            fontSize: 10.spV2,
            fontWeight: FontWeight.bold,
            color: AppColor.secondaryColor1,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => controller.openResume(context),
              icon: Icon(Icons.remove_red_eye, color: AppColor.secondaryColor1),
            ),
            IconButton(
              onPressed: () => controller.pickAndUploadResume(context),
              icon: Icon(Icons.edit, color: AppColor.secondaryColor1),
            ),
            IconButton(
              onPressed: () => controller.deleteResume(context),
              icon: Icon(Icons.delete, color: AppColor.secondaryColor1),
            ),
          ],
        ),
      ),
    );
  }

  // Fallback (legacy): Upload tile with PDF icon & hint text
  return GestureDetector(
    onTap: () => controller.pickAndUploadResume(context),
    child: Container(
      margin: EdgeInsets.only(left: 3.w, right: 3.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColor.resumeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.solidFilePdf,
            color: AppColor.textColor2,
            size: 25.spV2,
          ),
          SizedBox(height: 1.h),
          Text(
            "Upload Your Resume Here",
            style: TextStyle(fontSize: 12.spV2, color: AppColor.textColor2),
          ),
        ],
      ),
    ),
  );
}),

// -------- Bio --------
SizedBox(height: 2.h),
_Label("Bio"),
_BoxedField(
  controller: controller.bioController,
  hint: "Enter Bio Details",
  maxLines: 5,
  onChanged: (_) {
    controller.bioBool.value =
        controller.bioController.text != controller.bio;
  },
),

SizedBox(height: 2.h),

// -------- Row: Total Time | PIC Time (legacy layout) --------
Row(
  children: [
    Expanded(
      flex: 2,
      child: _LabeledBox(
        label: "Total Time",
        child: Obx(() => TextField(
              controller: controller.totalTimeController,
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
              style: TextStyle(
                fontSize: 10.spV2,
                fontWeight: FontWeight.bold,
                color: AppColor.secondaryColor1,
              ),
              onChanged: (_) {
                controller.totalBool.value =
                    controller.totalTimeController.text != controller.totalTime;
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Enter Total Time",
                hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                suffixIcon: _updateMarker(visible: controller.totalBool.value),
              ),
            )),
      ),
    ),
    Expanded(
      flex: 2,
      child: _LabeledBox(
        label: "PIC Time",
        child: Obx(() => TextField(
              controller: controller.picTimeController,
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
              style: TextStyle(
                fontSize: 10.spV2,
                fontWeight: FontWeight.bold,
                color: AppColor.secondaryColor1,
              ),
              onChanged: (_) {
                controller.picBool.value =
                    controller.picTimeController.text != controller.picTime;
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Enter PIC Time",
                hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                suffixIcon: _updateMarker(visible: controller.picBool.value),
              ),
            )),
      ),
    ),
  ],
),

SizedBox(height: 2.h),

// -------- Medical Class (read-only, opens picker) --------
_LabeledBox(
  label: "Medical Class",
  child: Obx(() => TextField(
        controller: controller.medicalClassController,
        readOnly: true,
        onTap: () {
          FocusScope.of(context).unfocus();
          controller.showMedicalPicker(context);
          controller.medicalBool.value = true;
        },
        style: TextStyle(
          fontSize: 10.spV2,
          fontWeight: FontWeight.bold,
          color: AppColor.secondaryColor1,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          suffixIcon: _updateMarker(visible: controller.medicalBool.value),
        ),
      )),
),

// -------- Country of Citizenship (read-only, multi-line) --------
_LabeledBox(
  label: "Country of Citizenship",
  child: Obx(() => TextField(
        controller: controller.citizenship,
        maxLines: 3,
        readOnly: true,
        onTap: () {
          FocusScope.of(context).unfocus();
          controller.citizenLocation(context);
          // Legacy code set a flag here; marker toggled via update flow if needed.
        },
        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
        style: TextStyle(
          fontSize: 10.spV2,
          fontWeight: FontWeight.bold,
          color: AppColor.secondaryColor1,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Country of Citizenship",
          hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
          suffixIcon: _updateMarker(visible: controller.countryBool.value),
        ),
      )),
),

SizedBox(height: 2.h),

// -------- Passport Expiration Date (read-only date) --------
_Label("Passport Expiration Date"),
Padding(
  padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 1.0.h),
  child: Container(
    decoration: BoxDecoration(
      border: Border.all(color: AppColor.secondaryColor1, width: 3.0, style: BorderStyle.solid),
      borderRadius: BorderRadius.circular(10.sp),
    ),
    child: Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Obx(() => TextField(
            controller: controller.passportExpireDateController,
            readOnly: true,
            onTap: () {
              FocusScope.of(context).unfocus();
              controller.selectPassportDate(context);
              // Legacy toggles passportDateBool here after comparing old vs new; we keep a simple marker trigger:
              controller.passportDateBool.value = true;
            },
            style: TextStyle(
              fontSize: 10.spV2,
              fontWeight: FontWeight.bold,
              color: AppColor.secondaryColor1,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Enter Passport Expiration Date",
              hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
              suffixIcon: _updateMarker(visible: controller.passportDateBool.value),
              contentPadding: const EdgeInsets.only(left: 0, bottom: 15, top: 11, right: 0),
            ),
          )),
    ),
  ),
),

// -------- Special Training --------
_Label("Special Training"),
Padding(
  padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 1.0.h),
  child: Container(
    decoration: BoxDecoration(
      border: Border.all(color: AppColor.secondaryColor1, width: 3.0, style: BorderStyle.solid),
      borderRadius: BorderRadius.circular(10.sp),
    ),
    child: Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Obx(() {
        final changed = (controller.isSpecialTrainingRx.value != controller.specialTrainingValue);
        return Row(
          children: [
            Theme(
              data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
              child: Checkbox(
                checkColor: AppColor.bgColor1,
                activeColor: AppColor.secondaryColor1,
                value: controller.isSpecialTrainingRx.value,
                onChanged: (value) {
                  FocusScope.of(context).unfocus();
                  controller.isSpecialTraining = true;
                  controller.isSpecialTrainingRx.value = true;
                },
              ),
            ),
            Text("Yes", style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1)),
            SizedBox(width: 5.w),
            Theme(
              data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
              child: Checkbox(
                checkColor: AppColor.bgColor1,
                activeColor: AppColor.secondaryColor1,
                value: !controller.isSpecialTrainingRx.value,
                onChanged: (value) {
                  FocusScope.of(context).unfocus();
                  controller.isSpecialTraining = false;
                  controller.isSpecialTrainingRx.value = false;
                },
              ),
            ),
            Text("No", style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1)),
            SizedBox(width: 3.w),
            _updateMarker(visible: changed),
          ],
        );
      }),
    ),
  ),
),

// -------- Select Training (only if isSpecialTraining) --------
Obx(() => controller.isSpecialTrainingRx.value
    ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 1.0.h),
            child: Row(
              children: [
                Text(
                  "Select Training",
                  style: TextStyle(
                    color: AppColor.textColor1,
                    fontFamily: 'ProductSans',
                    fontSize: 10.0.spV2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 1.0.w),
                  child: IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      controller.selectTrainingDialog(context);
                    },
                    icon: Icon(Icons.add_circle_outline_rounded, color: AppColor.historyRead),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 0.0.h),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.secondaryColor1, width: 3.0, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(10.sp),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 8.0, top: 0.8.h, bottom: 0.8.h, right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    controller.selectTrainingDialog(context);
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80.w,
                        child: (controller.selectTrainingSaveList.isNotEmpty)
                            ? Text(
                                controller.selectTrainingSaveList.join(", "),
                                style: TextStyle(
                                  fontSize: 10.spV2,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.secondaryColor1,
                                ),
                              )
                            : Text(
                                "Select Training",
                                style: TextStyle(color: AppColor.secondaryColor2, fontSize: 9.spV2),
                              ),
                      ),
                      SizedBox(width: 3.w),
                      _updateMarker(
                        visible: controller.selectTrainingSaveList.join(", ") != controller.selectTrainingStr,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    : SizedBox.shrink()),

// -------- Other Training (only when final selection is "Other") --------
Obx(() => (controller.isSpecialTrainingRx.value && controller.selectTrainingFinalList.contains("Other"))
    ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label("Other Training"),
          Padding(
            padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 1.0.h),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.secondaryColor1, width: 3.0, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(10.sp),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextField(
                  controller: controller.otherTrainingController,
                  onChanged: (value) {
                    // mirror legacy change-dot logic
                    // controller.specialNameBool not reactive; use text comparison instead when drawing marker
                  },
                  style: TextStyle(
                    fontSize: 10.spV2,
                    fontWeight: FontWeight.bold,
                    color: AppColor.secondaryColor1,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixIcon: _updateMarker(
                      visible: controller.otherTrainingController.text != controller.otherTraining,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    : SizedBox.shrink()),

// -------- Type Rating --------
Container(
  margin: EdgeInsets.only(left: 3.0.w, right: 2.0.w, top: 1.0.h, bottom: 2.h),
  alignment: Alignment.centerLeft,
  child: Text(
    "Type Rating",
    textAlign: TextAlign.left,
    style: TextStyle(color: AppColor.historyRead, fontSize: 12.spV2),
  ),
),
Container(
  margin: EdgeInsets.only(left: 3.w, right: 3.w),
  decoration: BoxDecoration(
    border: Border.all(color: AppColor.secondaryColor1, width: 3.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(10.sp),
  ),
  child: Column(
    children: [
      SizedBox(height: 1.h),
      Row(
        children: [
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: () => controller.openAddRatingType(context),
            child: Icon(Icons.add_circle_outline, size: 29, color: AppColor.deleteColor),
          ),
          GestureDetector(
            onTap: () => controller.openAddRatingType(context),
            child: Text(
              "   Add Type Ratings",
              style: TextStyle(fontWeight: FontWeight.w500, color: AppColor.secondaryColor1, fontSize: 9.spV2),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () => controller.openEditTypeRatings(context),
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                children: [
                  Icon(Icons.edit, size: 29, color: AppColor.deleteColor),
                  GestureDetector(
                    onTap: () => controller.openEditTypeRatings(context),
                    child: Text(
                      '  Edit Type Ratings',
                      style: TextStyle(fontWeight: FontWeight.w500, color: AppColor.secondaryColor1, fontSize: 9.spV2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      Divider(indent: 10, endIndent: 10, thickness: 1, color: AppColor.secondaryColor1),
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Text('Type Ratings', style: TextStyle(fontSize: 7.5.spV2, color: AppColor.textColor1)),
          ),
        ],
      ),
      Obx(() => controller.isLoadingRatings.value
          ? SizedBox(
              height: 8.h,
              child: Center(child: CupertinoActivityIndicator()),
            )
          : SizedBox(
              height: controller.ratingData.length * 35,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.ratingData.length,
                itemBuilder: (context, index) {
                  final item = controller.ratingData[index];
                  final ac = (item.aircraftType ?? '').isEmpty ? ' ' : (item.aircraftType ?? '');
                  return Padding(
                    padding: const EdgeInsets.only(left: 18.0, top: 5),
                    child: SizedBox(
                      height: 30,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: open details dialog if needed
                        },
                        child: Row(
                          children: [
                            Text(
                              ac,
                              style: TextStyle(
                                color: AppColor.secondaryColor1,
                                fontSize: 10.spV2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )),

      Divider(indent: 10, endIndent: 10, thickness: 1, color: AppColor.transparent),

      // -------- Continent Exp. (inside Type Rating card, as legacy) --------
      // Row(
      //   children: [
      //     Expanded(
      //       flex: 2,
      //       child: Padding(
      //         padding: EdgeInsets.symmetric(horizontal: 5.0.w, vertical: 2.h),
      //         child: GestureDetector(
      //           onTap: () => controller.preLocation(context),
      //           child: Text(
      //             "Continent Exp.",
      //             style: TextStyle(fontWeight: FontWeight.w500, color: AppColor.textColor1, fontSize: 9.5.spV2),
      //           ),
      //         ),
      //       ),
      //     ),
      //     Expanded(
      //       flex: 2,
      //       child: Padding(
      //         padding: EdgeInsets.only(right: 1.w),
      //         child: GestureDetector(
      //           onTap: () => controller.preLocation(context),
      //           child: Row(
      //             children: [
      //               SizedBox(
      //                 width: 35.w,
      //                 child: (controller.continentSaveList.isEmpty || controller.continentSaveList[0] == "")
      //                     ? Text(
      //                         "Enter Continent Exp.",
      //                         style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor2),
      //                       )
      //                     : Text(
      //                         controller.continentSaveList.join(", "),
      //                         style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1),
      //                         overflow: TextOverflow.ellipsis,
      //                         maxLines: 2,
      //                       ),
      //               ),
      //               SizedBox(width: 2.w),
      //               _updateMarker(visible: controller.continentBool.value),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      // Divider(indent: 10, endIndent: 10, thickness: 1, color: AppColor.secondaryColor1),

      // // -------- Oceanic Exp. (inside Type Rating card, as legacy) --------
      // Row(
      //   children: [
      //     Expanded(
      //       flex: 2,
      //       child: Padding(
      //         padding: EdgeInsets.symmetric(horizontal: 5.0.w, vertical: 2.h),
      //         child: GestureDetector(
      //           onTap: () => controller.oceanic(context),
      //           child: Text(
      //             "Oceanic Exp.",
      //             style: TextStyle(fontWeight: FontWeight.w500, color: AppColor.textColor1, fontSize: 9.5.spV2),
      //           ),
      //         ),
      //       ),
      //     ),
      //     Expanded(
      //       flex: 2,
      //       child: Padding(
      //         padding: EdgeInsets.only(right: 1.w),
      //         child: GestureDetector(
      //           onTap: () => controller.oceanic(context),
      //           child: Row(
      //             children: [
      //               SizedBox(
      //                 width: 35.w,
      //                 child: (controller.oceanicSaveList.isEmpty || controller.oceanicSaveList[0] == "")
      //                     ? Text(
      //                         "Enter Oceanic Exp.",
      //                         style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor2),
      //                       )
      //                     : Text(
      //                         controller.oceanicSaveList.join(", "),
      //                         style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1),
      //                         overflow: TextOverflow.ellipsis,
      //                         maxLines: 2,
      //                       ),
      //               ),
      //               SizedBox(width: 2.w),
      //               _updateMarker(visible: controller.oceanicBool.value),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
   
    ],
  ),
),

                    // ---------- You can continue the remaining sections the same way ----------
                    // The pattern above (small Obx islands + spV2) will keep UI identical and avoid Obx misuse.

SizedBox(height: 2.h),
// -------- Continent & Oceanic Experience (moved outside Type Rating card) --------
Container(
  margin: EdgeInsets.only(left: 3.w, right: 3.w),
  decoration: BoxDecoration(
    border: Border.all(
      color: AppColor.secondaryColor1,
      width: 3.0,
      style: BorderStyle.solid,
    ),
    borderRadius: BorderRadius.circular(10.sp),
  ),
  child: Column(
    children: [
      // -------- Region Exp. --------
      Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0.w, vertical: 2.h),
              child: GestureDetector(
                onTap: () => controller.preLocation(context),
                child: Text(
                  "Region Experience",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColor.textColor1,
                    fontSize: 9.5.spV2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(right: 1.w),
              child: GestureDetector(
                onTap: () => controller.preLocation(context),
                child: Row(
                  children: [
                    SizedBox(
                      width: 35.w,
                      child: (controller.continentSaveList.isEmpty ||
                              controller.continentSaveList[0] == "")
                          ? Text(
                              "Enter Region Experience",
                              style: TextStyle(
                                fontSize: 10.spV2,
                                fontWeight: FontWeight.bold,
                                color: AppColor.secondaryColor2,
                              ),
                            )
                          : Text(
                              controller.continentSaveList.join(", "),
                              style: TextStyle(
                                fontSize: 10.spV2,
                                fontWeight: FontWeight.bold,
                                color: AppColor.secondaryColor1,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                    ),
                    SizedBox(width: 2.w),
                    _updateMarker(visible: controller.continentBool.value),
                  ],
                ),
              ),
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
      // -------- Oceanic Exp. --------
      Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0.w, vertical: 2.h),
              child: GestureDetector(
                onTap: () => controller.oceanic(context),
                child: Text(
                  "Oceanic Experience",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColor.textColor1,
                    fontSize: 9.5.spV2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(right: 1.w),
              child: GestureDetector(
                onTap: () => controller.oceanic(context),
                child: Row(
                  children: [
                    SizedBox(
                      width: 35.w,
                      child: (controller.oceanicSaveList.isEmpty ||
                              controller.oceanicSaveList[0] == "")
                          ? Text(
                              "Enter Oceanic Experience",
                              style: TextStyle(
                                fontSize: 10.spV2,
                                fontWeight: FontWeight.bold,
                                color: AppColor.secondaryColor2,
                              ),
                            )
                          : Text(
                              controller.oceanicSaveList.join(", "),
                              style: TextStyle(
                                fontSize: 10.spV2,
                                fontWeight: FontWeight.bold,
                                color: AppColor.secondaryColor1,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                    ),
                    SizedBox(width: 2.w),
                    _updateMarker(visible: controller.oceanicBool.value),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  ),
),

                    
                    // -------- Share Profile --------
Container(
  margin: EdgeInsets.only(left: 3.0.w, right: 2.0.w, top: 2.0.h, bottom: 2.h),
  alignment: Alignment.centerLeft,
  child: Row(
    children: [
      Text(
        "Share Profile",
        textAlign: TextAlign.left,
        style: TextStyle(color: AppColor.historyRead, fontSize: 12.spV2),
      ),
      SizedBox(width: 2.0.w),
      Tooltip(
        margin: EdgeInsets.only(left: 3.0.w, right: 3.0.w),
        message:
            'You can paste a profile link or just type your username (for example: @johnsmith).\n\nUse Verify to make sure the link is valid.\nUse Preview to open and review your profile before saving.',
        triggerMode: TooltipTriggerMode.tap,
        showDuration: const Duration(seconds: 10), // ✅ controls how long it stays visible after showing
        textStyle: TextStyle(fontSize: 10.0.spV2, color: AppColor.textColor1),
        preferBelow: false,
        decoration: BoxDecoration(
          color: AppColor.bgColor2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.secondaryColor1, width: 1),
        ),
        child: Icon(Icons.info_outline, color: AppColor.deleteColor),
      ),
      SizedBox(width: 2.w),
      GestureDetector(
        onTap: () => controller.isClicked.value == false
            ? () {
                controller.isClicked.value = true;
                controller.createDynamicLink(
                  context,
                  link: controller.pkPilotId.toString(),
                  short: true,
                );
              }()
            : null,
        child: Icon(Icons.share, color: AppColor.textColor1),
      ),
    ],
  ),
),

// -------- Instagram --------
Padding(
  padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w),
  child: Row(
    children: [
      Text(
        "Instagram  ",
        style: TextStyle(color: AppColor.textColor1, fontSize: 10.0.spV2, fontWeight: FontWeight.bold),
      ),
      SizedBox(
        height: 2.0.h,
        child: Image.asset("assets/instagram.png", fit: BoxFit.contain),
      ),
    ],
  ),
),
Padding(
  padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 1.0.h),
  child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColor.secondaryColor1,
            width: 3.0,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(10.spV2),
        ),
        child: Padding(
    padding: const EdgeInsets.only(left: 8.0),
    child: Obx(() => TextFormField(
      controller: controller.instagramController,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => controller.canonicalizeOnDone(platform: 'instagram'),
      onEditingComplete: () => controller.canonicalizeOnDone(platform: 'instagram'),
      onChanged: (_) {
        controller.instaBool.value =
            controller.instagramController.text != controller.instagram;
        if (controller.instagramStatus.value.isNotEmpty) {
          controller.instagramStatus.value = '';
        }
      },
      maxLines: 1,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(
        fontSize: 10.spV2,
        fontWeight: FontWeight.bold,
        color: AppColor.secondaryColor1,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Enter instagram link or @username',
        hintStyle: TextStyle(color: AppColor.secondaryColor2, fontSize: 9.spV2),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Verify',
              icon: Icon(Icons.verified_outlined,
                  size: 18.spV2, color: AppColor.secondaryColor1),
              onPressed: () =>
                  controller.verifySocial(context, platform: 'instagram'),
            ),
            IconButton(
              tooltip: 'Preview',
              icon: Icon(Icons.open_in_new,
                  size: 18.spV2, color: AppColor.secondaryColor1),
              onPressed: () =>
                  controller.previewSocial(context, platform: 'instagram'),
            ),
            _updateMarker(visible: controller.instaBool.value),
          ],
        ),
      ),
    )),
  ),
      ),
),
Obx(() {
  if (controller.instagramStatus.value.isEmpty) return const SizedBox.shrink();
  final ok = controller.instagramStatus.value == 'valid';
  return Padding(
    padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 0.5.h),
    child: Row(
      children: [
        Icon(ok ? Icons.check_circle : Icons.error,
            size: 14.spV2, color: ok ? Colors.green : Colors.red),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            ok
                ? 'Looks like a valid Instagram profile link.'
                : 'This does not look like a valid Instagram profile link.',
            style: TextStyle(color: AppColor.textColor1, fontSize: 9.spV2),
          ),
        ),
      ],
    ),
  );
}),

// -------- Facebook --------
Padding(
  padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 1.0.h),
  child: Row(
    children: [
      Text(
        "Facebook  ",
        style: TextStyle(color: AppColor.textColor1, fontSize: 10.0.spV2, fontWeight: FontWeight.bold),
      ),
      SizedBox(
        height: 2.0.h,
        child: Image.asset("assets/facebook.png", fit: BoxFit.contain),
      ),
    ],
  ),
),
Padding(
  padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 1.0.h),
  child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColor.secondaryColor1,
            width: 3.0,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(10.spV2),
        ),
        child: Padding(
    padding: const EdgeInsets.only(left: 8.0),
    child: Obx(() => TextFormField(
      controller: controller.facebookController,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => controller.canonicalizeOnDone(platform: 'facebook'),
      onEditingComplete: () => controller.canonicalizeOnDone(platform: 'facebook'),
      onChanged: (_) {
        controller.facebookBool.value =
            controller.facebookController.text != controller.facebook;
        if (controller.facebookStatus.value.isNotEmpty) {
          controller.facebookStatus.value = '';
        }
      },
      maxLines: 1,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(
        fontSize: 10.spV2,
        fontWeight: FontWeight.bold,
        color: AppColor.secondaryColor1,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Enter facebook link or @username',
        hintStyle: TextStyle(color: AppColor.secondaryColor2, fontSize: 9.spV2),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Verify',
              icon: Icon(Icons.verified_outlined,
                  size: 18.spV2, color: AppColor.secondaryColor1),
              onPressed: () =>
                  controller.verifySocial(context, platform: 'facebook'),
            ),
            IconButton(
              tooltip: 'Preview',
              icon: Icon(Icons.open_in_new,
                  size: 18.spV2, color: AppColor.secondaryColor1),
              onPressed: () =>
                  controller.previewSocial(context, platform: 'facebook'),
            ),
            _updateMarker(visible: controller.facebookBool.value),
          ],
        ),
      ),
    )),
  ),
      ),
  ),
Obx(() {
  if (controller.facebookStatus.value.isEmpty) return const SizedBox.shrink();
  final ok = controller.facebookStatus.value == 'valid';
  return Padding(
    padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 0.5.h),
    child: Row(
      children: [
        Icon(ok ? Icons.check_circle : Icons.error,
            size: 14.spV2, color: ok ? Colors.green : Colors.red),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            ok
                ? 'Looks like a valid Facebook profile link.'
                : 'This does not look like a valid Facebook profile link.',
            style: TextStyle(color: AppColor.textColor1, fontSize: 9.spV2),
          ),
        ),
      ],
    ),
  );
}),

// -------- LinkedIn --------
Padding(
  padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 1.0.h),
  child: Row(
    children: [
      Text(
        "Linkedin  ",
        style: TextStyle(color: AppColor.textColor1, fontSize: 10.0.spV2, fontWeight: FontWeight.bold),
      ),
      SizedBox(
        height: 2.0.h,
        child: Image.asset("assets/linkedin.png", fit: BoxFit.contain),
      ),
    ],
  ),
),
Padding(
  padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 1.0.h),
  child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColor.secondaryColor1,
            width: 3.0,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(10.spV2),
        ),
        child: Padding(
    padding: const EdgeInsets.only(left: 8.0),
    child: Obx(() => TextFormField(
      controller: controller.linkedinController,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => controller.canonicalizeOnDone(platform: 'linkedin'),
      onEditingComplete: () => controller.canonicalizeOnDone(platform: 'linkedin'),
      onChanged: (_) {
        controller.linkedinBool.value =
            controller.linkedinController.text != controller.linkedin;
        if (controller.linkedinStatus.value.isNotEmpty) {
          controller.linkedinStatus.value = '';
        }
      },
      maxLines: 1,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(
        fontSize: 10.spV2,
        fontWeight: FontWeight.bold,
        color: AppColor.secondaryColor1,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Enter linkedIn link or @username',
        hintStyle: TextStyle(color: AppColor.secondaryColor2, fontSize: 9.spV2),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Verify',
              icon: Icon(Icons.verified_outlined,
                  size: 18.spV2, color: AppColor.secondaryColor1),
              onPressed: () =>
                  controller.verifySocial(context, platform: 'linkedin'),
            ),
            IconButton(
              tooltip: 'Preview',
              icon: Icon(Icons.open_in_new,
                  size: 18.spV2, color: AppColor.secondaryColor1),
              onPressed: () =>
                  controller.previewSocial(context, platform: 'linkedin'),
            ),
            _updateMarker(visible: controller.linkedinBool.value),
          ],
        ),
      ),
    )),
  ),
      ),
  ),
Obx(() {
  if (controller.linkedinStatus.value.isEmpty) return const SizedBox.shrink();
  final ok = controller.linkedinStatus.value == 'valid';
  return Padding(
    padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 0.5.h),
    child: Row(
      children: [
        Icon(ok ? Icons.check_circle : Icons.error,
            size: 14.spV2, color: ok ? Colors.green : Colors.red),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            ok
                ? 'Looks like a valid LinkedIn profile link.'
                : 'This does not look like a valid LinkedIn profile link.',
            style: TextStyle(color: AppColor.textColor1, fontSize: 9.spV2),
          ),
        ),
      ],
    ),
  );
}),

SizedBox(height: 3.h),

                  ],
                ),
              ),
            ),
          ));
  }

  // ---------- Small labeled UI helpers (kept identical look) ----------

  Widget _Label(String text) => Padding(
        padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 1.0.h),
        child: Text(
          text,
          style: TextStyle(
            color: AppColor.textColor1,
            fontFamily: 'ProductSans',
            fontSize: 10.0.spV2,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _updateMarker({required bool visible}) {
    // This reproduces the small trailing “changed” indicator logic you used.
    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.only(right: 6.0),
        child: Icon(Icons.brightness_1, size: 8.spV2, color: AppColor.secondaryColor1),
      ),
    );
  }

  Widget _LabeledBox({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        Padding(
          padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 1.0.h),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.secondaryColor1, width: 3.0, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(10.sp),
            ),
            child: Padding(padding: const EdgeInsets.only(left: 8.0), child: child),
          ),
        ),
      ],
    );
  }

  Widget _BoxedField({
    required TextEditingController controller,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
    // 👇 NEW: allow this field to be read-only when needed
    bool readOnly = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 1.0.h),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.secondaryColor1, width: 3.0, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: TextField(
            controller: controller,
            textCapitalization: textCapitalization,
            maxLines: maxLines,
            keyboardType: keyboardType,

            // 👇 NEW: forward readOnly flag to TextField
            readOnly: readOnly,

            style: TextStyle(
              fontSize: 10.spV2,
              fontWeight: FontWeight.bold,
              color: AppColor.secondaryColor1,
            ),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
              border: InputBorder.none,
              // Per-field "changed" dots are drawn by callers via suffixIcon if needed.
            ),
          ),
        ),
      ),
    );
  }
  
}