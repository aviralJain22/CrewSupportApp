import 'package:crew_support/features/message/chat_service.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'owner_view_profile_controller.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Read-only owner profile screen.
///
/// Converted from legacy `owner_profile.dart`.
/// UI is intentionally kept very close to the old implementation.
class OwnerViewProfileScreen extends GetView<OwnerViewProfileController> {
  const OwnerViewProfileScreen({super.key});

  // Helper to build avatar image safely (network/file/placeholder)
  Widget _buildAvatarImage(String? url) {
    // Fallback placeholder avatar
    Widget placeholder = CircleAvatar(
      backgroundColor: AppColor.secondaryColor1,
      child: Icon(Icons.account_circle, size: 60, color: AppColor.bgColor1),
    );
    if (url == null) return placeholder;
    final u = url.trim();
    if (u.isEmpty) return placeholder;
    if (u.startsWith('http://') || u.startsWith('https://')) {
      return Image.network(
        u,
        loadingBuilder: (context, child, ImageChunkEvent? prog) {
          if (prog == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: AppColor.bgColor1,
              value: prog.expectedTotalBytes != null
                  ? prog.cumulativeBytesLoaded / (prog.expectedTotalBytes!)
                  : null,
            ),
          );
        },
        errorBuilder: (context, _, __) => placeholder,
        fit: BoxFit.cover,
      );
    }
    if (u.startsWith('file://')) {
      // On web, dart:io isn't available; just show placeholder.
      if (kIsWeb) return placeholder;
      try {
        final path = Uri.parse(u).toFilePath();
        if (path.isEmpty) return placeholder;
        return Image.file(
          File(path),
          errorBuilder: (context, _, __) => placeholder,
          fit: BoxFit.cover,
        );
      } catch (_) {
        return placeholder;
      }
    }
    // Unknown scheme/path -> fallback
    return placeholder;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        backgroundColor: AppColor.bgColor1,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColor.secondaryColor1,
          ),
        ),
        title: Text(
          'Profile Detail',
          style: TextStyle(
            color: AppColor.secondaryColor1,
          ),
        ),
        actions: [
          Obx(() {
            return SizedBox(
              height: 15.spV2,
              width: 20.spV2,
              child: GestureDetector(
                onTap: controller.toggleFavorite,
                child: controller.isFavorite.value
                    ? SvgPicture.asset(
                        'assets/Heart Fill.svg',
                        color: AppColor.deleteColor,
                        cacheColorFilter: false,
                      )
                    : SvgPicture.asset(
                        'assets/Heart Outline.svg',
                        color: AppColor.textColor1,
                        cacheColorFilter: false,
                      ),
              ),
            );
          }),
          SizedBox(width: 3.w),
          // Message icon with disabled state until userId is loaded
          Obx(() {
            final isChatReady = controller.ownerUserId.value.trim().isNotEmpty;

            return Visibility(
              visible: controller.canMessageOwner,
              child: Opacity(
                opacity: isChatReady ? 1.0 : 0.4,
                child: IgnorePointer(
                  ignoring: !isChatReady,
                  child: GestureDetector(
                    onTap: () {
                      String fullName =
                        "${controller.firstNameController.value} ${controller.lastNameController.value}";

                        if (controller.showCompany.value) {
                          fullName = controller.companyNameController.value as String;
                        }

                      debugPrint(
                        "Tapped chat icon for userId: ${controller.ownerUserId.value}, membershipType: ${controller.membershipType.value}, receiverName: $fullName",
                      );

                      final ChatService chatService = ChatService();
                      chatService.openChatForProfile(
                        otherUserId: controller.ownerUserId.value,
                        otherProfileType: controller.membershipType.value ?? 0,
                        receiverName: fullName,
                        photoPath: controller.userPhoto.value,
                      );
                    },
                    child: SvgPicture.asset(
                      'assets/message.svg',
                      height: 3.0.h,
                      color: AppColor.textColor1,
                      cacheColorFilter: false,
                    ),
                  ),
                ),
              ),
            );
          }),
          SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 1.h),

                // Avatar
                GestureDetector(
                  onTap: () {
                    final url = controller.userPhoto.value.trim();
                    if (url.isEmpty ||
                        url == 'http' ||
                        url == 'http://' ||
                        url == 'https://' ||
                        url == 'file:///') {
                      return;
                    }
                    controller.openImagePreview();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 1.h),
                        child: CircleAvatar(
                          backgroundColor: AppColor.secondaryColor1,
                          radius: 55.spV2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(55.spV2),
                            child: SizedBox(
                              height: 110.0.h,
                              width: 110.0.w,
                              child: _buildAvatarImage(controller.userPhoto.value),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 1.h),
                  child: _divider(),
                ),

                _buildTwoColumnRow(
                  label: 'Membership Type',
                  textController: controller.membershipTypeController,
                  hint: 'Membership Type',
                ),
                _divider(),

                _buildSingleTrailingFieldRow(
                  label: 'Gender',
                  textController: controller.genderController,
                  hint: 'Gender',
                ),
                _divider(),

                Obx(() {
                  if (controller.showCompany.value) {
                    return Column(
                      children: [
                        _buildSingleTrailingFieldRow(
                          label: 'Company Name',
                          textController: controller.companyNameController,
                          hint: 'Company Name',
                        ),
                        _divider(),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      _buildSingleTrailingFieldRow(
                        label: 'First Name',
                        textController: controller.firstNameController,
                        hint: 'First Name',
                      ),
                      _divider(),
                      _buildSingleTrailingFieldRow(
                        label: 'Last Name',
                        textController: controller.lastNameController,
                      ),
                      _divider(),
                    ],
                  );
                }),

                /// Current location row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Current Location',
                          style: TextStyle(
                            color: AppColor.textColor1,
                            fontWeight: FontWeight.w500,
                            fontSize: 9.5.spV2,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          width: 40.w,
                          child: TextField(
                            controller: controller.currentLocationController,
                            readOnly: true,
                            style: TextStyle(
                              fontSize: 10.spV2,
                              fontWeight: FontWeight.bold,
                              color: AppColor.secondaryColor1,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Current Location',
                              hintStyle: TextStyle(
                                fontSize: 9.spV2,
                                color: AppColor.secondaryColor2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Visibility(
                          visible: controller.canShowLocationPin,
                          child: IconButton(
                            onPressed: () {
                              // Old code had map-launch logic commented out.
                              // Keeping icon for UI parity for now.
                            },
                            icon: Icon(
                              Icons.location_on,
                              color: AppColor.secondaryColor1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _divider(),

                /// Rating row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Rating',
                          style: TextStyle(
                            color: AppColor.textColor1,
                            fontWeight: FontWeight.w500,
                            fontSize: 9.5.spV2,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: RatingBar.builder(
                          itemSize: 18.0.sp,
                          unratedColor: AppColor.secondaryColor2,
                          initialRating: controller.ratingCount.value,
                          minRating: 0,
                          ignoreGestures: true,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding: const EdgeInsets.symmetric(
                            horizontal: 1.0,
                            vertical: 10.0,
                          ),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: AppColor.goldenColorNew,
                            size: 17.0.sp,
                          ),
                          onRatingUpdate: (double ratings) {},
                        ),
                      ),
                    ],
                  ),
                ),
                _divider(),

                /// Bio title
                Container(
                  margin: EdgeInsets.only(left: 5.w, top: 5.h, bottom: 2.h),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Bio',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColor.historyRead,
                      fontSize: 11.spV2,
                    ),
                  ),
                ),

                /// Bio box
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColor.secondaryColor1,
                      width: 1.0,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(10.sp),
                  ),
                  child: TextFormField(
                    minLines: 4,
                    maxLines: 10,
                    controller: controller.bioController,
                    readOnly: true,
                    style: TextStyle(
                      fontSize: 10.spV2,
                      fontWeight: FontWeight.bold,
                      color: AppColor.secondaryColor1,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Bio',
                      hintStyle: TextStyle(
                        fontSize: 9.spV2,
                        color: AppColor.secondaryColor2,
                      ),
                    ),
                  ),
                ),

                /// See Profile title
                Obx(() {
                  return Visibility(
                    visible: controller.hasAnySocialLink,
                    child: Container(
                      margin: EdgeInsets.only(left: 5.w, top: 4.h, bottom: 1.h),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'See Profile ',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColor.historyRead,
                          fontSize: 11.spV2,
                        ),
                      ),
                    ),
                  );
                }),

                Obx(() {
                  return Visibility(
                    visible: controller.hasAnySocialLink,
                    child: _divider(),
                  );
                }),

                /// Social icons row
                Obx(() {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: controller.instagramLink.value.isNotEmpty,
                        child: InkWell(
                          onTap: () => controller.openSocialLink(
                            controller.instagramLink.value,
                          ),
                          child: Container(
                            height: 5.0.h,
                            margin: EdgeInsets.only(
                              right: 5.0.w,
                              top: 1.0.h,
                              bottom: 1.0.h,
                            ),
                            child: Image.asset('assets/instagram_big.png'),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: controller.facebookLink.value.isNotEmpty,
                        child: InkWell(
                          onTap: () => controller.openSocialLink(
                            controller.facebookLink.value,
                          ),
                          child: Container(
                            height: 5.0.h,
                            margin: EdgeInsets.only(
                              right: 5.0.w,
                              top: 1.0.h,
                              bottom: 1.0.h,
                            ),
                            child: Image.asset('assets/facebook_big.png'),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: controller.linkedinLink.value.isNotEmpty,
                        child: InkWell(
                          onTap: () => controller.openSocialLink(
                            controller.linkedinLink.value,
                          ),
                          child: Container(
                            height: 5.0.h,
                            margin: EdgeInsets.only(
                              right: 5.0.w,
                              top: 1.0.h,
                              bottom: 1.0.h,
                            ),
                            child: Image.asset('assets/linkedin.png'),
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                Obx(() {
                  return Visibility(
                    visible: controller.hasAnySocialLink,
                    child: _divider(),
                  );
                }),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      indent: 10,
      endIndent: 10,
      thickness: 1,
      color: AppColor.secondaryColor1,
    );
  }

  Widget _buildTwoColumnRow({
    required String label,
    required TextEditingController textController,
    required String hint,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.only(left: 5.w),
            child: Text(
              label,
              style: TextStyle(
                color: AppColor.textColor1,
                fontWeight: FontWeight.w500,
                fontSize: 9.5.spV2,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: TextField(
            controller: textController,
            readOnly: true,
            style: TextStyle(
              fontSize: 10.spV2,
              fontWeight: FontWeight.bold,
              color: AppColor.secondaryColor1,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 9.spV2,
                color: AppColor.secondaryColor2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleTrailingFieldRow({
    required String label,
    required TextEditingController textController,
    String? hint,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColor.textColor1,
              fontWeight: FontWeight.w500,
              fontSize: 9.5.spV2,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: SizedBox(
              width: 40.w,
              child: TextField(
                controller: textController,
                readOnly: true,
                style: TextStyle(
                  fontSize: 10.spV2,
                  fontWeight: FontWeight.bold,
                  color: AppColor.secondaryColor1,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: TextStyle(
                    fontSize: 9.spV2,
                    color: AppColor.secondaryColor2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}