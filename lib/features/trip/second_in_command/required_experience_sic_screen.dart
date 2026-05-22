import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'required_experience_sic_controller.dart';

class RequiredExperienceSICScreen extends GetWidget<RequiredExperienceSICController> {
  const RequiredExperienceSICScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async => controller.lockBack ? false : true,
      child: Scaffold(
        backgroundColor: AppColor.bgColor1,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "Required Experience - SIC",
            style: TextStyle(color: AppColor.secondaryColor1),
          ),
          backgroundColor: AppColor.bgColor1,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => controller.lockBack ? null : Get.back(),
            icon: Icon(Icons.adaptive.arrow_back_rounded, color: AppColor.secondaryColor1),
          ),
        ),

        // If loadDraft==true, we observe isLoading; otherwise, no Obx wrapper (to avoid GetX misuse warning)
        body: controller.args.loadDraft
            ? Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LoadingAnimationWidget.threeRotatingDots(
                          color: AppColor.secondaryColor1,
                          size: 50.sp,
                        ),
                        SizedBox(height: 2.h),
                        Text('Loading...', style: TextStyle(color: AppColor.textColor1)),
                      ],
                    ),
                  );
                }
                return _buildMainForm(context);
              })
            : _buildMainForm(context),
      ),
    );
  }

  Widget _buildMainForm(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Column(
                    children: [
                      // --- BEGIN: moved content from previous SafeArea block ---
                      _rowLabelField(
                        label: "Total Time",
                        child: TextFormField(
                          controller: controller.totalTimeController,
                          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
                          style: TextStyle(
                            fontSize: 10.spV2,
                            fontWeight: FontWeight.bold,
                            color: AppColor.secondaryColor1,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter Total Time",
                            hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                          ),
                        ),
                      ),
                      _divider(),
                      _rowLabelField(
                        label: "Total Time in Type",
                        child: TextFormField(
                          controller: controller.totalTimeTypeController,
                          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
                          style: TextStyle(
                            fontSize: 10.spV2,
                            fontWeight: FontWeight.bold,
                            color: AppColor.secondaryColor1,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter Time",
                            hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                          ),
                        ),
                      ),
                      _divider(),
                      _rowLabelField(
                        label: "Medical Class",
                        child: TextFormField(
                          controller: controller.medicalClassController,
                          readOnly: true,
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            controller.showMedicalPicker(context);
                          },
                          style: TextStyle(
                            fontSize: 10.spV2,
                            fontWeight: FontWeight.bold,
                            color: AppColor.secondaryColor1,
                          ),
                          decoration: InputDecoration(
                            suffixIcon: Icon(Icons.keyboard_arrow_down_outlined, color: AppColor.secondaryColor1),
                            border: InputBorder.none,
                            hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                          ),
                        ),
                      ),
                      _divider(),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       flex: 2,
                      //       child: Padding(
                      //         padding: EdgeInsets.only(left: 5.w),
                      //         child: Text(
                      //           "Select Desired Rating",
                      //           style: TextStyle(
                      //             fontWeight: FontWeight.w500,
                      //             color: AppColor.textColor1,
                      //             fontSize: 9.5.spV2,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     Expanded(
                      //       flex: 2,
                      //       child: Obx(() {
                      //         return RatingBar.builder(
                      //           itemSize: 18.0.sp,
                      //           unratedColor: AppColor.textColor1,
                      //           initialRating: controller.rating.value.toDouble(),
                      //           minRating: 0,
                      //           direction: Axis.horizontal,
                      //           allowHalfRating: false,
                      //           itemCount: 5,
                      //           itemPadding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 10.0),
                      //           itemBuilder: (context, _) => Icon(
                      //             Icons.star,
                      //             color: AppColor.goldenColorNew,
                      //             size: 17.0.sp,
                      //           ),
                      //           onRatingUpdate: (ratings) {
                      //             controller.rating.value = ratings.toInt();
                      //             print(controller.rating.value);
                      //           },
                      //         );
                      //       }),
                      //     ),
                      //   ],
                      // ),
                      // _divider(),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.only(left: 5.w),
                              child: Text(
                                "Valid Passport",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.textColor1,
                                  fontSize: 9.5.spV2,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Obx(() {
                              return Row(
                                children: [
                                  Theme(
                                    data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                                    child: Checkbox(
                                      checkColor: AppColor.textColor2,
                                      activeColor: AppColor.secondaryColor1,
                                      onChanged: (value) {
                                        FocusScope.of(context).unfocus();
                                        controller.isValidPass.value = true;
                                      },
                                      value: controller.isValidPass.value,
                                    ),
                                  ),
                                  Text(
                                    "Yes",
                                    style: TextStyle(
                                      fontSize: 10.spV2,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.secondaryColor1,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Theme(
                                    data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                                    child: Checkbox(
                                      checkColor: AppColor.textColor2,
                                      activeColor: AppColor.secondaryColor1,
                                      onChanged: (value) {
                                        FocusScope.of(context).unfocus();
                                        controller.isValidPass.value = false;
                                      },
                                      value: !controller.isValidPass.value,
                                    ),
                                  ),
                                  Text(
                                    "No",
                                    style: TextStyle(
                                      fontSize: 10.spV2,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.secondaryColor1,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                      _divider(),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.only(left: 5.w),
                              child: Text(
                                "Rating Type",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.textColor1,
                                  fontSize: 9.5.spV2,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Obx(() {
                              return Row(
                                children: [
                                  Theme(
                                    data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                                    child: Checkbox(
                                      checkColor: AppColor.textColor2,
                                      activeColor: AppColor.secondaryColor1,
                                      onChanged: (value) {
                                        FocusScope.of(context).unfocus();
                                        controller.isCommercial.value = value ?? false;
                                      },
                                      value: controller.isCommercial.value,
                                    ),
                                  ),
                                  Text(
                                    "Commercial",
                                    style: TextStyle(
                                      fontSize: 10.spV2,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.secondaryColor1,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Theme(
                                    data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                                    child: Checkbox(
                                      checkColor: AppColor.textColor2,
                                      activeColor: AppColor.secondaryColor1,
                                      onChanged: (value) {
                                        FocusScope.of(context).unfocus();
                                        controller.isATP.value = value ?? false;
                                      },
                                      value: controller.isATP.value,
                                    ),
                                  ),
                                  Text(
                                    "ATP",
                                    style: TextStyle(
                                      fontSize: 10.spV2,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.secondaryColor1,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                      _divider(),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.w),
                              child: Text(
                                " Region Experience",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.textColor1,
                                  fontSize: 9.5.spV2,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                controller.showContinentDialog(context);
                              },
                              child: Obx(() {
                                final has = controller.continentExpSaveList.isNotEmpty;
                                return Text(
                                  has ? controller.continentExpSaveList.join(", ") : " Enter Region Experience",
                                  style: TextStyle(
                                    fontSize: has ? 10.spV2 : 9.spV2,
                                    fontWeight: has ? FontWeight.bold : FontWeight.normal,
                                    color: has ? AppColor.secondaryColor1 : AppColor.secondaryColor2,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                      _divider(),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.only(left: 5.w),
                              child: Text(
                                "12 month simulator current",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.textColor1,
                                  fontSize: 9.5.spV2,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Obx(() {
                              return Row(
                                children: [
                                  Theme(
                                    data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                                    child: Checkbox(
                                      checkColor: AppColor.textColor2,
                                      activeColor: AppColor.secondaryColor1,
                                      onChanged: (value) {
                                        FocusScope.of(context).unfocus();
                                        controller.checkbox12SimulatorYes.value = true;
                                      },
                                      value: controller.checkbox12SimulatorYes.value,
                                    ),
                                  ),
                                  Text(
                                    "Yes",
                                    style: TextStyle(
                                      fontSize: 10.spV2,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.secondaryColor1,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Theme(
                                    data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                                    child: Checkbox(
                                      checkColor: AppColor.textColor2,
                                      activeColor: AppColor.secondaryColor1,
                                      onChanged: (value) {
                                        FocusScope.of(context).unfocus();
                                        controller.checkbox12SimulatorYes.value = false;
                                      },
                                      value: !controller.checkbox12SimulatorYes.value,
                                    ),
                                  ),
                                  Text(
                                    "No",
                                    style: TextStyle(
                                      fontSize: 10.spV2,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.secondaryColor1,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                      _divider(),
                      SizedBox(height: 2.h),
                      SizedBox(
                        width: 85.w,
                        child: MaterialButton(
                          disabledColor: AppColor.disablebutton,
                          disabledTextColor: AppColor.disablebuttonText,
                          textColor: AppColor.textColor2,
                          color: AppColor.secondaryColor1,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                          onPressed: controller.onTapNext,
                          child: Text("NEXT", style: TextStyle(fontSize: 10.spV2)),
                        ),
                      ),

                      if (!controller.isFromAddCrew) ...[
                        SizedBox(
                          width: 85.w,
                          child: MaterialButton(
                            disabledColor: AppColor.disablebutton,
                            disabledTextColor: AppColor.disablebuttonText,
                            textColor: AppColor.textColor2,
                            color: AppColor.secondaryColor1,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                              borderRadius: BorderRadius.circular(2.w),
                            ),
                            onPressed: controller.onTapSaveDraft,
                            child: Text("Save As Draft", style: TextStyle(fontSize: 10.spV2)),
                          ),
                        ),
                      ]
                      
                      // --- END: moved content ---
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------- UI helpers to keep code tidy (and match exact legacy layout) -------

  Widget _rowLabelField({
    required String label,
    required Widget child,
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
                fontWeight: FontWeight.w500,
                color: AppColor.textColor1,
                fontSize: 9.5.spV2,
              ),
            ),
          ),
        ),
        Expanded(flex: 2, child: child),
      ],
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
}