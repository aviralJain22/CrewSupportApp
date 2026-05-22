import 'package:crew_support/features/connection/connection_profile_model.dart';
import 'package:crew_support/helper/user_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'connection_controller.dart';

class ConnectionScreen extends GetView<ConnectionController> {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            // --- Loading state ---
            return SizedBox(
              height: 55.h,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LoadingAnimationWidget.threeRotatingDots(
                      color: AppColor.secondaryColor1,
                      size: 50.spV2,
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: AppColor.textColor1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }


          // --- Data available state ---
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Requests count
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () => _showRequestsOverlay(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 0.8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.bgColor1,
                        borderRadius: BorderRadius.circular(20.spV2),
                        border: Border.all(
                          color: AppColor.secondaryColor1,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        "Requests (${controller.pendingReceivedRequestList.length})",
                        style: TextStyle(
                          color: AppColor.textColor1,
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // Search field
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: controller.searchController,
                    onChanged: controller.filterByName,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColor.textColor1,
                      ),
                      labelText: "search",
                      fillColor: AppColor.textColor1,
                      labelStyle: TextStyle(
                        color: AppColor.textColor1,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 3,
                          color: AppColor.secondaryColor1.withOpacity(0.8),
                        ),
                        borderRadius:
                            BorderRadius.circular(10.spV2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 3,
                          color: AppColor.secondaryColor1.withOpacity(0.8),
                        ),
                        borderRadius:
                            BorderRadius.circular(5.spV2),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontFamily: "Poppins",
                      color: AppColor.textColor1,
                    ),
                  ),
                ),

