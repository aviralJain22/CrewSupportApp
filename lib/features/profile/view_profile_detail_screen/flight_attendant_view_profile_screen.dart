import 'dart:math' as math;
import 'package:crew_support/features/message/chat_service.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:crew_support/utils/url_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'flight_attendant_view_profile_controller.dart';

class FlightAttendantViewProfileScreen
    extends GetView<FlightAttendantViewProfileController> {
  const FlightAttendantViewProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        title: Text(
          "Profile Detail",
          style: TextStyle(color: AppColor.secondaryColor1),
        ),
        centerTitle: true,
        backgroundColor: AppColor.bgColor1,
        leadingWidth: 30.w,
        leading: Row(
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.adaptive.arrow_back_rounded, color: AppColor.secondaryColor1),
            ),

            // Connection status icon.
            // Placed on the left side so the title stays visually centered.
            Obx(() {
              final status = controller.connectionStatus.value;
              final direction = controller.connectionDirection.value;
              final isLoadedUser = controller.userId.value.trim().isNotEmpty;

              if (!isLoadedUser || status == 'self') {
                return SizedBox.shrink();
              }

              IconData icon;
              Color color;
              String tooltip;

              if (status == 'accepted') {
                icon = Icons.group_rounded;
                color = AppColor.secondaryColor1;
                tooltip = 'Connected';
              } else if (status == 'pending') {
                icon = direction == 'received'
                    ? Icons.person_add_alt_1_rounded
                    : Icons.hourglass_top_rounded;
                color = AppColor.goldenColorNew;
                tooltip = direction == 'received'
                    ? 'Friend request received'
                    : 'Friend request pending';
              } else {
                icon = Icons.person_add_alt_1_outlined;
                color = AppColor.textColor1;
                tooltip = 'Add friend';
              }

              return IconButton(
                tooltip: tooltip,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: controller.isSendingConnectionRequest.value ||
                        controller.isRespondingToConnectionRequest.value ||
                        controller.isCancellingConnectionRequest.value ||
                        controller.isUnfriendingConnection.value
                    ? null
                    : () {
                        debugPrint(
                          'Connection icon tapped. status: $status, direction: $direction, connectionId: ${controller.connectionObjectId.value}',
                        );

                        if (status == 'none' || status == 'denied' || status == 'cancelled' || status == 'unfriended') {
                          controller.sendConnectionRequest();
                        } else if (status == 'pending') {
                          if (direction == 'received') {
                            _showConnectionRequestDialog(context);
                          } else {
                            _showCancelConnectionRequestDialog(context);
                          }
                        } else if (status == 'accepted') {
                          _showUnfriendConnectionDialog(context);
                        }
                      },
                icon: Icon(
                  icon,
                  color: color,
                ),
              );
            }),
          ],
        ),
        elevation: 0,
        actions: [

          // Airplane mode icon (visible only for Owner profile)
          Obx(() {
            final showIcon = controller.dash.selectedProfileType.value == MembershipType.ownerOperator &&
                controller.hideDirectTripButton.value != true;
            if (!showIcon) return SizedBox.shrink();

            final isDirectTripReady = controller.attendantProfileId.value.trim().isNotEmpty;
            if (!isDirectTripReady) return SizedBox.shrink();
            debugPrint("Direct Trip icon isDirectTripReady: $isDirectTripReady, attendantProfileId: '${controller.attendantProfileId.value}'");

            return IconButton(
              onPressed: () {
                controller.goToCreateDirectTrip();
              },
              icon: Transform.rotate(
                angle: 45 * math.pi / 180, // 45 degrees in radians (clockwise)
                child: Icon(
                  Icons.airplanemode_active_rounded,
                  color: AppColor.textColor1,
                ),
              ),
            );
          }),
          SizedBox(width: 0.w),

          // Favorite heart
          Obx(() {
            final fav = controller.isFavorite.value;
            return SizedBox(
              height: 15.spV2,
              width: 20.spV2,
              child: GestureDetector(
                onTap: controller.toggleFavorite,
                child: SvgPicture.asset(
                  fav ? 'assets/Heart Fill.svg' : 'assets/Heart Outline.svg',
                  color: fav ? AppColor.deleteColor : AppColor.textColor1,
                  cacheColorFilter: false,
                ),
              ),
            );
          }),
          SizedBox(width: 3.w),

          // Message (visibility copied from old logic)
          // Message icon with disabled state until userId is loaded
          Obx(() {
            // debugPrint("controller.dash.selectedProfileType value: ${controller.dash.selectedProfileType.value}");
            // final canShow = (controller.dash.selectedProfileType.value == MembershipType.ownerOperator);
            // debugPrint("Message icon canShow: $canShow");
            // if (!canShow) return SizedBox.shrink();

            // Disable chat icon until the profile's backing _User objectId is loaded.
            // This prevents opening chat with an empty otherUserId.
            final isChatReady = controller.userId.value.trim().isNotEmpty;
            debugPrint("Chat icon isChatReady: $isChatReady, userId: '${controller.userId.value}'");

            return Opacity(
              opacity: isChatReady ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !isChatReady,
                child: GestureDetector(
                  onTap: () {
                    String fullName =
                        "${controller.firstNameController.text} ${controller.lastNameController.text}".trim();

                    debugPrint(
                      "Tapped chat icon for userId: ${controller.userId.value}, membershipType: ${controller.membershipType.value}, receiverName: $fullName",
                    );

                    final ChatService chatService = ChatService();
                    chatService.openChatForProfile(
                      otherUserId: controller.userId.value,
                      otherProfileType: controller.membershipType.value,
                      receiverName: fullName,
                      photoPath: controller.photoPath.value,
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
            );
          }),
          const SizedBox(width: 10),
        ],
      ),

      body: SafeArea(
        top: false,
        child: Obx(() {
          return SingleChildScrollView(
            child: controller.isLoading.value
                ? SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LoadingAnimationWidget.threeRotatingDots(
                              color: AppColor.secondaryColor1, size: 50.spV2),
                          SizedBox(height: 2.h),
                          Text('Loading...', style: TextStyle(color: AppColor.textColor1, fontSize: 11.spV2)),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      SizedBox(height: 1.h),

                      // Profile Photo
                      GestureDetector(
                        onTap: () {
                          final url = controller.userPhoto.value;
                          if (url.isEmpty || url == 'http') return;
                          //TODO:
                          // Get.to(() => ImageViewScreen2(imageUrl: url));
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
                                    child: Image.network(
                                      controller.userPhoto.value,
                                      loadingBuilder: (c, child, progress) {
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
                                      errorBuilder: (_, __, ___) => CircleAvatar(
                                        backgroundColor: AppColor.secondaryColor1,
                                        child: Icon(Icons.account_circle, size: 60, color: AppColor.bgColor1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      _divider(),
                      _kvRow("Membership Type", controller.membershipTypeController.text),
                      Visibility(visible: !(controller.showGender == true), child: _divider()),
                      Visibility(
                        visible: !(controller.showGender == true),
                        child: _kvRow("Gender", controller.genderController.text),
                      ),
                      _divider(),

                      _kvRow("First Name", controller.firstNameController.text),
                      _divider(),
                      _kvRow("Last Name", controller.lastNameController.text),
                      _divider(),

                      // Current Location row with location icon visibility
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 0.5.h),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: EdgeInsets.only(left: 5.w),
                                child: Text(
                                  "Current Location",
                                  style: TextStyle(
                                    color: AppColor.textColor1,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 9.5.spV2,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                readOnly: true,
                                controller: controller.currentLocationController,
                                style: TextStyle(
                                  fontSize: 10.spV2,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.secondaryColor1,
                                ),
                                decoration: const InputDecoration(border: InputBorder.none),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Visibility(
                                visible: (controller.currentLocation.value == true) &&
                                    controller.lat.value.isNotEmpty,
                                child: SizedBox(
                                  width: 40.w,
                                  child: IconButton(
                                    onPressed: () {
                                      // You had MapUtils.openMap() commented out in old code.
                                      final lat = controller.lat.value;
                                      final lng = controller.long.value;
                                      if (lat.isEmpty || lng.isEmpty) return;
                                      final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
                                      launchUrl(uri, mode: LaunchMode.externalApplication);
                                    },
                                    icon: Icon(Icons.location_on, color: AppColor.secondaryColor1),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      _divider(),

                      // Rating
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Rating",
                                style: TextStyle(
                                  color: AppColor.textColor1,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 9.5.spV2,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Obx(() {
                                return RatingBar.builder(
                                  itemSize: 18.0.spV2,
                                  initialRating: controller.ratingCount.value,
                                  minRating: 0,
                                  unratedColor: AppColor.secondaryColor2,
                                  ignoreGestures: true,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemPadding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 10.0),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: AppColor.goldenColorNew,
                                    size: 17.0.spV2,
                                  ),
                                  onRatingUpdate: (_) {},
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                      // Availability (operator-only)
                      Visibility(
                        visible: controller.dash.selectedProfileType.value == MembershipType.ownerOperator,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _divider(),
                            Padding(
                              padding: EdgeInsets.only(left: 5.w, top: 1.h),
                              child: Text(
                                'Available',
                                style: TextStyle(
                                  color: AppColor.textColor1,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 9.5.spV2,
                                ),
                              ),
                            ),
                            Obx(() {
                              final items = controller.availList;
                              if (items.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: items.length,
                                itemBuilder: (_, index) {
                                  final it = items[index];
                                  if (it.isPast == true) return const SizedBox.shrink();
                                  final from = it.fromDate;
                                  final to = it.toDate;

                                  // If dates are missing, skip row to avoid crashes
                                  if (from == null || to == null) return const SizedBox.shrink();

                                  return Padding(
                                    padding: EdgeInsets.only(
                                      left: 5.w,
                                      right: 5.w,
                                      top: 5,
                                      bottom: 5,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'From ${DateFormat('MM/dd/yyyy').format(from)} '
                                          'To ${DateFormat('MM/dd/yyyy').format(to)}',
                                          style: TextStyle(
                                            color: AppColor.secondaryColor1,
                                            fontSize: 10.spV2,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 1.h),
                                        // Wrap instead of Row so on iPad (or large accessibility text)
                                        // the content can flow to a new line without overflowing.
                                        Wrap(
                                          spacing: 3.w,
                                          runSpacing: 0.5.h,
                                          children: [
                                            Text(
                                              'Nearest Airport: ${it.airportCode ?? ''}',
                                              style: TextStyle(
                                                color: AppColor.secondaryColor2,
                                                fontSize: 9.spV2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }),
                          ],
                        ),
                      ),

                      _divider(),
                      _kvRow("Passport", controller.passportController.text),
                      _divider(),
                      _kvRow("Full Time Work", controller.fullTimeController.text),

                      // Resume block (parity with nested visibility)
                      controller.canShowResume
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 5.w, top: 3.h, bottom: 2.h),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Resume",
                                    style: TextStyle(color: AppColor.historyRead, fontSize: 11.spV2),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColor.secondaryColor1, width: 1.0),
                                    borderRadius: BorderRadius.circular(10.spV2),
                                  ),
                                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${controller.firstNameController.text} ${controller.lastNameController.text}",
                                        style: TextStyle(
                                          fontSize: 10.spV2,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.secondaryColor1,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          final url = controller.resumePath!;
                                          UrlHelper.openInAppNoContext(url);
                                        },
                                        icon: Icon(Icons.remove_red_eye, color: AppColor.secondaryColor1),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                _divider(),
                              ],
                            )
                          : const SizedBox.shrink(),

                      // Bio
                      Container(
                        margin: EdgeInsets.only(left: 5.w, top: 3.h, bottom: 2.h),
                        alignment: Alignment.centerLeft,
                        child: Text("Bio",
                            style: TextStyle(color: AppColor.historyRead, fontSize: 11.spV2)),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 5.w),
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColor.secondaryColor1, width: 1.0),
                          borderRadius: BorderRadius.circular(10.spV2),
                        ),
                        child: TextFormField(
                          minLines: 4,
                          maxLines: 5,
                          readOnly: true,
                          controller: controller.bioController,
                          style: TextStyle(
                            fontSize: 10.spV2,
                            fontWeight: FontWeight.bold,
                            color: AppColor.secondaryColor1,
                          ),
                          decoration: const InputDecoration(border: InputBorder.none),
                        ),
                      ),

                      // Experience
                      Container(
                        margin: EdgeInsets.only(left: 5.w, top: 5.h, bottom: 1.h),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Experience",
                          style: TextStyle(color: AppColor.historyRead, fontSize: 9.5.spV2),
                        ),
                      ),
                      _divider(),
                      _kvRow("Years of Experience", controller.yrExperienceController.text),
                      _divider(),

                      // Aircraft Experience (with See More)
                      _listFieldRow(
                        context: context,
                        label: "Aircraft Experience",
                        sheetTitle: "Aircraft Experience",
                        valueText: controller.aircraftExpStr.value,
                        items: controller.aircraftTypeExp,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        labelPadding: EdgeInsets.symmetric(horizontal: 5.w),
                        emptyPlaceholder: 'Aircraft Experience',
                        isHighlightedOverride: controller.aircraftTypeExp.isNotEmpty,
                      ),

                      _divider(),

                      // Continent Exp
                      _listFieldRow(
                        context: context,
                        label: "Region Experience",
                        sheetTitle: "Region Experience",
                        valueText: controller.continentExpStr.value,
                        items: controller.continentExpSaveList,
                        padding: EdgeInsets.symmetric(vertical: 5.w),
                        labelPadding: EdgeInsets.only(left: 5.w),
                        emptyPlaceholder: 'Region Experience',
                      ),

                      _divider(),
                      
                     _listFieldRow(
                        context: context,
                        label: "International Visas Held",
                        sheetTitle: "International Visas Held",
                        valueText: controller.internationalVisasHeldStr.value,
                        items: controller.internationalVisaSaveList,
                        padding: EdgeInsets.symmetric(vertical: 5.w),
                        emptyPlaceholder: '-',
                        labelPadding: EdgeInsets.only(left: 5.w),
                      ),

                      _divider(),

                      _listFieldRow(
                        context: context,
                        label: "Languages Spoken",
                        sheetTitle: "Languages Spoken",
                        valueText: controller.languagesStr.value,
                        items: controller.languageSaveList,
                        padding: EdgeInsets.symmetric(vertical: 5.w),
                        emptyPlaceholder: '-',
                        labelPadding: EdgeInsets.only(left: 5.w),
                      ),

                      _divider(),

                      _listFieldRow(
                        context: context,
                        label: "Special Training",
                        sheetTitle: "Special Training",
                        valueText: controller.specialTrainingStr.value,
                        items: controller.specialTrainingSaveList,
                        padding: EdgeInsets.symmetric(vertical: 5.w),
                        emptyPlaceholder: '-',
                        labelPadding: EdgeInsets.only(left: 5.w),
                      ),

                      Visibility(
                        visible: controller.otherTrainingStr.value.isNotEmpty,
                        child: _listFieldRow(
                          context: context,
                          label: "Other Training",
                          sheetTitle: "Other Training",
                          valueText: controller.otherTrainingStr.value,
                          items: controller.otherTrainingSaveList,
                          padding: EdgeInsets.symmetric(vertical: 5.w),
                          emptyPlaceholder: '-',
                          labelPadding: EdgeInsets.only(left: 5.w),
                        ),
                      ),

                      // (The legacy file continues further; keep adding blocks below in the same pattern if needed.)

                      SizedBox(height: 2.h),

                      // -----------------------------
                      // AFTER "Continent Exp." UI
                      // -----------------------------
                      Obx(() {
                        final bool showSocial = controller.hasAnySocialLink;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // -------- See Profile (Social Icons) --------
                            Visibility(
                              visible: showSocial,
                              child: Container(
                                margin: EdgeInsets.only(left: 5.w, top: 4.h, bottom: 1.h),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "See Profile ",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: AppColor.historyRead,
                                    fontSize: 9.5.spV2,
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: showSocial,
                              child: Divider(
                                indent: 10,
                                endIndent: 10,
                                thickness: 1,
                                color: AppColor.secondaryColor1,
                              ),
                            ),
                            Visibility(
                              visible: showSocial,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Instagram
                                  Obx(() => Visibility(
                                        visible: controller.instagramLink.value.trim().isNotEmpty,
                                        child: InkWell(
                                          onTap: () => UrlHelper.openInAppNoContext(
                                            controller.instagramLink.value,
                                          ),
                                          child: Container(
                                            height: 5.0.h,
                                            margin: EdgeInsets.only(
                                              right: 5.0.w,
                                              top: 1.0.h,
                                              bottom: 1.0.h,
                                            ),
                                            child: Image.asset("assets/instagram_big.png"),
                                          ),
                                        ),
                                      )),

                                  // Facebook
                                  Obx(() => Visibility(
                                        visible: controller.facebookLink.value.trim().isNotEmpty,
                                        child: InkWell(
                                          onTap: () => UrlHelper.openInAppNoContext(
                                            controller.facebookLink.value,
                                          ),
                                          child: Container(
                                            height: 5.0.h,
                                            margin: EdgeInsets.only(
                                              right: 5.0.w,
                                              top: 1.0.h,
                                              bottom: 1.0.h,
                                            ),
                                            child: Image.asset("assets/facebook_big.png"),
                                          ),
                                        ),
                                      )),

                                  // LinkedIn
                                  Obx(() => Visibility(
                                        visible: controller.linkedinLink.value.trim().isNotEmpty,
                                        child: InkWell(
                                          onTap: () => UrlHelper.openInAppNoContext(
                                            controller.linkedinLink.value,
                                          ),
                                          child: Container(
                                            height: 5.0.h,
                                            margin: EdgeInsets.only(
                                              right: 5.0.w,
                                              top: 1.0.h,
                                              bottom: 1.0.h,
                                            ),
                                            child: Image.asset("assets/linkedin.png"),
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: showSocial,
                              child: Divider(
                                indent: 10,
                                endIndent: 10,
                                thickness: 1,
                                color: AppColor.secondaryColor1,
                              ),
                            ),

                            // -------- My Photos --------
                            // Old code: visible: widget.showProfile == true ? false : true
                            Visibility(
                              visible: controller.showProfile != true, // <-- use your screen param
                              child: Container(
                                margin: EdgeInsets.only(left: 5.w, top: 4.h, bottom: 1.h),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "My Photos",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: AppColor.historyRead,
                                    fontSize: 9.5.spV2,
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: controller.showProfile != true,
                              child: Divider(
                                indent: 10,
                                endIndent: 10,
                                thickness: 1,
                                color: AppColor.secondaryColor1,
                              ),
                            ),

                            // Row 1 (image1, image2, image3)
                            Visibility(
                              visible: controller.showProfile != true,
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 2.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _photoBox(
                                      context: context,
                                      imageUrl: controller.image1.value,
                                      onTap: () => controller.openImageViewer(
                                        selectedImage: controller.image1.value,
                                        context: context,
                                      ),
                                    ),
                                    _photoBox(
                                      context: context,
                                      imageUrl: controller.image2.value,
                                      onTap: () => controller.openImageViewer(
                                        selectedImage: controller.image2.value,
                                        context: context,
                                      ),
                                    ),
                                    _photoBox(
                                      context: context,
                                      imageUrl: controller.image3.value,
                                      onTap: () => controller.openImageViewer(
                                        selectedImage: controller.image3.value,
                                        context: context,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Row 2 (image4, image5, image6)
                            Visibility(
                              visible: controller.showProfile != true,
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 2.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _photoBox(
                                      context: context,
                                      imageUrl: controller.image4.value,
                                      onTap: () => controller.openImageViewer(
                                        selectedImage: controller.image4.value,
                                        context: context,
                                      ),
                                    ),
                                    _photoBox(
                                      context: context,
                                      imageUrl: controller.image5.value,
                                      onTap: () => controller.openImageViewer(
                                        selectedImage: controller.image5.value,
                                        context: context,
                                      ),
                                    ),
                                    _photoBox(
                                      context: context,
                                      imageUrl: controller.image6.value,
                                      onTap: () => controller.openImageViewer(
                                        selectedImage: controller.image6.value,
                                        context: context,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
          );
        }),
      ),
    );
  }

  // --- Helpers (UI) ----------------------------------------------------------

  void _showConnectionRequestDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('Connection Request'),
        content: Padding(
          padding: EdgeInsets.only(top: 1.h),
          child: Text(
            '${controller.firstNameController.text} has sent you a connection request.',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Get.back();
              await controller.denyConnectionRequest();
            },
            child: Text('Deny'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              Get.back();
              await controller.acceptConnectionRequest();
            },
            child: Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showCancelConnectionRequestDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('Cancel Request'),
        content: Padding(
          padding: EdgeInsets.only(top: 1.h),
          child: Text(
            'A friend request to ${controller.firstNameController.text} is pending. Do you want to cancel it?',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Get.back(),
            child: Text('Keep Pending'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Get.back();
              await controller.cancelConnectionRequest();
            },
            child: Text('Cancel Request'),
          ),
        ],
      ),
    );
  }

  void _showUnfriendConnectionDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('Remove Connection'),
        content: Padding(
          padding: EdgeInsets.only(top: 1.h),
          child: Text(
            'Are you sure that you want to remove your connection with ${controller.firstNameController.text}?',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Get.back();
              await controller.unfriendConnection();
            },
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Padding(
        padding: EdgeInsets.only(top: 1.h),
        child: Divider(
          indent: 10,
          endIndent: 10,
          thickness: 1,
          color: AppColor.secondaryColor1,
        ),
      );

  Widget _kvRow(String keyLabel, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.only(left: 5.w),
            child: Text(
              keyLabel,
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
          child: TextFormField(
            readOnly: true,
            controller: TextEditingController(text: value),
            style: TextStyle(
              fontSize: 10.spV2,
              fontWeight: FontWeight.bold,
              color: AppColor.secondaryColor1,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: keyLabel,
              hintStyle: TextStyle(fontSize: 10.spV2, color: AppColor.secondaryColor2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _photoBox({
    required BuildContext context,
    required String? imageUrl,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColor.secondaryColor1,
          width: 3.0,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(10.sp),
      ),
      child: SizedBox(
        height: 20.w,
        width: 20.w,
        child: (imageUrl == null || imageUrl.trim().isEmpty)
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.sp),
                  color: AppColor.textColor2,
                ),
                child: Icon(
                  Icons.image,
                  color: AppColor.secondaryColor1,
                  size: 40,
                ),
              )
            : GestureDetector(
                onTap: onTap,
                child: Image.network(
                  imageUrl,
                  loadingBuilder: (
                    BuildContext context,
                    Widget child,
                    ImageChunkEvent? loadingProgress,
                  ) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColor.secondaryColor1,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (
                    BuildContext context,
                    Object exception,
                    StackTrace? stackTrace,
                  ) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.sp),
                        color: AppColor.textColor2,
                      ),
                      child: Icon(
                        Icons.image,
                        size: 40,
                        color: AppColor.secondaryColor1,
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  void _showListBottomSheet({
    required BuildContext context,
    required String title,
    required List<String> items,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: AppColor.bgColor1,
              bottomNavigationBar: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 5.w),
                child: MaterialButton(
                  textColor: AppColor.textColor2,
                  color: AppColor.secondaryColor1,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: const Text('Close'),
                  onPressed: () => Get.back(),
                ),
              ),
              body: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListView.builder(
                        itemCount: items.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (_, index) {
                          final label = items[index];
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 2.0.w,
                                  height: 2.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColor.textColor1,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 10.spV2,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.secondaryColor1,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 5.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  bool _hasMeaningfulFirstItem(List<String> items) {
    if (items.isEmpty) return false;
    return items.first.trim().isNotEmpty;
  }

  //for list fields with See More button
  Widget _listFieldRow({
    required BuildContext context,
    required String label,
    required String sheetTitle,
    required String valueText,
    required List<String> items,
    required EdgeInsets padding,
    EdgeInsets labelPadding = const EdgeInsets.only(left: 0),
    String emptyPlaceholder = '-',
    bool? isHighlightedOverride,
  }) {
    final hasValue = valueText.trim().isNotEmpty;
    // Default highlight behavior matches the legacy rows (bold/color when first item is meaningful).
    final isHighlighted = isHighlightedOverride ?? _hasMeaningfulFirstItem(items);

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: labelPadding,
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 2,
                  child: Text(
                    hasValue ? valueText : emptyPlaceholder,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.spV2,
                      fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                      color: isHighlighted ? AppColor.secondaryColor1 : AppColor.secondaryColor2,
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Visibility(
                    visible: items.length > 1,
                    child: GestureDetector(
                      onTap: () {
                        _showListBottomSheet(
                          context: context,
                          title: sheetTitle,
                          items: items,
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '   See More',
                              style: TextStyle(
                                fontSize: 8.spV2,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
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
    );
  }

}