import 'package:crew_support/utils/AppColor.dart'; // NEW AppColor import
import 'package:crew_support/utils/sizer_v2_compat.dart'; // for .spV2
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'profile_owner_controller.dart';

class ProfileOwnerScreen extends GetView<ProfileOwnerController> {
  const ProfileOwnerScreen({super.key});

  // Small helper to match the old “update” suffix icon pattern.
  Widget showUpdateMessage({required bool permissionBool}) {
    return permissionBool
        ? Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: Icon(Icons.info_outline,
                size: 14.spV2, color: AppColor.secondaryColor1),
          )
        : SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {

    return Obx(() {
      if (controller.isLoading.value) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: AppColor.bgColor1,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.threeRotatingDots(
                    color: AppColor.secondaryColor1,
                    size: 50.spV2,
                  ),
                  SizedBox(height: 2.h),
                  Text('Loading...',
                      style: TextStyle(color: AppColor.textColor1)),
                ],
              ),
            ),
          ),
        );
      }

      return SafeArea(
        child: Scaffold(
          backgroundColor: AppColor.bgColor1,
          bottomNavigationBar: Obx(() {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                // Nice bottom bar reveal/hide animation
                return SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1.0,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: controller.hasAnyChange
                  ? Container(
                      key: const ValueKey('update_bar'),
                      width: 85.w,
                      margin: const EdgeInsets.all(20),
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
                        onPressed: controller.isPressed.value
                            ? () async {
                                FocusScope.of(context).unfocus();
                                await controller.onTapUpdate(context);
                              }
                            : null,
                        child: Text("Update", style: TextStyle(fontSize: 10.spV2)),
                      ),
                    )
                  : const SizedBox(
                      key: ValueKey('update_bar_empty'),
                      height: 0,
                    ),
            );
          }),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView(
              children: [
                // -------------------- Avatar (unchanged visually) --------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 1.h),
                      child: CircleAvatar(
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
                                        value: progress.expectedTotalBytes !=
                                                null
                                            ? progress.cumulativeBytesLoaded /
                                                progress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, _, __) {
                                    return CircleAvatar(
                                      backgroundColor:
                                          AppColor.secondaryColor1,
                                      child: Icon(Icons.account_circle,
                                          color: AppColor.bgColor1, size: 60),
                                    );
                                  },
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
                                    border: Border.all(
                                        width: 3, color: AppColor.bgColor1),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(50),
                                    ),
                                    color: AppColor.secondaryColor1,
                                    boxShadow: const [BoxShadow(blurRadius: 3)],
                                  ),
                                  child: Icon(Icons.edit,
                                      color: AppColor.bgColor1),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  thickness: 2,
                  color: AppColor.secondaryColor1,
                ),

                // -------------------- Membership + Gender --------------------
                Row(
                  children: const [
                    Expanded(
                      flex: 2,
                      child: _SectionLabel("Membership Type"),
                    ),
                    Expanded(
                      flex: 2,
                      child: _SectionLabel("Gender"),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _LabeledBox(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: TextField(
                            controller: controller.membershipTypeController,
                            readOnly: true,
                            style: TextStyle(
                              fontSize: 11.spV2,
                              fontWeight: FontWeight.bold,
                              color: AppColor.secondaryColor4,
                            ),
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _LabeledBox(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              dropdownColor: AppColor.bgColor1,
                              value: controller.genders.contains(controller.genderController.text)
                                  ? controller.genderController.text
                                  : null,
                              hint: Text(
                                'Select Gender',
                                style: TextStyle(
                                  color: AppColor.secondaryColor2,
                                  fontSize: 9.spV2,
                                ),
                              ),
                              icon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.keyboard_arrow_down),
                                  showUpdateMessage(
                                    permissionBool:
                                        controller.genderBool.value,
                                  ),
                                ],
                              ),
                              style: TextStyle(
                                fontSize: 11.spV2,
                                fontWeight: FontWeight.bold,
                                color: AppColor.secondaryColor1,
                              ),
                              items: controller.genders
                                  .map((g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(g),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  controller.onGenderChanged(val);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // -------------------- Use company name? (Yes/No) --------------------
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColor.secondaryColor1,
                      width: 3.0,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(10.spV2),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Use company name?",
                            style: TextStyle(
                              color: AppColor.secondaryColor1,
                              fontWeight: FontWeight.w500,
                              fontSize: 9.5.spV2,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Theme(
                                data: ThemeData(
                                    unselectedWidgetColor: AppColor.textColor1),
                                child: Checkbox(
                                  checkColor: AppColor.textColor2,
                                  activeColor: AppColor.secondaryColor1,
                                  value: controller.showCompanyName.value,
                                  onChanged: (v) =>
                                      controller.setUseCompanyName(true),
                                ),
                              ),
                              Text("Yes",
                                  style: TextStyle(
                                      fontSize: 10.spV2,
                                      color: AppColor.textColor1)),
                              const SizedBox(width: 20),
                              Theme(
                                data: ThemeData(
                                    unselectedWidgetColor: AppColor.textColor1),
                                child: Checkbox(
                                  checkColor: AppColor.textColor2,
                                  activeColor: AppColor.secondaryColor1,
                                  value: !controller.showCompanyName.value,
                                  onChanged: (v) =>
                                      controller.setUseCompanyName(false),
                                ),
                              ),
                              Text("No",
                                  style: TextStyle(
                                      fontSize: 10.spV2,
                                      color: AppColor.textColor1)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // -------------------- First Name / Last Name (hidden if isDefault) --------------------
                if (!controller.showCompanyName.value) ...[
                  _SectionLabel("First Name"),
                  _LabeledBox(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextField(
                        controller: controller.firstNameController,
                        textCapitalization: TextCapitalization.words,
                        onChanged: controller.onFirstNameChanged,
                        style: TextStyle(
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondaryColor1,
                        ),
                        decoration: InputDecoration(
                          suffixIcon: showUpdateMessage(
                              permissionBool: controller.firstNameBool.value),
                          hintText: "Enter First Name",
                          hintStyle: TextStyle(
                            fontSize: 9.spV2,
                            color: AppColor.secondaryColor2,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  _SectionLabel("Last Name"),
                  _LabeledBox(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextField(
                        controller: controller.lastNameController,
                        textCapitalization: TextCapitalization.words,
                        onChanged: controller.onLastNameChanged,
                        style: TextStyle(
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondaryColor1,
                        ),
                        decoration: InputDecoration(
                          suffixIcon: showUpdateMessage(
                              permissionBool: controller.lastNameBool.value),
                          hintText: "Enter Last Name",
                          hintStyle: TextStyle(
                            fontSize: 9.spV2,
                            color: AppColor.secondaryColor2,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],

                // -------------------- Company Name (visible if isDefault) --------------------
                if (controller.showCompanyName.value) ...[
                  _SectionLabel("Company Name"),
                  _LabeledBox(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextField(
                        controller: controller.companyNameController,
                        onChanged: controller.onCompanyNameChanged,
                        style: TextStyle(
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondaryColor1,
                        ),
                        decoration: InputDecoration(
                          suffixIcon: showUpdateMessage(
                              permissionBool: controller.companyNameBool.value),
                          hintText: "Enter company name",
                          hintStyle: TextStyle(
                            fontSize: 9.spV2,
                            color: AppColor.secondaryColor2,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 10),

                // -------------------- Rating & Current Location --------------------
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _SectionLabel("Rating"),
                    ),
                    Expanded(
                      flex: 2,
                      child: _SectionLabel("Current Location"),
                    )
                  ],
                ),
                Row(
                  children: [
                    // Rating (read-only just like legacy)
                    Expanded(
                      flex: 2,
                      child: _LabeledBox(
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 1.0.w, top: 0.2.h, bottom: 0.6.h),
                          child: IgnorePointer(
                            ignoring: true,
                            child: Row(
                              children: List.generate(5, (idx) {
                                final star =
                                    controller.ratingCount.value.clamp(0, 5);
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
                                        : (isHalf
                                            ? Icons.star_half
                                            : Icons.star_border),
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
                    // Current Location dropdown
                    Expanded(
                      flex: 2,
                      child: _LabeledBox(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              dropdownColor: AppColor.bgColor1,
                              value: controller.onOff.contains(controller.currentLocationController.text)
                                  ? controller.currentLocationController.text
                                  : null,
                              icon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.keyboard_arrow_down),
                                  showUpdateMessage(
                                    permissionBool:
                                        controller.currentLocaBool.value,
                                  ),
                                ],
                              ),
                              style: TextStyle(
                                fontSize: 10.spV2,
                                fontWeight: FontWeight.bold,
                                color: AppColor.secondaryColor1,
                              ),
                              isExpanded: true,
                              items: controller.onOff
                                  .map((v) => DropdownMenuItem(
                                        value: v,
                                        child: Text(v),
                                      ))
                                  .toList(),
                              onChanged: (val) async {
                                if (val == null) return;
                                FocusScope.of(context).unfocus();

                                // Start the dedicated permission flow only when the
                                // user explicitly changes the Current Location field.
                                // The controller will automatically revert the value
                                // if permission is not sufficient.
                                await controller.onCurrentLocationChanged(context, val);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                                SizedBox(height: 10),

                // -------------------- Bio --------------------
                _SectionLabel("Bio"),
                _LabeledBox(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: TextField(
                      controller: controller.bioController,
                      minLines: 4,
                      maxLines: 5,
                      onChanged: (v) {
                        controller.bioBool.value = controller.bioController.text != controller.bio;
                      },
                      style: TextStyle(
                        fontSize: 10.spV2,
                        fontWeight: FontWeight.bold,
                        color: AppColor.secondaryColor1,
                      ),
                      decoration: InputDecoration(
                        suffixIcon: showUpdateMessage(permissionBool: controller.bioBool.value),
                        border: InputBorder.none,
                        hintText: "Enter Bio details",
                        hintStyle: TextStyle(
                          fontSize: 9.spV2,
                          color: AppColor.secondaryColor2,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // -------------------- Share Profile --------------------
                Padding(
                  padding: EdgeInsets.only(left: 15, top: 4.h, bottom: 1.h),
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
                        textStyle: TextStyle(fontSize: 10.0.spV2, color: AppColor.textColor2),
                        decoration: BoxDecoration(
                          color: AppColor.secondaryColor1.withOpacity(0.9), // dark background
                          borderRadius: BorderRadius.circular(8),
                        ),
                        preferBelow: false,
                        child: const Icon(Icons.info_outline, color: Colors.red),
                      ),
                      SizedBox(width: 2.w),
                      GestureDetector(
                        onTap: controller.isClicked.isFalse
                            ? () => controller.shareCurrentUserProfile(context)
                            : null,
                        child: Icon(Icons.share, color: AppColor.textColor1),
                      ),
                    ],
                  ),
                ),

                // -------------------- Instagram --------------------
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
                _LabeledBox(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextFormField(
                      controller: controller.instagramController,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => controller.canonicalizeOnDone(platform: 'instagram'),
                      onEditingComplete: () => controller.canonicalizeOnDone(platform: 'instagram'),
                      onChanged: (v) {
                        controller.instaBool.value = controller.instagramController.text != controller.instagram;
                        // reset soft-verify status while typing
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
                        hintText: "Enter instagram link or @username",
                        hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Verify',
                              icon: Icon(Icons.verified_outlined, size: 18.spV2, color: AppColor.secondaryColor1),
                              onPressed: () => controller.verifySocial(context, platform: 'instagram'),
                            ),
                            IconButton(
                              tooltip: 'Preview',
                              icon: Icon(Icons.open_in_new, size: 18.spV2, color: AppColor.secondaryColor1),
                              onPressed: () => controller.previewSocial(context, platform: 'instagram'),
                            ),
                            showUpdateMessage(permissionBool: controller.instaBool.value),
                          ],
                        ),
                      ),
                    )
                  ),
                ),
                Obx(() {
                  if (controller.instagramStatus.value.isEmpty) return const SizedBox.shrink();
                  final ok = controller.instagramStatus.value == 'valid';
                  return Padding(
                    padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 0.5.h),
                    child: Row(
                      children: [
                        Icon(ok ? Icons.check_circle : Icons.error, size: 14.spV2, color: ok ? Colors.green : Colors.red),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            ok ? 'Looks like a valid Instagram profile link.' : 'This does not look like a valid Instagram profile link.',
                            style: TextStyle(color: AppColor.textColor1, fontSize: 9.spV2),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // -------------------- Facebook --------------------
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
                _LabeledBox(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextFormField(
                      controller: controller.facebookController,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => controller.canonicalizeOnDone(platform: 'facebook'),
                      onEditingComplete: () => controller.canonicalizeOnDone(platform: 'facebook'),
                      onChanged: (v) {
                        controller.facebookBool.value = controller.facebookController.text != controller.facebook;
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
                        hintText: "Enter facebook link or @username",
                        hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Verify',
                              icon: Icon(Icons.verified_outlined, size: 18.spV2, color: AppColor.secondaryColor1),
                              onPressed: () => controller.verifySocial(context, platform: 'facebook'),
                            ),
                            IconButton(
                              tooltip: 'Preview',
                              icon: Icon(Icons.open_in_new, size: 18.spV2, color: AppColor.secondaryColor1),
                              onPressed: () => controller.previewSocial(context, platform: 'facebook'),
                            ),
                            showUpdateMessage(permissionBool: controller.facebookBool.value),
                          ],
                        ),
                      ),
                    )
                  ),
                ),
                Obx(() {
                  if (controller.facebookStatus.value.isEmpty) return const SizedBox.shrink();
                  final ok = controller.facebookStatus.value == 'valid';
                  return Padding(
                    padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 0.5.h),
                    child: Row(
                      children: [
                        Icon(ok ? Icons.check_circle : Icons.error, size: 14.spV2, color: ok ? Colors.green : Colors.red),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            ok ? 'Looks like a valid Facebook profile link.' : 'This does not look like a valid Facebook profile link.',
                            style: TextStyle(color: AppColor.textColor1, fontSize: 9.spV2),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // -------------------- LinkedIn --------------------
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
                _LabeledBox(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextFormField(
                      controller: controller.linkedinController,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => controller.canonicalizeOnDone(platform: 'linkedin'),
                      onEditingComplete: () => controller.canonicalizeOnDone(platform: 'linkedin'),
                      onChanged: (v) {
                        controller.linkedInBool.value = controller.linkedinController.text != controller.linkedin;
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
                        hintText: "Enter linkedIn link or @username",
                        hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Verify',
                              icon: Icon(Icons.verified_outlined, size: 18.spV2, color: AppColor.secondaryColor1),
                              onPressed: () => controller.verifySocial(context, platform: 'linkedin'),
                            ),
                            IconButton(
                              tooltip: 'Preview',
                              icon: Icon(Icons.open_in_new, size: 18.spV2, color: AppColor.secondaryColor1),
                              onPressed: () => controller.previewSocial(context, platform: 'linkedin'),
                            ),
                            showUpdateMessage(permissionBool: controller.linkedInBool.value),
                          ],
                        ),
                      ),
                    )
                  ),
                ),
                Obx(() {
                  if (controller.linkedinStatus.value.isEmpty) return const SizedBox.shrink();
                  final ok = controller.linkedinStatus.value == 'valid';
                  return Padding(
                    padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w, top: 0.5.h),
                    child: Row(
                      children: [
                        Icon(ok ? Icons.check_circle : Icons.error, size: 14.spV2, color: ok ? Colors.green : Colors.red),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            ok ? 'Looks like a valid LinkedIn profile link.' : 'This does not look like a valid LinkedIn profile link.',
                            style: TextStyle(color: AppColor.textColor1, fontSize: 9.spV2),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                SizedBox(height: 2.h),

              ],
            ),
          ),
        ),
      );
    });
  }
}

/// Heading label widget to match legacy style quickly
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
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
  }
}

/// Bordered container that mimics the legacy boxes
class _LabeledBox extends StatelessWidget {
  final Widget child;
  const _LabeledBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
        child: child,
      ),
    );
  }
}