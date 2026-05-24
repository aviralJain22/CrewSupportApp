import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart'; // for .spV2
import 'required_experience_captain_controller.dart';

class RequiredExperienceCaptainScreen
    extends GetWidget<RequiredExperienceCaptainController> {
  const RequiredExperienceCaptainScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor.bgColor1,
        leading: IconButton(
          icon: Icon(Icons.adaptive.arrow_back_rounded,
              color: AppColor.secondaryColor1),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Required Experience - Captain',
          style: TextStyle(
            fontSize: 12.spV2,
            color: AppColor.secondaryColor1,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LoadingAnimationWidget.threeRotatingDots(
                  color: AppColor.secondaryColor1,
                  size: 50.sp, // matches legacy visual size
                ),
                SizedBox(height: 2.h),
                Text('Loading...', style: TextStyle(color: AppColor.textColor1)),
              ],
            ),
          );
        }

        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildRowLabelTextField(
                      label: 'Total Time',
                      controller: controller.totalTimeController,
                      hint: 'Enter Total Time',
                    ),
                    _divider(),
                    _buildRowLabelTextField(
                      label: 'PIC Time',
                      controller: controller.picTimeController,
                      hint: 'Enter PIC Time',
                    ),
                    _divider(),
                    _buildRowLabelTextField(
                      label: 'Total Time in Type',
                      controller: controller.totalTimeTypeController,
                      hint: 'Enter Time',
                    ),
                    _divider(),
                    _buildRowLabelTextField(
                      label: 'PIC Time in Type',
                      controller: controller.totalPicTypeController,
                      hint: 'Enter Time ',
                    ),
                    _divider(),

                    // Medical Class (read-only + Cupertino picker)
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.only(left: 5.w),
                            child: Text(
                              'Medical Class',
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
                          child: TextFormField(
                            controller: controller.medicalClassController,
                            style: TextStyle(
                              fontSize: 10.spV2,
                              fontWeight: FontWeight.bold,
                              color: AppColor.secondaryColor1,
                            ),
                            readOnly: true,
                            onTap: controller.showMedicalPicker,
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Icons.keyboard_arrow_down_outlined,
                                color: AppColor.secondaryColor1,
                              ),
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                fontSize: 9.spV2,
                                color: AppColor.secondaryColor2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    _divider(),

                    // 135 Training (Yes/No → when Yes, open multi-select)
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       flex: 2,
                    //       child: Padding(
                    //         padding:
                    //             EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    //         child: Text(
                    //           '135 Training',
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
                    //       child: TextField(
                    //         controller: controller.specialTrainingController,
                    //         readOnly: true,
                    //         onTap: controller.showSpecialTrainingYesNo,
                    //         decoration: InputDecoration(
                    //           border: InputBorder.none,
                    //           hintText: 'Select 135 Training',
                    //           hintStyle: TextStyle(
                    //             fontSize: 9.spV2,
                    //             color: AppColor.secondaryColor2,
                    //           ),
                    //         ),
                    //         style: TextStyle(
                    //           fontSize: 10.spV2,
                    //           fontWeight: FontWeight.bold,
                    //           color: AppColor.secondaryColor1,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    // // If "Yes" → show "Select 135 Training" chip (as tap-to-open multi)
                    // Obx(() => Visibility(
                    //       visible:
                    //           controller.specialTraining.value == 'Yes',
                    //       child: Column(
                    //         children: [
                    //           _divider(),
                    //           Row(
                    //             children: [
                    //               Expanded(
                    //                 flex: 2,
                    //                 child: Padding(
                    //                   padding: EdgeInsets.symmetric(
                    //                       horizontal: 5.w, vertical: 2.h),
                    //                   child: Text(
                    //                     'Select 135 Training',
                    //                     style: TextStyle(
                    //                       fontWeight: FontWeight.w500,
                    //                       color: AppColor.textColor1,
                    //                       fontSize: 9.5.spV2,
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //               Expanded(
                    //                 flex: 2,
                    //                 child: GestureDetector(
                    //                   onTap: controller.openSpecialTrainingMulti,
                    //                   child: Obx(() => controller.oceanicSaveList.isNotEmpty
                    //                       ? Text(
                    //                           controller.oceanicSaveList.join(', '),
                    //                           style: TextStyle(
                    //                             fontSize: 10.spV2,
                    //                             fontWeight: FontWeight.bold,
                    //                             color: AppColor.secondaryColor1,
                    //                           ),
                    //                         )
                    //                       : Text(
                    //                           'Select 135 Training',
                    //                           style: TextStyle(
                    //                             color: AppColor.secondaryColor2,
                    //                             fontSize: 9.spV2,
                    //                           ),
                    //                         ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ],
                    //       ),
                    //     )),

                    // // If "Other" selected → show text field
                    // Obx(() => Visibility(
                    //       visible:
                    //           controller.selectTrainingCsv.value.contains('Other'),
                    //       child: Column(
                    //         children: [
                    //           _divider(),
                    //           Row(
                    //             children: [
                    //               Expanded(
                    //                 flex: 2,
                    //                 child: Padding(
                    //                   padding: EdgeInsets.symmetric(
                    //                       horizontal: 5.w, vertical: 2.h),
                    //                   child: Text(
                    //                     'Other Training',
                    //                     style: TextStyle(
                    //                       fontWeight: FontWeight.w500,
                    //                       color: AppColor.textColor1,
                    //                       fontSize: 9.5.spV2,
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //               Expanded(
                    //                 flex: 2,
                    //                 child: CupertinoTextField(
                    //                   controller: controller
                    //                       .otherSelectTrainingController,
                    //                   style: TextStyle(
                    //                     fontSize: 10.spV2,
                    //                     fontWeight: FontWeight.bold,
                    //                     color: AppColor.secondaryColor1,
                    //                   ),
                    //                   readOnly: false,
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ],
                    //       ),
                    //     )),

                    // _divider(),

                    // Desired Rating (stars)
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       flex: 2,
                    //       child: Padding(
                    //         padding: EdgeInsets.only(left: 5.w),
                    //         child: Text(
                    //           'Select Desired Rating',
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
                    //       child: Obx(
                    //         () => RatingBar.builder(
                    //           unratedColor: AppColor.secondaryColor2,
                    //           itemSize: 18.sp, // matches legacy .sp usage for icons
                    //           initialRating:
                    //               controller.rating.value.toDouble(),
                    //           minRating: 0,
                    //           allowHalfRating: false,
                    //           direction: Axis.horizontal,
                    //           itemCount: 5,
                    //           itemPadding: EdgeInsets.symmetric(
                    //               horizontal: 1.0, vertical: 10.0),
                    //           itemBuilder: (context, _) => Icon(
                    //             Icons.star,
                    //             color: AppColor.goldenColorNew,
                    //             size: 17.sp,
                    //           ),
                    //           onRatingUpdate: (val) =>
                    //               controller.rating.value = val.toInt(),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    // _divider(),

                    // Valid Passport (Yes/No)
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.only(left: 5.w),
                            child: Text(
                              'Valid Passport',
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
                          child: Obx(
                            () => Row(
                              children: [
                                Theme(
                                  data: ThemeData(
                                    unselectedWidgetColor: AppColor.textColor1,
                                  ),
                                  child: Checkbox(
                                    activeColor: AppColor.secondaryColor1,
                                    checkColor: AppColor.textColor2,
                                    value:
                                        controller.checkboxValidPassportYes.value,
                                    onChanged: (_) => controller
                                        .checkboxValidPassportYes.value = true,
                                  ),
                                ),
                                Text(
                                  'Yes',
                                  style: TextStyle(
                                    fontSize: 10.spV2,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.secondaryColor1,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Theme(
                                  data: ThemeData(
                                    unselectedWidgetColor: AppColor.textColor1,
                                  ),
                                  child: Checkbox(
                                    activeColor: AppColor.secondaryColor1,
                                    checkColor: AppColor.textColor2,
                                    value: !controller
                                        .checkboxValidPassportYes.value,
                                    onChanged: (_) => controller
                                        .checkboxValidPassportYes.value = false,
                                  ),
                                ),
                                Text(
                                  'No',
                                  style: TextStyle(
                                    fontSize: 10.spV2,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.secondaryColor1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    _divider(),

                    // Rating Type
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.only(left: 5.w),
                            child: Text(
                              'Rating Type',
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
                          child: Obx(
                            () => Row(
                              children: [
                                Theme(
                                  data: ThemeData(
                                    unselectedWidgetColor: AppColor.textColor1,
                                  ),
                                  child: Checkbox(
                                    activeColor: AppColor.secondaryColor1,
                                    checkColor: AppColor.textColor2,
                                    value: controller.isCommercial.value,
                                    onChanged: (v) =>
                                        controller.isCommercial.value = v!,
                                  ),
                                ),
                                Text(
                                  'Commercial',
                                  style: TextStyle(
                                    fontSize: 10.spV2,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.secondaryColor1,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Theme(
                                  data: ThemeData(
                                    unselectedWidgetColor: AppColor.textColor1,
                                  ),
                                  child: Checkbox(
                                    activeColor: AppColor.secondaryColor1,
                                    checkColor: AppColor.textColor2,
                                    value: controller.isATP.value,
                                    onChanged: (v) =>
                                        controller.isATP.value = v!,
                                  ),
                                ),
                                Text(
                                  'ATP',
                                  style: TextStyle(
                                    fontSize: 10.spV2,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.secondaryColor1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    _divider(),

                    // Region Experience
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                            child: Text(
                              ' Region Experience',
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
                            onTap: controller.openContinentExpDialog,
                            child: Obx(
                              () => controller.continentExpSaveList.isNotEmpty
                                  ? Text(
                                      controller.continentExpSaveList.join(', '),
                                      style: TextStyle(
                                        fontSize: 10.spV2,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.secondaryColor1,
                                      ),
                                    )
                                  : Text(
                                      'Enter Region Experience',
                                      style: TextStyle(
                                        fontSize: 9.spV2,
                                        color: AppColor.secondaryColor2,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    _divider(),

                    // Oceanic Exp.
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                            child: Text(
                              ' Oceanic Experience',
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
                            onTap: controller.openOceanicDialog,
                            child: Obx(
                              () => controller.oceanicSaveList.isNotEmpty
                                  ? Text(
                                      controller.oceanicSaveList.join(','),
                                      style: TextStyle(
                                        fontSize: 10.spV2,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.secondaryColor1,
                                      ),
                                    )
                                  : Text(
                                      'Enter Oceanic Experience',
                                      style: TextStyle(
                                        fontSize: 9.spV2,
                                        color: AppColor.secondaryColor2,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    _divider(),

                    // 12 month simulator current
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.only(left: 5.w),
                            child: Text(
                              '12 month simulator current',
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
                          child: Obx(
                            () => Row(
                              children: [
                                Theme(
                                  data: ThemeData(
                                    unselectedWidgetColor: AppColor.textColor1,
                                  ),
                                  child: Checkbox(
                                    activeColor: AppColor.secondaryColor1,
                                    checkColor: AppColor.textColor2,
                                    value: controller.checkboxSimulatorYes.value,
                                    onChanged: (_) =>
                                        controller.checkboxSimulatorYes.value =
                                            true,
                                  ),
                                ),
                                Text(
                                  'Yes',
                                  style: TextStyle(
                                    fontSize: 10.spV2,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.secondaryColor1,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Theme(
                                  data: ThemeData(
                                    unselectedWidgetColor: AppColor.textColor1,
                                  ),
                                  child: Checkbox(
                                    activeColor: AppColor.secondaryColor1,
                                    checkColor: AppColor.textColor2,
                                    value:
                                        !controller.checkboxSimulatorYes.value,
                                    onChanged: (_) =>
                                        controller.checkboxSimulatorYes.value =
                                            false,
                                  ),
                                ),
                                Text(
                                  'No',
                                  style: TextStyle(
                                    fontSize: 10.spV2,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.secondaryColor1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    _divider(),
                    SizedBox(height: 2.h),

                    // Buttons
                    SizedBox(
                      width: 85.w,
                      child: MaterialButton(
                        disabledColor: AppColor.secondaryColor1,
                        disabledTextColor: AppColor.textColor2,
                        textColor: AppColor.textColor2,
                        color: AppColor.secondaryColor1,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: AppColor.secondaryColor1,
                            width: 0.6.w,
                          ),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        onPressed: controller.onTapNext,
                        child: Text(
                          'NEXT',
                          style: TextStyle(fontSize: 10.spV2),
                        ),
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    if (!controller.isFromAddCrew) ...[
                      SizedBox(
                        width: 85.w,
                        child: MaterialButton(
                          disabledColor: AppColor.secondaryColor1,
                          disabledTextColor: AppColor.textColor2,
                          textColor: AppColor.textColor2,
                          color: AppColor.secondaryColor1,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: AppColor.secondaryColor1,
                              width: 0.6.w,
                            ),
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                          onPressed: controller.onTapSaveDraft,
                          child: Text(
                            'Save as draft',
                            style: TextStyle(fontSize: 10.spV2),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ]
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ====== UI helpers to keep things consistent with legacy layout ======
  Widget _divider() => Divider(
        indent: 10,
        endIndent: 10,
        thickness: 1,
        color: AppColor.secondaryColor1,
      );

  Widget _buildRowLabelTextField({
    required String label,
    required TextEditingController controller,
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
                fontWeight: FontWeight.w500,
                color: AppColor.textColor1,
                fontSize: 9.5.spV2,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
              decimal: false,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
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
}