import 'package:crew_support/utils/AppColor.dart'; // NEW path
import 'package:crew_support/utils/sizer_v2_compat.dart'; // NEW spV2
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'profile_flight_attendant_controller.dart';

class ProfileFlightAttendantScreen extends GetView<ProfileFlightAttendantController> {
  const ProfileFlightAttendantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isLoading.value
          ? SizedBox(
              height: 55.h,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingAnimationWidget.threeRotatingDots(
                      color: AppColor.secondaryColor1,
                      size: 50.spV2,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Loading...',
                      style: TextStyle(color: AppColor.textColor1, fontSize: 11.spV2),
                    ),
                  ],
                ),
              ),
            )
          : SafeArea(
              child: Scaffold(
                backgroundColor: AppColor.bgColor1,
                bottomNavigationBar: _bottomBar(context),
                body: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: ListView(
                    children: [
                      _avatarHeader(context),
                      Divider(indent: 10, endIndent: 10, thickness: 2, color: AppColor.secondaryColor1),

                      _topTwoFields(context), // Membership Type + Gender
                      _firstName(context),
                      _lastName(context),
                      _email(context),
                      _phone(context),
                      _ratingAndPassport(context),

                      _passportDateAndLocation(context),

                      // ✅ Rest of legacy sections
                      _yearsOfExperience(context),
                      _dayRates(context),
                      _internationalVisas(context),
                      _aircraftExperience(context),
                      // _aircraftSpecificTraining(context),
                      // _regionExperience(context),
                      _continents(context),
                      _languages(context),
                      _specialTraining(context),
                      _otherTrainingIfNeeded(context),
                      _toggles(context),
                      _resumeSection(context),
                      _bio(context),
                      _shareProfileSection(context),
                      _socialLinks(context),
                      _galleryImages(context),

                      SizedBox(height: 3.h),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ------------------ Bottom bar ------------------

  Widget _bottomBar(BuildContext context) {
    return Obx(() {
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
                key: const ValueKey('fa_update_bar'),
                margin: EdgeInsets.only(left: 5.0.w, right: 5.0.w),
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
                  onPressed: controller.isPressed.value ? () async => controller.submitUpdate(context) : null,
                  child: Text('Update', style: TextStyle(fontSize: 11.spV2)),
                ),
              )
            : const SizedBox(
                key: ValueKey('fa_update_bar_empty'),
                height: 0,
              ),
      );
    });
  }

  // ------------------ Header ------------------

  Widget _avatarHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 1.h),
          child: Obx(
            () => CircleAvatar(
              backgroundColor: AppColor.secondaryColor1,
              radius: 55.spV2,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(55.spV2),
                    child: SizedBox(
                      height: 110.0.h,
                      width: 110.0.w,
                      child: Image.network(
                        controller.selectedImage.value,
                        fit: BoxFit.fill,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColor.bgColor1,
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
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
                    bottom: 7.0.spV2,
                    right: 3.spV2,
                    child: GestureDetector(
                      onTap: () => controller.showChoiceDialog(context),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 3.spV2, color: AppColor.bgColor1),
                          borderRadius: BorderRadius.all(Radius.circular(50.spV2)),
                          color: AppColor.secondaryColor1,
                          boxShadow: const [BoxShadow(blurRadius: 3)],
                        ),
                        child: Icon(Icons.edit, color: AppColor.bgColor1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------ Fields ------------------

  Widget _topTwoFields(BuildContext context) {
    return Row(
      children: [
        // Membership Type (read-only)
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Membership Type'),
              _boxedField(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextField(
                    controller: controller.membershipTypeController,
                    readOnly: true,
                    style: TextStyle(fontSize: 11.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor2),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Gender (Dropdown) – stretches right end ✅
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Gender'),
              _boxedField(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Obx(
                    () => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: controller.genderController.text.isNotEmpty ? controller.genderController.text : null,
                        hint: Text('Select Gender', style: TextStyle(color: AppColor.secondaryColor2, fontSize: 9.spV2)),
                        dropdownColor: AppColor.bgColor1,
                        icon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.keyboard_arrow_down),
                            _updateDot(controller.genderBool.value),
                          ],
                        ),
                        style: TextStyle(fontSize: 11.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1),
                        items: controller.itemsGender.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: controller.onGenderChanged,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _firstName(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('First Name'),
        _boxedField(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Obx(
              () => TextField(
                controller: controller.firstNameController,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => controller.firstNameBool.value = controller.firstNameController.text != controller.firstName,
                style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1),
                decoration: InputDecoration(
                  suffixIcon: _updateDot(controller.firstNameBool.value),
                  hintText: 'Enter First Name',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _lastName(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Last Name'),
        _boxedField(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Obx(
              () => TextField(
                controller: controller.lastNameController,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => controller.lastNameBool.value = controller.lastNameController.text != controller.lastName,
                style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1),
                decoration: InputDecoration(
                  suffixIcon: _updateDot(controller.lastNameBool.value),
                  border: InputBorder.none,
                  hintText: 'Enter Last Name',
                  hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _email(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Email Address'),
        _boxedField(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Obx(
              () => TextField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                minLines: 1,
                maxLines: 2,
                onChanged: (_) => controller.emailBool.value = controller.emailController.text != controller.email,
                style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1),
                decoration: InputDecoration(
                  suffixIcon: _updateDot(controller.emailBool.value),
                  hintText: 'Enter Email',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _phone(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Phone Number'),
        _boxedField(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Obx(
              () => TextField(
                controller: controller.phoneNumberController,
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                onChanged: (_) => controller.phoneBool.value = controller.phoneNumberController.text != controller.phoneNumber,
                style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1),
                decoration: InputDecoration(
                  hintText: 'Enter Phone Number',
                  hintStyle: TextStyle(color: AppColor.secondaryColor2, fontSize: 9.spV2),
                  suffixIcon: _updateDot(controller.phoneBool.value),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _ratingAndPassport(BuildContext context) {
    return Row(
      children: [
        // Rating – NOT stretched ✅ (prevents blank space after last star)
        Flexible(
          flex: 0,
          fit: FlexFit.loose,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Rating'),
              _boxedField(
                child: Padding(
                  padding: EdgeInsets.only(left: 1.0.w, top: 0.2.h, bottom: 0.6.h),
                  child: Obx(() {
                    final rating = controller.ratingCount.value.clamp(0.0, 5.0);
                    return Row(
                      children: List.generate(5, (i) {
                        final filled = (i + 1) <= rating.floor();
                        final half = !filled && (rating - i) >= 0.5;
                        return Padding(
                          padding: EdgeInsets.only(right: 1.0.w),
                          child: Icon(
                            half ? Icons.star_half : (filled ? Icons.star : Icons.star_border),
                            size: 16.spV2,
                            color: AppColor.goldenColorNew,
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        // Passport
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Passport'),
              _boxedField(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Obx(
                    () => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: AppColor.bgColor1,
                        value: controller.passportController.text.isEmpty ? null : controller.passportController.text,
                        icon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.keyboard_arrow_down),
                            _updateDot(controller.passportBool.value),
                          ],
                        ),
                        style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1),
                        items: controller.itemsYesNo.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: controller.onPassportChanged,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _passportDateAndLocation(BuildContext context) {
    return Row(
      children: [
        // Passport Expiration Date
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Passport Expiration Date'),
              _boxedField(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Obx(
                    () => TextFormField(
                      controller: controller.passportExpireDateController,
                      readOnly: true,
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: controller.currentDate.value,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2050),
                          initialEntryMode: DatePickerEntryMode.calendarOnly,
                          builder: (ctx, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                dialogBackgroundColor: AppColor.bgColor2,
                                colorScheme: ColorScheme.dark(
                                  primary: AppColor.secondaryColor1,
                                  onPrimary: AppColor.textColor1,
                                  onSurface: AppColor.textColor1,
                                  surface: AppColor.bgColor2,
                                  background: AppColor.bgColor2,
                                  onError: AppColor.deleteColor,
                                ).copyWith(secondary: AppColor.secondaryColor1),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) controller.setPassportDate(picked);
                      },
                      style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1),
                      decoration: InputDecoration(
                        suffixIcon: _updateDot(controller.passportDateBool.value),
                        border: InputBorder.none,
                        hintText: 'Enter Expiration Date',
                        hintStyle: TextStyle(color: AppColor.secondaryColor2, fontSize: 9.spV2),
                        contentPadding: const EdgeInsets.only(left: 0, bottom: 15, top: 11, right: 0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Current Location
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Current Location'),
              _boxedField(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Obx(
                    () => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: AppColor.bgColor1,
                        value: controller.currentLocationController.text.isEmpty ? null : controller.currentLocationController.text,
                        icon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.keyboard_arrow_down),
                            _updateDot(controller.currentLocaBool.value),
                          ],
                        ),
                        style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1),
                        items: controller.itemsLocation.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
        ),
      ],
    );
  }

  // ------------------ Remaining legacy sections ------------------

  Widget _yearsOfExperience(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Years Of Experience'),
        _boxedField(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Obx(
              () => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: controller.yrExperienceController.text.isEmpty ? null : controller.yrExperienceController.text,
                  hint: Text('Select Years Of Experience', style: TextStyle(color: AppColor.secondaryColor2, fontSize: 9.spV2)),
                  dropdownColor: AppColor.bgColor1,
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.keyboard_arrow_down),
                      _updateDot(controller.yroeBool.value),
                    ],
                  ),
                  style: TextStyle(fontSize: 11.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1),
                  items: controller.itemsYearsOfExp.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    controller.yrExperienceController.text = v;
                    controller.yroeBool.value = true;
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dayRates(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Rate Per Day'),
              _boxedField(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Obx(
                    () => Row(
                      children: [
                        Text(
                          "\$",
                          style: TextStyle(
                            fontSize: 10.spV2,
                            fontWeight: FontWeight.bold,
                            color: AppColor.secondaryColor1,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: TextField(
                            controller: controller.dayDomesticController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => controller.domRPDBool.value = true,
                            style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1),
                            decoration: InputDecoration(
                              suffixIcon: _updateDot(controller.domRPDBool.value),
                              hintText: '0.00',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12.spV2),
                              hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Expanded(
        //   flex: 2,
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       _label('International Rate Per Day'),
        //       _boxedField(
        //         child: Padding(
        //           padding: const EdgeInsets.only(left: 8.0),
        //           child: Obx(
        //             () => Row(
        //               children: [
        //                 Text(
        //                   "\$",
        //                   style: TextStyle(
        //                     fontSize: 10.spV2,
        //                     fontWeight: FontWeight.bold,
        //                     color: AppColor.secondaryColor1,
        //                   ),
        //                 ),
        //                 SizedBox(width: 3.w),
        //                 Expanded(
        //                   child: TextField(
        //                     controller: controller.dayInternationalController,
        //                     keyboardType: const TextInputType.numberWithOptions(decimal: false),
        //                     onChanged: (_) => controller.intRPDBool.value = true,
        //                     style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1),
        //                     decoration: InputDecoration(
        //                       suffixIcon: _updateDot(controller.intRPDBool.value),
        //                       hintText: '0',
        //                       border: InputBorder.none,
        //                       isDense: true,
        //                       contentPadding: EdgeInsets.symmetric(vertical: 12.spV2),
        //                       hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
        //                     ),
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _internationalVisas(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('International Visas'),
        _boxedField(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Obx(
              () => Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.internationalVisaStr.value.isEmpty ? 'None' : controller.internationalVisaStr.value,
                      style: TextStyle(
                        fontSize: 10.spV2,
                        fontWeight: FontWeight.bold,
                        color: controller.internationalVisaStr.value.isEmpty ? AppColor.secondaryColor2 : AppColor.secondaryColor1,
                      ),
                    ),
                  ),
                  _updateDot(controller.internationalBool.value),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ).applyGesture(
          onTap: () {
            FocusScope.of(context).unfocus();
            controller.selectInternationalVisas(context);
          },
        ),
      ],
    );
  }

  Widget _aircraftExperience(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Aircraft Experience'),
        _boxedField(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Obx(
              () => Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.aircraftExpStr.value.isEmpty ? 'Select' : controller.aircraftExpStr.value,
                      style: TextStyle(
                        fontSize: 10.spV2,
                        fontWeight: FontWeight.bold,
                        color: controller.aircraftExpStr.value.isEmpty ? AppColor.secondaryColor2 : AppColor.secondaryColor1,
                      ),
                    ),
                  ),
                  _updateDot(controller.aircraftBool.value),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ).applyGesture(
          onTap: () {
            FocusScope.of(context).unfocus();
            controller.selectAircraftExperience(context);
          },
        ),
      ],
    );
  }

  // Widget _aircraftSpecificTraining(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _label('Aircraft Specific Training'),
  //       _boxedField(
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //           child: Obx(
  //             () => Row(
  //               children: [
  //                 Checkbox(
  //                   value: controller.checkboxTrainingYes.value,
  //                   activeColor: AppColor.secondaryColor1,
  //                   checkColor: AppColor.textColor2,
  //                   onChanged: (v) {
  //                     controller.checkboxTrainingYes.value = v ?? false;
  //                     controller.checkboxTrainingNo.value = !(v ?? false);
  //                     controller.checkBoxValue.value = v ?? false;
  //                     controller.aircraftSpecialBool.value = true;
  //                   },
  //                 ),
  //                 Text('Yes', style: TextStyle(color: AppColor.textColor1, fontSize: 10.spV2)),
  //                 SizedBox(width: 4.w),
  //                 Checkbox(
  //                   value: controller.checkboxTrainingNo.value,
  //                   activeColor: AppColor.secondaryColor1,
  //                   checkColor: AppColor.textColor2,
  //                   onChanged: (v) {
  //                     controller.checkboxTrainingNo.value = v ?? false;
  //                     controller.checkboxTrainingYes.value = !(v ?? false);
  //                     controller.checkBoxValue.value = !(v ?? false);
  //                     controller.aircraftSpecialBool.value = true;
  //                   },
  //                 ),
  //                 Text('No', style: TextStyle(color: AppColor.textColor1, fontSize: 10.spV2)),
  //                 const Spacer(),
  //                 _updateDot(controller.aircraftSpecialBool.value),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _regionExperience(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _label('Region Experience'),
  //       _boxedField(
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
  //           child: Obx(
  //             () => Row(
  //               children: [
  //                 Expanded(
  //                   child: Text(
  //                     controller.continentExpStr.value.isEmpty ? 'Select' : controller.continentExpStr.value,
  //                     style: TextStyle(
  //                       fontSize: 10.spV2,
  //                       fontWeight: FontWeight.bold,
  //                       color: controller.continentExpStr.value.isEmpty ? AppColor.secondaryColor2 : AppColor.secondaryColor1,
  //                     ),
  //                   ),
  //                 ),
  //                 _updateDot(controller.continent2Bool.value),
  //                 const Icon(Icons.chevron_right),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ).applyGesture(
  //         onTap: () {
  //           FocusScope.of(context).unfocus();
  //           controller.selectRegionExperience(context);
  //         },
  //       ),
  //     ],
  //   );
  // }

  Widget _continents(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Region Experience'),
        _boxedField(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Obx(
              () => Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.continentStr.value.isEmpty ? 'Select' : controller.continentStr.value,
                      style: TextStyle(
                        fontSize: 10.spV2,
                        fontWeight: FontWeight.bold,
                        color: controller.continentStr.value.isEmpty ? AppColor.secondaryColor2 : AppColor.secondaryColor1,
                      ),
                    ),
                  ),
                  _updateDot(controller.continentBool.value),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ).applyGesture(
          onTap: () {
            FocusScope.of(context).unfocus();
            controller.selectContinents(context);
          },
        ),
      ],
    );
  }

  Widget _languages(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Languages Spoken'),
        _boxedField(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Obx(
              () => Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.languageStr.value.isEmpty ? 'Select' : controller.languageStr.value,
                      style: TextStyle(
                        fontSize: 10.spV2,
                        fontWeight: FontWeight.bold,
                        color: controller.languageStr.value.isEmpty ? AppColor.secondaryColor2 : AppColor.secondaryColor1,
                      ),
                    ),
                  ),
                  _updateDot(controller.languageBool.value),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ).applyGesture(
          onTap: () {
            FocusScope.of(context).unfocus();
            controller.selectLanguages(context);
          },
        ),
      ],
    );
  }

  Widget _specialTraining(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Special Training'),
        _boxedField(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Obx(
              () => Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.selectTrainingStr.value.isEmpty ? 'Select' : controller.selectTrainingStr.value,
                      style: TextStyle(
                        fontSize: 10.spV2,
                        fontWeight: FontWeight.bold,
                        color: controller.selectTrainingStr.value.isEmpty ? AppColor.secondaryColor2 : AppColor.secondaryColor1,
                      ),
                    ),
                  ),
                  _updateDot(controller.specialBool.value),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ).applyGesture(
          onTap: () {
            FocusScope.of(context).unfocus();
            controller.selectTrainingDialog(context);
          },
        ),
      ],
    );
  }

  Widget _otherTrainingIfNeeded(BuildContext context) {
    return Obx(() {
      final hasOther = controller.selectTrainingSaveList.contains('Other') ||
          controller.selectTrainingStr.value.contains('Other');
      if (!hasOther) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Other Training'),
          _boxedField(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Obx(
                () => TextField(
                  controller: controller.otherTrainingController,
                  onChanged: (_) => controller.specialNameBool.value = true,
                  style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1),
                  decoration: InputDecoration(
                    suffixIcon: _updateDot(controller.specialNameBool.value),
                    hintText: 'Enter Other Training',
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

    Widget _toggles(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 2.h),
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
                child: Obx(
                  () => Row(
                    children: [
                      Theme(
                        data: ThemeData(
                          unselectedWidgetColor: AppColor.textColor1,
                        ),
                        child: Checkbox(
                          checkColor: AppColor.bgColor1,
                          activeColor: AppColor.secondaryColor1,
                          value: controller.isIgnoreAvailability,
                          onChanged: (v) {
                            FocusScope.of(context).unfocus();
                            controller.allowBool.value = true;
                            controller.isIgnoreAvailability = true;
                            if (controller.isIgnoreAvailabilityCheck ==
                                controller.isIgnoreAvailability) {
                              controller.allowBool.value = false;
                            }
                          },
                        ),
                      ),
                      Text(
                        "Yes",
                        style: TextStyle(
                          fontSize: 10.spV2,
                          color: AppColor.textColor1,
                        ),
                      ),
                      Theme(
                        data: ThemeData(
                          unselectedWidgetColor: AppColor.textColor1,
                        ),
                        child: Checkbox(
                          checkColor: AppColor.bgColor1,
                          activeColor: AppColor.secondaryColor1,
                          value: !controller.isIgnoreAvailability,
                          onChanged: (v) {
                            FocusScope.of(context).unfocus();
                            controller.allowBool.value = true;
                            controller.isIgnoreAvailability = false;
                            if (controller.isIgnoreAvailabilityCheck ==
                                controller.isIgnoreAvailability) {
                              controller.allowBool.value = false;
                            }
                          },
                        ),
                      ),
                      Text(
                        "No",
                        style: TextStyle(
                          fontSize: 10.spV2,
                          color: AppColor.textColor1,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      _updateDot(controller.allowBool.value),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),

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
                child: Obx(
                  () => Row(
                    children: [
                      Theme(
                        data: ThemeData(
                          unselectedWidgetColor: AppColor.textColor1,
                        ),
                        child: Checkbox(
                          checkColor: AppColor.bgColor1,
                          activeColor: AppColor.secondaryColor1,
                          value: controller.isFullTime.value,
                          onChanged: (v) {
                            FocusScope.of(context).unfocus();
                            controller.fullTime.value = true;
                            controller.isFullTime.value = true;
                          },
                        ),
                      ),
                      Text(
                        "Yes",
                        style: TextStyle(
                          fontSize: 10.spV2,
                          color: AppColor.textColor1,
                        ),
                      ),
                      Theme(
                        data: ThemeData(
                          unselectedWidgetColor: AppColor.textColor1,
                        ),
                        child: Checkbox(
                          checkColor: AppColor.bgColor1,
                          activeColor: AppColor.secondaryColor1,
                          value: !controller.isFullTime.value,
                          onChanged: (v) {
                            FocusScope.of(context).unfocus();
                            controller.fullTime.value = true;
                            controller.isFullTime.value = false;
                          },
                        ),
                      ),
                      Text(
                        "No",
                        style: TextStyle(
                          fontSize: 10.spV2,
                          color: AppColor.textColor1,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      _updateDot(controller.fullTime.value),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),

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
                child: Obx(
                  () => Row(
                    children: [
                      Theme(
                        data: ThemeData(
                          unselectedWidgetColor: AppColor.textColor1,
                        ),
                        child: Checkbox(
                          checkColor: AppColor.bgColor1,
                          activeColor: AppColor.secondaryColor1,
                          value: controller.isShowResume.value,
                          onChanged: (v) {
                            FocusScope.of(context).unfocus();
                            controller.showResume.value =
                                true; // update-dot trigger
                            controller.isShowResume.value = true;
                          },
                        ),
                      ),
                      Text(
                        "Yes",
                        style: TextStyle(
                          fontSize: 10.spV2,
                          color: AppColor.textColor1,
                        ),
                      ),
                      Theme(
                        data: ThemeData(
                          unselectedWidgetColor: AppColor.textColor1,
                        ),
                        child: Checkbox(
                          checkColor: AppColor.bgColor1,
                          activeColor: AppColor.secondaryColor1,
                          value: !controller.isShowResume.value,
                          onChanged: (v) {
                            FocusScope.of(context).unfocus();
                            controller.showResume.value =
                                true; // update-dot trigger
                            controller.isShowResume.value = false;
                          },
                        ),
                      ),
                      Text(
                        "No",
                        style: TextStyle(
                          fontSize: 10.spV2,
                          color: AppColor.textColor1,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      _updateDot(controller.showResume.value),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _resumeSection(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 2.h),
        Obx(() {
          final path = (controller.resumePath.value ?? '').trim();
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
        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _shareProfileSection(BuildContext context) {
    return Container(
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
            // onTap: () => controller.isClicked.value == false
            //     ? () {
            //         controller.isClicked.value = true;
            //         controller.createDynamicLink(
            //           context,
            //           link: controller.pkPilotId.toString(),
            //           short: true,
            //         );
            //       }()
            //     : null,
            child: Icon(Icons.share, color: AppColor.textColor1),
          ),
        ],
      ),
    );
  }


  Widget _bio(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Bio'),
        _boxedField(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Obx(
              () => TextField(
                controller: controller.bioController,
                minLines: 2,
                maxLines: 5,
                onChanged: (_) => controller.bioBool.value = true,
                style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1),
                decoration: InputDecoration(
                  suffixIcon: _updateDot(controller.bioBool.value),
                  hintText: 'Enter Bio',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _socialLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
                  padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 1.0.h),
                  child: Row(
                    children: [
                      Text(
                        "Instagram  ",
                        style: TextStyle(
                          color: AppColor.textColor1,
                          fontSize: 10.0.spV2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.0.h, child: Image.asset("assets/instagram.png", fit: BoxFit.contain)),
                    ],
                  ),
                ),
        _boxedField(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Obx(
              () => TextField(
                controller: controller.instagramController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => controller.canonicalizeOnDone(platform: 'instagram'),
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
                  hintText: 'Enter instagram link or @username',
                  hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                  border: InputBorder.none,
                  suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Verify',
                        icon: Icon(Icons.verified_outlined,
                            size: 18.spV2, color: AppColor.secondaryColor1),
                        onPressed: () => controller.verifySocial(context, platform: 'instagram'),
                      ),
                      IconButton(
                        tooltip: 'Preview',
                        icon: Icon(Icons.open_in_new,
                            size: 18.spV2, color: AppColor.secondaryColor1),
                        onPressed: () => controller.previewSocial(context, platform: 'instagram'),
                      ),
                      _updateDot(controller.instaBool.value),
                    ],
                  ),
                ),
              ),
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

        // SizedBox(height: 1.5.h),

        Padding(
                  padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 1.0.h),
                  child: Row(
                    children: [
                      Text(
                        "Facebook  ",
                        style: TextStyle(
                          color: AppColor.textColor1,
                          fontSize: 10.0.spV2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.0.h, child: Image.asset("assets/facebook.png", fit: BoxFit.contain)),
                    ],
                  ),
                ),
        _boxedField(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Obx(
              () => TextField(
                controller: controller.facebookController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => controller.canonicalizeOnDone(platform: 'facebook'),
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
                  hintText: 'Enter facebook link or @username',
                  hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                  border: InputBorder.none,
                  suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Verify',
                        icon: Icon(Icons.verified_outlined,
                            size: 18.spV2, color: AppColor.secondaryColor1),
                        onPressed: () => controller.verifySocial(context, platform: 'facebook'),
                      ),
                      IconButton(
                        tooltip: 'Preview',
                        icon: Icon(Icons.open_in_new,
                            size: 18.spV2, color: AppColor.secondaryColor1),
                        onPressed: () => controller.previewSocial(context, platform: 'facebook'),
                      ),
                      _updateDot(controller.facebookBool.value),
                    ],
                  ),
                ),
              ),
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

        // SizedBox(height: 1.5.h),

        Padding(
                  padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 1.0.h),
                  child: Row(
                    children: [
                      Text(
                        "Linkedin  ",
                        style: TextStyle(
                          color: AppColor.textColor1,
                          fontSize: 10.0.spV2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.0.h, child: Image.asset("assets/linkedin.png", fit: BoxFit.contain)),
                    ],
                  ),
                ),
        _boxedField(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Obx(
              () => TextField(
                controller: controller.linkedinController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => controller.canonicalizeOnDone(platform: 'linkedin'),
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
                  hintText: 'Enter linkedin link or @username',
                  hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                  border: InputBorder.none,
                  suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Verify',
                        icon: Icon(Icons.verified_outlined,
                            size: 18.spV2, color: AppColor.secondaryColor1),
                        onPressed: () => controller.verifySocial(context, platform: 'linkedin'),
                      ),
                      IconButton(
                        tooltip: 'Preview',
                        icon: Icon(Icons.open_in_new,
                            size: 18.spV2, color: AppColor.secondaryColor1),
                        onPressed: () => controller.previewSocial(context, platform: 'linkedin'),
                      ),
                      _updateDot(controller.linkedinBool.value),
                    ],
                  ),
                ),
              ),
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

        SizedBox(height: 2.h),
      ],
    );
  }
  
  Widget _galleryImages(BuildContext context) {
    final tiles = <Map<String, dynamic>>[
      {'idx': 1, 'rx': controller.image1},
      {'idx': 2, 'rx': controller.image2},
      {'idx': 3, 'rx': controller.image3},
      {'idx': 4, 'rx': controller.image4},
      {'idx': 5, 'rx': controller.image5},
      {'idx': 6, 'rx': controller.image6},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(left: 5.w, top: 1.h, bottom: 1.h),
          alignment: Alignment.centerLeft,
          child: Text(
            "My Photos",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColor.historyRead,
              fontSize: 9.5.spV2.spV2,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.0.w),
          child: Wrap(
            spacing: 2.w,
            runSpacing: 2.w,
            children: tiles.map((t) {
              final int idx = t['idx'] as int;
              final RxnString rx = t['rx'] as RxnString;

              return Obx(() {
                final url = rx.value ?? '';
                return SizedBox(
                  width: 28.w,
                  height: 28.w,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColor.secondaryColor1, width: 1),
                            borderRadius: BorderRadius.circular(10.spV2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.spV2),
                            child: url.isEmpty
                                ? Container(
                                    color: AppColor.bgColor2,
                                    child: Icon(Icons.image, color: AppColor.secondaryColor2),
                                  )
                                : Image.network(url, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: GestureDetector(
                          onTap: () => controller.pickFAImage(context, idx),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColor.secondaryColor1,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(Icons.edit, color: AppColor.bgColor1, size: 14.spV2),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ------------------ Shared mini-widgets ------------------

  Widget _label(String text) => Padding(
        padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w),
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

  /// Slight vertical gap like legacy ✅
  Widget _boxedField({required Widget child}) => Padding(
        padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 1.0.h, bottom: 2.0.h),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.secondaryColor1, width: 3.0, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(10.spV2),
          ),
          child: child,
        ),
      );

  Widget _updateDot(bool changed) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: changed ? Icon(Icons.circle, size: 8.spV2, color: AppColor.secondaryColor1) : const SizedBox.shrink(),
    );
  }
}

// Small helper used for clickable boxed sections
extension _GestureWrap on Widget {
  Widget applyGesture({required VoidCallback onTap}) {
    return GestureDetector(onTap: onTap, child: this);
  }
}
