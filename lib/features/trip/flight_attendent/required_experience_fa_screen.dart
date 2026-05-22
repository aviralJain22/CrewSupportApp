import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart'; // for .spV2 sizes
import 'required_experience_fa_controller.dart';

class RequiredExperienceFAScreen extends GetWidget<RequiredExperienceFAController> {
  const RequiredExperienceFAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
          canPop: controller.backbutton == true ? false : true,
          onPopInvokedWithResult: (didPop, result) {
            // No-op. `canPop` controls whether system back can pop.
          },
          child: Scaffold(
        backgroundColor: AppColor.bgColor1,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'Required Experience - FA',
            style: TextStyle(color: AppColor.secondaryColor1, fontSize: 11.spV2),
          ),
          backgroundColor: AppColor.bgColor1,
          leading: IconButton(
            onPressed: () => controller.backbutton == true ? null : Get.back(),
            icon: Icon(Icons.adaptive.arrow_back_rounded, color: AppColor.secondaryColor1),
          ),
        ),
        body: SafeArea(
          child: ListView(
            children: [
              Column(
                children: [
                  _rowLabelPicker(
                    context: context,
                    label: 'Years of Experience',
                    onTap: () => controller.showYearOfExperiencePicker(context),
                    child: TextFormField(
                      controller: controller.yrExperienceController,
                      onTap: () => controller.showYearOfExperiencePicker(context),
                      showCursor: false,
                      enableInteractiveSelection: false,
                      readOnly: true,
                      style: TextStyle(
                        fontSize: 10.spV2,
                        fontWeight: FontWeight.bold,
                        color: AppColor.secondaryColor1,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Select Years',
                        hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                      ),
                    ),
                  ),
                  _divider(),

                  // Valid Passport (Yes/No)
                  Padding(
                    padding: EdgeInsets.only(left: 5.w, right: 0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Valid Passport',
                            style: TextStyle(fontWeight: FontWeight.w500, color: AppColor.textColor1, fontSize: 9.5.spV2),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Obx(() => Row(
                                children: [
                                  Theme(
                                    data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                                    child: Checkbox(
                                      activeColor: AppColor.secondaryColor1,
                                      checkColor: AppColor.textColor2,
                                      onChanged: (value) => controller.checkboxValidPassportYes.value = true,
                                      value: controller.checkboxValidPassportYes.value,
                                    ),
                                  ),
                                  Text('Yes', style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1)),
                                  SizedBox(width: 20),
                                  Theme(
                                    data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                                    child: Checkbox(
                                      activeColor: AppColor.secondaryColor1,
                                      checkColor: AppColor.textColor2,
                                      onChanged: (value) => controller.checkboxValidPassportYes.value = false,
                                      value: !controller.checkboxValidPassportYes.value,
                                    ),
                                  ),
                                  Text('No', style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1)),
                                ],
                              )),
                        )
                      ],
                    ),
                  ),
                  _divider(),

                  // Region Experience (multi-select)
                  _rowLabelPicker(
                    context: context,
                    label: 'Region Experience',
                    onTap: () => controller.openContinentExpDialog(context),
                    child: Obx(() {
                      final items = controller.continentExpSaveList;
                      return (items.isNotEmpty && items.first != '')
                          ? Text(
                              items.join(', '),
                              style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1),
                            )
                          : Text('Enter Region Experience', style: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2));
                    }),
                  ),
                  _divider(),

                  // Desired Rating (stars)
                  // Padding(
                  //   padding: EdgeInsets.only(left: 5.w, right: 5.w),
                  //   child: Row(
                  //     children: [
                  //       Expanded(
                  //         flex: 2,
                  //         child: Text('Select Desired Rating', style: TextStyle(fontWeight: FontWeight.w500, color: AppColor.textColor1, fontSize: 9.5.spV2)),
                  //       ),
                  //       Expanded(
                  //         flex: 2,
                  //         child: Obx(() => RatingBar.builder(
                  //               initialRating: controller.rating.value.toDouble(),
                  //               itemSize: 18.0.spV2,
                  //               unratedColor: AppColor.secondaryColor2,
                  //               minRating: 0,
                  //               direction: Axis.horizontal,
                  //               allowHalfRating: false,
                  //               itemCount: 5,
                  //               itemPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 10.0),
                  //               itemBuilder: (context, _) => Icon(Icons.star, color: AppColor.goldenColorNew, size: 17.0.spV2),
                  //               onRatingUpdate: (v) => controller.rating.value = v.toInt(),
                  //             )),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // _divider(),

                  // Aircraft Specific Training (Yes/No)
                  Padding(
                    padding: EdgeInsets.only(left: 5.w, right: 0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text('Aircraft Specific Training', style: TextStyle(fontWeight: FontWeight.w500, color: AppColor.textColor1, fontSize: 9.5.spV2)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Obx(() => Row(
                                children: [
                                  Theme(
                                    data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                                    child: Checkbox(
                                      checkColor: AppColor.textColor2,
                                      activeColor: AppColor.secondaryColor1,
                                      onChanged: (v) => controller.checkboxTrainingYes.value = true,
                                      value: controller.checkboxTrainingYes.value,
                                    ),
                                  ),
                                  Text('Yes', style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1)),
                                  SizedBox(width: 20),
                                  Theme(
                                    data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                                    child: Checkbox(
                                      checkColor: AppColor.textColor2,
                                      activeColor: AppColor.secondaryColor1,
                                      onChanged: (v) => controller.checkboxTrainingYes.value = false,
                                      value: !controller.checkboxTrainingYes.value,
                                    ),
                                  ),
                                  Text('No', style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1)),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                  _divider(),

                  // Special Training selector (Yes/No)
                  _rowLabelPicker(
                    context: context,
                    label: 'Special Training',
                    onTap: () => controller.showSpecialTrainingPicker(context),
                    child: IgnorePointer(
                      ignoring: true, // <- key line: TextField will NOT request focus / show menu
                      child: TextField(
                        controller: controller.specialTrainingController,
                        readOnly: true,
                        showCursor: false,
                        enableInteractiveSelection: false,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                          hintText: 'Select Special Training',
                        ),
                        style: TextStyle(
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondaryColor1,
                        ),
                      ),
                    ),
                  ),

                  Obx(() => Visibility(
                        visible: controller.specialTrainingValue.value == 'Yes',
                        child: Column(
                          children: [
                            _divider(),
                            _rowLabelPicker(
                              context: context,
                              label: 'Select Training',
                              onTap: () => controller.openSpecialTrainingNamesDialog(context),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 0.5),
                                child: Obx(() {
                                  final t = controller.selectedTrainingValue.value;
                                  return t.isNotEmpty
                                      ? Text(t, style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1))
                                      : Text('Select Training', style: TextStyle(color: AppColor.secondaryColor2, fontSize: 9.spV2));
                                }),
                              ),
                            ),
                          ],
                        ),
                      )),

                  Obx(() => Visibility(
                        visible: controller.selectedTrainingValue.value == 'Other',
                        child: Column(
                          children: [
                            _divider(),
                            _rowLabelPicker(
                              context: context,
                              label: 'Other Training',
                              child: CupertinoTextField(
                                controller: controller.otherSelectTrainingController,
                                style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1),
                                readOnly: false,
                              ),
                            ),
                          ],
                        ),
                      )),

                  _divider(),

                  // International Visa Held (multi-select)
                  _rowLabelPicker(
                    context: context,
                    label: 'International Visa Held',
                    onTap: () => controller.openInternationalVisaDialog(context),
                    child: Obx(() {
                      final list = controller.internationalVisaSaveList;
                      return (list.isNotEmpty && list.first != '')
                          ? Text(list.join(', '), style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1))
                          : Text('Select Country', style: TextStyle(color: AppColor.secondaryColor2, fontSize: 9.spV2));
                    }),
                  ),
                  _divider(),

                  // Languages Spoken (multi-select)
                  _rowLabelPicker(
                    context: context,
                    label: 'Languages Spoken',
                    onTap: () => controller.openLanguageDialog(context),
                    child: Obx(() {
                      final list = controller.languageSaveList;
                      return (list.isNotEmpty && list.first != '')
                          ? Text(list.join(', '), style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1))
                          : Text('Select Language ', style: TextStyle(color: AppColor.secondaryColor2, fontSize: 9.spV2));
                    }),
                  ),
                  _divider(),

                  // Hide Profile Picture (Yes/No)
                  Padding(
                    padding: EdgeInsets.only(left: 5.w, right: 0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text('Hide Profile Picture', style: TextStyle(fontWeight: FontWeight.w500, color: AppColor.textColor1, fontSize: 9.5.spV2)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Obx(() => Row(children: [
                                Theme(
                                  data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                                  child: Checkbox(
                                    activeColor: AppColor.secondaryColor1,
                                    checkColor: AppColor.textColor2,
                                    onChanged: (v) => controller.checkboxShowProfileYes.value = true,
                                    value: controller.checkboxShowProfileYes.value,
                                  ),
                                ),
                                Text('Yes', style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1)),
                                SizedBox(width: 20),
                                Theme(
                                  data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                                  child: Checkbox(
                                    activeColor: AppColor.secondaryColor1,
                                    checkColor: AppColor.textColor2,
                                    onChanged: (v) => controller.checkboxShowProfileYes.value = false,
                                    value: !controller.checkboxShowProfileYes.value,
                                  ),
                                ),
                                Text('No', style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1)),
                              ])),
                        ),
                      ],
                    ),
                  ),
                  _divider(),

                  // Hide Gender (Yes/No)
                  Padding(
                    padding: EdgeInsets.only(left: 5.w, right: 0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text('Hide Gender', style: TextStyle(fontWeight: FontWeight.w500, color: AppColor.textColor1, fontSize: 9.5.spV2)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Obx(() => Row(children: [
                                Theme(
                                  data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                                  child: Checkbox(
                                    activeColor: AppColor.secondaryColor1,
                                    checkColor: AppColor.textColor2,
                                    onChanged: (v) => controller.checkboxShowGenderYes.value = true,
                                    value: controller.checkboxShowGenderYes.value,
                                  ),
                                ),
                                Text('Yes', style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1)),
                                SizedBox(width: 20),
                                Theme(
                                  data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                                  child: Checkbox(
                                    activeColor: AppColor.secondaryColor1,
                                    checkColor: AppColor.textColor2,
                                    onChanged: (v) => controller.checkboxShowGenderYes.value = false,
                                    value: !controller.checkboxShowGenderYes.value,
                                  ),
                                ),
                                Text('No', style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1)),
                              ])),
                        ),
                      ],
                    ),
                  ),
                  _divider(),

                  SizedBox(height: 2.h),

                  // NEXT button
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
                      onPressed: () => controller.onTapNext(context),
                      child: Text('NEXT', style: TextStyle(fontSize: 10.spV2)),
                    ),
                  ),

                  // Save as Draft button
                  if (!controller.isFromAddCrew) ...[
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
                        onPressed: controller.onTapSaveDraft,
                        child: Text('Save As Draft', style: TextStyle(fontSize: 10.spV2)),
                      ),
                    ),
                  ]

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Divider(
        indent: 10,
        endIndent: 10,
        thickness: 1,
        color: AppColor.secondaryColor1,
      );

  Widget _rowLabelPicker({
    required BuildContext context,
    required String label,
    Widget? child,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
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
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onTap,
            child: child ?? SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}