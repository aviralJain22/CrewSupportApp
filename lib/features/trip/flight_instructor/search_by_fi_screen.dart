// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart'; // <-- for .spV2
import 'search_by_fi_controller.dart';

/// UI for "Search by - FI"
/// Matches the legacy UI exactly (cards, copy, spacing), but powered by GetX.
class SearchByFIScreen extends GetView<SearchByFIController> {
  const SearchByFIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // SizerUtil().toString(); // not needed; Sizer context exists in app root
    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor.bgColor1,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.adaptive.arrow_back_rounded, color: AppColor.secondaryColor1),
        ),
        title: Text(
          "Search by - FI",
          style: TextStyle(color: AppColor.secondaryColor1),
        ),
      ),
      // TODO (kept): "make UI look good for FI" (from old code comment)
      body: SafeArea(
        child: GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  children: [
                    // ---------- Nearest FI ----------
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 5.0,
                        color: AppColor.textColor2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(width: 2.sp, color: AppColor.secondaryColor1),
                        ),
                        child: InkWell(
                          onTap: controller.toggleNear,
                          child: ListTile(
                            title: Text(
                              "Nearest FI",
                              style: TextStyle(
                                color: AppColor.secondaryColor1,
                                fontSize: 14.0.spV2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "It will display the nearest FI.",
                              style: TextStyle(color: AppColor.secondaryColor2),
                            ),
                            trailing: Theme(
                              data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                              child: Obx(() => Checkbox(
                                    activeColor: AppColor.secondaryColor1,
                                    checkColor: AppColor.textColor2,
                                    value: controller.isNear.value,
                                    onChanged: (_) => controller.toggleNear(),
                                  )),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ---------- Favorite FI ----------
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 5.0,
                        color: AppColor.textColor2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(width: 2.sp, color: AppColor.secondaryColor1),
                        ),
                        child: InkWell(
                          onTap: controller.toggleFavorite,
                          child: ListTile(
                            title: Text(
                              "Favorite FI",
                              style: TextStyle(
                                color: AppColor.secondaryColor1,
                                fontSize: 14.0.spV2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "It will display the favorite FI.",
                              style: TextStyle(color: AppColor.secondaryColor2),
                            ),
                            trailing: Theme(
                              data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                              child: Obx(() => Checkbox(
                                    activeColor: AppColor.secondaryColor1,
                                    checkColor: AppColor.textColor2,
                                    value: controller.isFavorite.value,
                                    onChanged: (_) => controller.toggleFavorite(),
                                  )),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ---------- Available FI ----------
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 5.0,
                        color: AppColor.textColor2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(width: 2.sp, color: AppColor.secondaryColor1),
                        ),
                        child: InkWell(
                          onTap: controller.toggleAvailable,
                          child: ListTile(
                            title: Text(
                              "Available FI",
                              style: TextStyle(
                                color: AppColor.secondaryColor1,
                                fontSize: 14.0.spV2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "It will display the available FI.",
                              style: TextStyle(color: AppColor.secondaryColor2),
                            ),
                            trailing: Theme(
                              data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                              child: Obx(() => Checkbox(
                                    activeColor: AppColor.secondaryColor1,
                                    checkColor: AppColor.textColor2,
                                    value: controller.isAvailable.value,
                                    onChanged: (_) => controller.toggleAvailable(),
                                  )),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ---------- Search All FI ----------
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 5.0,
                        color: AppColor.textColor2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(width: 2.sp, color: AppColor.secondaryColor1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: InkWell(
                            onTap: controller.toggleNotAvailable,
                            child: ListTile(
                              title: Text(
                                "Search All FI",
                                style: TextStyle(
                                  color: AppColor.secondaryColor1,
                                  fontSize: 14.0.spV2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "It will display the FI regardless of availability!",
                                style: TextStyle(color: AppColor.secondaryColor2),
                              ),
                              trailing: Theme(
                                data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                                child: Obx(() => Checkbox(
                                      activeColor: AppColor.secondaryColor1,
                                      checkColor: AppColor.textColor2,
                                      value: controller.notAvailable.value,
                                      onChanged: (_) => controller.toggleNotAvailable(),
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 3.0.h),

                // --------------------- NEXT Button ---------------------
                SizedBox(
                  width: 85.w,
                  child: MaterialButton(
                    disabledColor: AppColor.secondaryColor1,
                    disabledTextColor: AppColor.textColor2,
                    textColor: AppColor.textColor2,
                    color: AppColor.secondaryColor1,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    onPressed: controller.onTapNext,
                    child: Text(
                      "NEXT",
                      style: TextStyle(fontSize: 10.spV2),
                    ),
                  ),
                ),
                SizedBox(height: 1.5.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}