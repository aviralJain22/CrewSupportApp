import 'dart:math' as math;
import 'package:crew_support/database/airport_display_helper.dart';
import 'package:crew_support/features/message/chat_service.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:crew_support/utils/url_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:sizer/sizer.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'pilot_view_profile_controller.dart';

class PilotViewProfileScreen
    extends GetView<PilotViewProfileController> {
  const PilotViewProfileScreen({super.key});

  // Helper to open the “See more” bottom sheet
  void _showSeeMore(BuildContext context, List<String> items) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.bgColor1,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
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
                    side: BorderSide(
                        color: AppColor.secondaryColor1, width: 0.6.w),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Text('Close'),
                  onPressed: () => Get.back(),
                ),
              ),
              body: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: items.length,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                itemBuilder: (_, i) => Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                  child: Row(
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
                      Expanded(
                        child: Text(
                          items[i],
                          style: TextStyle(
                            fontSize: 10.spV2,
                            fontWeight: FontWeight.bold,
                            color: AppColor.secondaryColor1,
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
      },
    );
  }

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
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColor.bgColor1,
        title: Text(
          "Profile Detail",
          style: TextStyle(color: AppColor.secondaryColor1),
        ),
        leadingWidth: 30.w,
        leading: Row(
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Icons.adaptive.arrow_back_rounded,
                color: AppColor.secondaryColor1,
              ),
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

                      if (status == 'none' ||
                          status == 'denied' ||
                          status == 'cancelled' ||
                          status == 'unfriended') {
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

        actions: [

          // Direct trip icon (visible only for Owner profile)
          Obx(() {
            final showIcon =
                controller.dash.selectedProfileType.value == MembershipType.ownerOperator &&
                controller.hideDirectTripButton.value != true;
            if (!showIcon) return SizedBox.shrink();

            final isDirectTripReady = controller.pilotProfileId.value.trim().isNotEmpty;
            if (!isDirectTripReady) return SizedBox.shrink();
            debugPrint("Direct Trip icon isDirectTripReady: $isDirectTripReady, pilotProfileId: '${controller.pilotProfileId.value}'");

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

          // Favourite heart
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
                        "${controller.firstName.value} ${controller.lastName.value}";

                    debugPrint(
                      "Tapped chat icon for userId: ${controller.userId.value}, membershipType: ${controller.membershipType.value}, receiverName: $fullName",
                    );

                    final ChatService chatService = ChatService();
                    chatService.openChatForProfile(
                      otherUserId: controller.userId.value,
                      otherProfileType: controller.membershipType.value ?? 0,
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
          SizedBox(width: 10),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
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
                    style: TextStyle(color: AppColor.textColor1),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 1.h),

              // Avatar
              GestureDetector(
                onTap: () {
                  final url = controller.photoPath.value.trim();
                  if (url.isEmpty || url == 'http' || url == 'http://' || url == 'https://' || url == 'file:///') {
                    return;
                  }
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
                            child: _buildAvatarImage(controller.photoPath.value),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: Divider(
                  indent: 10,
                  endIndent: 10,
                  thickness: 1,
                  color: AppColor.secondaryColor1,
                ),
              ),

              // Membership Type
              _rowTextAndReadonlyField(
                label: "Membership Type",
                controller: controller.membershipTypeController,
              ),

              _divider(),

              // Gender
              _rowTextAndReadonlyField(
                label: "Gender",
                controller: controller.genderController,
              ),

              _divider(),

              // First Name
              _rowTextAndReadonlyField(
                label: "First Name",
                controller: controller.firstNameController,
              ),

              _divider(),

              // Last Name
              _rowTextAndReadonlyField(
                label: "Last Name",
                controller: controller.lastNameController,
              ),

              _divider(),

              // Current Location + map icon (visible only if ON and lat non-empty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Current Location",
                        style: TextStyle(
                          color: AppColor.textColor1,
                          fontWeight: FontWeight.w500,
                          fontSize: 9.5.spV2,
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
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Current Location",
                          hintStyle: TextStyle(
                            fontSize: 9.spV2,
                            color: AppColor.secondaryColor2,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Obx(() {
                        // Always touch reactive first so Obx registers a dependency
                        final hasLat = controller.lat.value.isNotEmpty;
                        final showIcon = (controller.currentLocation.value != false) && hasLat;
                        if (!showIcon) return SizedBox.shrink();
                        return SizedBox(
                          width: 40.w,
                          child: IconButton(
                            onPressed: () {
                              // If you have a MapUtils.openMap, call it here
                              // MapUtils.openMap(double.parse(controller.lat.value), double.parse(controller.long.value));
                            },
                            icon: Icon(
                              Icons.location_on,
                              color: AppColor.secondaryColor1,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              _divider(),

              // Rating (read-only)
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
                      child: Obx(() => RatingBar.builder(
                            itemSize: 18.0.spV2,
                            unratedColor: AppColor.secondaryColor2,
                            initialRating: controller.rating.value.isEmpty
                                ? 0.0
                                : double.tryParse(controller.rating.value) ?? 0.0,
                            minRating: 0,
                            ignoreGestures: true,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: EdgeInsets.symmetric(
                                horizontal: 1.0, vertical: 10.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: AppColor.goldenColorNew,
                              size: 17.0.spV2,
                            ),
                            onRatingUpdate: (_) {},
                          )),
                    ),
                  ],
                ),
              ),

              // Availability (visible to membershipId == "1")
              Obx(() {
                // Touch a reactive first so Obx has a dependency even if we early-return
                final _ = controller.availabilityList.length;
                final showAvail = controller.dash.selectedProfileType.value ==  MembershipType.ownerOperator;
                if (!showAvail) return SizedBox.shrink();

                var availabilityTitle = "Availability";
                if (controller.availabilityList.isEmpty) {
                  availabilityTitle = "Availability not set";
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _divider(),
                    Padding(
                      padding: EdgeInsets.only(left: 5.w, top: 1.h),
                      child: Text(
                        availabilityTitle,
                        style: TextStyle(
                          color: AppColor.textColor1,
                          fontWeight: FontWeight.w500,
                          fontSize: 9.5.spV2,
                        ),
                      ),
                    ),
                    if (controller.availabilityList.isEmpty)
                      SizedBox.shrink()
                    else
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: controller.availabilityList.length,
                        itemBuilder: (context, index) {
                          final a = controller.availabilityList[index];
                          String fmt(DateTime d) =>
                              DateFormat('MM/dd/yyyy').format(d);
                          DateTime? fd, td;
                          try {
                            fd = DateTime.parse(a.fromDate.toString());
                            td = DateTime.parse(a.toDate.toString());
                          } catch (_) {}

                          return Padding(
                            padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 5, bottom: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'From ${fd != null ? fmt(fd) : ""} To ${td != null ? fmt(td) : ""}',
                                  style: TextStyle(
                                    color: AppColor.secondaryColor1,
                                    fontSize: 10.spV2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                // Wrap instead of Row so on iPad (or large accessibility text)
                                // the content can flow to a new line without overflowing.
                                Obx(() {
                                  final airportCode = (a.airportCode ?? '').trim();
                                  final airport = controller.airportByCode[airportCode];
                                  final airportDisplay = formatAirportDisplay(
                                    airport,
                                    fallbackCode: airportCode,
                                  );

                                  return Wrap(
                                    spacing: 3.w,
                                    runSpacing: 0.5.h,
                                    children: [
                                      Text(
                                        'Nearest Airport: $airportDisplay',
                                        style: TextStyle(
                                          color: AppColor.secondaryColor2,
                                          fontSize: 9.spV2,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                );
              }),

              _divider(),

              // Total Time
              _rowNumberAndReadonlyField(
                label: "Total Time",
                controller: controller.totalTimeController,
              ),

              _divider(),

              // PIC Time
              _rowNumberAndReadonlyField(
                label: "PIC Time",
                controller: controller.picTimeController,
              ),

              _divider(),

              // Medical Class
              _rowTextAndReadonlyField(
                label: "Medical Class",
                controller: controller.medicalClassController,
              ),

              _divider(),

              // Passport
              _rowTextAndReadonlyField(
                label: "Passport",
                controller: controller.passportController,
              ),

              _divider(),

              // Country of Citizenship
              _rowListFirstItemWithSeeMore(
                title: "Country of Citizenship",
                itemsRx: controller.citizenshipSaveList,
                fallbackHint: "Country of Citizenship",
                onSeeMore: () => _showSeeMore(
                    context, controller.citizenshipSaveList.toList()),
              ),

              _divider(),

              // Passport Expiration Date
              _rowTextAndReadonlyField(
                label: "Passport Expiration Date",
                controller: controller.passportExpireDateController,
              ),

              _divider(),

              // Full Time Work
              _rowTextAndReadonlyField(
                label: "Full Time Work",
                controller: controller.fullTimeController,
              ),

              _divider(),

              // Resume (visibility conditions retained exactly)
              _resumeBlock(controller),

              // Type Rating header (same text size usage retained)
              Container(
                margin: EdgeInsets.only(left: 5.w, top: 3.h, bottom: 1.h),
                alignment: Alignment.centerLeft,
                child: Text(
                  "Type Rating",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColor.historyRead,
                    fontSize: 9.5.spV2.spV2, // matches original chained call
                  ),
                ),
              ),

              _divider(),

              // Type Ratings one-line + See More
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Type Ratings",
                        style: TextStyle(
                          color: AppColor.textColor1,
                          fontWeight: FontWeight.w500,
                          fontSize: 9.5.spV2,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.only(right: 1.w),
                        child: Obx(() {
                          final list = controller.ratingData;
                          final hasAny = list.isNotEmpty;
                          final firstText =
                              hasAny ? (list.first.aircraftType ?? '') : '';
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                flex: 2,
                                child: Text(
                                  hasAny && firstText.isNotEmpty
                                      ? firstText
                                      : "Type Ratings",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: hasAny ? 10.spV2 : 9.spV2,
                                    fontWeight: hasAny
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: hasAny
                                        ? AppColor.secondaryColor1
                                        : AppColor.secondaryColor2,
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: Visibility(
                                  visible: list.length > 1,
                                  child: GestureDetector(
                                    onTap: () => _showSeeMore(
                                      context,
                                      list
                                          .map((e) => e.aircraftType ?? '')
                                          .where((e) => e.isNotEmpty)
                                          .toList(),
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '   See More',
                                            style: TextStyle(
                                              fontSize: 8.spV2,
                                              fontWeight: FontWeight.bold,
                                              color: AppColor.historyRead,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              _divider(),

              // Continent Exp.
              _rowListFirstItemWithSeeMore(
                title: "Region Experience",
                itemsRx: controller.continentSaveList,
                fallbackHint: "Region Experience",
                onSeeMore: () =>
                    _showSeeMore(context, controller.continentSaveList.toList()),
              ),

              _divider(),

              // Oceanic Exp.
              _rowListFirstItemWithSeeMore(
                title: "Oceanic Experience",
                itemsRx: controller.oceanicSaveList,
                fallbackHint: "Oceanic Experience",
                onSeeMore: () =>
                    _showSeeMore(context, controller.oceanicSaveList.toList()),
              ),

              _divider(),

              // --------------------------------------------------
              // Bio (legacy section)
              // --------------------------------------------------
              Container(
                margin: EdgeInsets.only(left: 5.w, top: 5.h, bottom: 2.h),
                alignment: Alignment.centerLeft,
                child: Text(
                  "Bio",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColor.historyRead,
                    fontSize: 11.spV2,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5.w),
                padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColor.secondaryColor1,
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(10.spV2),
                ),
                child: TextFormField(
                  minLines: 4,
                  maxLines: 5,
                  readOnly: true,
                  controller: controller.bioController,
                  cursorColor: AppColor.secondaryColor1,
                  style: TextStyle(
                    fontSize: 10.spV2,
                    fontWeight: FontWeight.bold,
                    color: AppColor.secondaryColor1,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Bio",
                    hintStyle: TextStyle(
                      fontSize: 9.spV2,
                      color: AppColor.secondaryColor2,
                    ),
                  ),
                ),
              ),

              // --------------------------------------------------
              // See Profile (Instagram / Facebook / LinkedIn)
              // --------------------------------------------------
              Obx(() {
                final insta = controller.instagram.value.trim();
                final fb = controller.facebook.value.trim();
                final li = controller.linkedIn.value.trim();

                final hasAny = insta.isNotEmpty || fb.isNotEmpty || li.isNotEmpty;

                if (!hasAny) return SizedBox.shrink();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 5.w, top: 4.h, bottom: 1.h),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "See Profile ",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColor.historyRead,
                          fontSize: 11.spV2,
                        ),
                      ),
                    ),
                    _divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: insta.isNotEmpty,
                          child: InkWell(
                            onTap: () => UrlHelper.openInAppNoContext(insta),
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
                        ),
                        Visibility(
                          visible: fb.isNotEmpty,
                          child: InkWell(
                            onTap: () => UrlHelper.openInAppNoContext(fb),
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
                        ),
                        Visibility(
                          visible: li.isNotEmpty,
                          child: InkWell(
                            onTap: () => UrlHelper.openInAppNoContext(li),
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
                        ),
                      ],
                    ),
                    _divider(),
                    SizedBox(height: 3.h),
                  ],
                );
              }),

              SizedBox(height: 4.h),
            ],
          ),
        );
      }),
    );
  }

  void _showConnectionRequestDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(
          'Connection Request',
        ),
        content: Padding(
          padding: EdgeInsets.only(top: 1.h),
          child: Text(
            '${controller.firstName.value} has sent you a connection request.',
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
            child: Text('Accept', style: TextStyle(color: AppColor.secondaryColor1)),
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
            'A friend request to ${controller.firstName.value} is pending. Do you want to cancel it?',
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
            'Are you sure that you want to remove your connection with ${controller.firstName.value}?',
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

  // ---------- Small helpers to keep UI identical & tidy ----------

  Widget _divider() => Divider(
        indent: 10,
        endIndent: 10,
        thickness: 1,
        color: AppColor.secondaryColor1,
      );

  Widget _rowTextAndReadonlyField({
    required String label,
    required TextEditingController controller,
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
          child: TextFormField(
            controller: controller,
            readOnly: true,
            style: TextStyle(
              fontSize: 10.spV2,
              fontWeight: FontWeight.bold,
              color: AppColor.secondaryColor1,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: label,
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

  Widget _rowNumberAndReadonlyField({
    required String label,
    required TextEditingController controller,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.only(left: 5.0.w),
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
          child: TextFormField(
            controller: controller,
            readOnly: true,
            keyboardType:
                const TextInputType.numberWithOptions(signed: true, decimal: false),
            style: TextStyle(
              fontSize: 10.spV2,
              fontWeight: FontWeight.bold,
              color: AppColor.secondaryColor1,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: label,
              hintStyle: TextStyle(
                color: AppColor.secondaryColor2,
                fontSize: 9.spV2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _rowListFirstItemWithSeeMore({
    required String title,
    required RxList<String> itemsRx,
    required String fallbackHint,
    required VoidCallback onSeeMore,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0.w, vertical: 2.h),
            child: Text(
              title,
              style: TextStyle(
                color: AppColor.textColor1,
                fontWeight: FontWeight.w500,
                fontSize: 9.5.spV2,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.only(right: 1.w),
            child: Obx(() {
              final items = itemsRx;
              final hasAny = items.isNotEmpty && items.first.isNotEmpty;
              final first = hasAny ? items.first : '';

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    flex: 2,
                    child: Text(
                      hasAny ? first : fallbackHint,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: hasAny ? 10.spV2 : 9.spV2,
                        fontWeight:
                            hasAny ? FontWeight.bold : FontWeight.normal,
                        color: hasAny
                            ? AppColor.secondaryColor1
                            : AppColor.secondaryColor2,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Visibility(
                      visible: items.length > 1,
                      child: GestureDetector(
                        onTap: onSeeMore,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '   See More',
                                style: TextStyle(
                                  fontSize: 8.spV2,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.historyRead,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _resumeBlock(PilotViewProfileController c) {
    // Visibility logic copied exactly from old file
    final resumePath = c.resumePath.value;
    final isHttp = resumePath == "" || resumePath == "http";
    // final isFullTimeNo = c.fullTimeController.text == "No";

    final showIfMember1 =
        c.isResume.value && c.dash.selectedProfileType.value ==  MembershipType.ownerOperator;
    final showElse =
        c.isResume.value == false; // from old "else" branch

    final visible = isHttp
        ? false
        : (showIfMember1 ? true : showElse);

    if (!visible) return SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.only(left: 5.w, top: 3.h, bottom: 2.h),
          alignment: Alignment.centerLeft,
          child: Text(
            "Resume",
            textAlign: TextAlign.left,
            style: TextStyle(color: AppColor.historyRead, fontSize: 11.spV2),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: AppColor.secondaryColor1, width: 1.0, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(10.spV2),
          ),
          margin: EdgeInsets.only(left: 3.w, right: 3.w),
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${c.firstNameController.text} ${c.lastNameController.text}",
                  style: TextStyle(
                    fontSize: 10.spV2,
                    fontWeight: FontWeight.bold,
                    color: AppColor.secondaryColor1,
                  )),
              IconButton(
                onPressed: () {
                  UrlHelper.openInAppNoContext(resumePath);
                },
                icon: Icon(Icons.remove_red_eye, color: AppColor.secondaryColor1),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        _divider(),
      ],
    );
  }
}