                // Dismiss keyboard on tap
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: controller.filteredRequestList.isEmpty
                      ? SizedBox(
                          height: 50.h,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: const AssetImage(
                                  "assets/logoNewGolden.png",
                                ),
                                colorFilter: ColorFilter.mode(
                                  AppColor.bgColor1.withOpacity(0.9),
                                  BlendMode.srcOver,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text("Accepted connections will appear here",
                                style: TextStyle(
                                  fontSize: 10.spV2,
                                  color: AppColor.secondaryColor1,
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 50.h,
                          child: ListView.builder(
                            itemCount:
                                controller.filteredRequestList.length,
                            itemBuilder: (context, index) {
                              final request =
                                  controller.filteredRequestList[index];

                              return Dismissible(
                                key: ValueKey('connection_${request.connectionId}_${request.otherProfileId}'),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (_) => _confirmUnfriend(context, request),
                                onDismissed: (_) async {
                                  await controller.unfriendConnection(request);
                                },
                                background: Container(
                                  margin: EdgeInsets.all(3.0.w),
                                  padding: EdgeInsets.only(right: 5.w),
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(
                                    color: AppColor.deleteColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.person_remove_alt_1_rounded,
                                    color: AppColor.textColor1,
                                    size: 24.spV2,
                                  ),
                                ),
                                child: Container(
                                  margin: EdgeInsets.all(0.4.w),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(10),
                                    color: AppColor.bgColor1,
                                  ),
                                  padding: EdgeInsets.only(
                                    top: 1.0.h,
                                    bottom: 1.0.h,
                                    left: 2.0.w,
                                    right: 2.0.w,
                                  ),
                                  child: ListTile(
                                    textColor: AppColor.textColor2,
                                    title: Text(
                                      request.fullName,
                                      style: TextStyle(
                                        fontSize: 12.spV2,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            AppColor.secondaryColor1,
                                      ),
                                    ),
                                    subtitle: Text(
                                      getMembershipTitle(request.otherProfileType.toString()),
                                      style: TextStyle(
                                        fontSize: 9.0.spV2,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            AppColor.secondaryColor2,
                                      ),
                                    ),
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundColor:
                                          AppColor.secondaryColor1,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(
                                                30),
                                        child: SizedBox(
                                          height: 60.0.spV2,
                                          width: 60.0.spV2,
                                          child: Image.network(
                                            request.photoPath,
                                            fit: BoxFit.fill,
                                            height: 4.h,
                                            width: 4.w,
                                            loadingBuilder: (
                                              BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress,
                                            ) {
                                              if (loadingProgress ==
                                                  null) {
                                                return child;
                                              }
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color:
                                                      AppColor.bgColor1,
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (
                                              BuildContext context,
                                              Object exception,
                                              StackTrace? stackTrace,
                                            ) {
                                              return CircleAvatar(
                                                backgroundColor:
                                                    AppColor
                                                        .secondaryColor1,
                                                child: Icon(
                                                  Icons.person,
                                                  color:
                                                      AppColor.textColor2,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Trailing icons
                                    trailing: GestureDetector(
                                      onTap: () => controller.openChat(request),
                                      child: SvgPicture.asset(
                                        'assets/message.svg',
                                        height: 3.0.h,
                                        color: AppColor.secondaryColor1,
                                        cacheColorFilter: false,
                                      ),
                                    ),

                                    // Whole row tap → open profile
                                    onTap: () {
                                      controller.handleRowTap(
                                        request,
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showRequestsOverlay(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: Obx(
          () => Container(
            constraints: BoxConstraints(maxHeight: 80.h),
            decoration: BoxDecoration(
              color: AppColor.bgColor1,
              borderRadius: BorderRadius.circular(14.spV2),
              border: Border.all(
                color: AppColor.secondaryColor1,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 4.w, right: 1.w, top: 1.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Connection Requests (${controller.pendingReceivedRequestList.length})',
                          style: TextStyle(
                            color: AppColor.secondaryColor1,
                            fontSize: 12.spV2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColor.textColor1,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: AppColor.secondaryColor1.withOpacity(0.4)),
                Flexible(
                  child: controller.pendingReceivedRequestList.isEmpty
                      ? SizedBox(
                          height: 28.h,
                          child: Center(
                            child: Text(
                              'No pending connection requests.',
                              style: TextStyle(
                                color: AppColor.secondaryColor1,
                                fontSize: 10.spV2,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          itemCount: controller.pendingReceivedRequestList.length,
                          itemBuilder: (context, index) {
                            final request = controller.pendingReceivedRequestList[index];

                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 0.8.h,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  colors: [
                                    AppColor.secondaryColor1,
                                    AppColor.secondaryColor1,
                                  ],
                                ),
                              ),
                              child: Container(
                                margin: EdgeInsets.all(0.4.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppColor.bgColor1,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: AppColor.secondaryColor1,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.network(
                                        request.photoPath,
                                        height: 60.spV2,
                                        width: 60.spV2,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.person,
                                          color: AppColor.textColor2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    request.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.spV2,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.secondaryColor1,
                                    ),
                                  ),
                                  subtitle: Text(
                                    getMembershipTitle(
                                      request.otherProfileType.toString(),
                                    ),
                                    style: TextStyle(
                                      fontSize: 9.spV2,
                                      color: AppColor.secondaryColor2,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          // Keep the requests overlay open; after success,
                                          // controller.getData() refreshes this reactive list.
                                          await controller.denyConnectionRequest(request);
                                        },
                                        child: Icon(
                                          Icons.cancel_outlined,
                                          color: AppColor.deleteColor,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      GestureDetector(
                                        onTap: () async {
                                          // Keep the requests overlay open; after success,
                                          // controller.getData() refreshes this reactive list.
                                          await controller.acceptConnectionRequest(request);
                                        },
                                        child: Icon(
                                          Icons.check_circle_outline,
                                          color: AppColor.historyRead,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () => controller.handleRowTap(request),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }


}
  /// Shows a Cupertino-style confirmation before unfriending a connection.
  Future<bool?> _confirmUnfriend(
    BuildContext context,
    ConnectionProfile request,
  ) async {
    final bool? shouldUnfriend = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Remove Connection?'),
          content: Text(
            'Are you sure that you want to remove your connection with ${request.fullName}?',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    return shouldUnfriend == true;
  }
