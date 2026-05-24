// ignore_for_file: prefer_const_constructors

import 'package:crew_support/app/routes.dart';
import 'package:crew_support/helper/user_helper.dart';
import 'package:crew_support/model/rating_certification.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

import 'type_rating_controller.dart';

/// Type Rating list screen (Current)
/// Converted from type_rating_screen_old.dart to GetX pattern.
/// UI is kept as close as possible to original.
class TypeRatingScreen extends GetWidget<TypeRatingController> {
  const TypeRatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Current",
          style: TextStyle(color: AppColor.secondaryColor1),
        ),
        backgroundColor: AppColor.bgColor1,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColor.secondaryColor1,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          // Same loading UI as old code
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LoadingAnimationWidget.threeRotatingDots(
                  color: AppColor.secondaryColor1,
                  size: 50.sp,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Loading...',
                  style: TextStyle(color: AppColor.textColor1),
                ),
              ],
            ),
          );
        }

        if (controller.ratingData.isEmpty) {
          // "No data available" state
          return SizedBox(
            height: 75.h,
            child: Center(
              child: Text(
                "No data available",
                style: TextStyle(
                  fontSize: 10.spV2, // was 10.sp in old code
                  color: AppColor.secondaryColor1,
                ),
              ),
            ),
          );
        }

        // Main list
        return Theme(
          data: ThemeData(
            canvasColor: AppColor.transparent,
          ),
          child: ListView.builder(
            itemCount: controller.ratingData.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final RatingCertification item = controller.ratingData[index];

              return Column(
                key: ValueKey(item.objectId),
                children: [
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.all(3.0.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColor.secondaryColor1,
                            width: 1.5.sp,
                          ),
                        ),
                        child: Container(
                          margin: EdgeInsets.all(0.7.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColor.bgColor1,
                          ),
                          padding: EdgeInsets.only(
                            top: 1.0.h,
                            bottom: 1.0.h,
                            left: 2.0.w,
                            right: 2.0.w,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Certificate
                              Row(
                                children: [
                                  SizedBox(
                                    width: 30.w,
                                    child: Text(
                                      "Certificate : ",
                                      style: TextStyle(
                                        color: AppColor.textColor1,
                                        fontSize: 10.spV2, // 10.sp -> 10.spV2
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 35.w,
                                    child: Text(
                                      item.ratingName.toString(),
                                      style: TextStyle(
                                        fontSize: 10.spV2,
                                        color: AppColor.secondaryColor1,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Make/Model
                              Row(
                                children: [
                                  SizedBox(
                                    width: 30.w,
                                    child: Text(
                                      "Make/Model : ",
                                      style: TextStyle(
                                        color: AppColor.textColor1,
                                        fontSize: 10.spV2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 35.w,
                                    child: Text(
                                      item.aircraftType.toString(),
                                      style: TextStyle(
                                        fontSize: 10.spV2,
                                        color: AppColor.secondaryColor1,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Category
                              Row(
                                children: [
                                  SizedBox(
                                    width: 30.w,
                                    child: Text(
                                      "Category : ",
                                      style: TextStyle(
                                        color: AppColor.textColor1,
                                        fontSize: 10.spV2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 35.w,
                                    child: Text(
                                      getCategoryTextFromId(item.categoryId),
                                      style: TextStyle(
                                        fontSize: 10.spV2,
                                        color: AppColor.secondaryColor1,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Class
                              Row(
                                children: [
                                  SizedBox(
                                    width: 30.w,
                                    child: Text(
                                      "Class : ",
                                      style: TextStyle(
                                        color: AppColor.textColor1,
                                        fontSize: 10.spV2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 35.w,
                                    child: Text(
                                      getClassRatingTextFromId(item.classId),
                                      style: TextStyle(
                                        fontSize: 10.spV2,
                                        color: AppColor.secondaryColor1,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Hours
                              Row(
                                children: [
                                  SizedBox(
                                    width: 30.w,
                                    child: Text(
                                      "Hours : ",
                                      style: TextStyle(
                                        color: AppColor.textColor1,
                                        fontSize: 10.spV2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 35.w,
                                    child: Text(
                                      item.totalHours?.toString() ?? "",
                                      style: TextStyle(
                                        fontSize: 10.spV2,
                                        color: AppColor.secondaryColor1,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // PIC
                              Row(
                                children: [
                                  SizedBox(
                                    width: 30.w,
                                    child: Text(
                                      "PIC : ",
                                      style: TextStyle(
                                        color: AppColor.textColor1,
                                        fontSize: 10.spV2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 35.w,
                                    child: Text(
                                      item.pic?.toString() ?? "",
                                      style: TextStyle(
                                        fontSize: 10.spV2,
                                        color: AppColor.secondaryColor1,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Minimum Rate
                              Row(
                                children: [
                                  SizedBox(
                                    width: 30.w,
                                    child: Text(
                                      "Minimum Rate : ",
                                      style: TextStyle(
                                        color: AppColor.textColor1,
                                        fontSize: 10.spV2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 35.w,
                                    child: Text(
                                      item.minimumRate != null
                                          ? "\$${item.minimumRate!.toStringAsFixed(2)}"
                                          : "",
                                      style: TextStyle(
                                        fontSize: 10.spV2,
                                        color: AppColor.secondaryColor1,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Current
                              Row(
                                children: [
                                  SizedBox(
                                    width: 30.w,
                                    child: Text(
                                      "Current : ",
                                      style: TextStyle(
                                        color: AppColor.textColor1,
                                        fontSize: 10.spV2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 35.w,
                                    child: Text(
                                      item.currentInType.toString(),
                                      style: TextStyle(
                                        fontSize: 10.spV2,
                                        color: AppColor.secondaryColor1,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ),

                      // Edit icon
                      GestureDetector(
                        onTap: () async {
                          // Prefer named routes (adjust route names as per your app)
                          // Pass the rating model as argument, same as old code.
                          await Get.toNamed(
                            AppRoutes.updateRatingType,
                            arguments: item,
                          );

                          // Refresh list after returning
                          await controller.refreshData();
                        },
                        child: Icon(
                          Icons.edit,
                          size: 24,
                          color: AppColor.secondaryColor1,
                        ),
                      ),
                      SizedBox(width: 2.w),

                      // Delete icon
                      GestureDetector(
                        onTap: () {
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext ctx) {
                              return Theme(
                                data: ThemeData.dark(),
                                child: CupertinoAlertDialog(
                                  content: SizedBox(
                                    height: 5.h,
                                    width: 60.w,
                                    child: Text(
                                      "Do you want to delete certificate?",
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(
                                        'No',
                                        style: TextStyle(
                                          color: AppColor.secondaryColor1,
                                          fontSize: 10.spV2,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text(
                                        'Yes',
                                        style: TextStyle(
                                          color: AppColor.secondaryColor1,
                                          fontSize: 10.spV2,
                                        ),
                                      ),
                                      onPressed: () {
                                        // Same behaviour as old code:
                                        // Call controller which will:
                                        // - show loading dialog
                                        // - call delete API
                                        // - pop both dialogs
                                        // - show result
                                        // - remove item from list
                                        controller.deleteCertificate(
                                          ctx,
                                          index,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: const Icon(
                          Icons.delete,
                          size: 24,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    indent: 10,
                    endIndent: 10,
                    thickness: 1,
                  ),
                ],
              );
            },
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Obx(() {
          // Show button only when not loading (same logic as old Visibility)
          if (controller.isLoading.value) {
            return SizedBox.shrink();
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
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
              onPressed: () async {
                // Navigate to Add Rating Type screen
                await Get.toNamed('/addRatingType');

                // Refresh after coming back
                await controller.refreshData();
              },
              child: Text(
                "ADD NEW TYPE RATING",
              ),
            ),
          );
        }),
      ),
    );
  }
}