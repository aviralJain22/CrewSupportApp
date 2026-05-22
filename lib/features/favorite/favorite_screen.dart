import 'package:crew_support/features/favorite/favorite_controller.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class FavoriteScreen extends GetView<FavoriteController> {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        backgroundColor: AppColor.bgColor1,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "My Favorites",
          style: TextStyle(
            color: AppColor.secondaryColor1,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColor.secondaryColor1,
          ),
        ),
      ),
      body: Obx(
        () {
          /// Loading state
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.threeRotatingDots(
                    color: AppColor.secondaryColor1,
                    size: 50.spV2,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Loading...",
                    style: TextStyle(
                      color: AppColor.textColor1,
                    ),
                  ),
                ],
              ),
            );
          }

          /// Empty state
          if (controller.favorites.isEmpty) {
            return Center(
              child: Text(
                "Your favorites will appear here.",
                style: TextStyle(
                  color: AppColor.secondaryColor1,
                ),
              ),
            );
          }

          /// Favorite list
          return ListView.builder(
            itemCount: controller.favorites.length,
            itemBuilder: (context, index) {
              final favourite = controller.favorites[index];

              if (favourite.isFavourite != true) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 0.5.h,
                  horizontal: 2.w,
                ),
                child: Card(
                  color: AppColor.bgColor1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  shadowColor: AppColor.textColor1,
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 2.w,
                      right: 5.w,
                      top: 1.h,
                      bottom: 1.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Left section
                        Row(
                          children: [
                            SizedBox(width: 2.w),

                            /// Avatar
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColor.bgColor1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: SizedBox(
                                  height: 60.spV2,
                                  width: 60.spV2,
                                  child: Image.network(
                                    favourite.photoPath ?? '',
                                    fit: BoxFit.fill,
                                    height: 4.h,
                                    width: 4.w,
                                    loadingBuilder: (
                                      BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress,
                                    ) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }

                                      return Center(
                                        child: CircularProgressIndicator(
                                          color:
                                              AppColor.secondaryColor1,
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
                                    errorBuilder: (
                                      BuildContext context,
                                      Object exception,
                                      StackTrace? stackTrace,
                                    ) {
                                      return CircleAvatar(
                                        backgroundColor:
                                            AppColor.bgColor1,
                                        child: Icon(
                                          Icons.account_circle,
                                          color: AppColor.secondaryColor1,
                                          size: 60,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 8.w),

                            /// User info
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${favourite.pilotFname ?? ''} ${favourite.pilotlname ?? ''}",
                                  style: TextStyle(
                                    color: AppColor.textColor1,
                                    fontSize: 12.spV2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                Text(
                                  favourite.memberShipType ?? '',
                                  style: TextStyle(
                                    color:
                                        AppColor.secondaryColor2,
                                    fontSize: 10.spV2,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),

                                RatingBar.builder(
                                  itemSize: 13.spV2,
                                  initialRating:
                                      controller.parseRating(
                                    favourite.ratingCount,
                                  ),
                                  minRating: 0,
                                  direction: Axis.horizontal,
                                  ignoreGestures: true,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemBuilder: (context, _) {
                                    return Icon(
                                      Icons.star,
                                      color:
                                          AppColor.goldenColorNew,
                                      size: 17.spV2,
                                    );
                                  },
                                  onRatingUpdate: (rating) {},
                                ),
                              ],
                            ),
                          ],
                        ),

                        /// Remove favorite button
                        GestureDetector(
                          onTap: () {
                            controller.removeFavorite(
                              favourite,
                            );
                          },
                          child: SizedBox(
                            height: 14.spV2,
                            width: 14.spV2,
                            child: SvgPicture.asset(
                              'assets/Heart Fill.svg',
                              fit: BoxFit.fill,
                              color: AppColor.deleteColor,
                              cacheColorFilter: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}