import 'package:crew_support/features/profile/pilot/add_rating_type_controller.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class AddRatingTypeScreen extends GetWidget<AddRatingTypeController> {
  const AddRatingTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColor.secondaryColor1,
          ),
        ),
        title: Text(
          "Add Rating Type",
          style: TextStyle(
            color: AppColor.secondaryColor1,
            fontSize: 12.spV2,
          ),
        ),
        backgroundColor: AppColor.bgColor1,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                // Certificate
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.w),
                        child: Text(
                          "Certificate",
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
                      child: TextFormField(
                        controller: controller.certificateController,
                        style: TextStyle(
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondaryColor1,
                        ),
                        readOnly: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Select Certificate",
                          hintStyle: TextStyle(
                            color: AppColor.secondaryColor2,
                            fontSize: 9.0.spV2,
                          ),
                        ),
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          controller.showCertificatePicker(context);
                        },
                      ),
                    ),
                  ],
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  thickness: 1,
                  color: AppColor.secondaryColor1,
                ),

                // Category
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.w),
                        child: Text(
                          "Category",
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
                      child: TextFormField(
                        controller: controller.categoryController,
                        style: TextStyle(
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondaryColor1,
                        ),
                        readOnly: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: AppColor.secondaryColor2,
                            fontSize: 9.0.spV2,
                          ),
                          hintText: "Select Category",
                        ),
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          controller.showCategoryPicker(context);
                        },
                      ),
                    ),
                  ],
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  thickness: 1,
                  color: AppColor.secondaryColor1,
                ),

                // Class
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.w),
                        child: Text(
                          "Class",
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
                      child: TextFormField(
                        controller: controller.classController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Select Class",
                          hintStyle: TextStyle(
                            fontSize: 9.0.spV2,
                            color: AppColor.secondaryColor2,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondaryColor1,
                        ),
                        readOnly: true,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          controller.showClassDialog(context);
                        },
                      ),
                    ),
                  ],
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  thickness: 1,
                  color: AppColor.secondaryColor1,
                ),

                // Make/Model
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.w),
                        child: Text(
                          "Make/Model",
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
                      child: TextFormField(
                        controller: controller.aircraftTypeController,
                        style: TextStyle(
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondaryColor1,
                        ),
                        readOnly: true,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          controller.showModelListDialog(context);
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Select Aircraft",
                          hintStyle: TextStyle(
                            color: AppColor.secondaryColor2,
                            fontSize: 9.spV2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  thickness: 1,
                  color: AppColor.secondaryColor1,
                ),

                // Hours
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.w),
                        child: Text(
                          "Hours",
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
                      child: TextFormField(
                        controller: controller.hoursController,
                        style: TextStyle(
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondaryColor1,
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          signed: true,
                          decimal: false,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter Hours",
                          hintStyle: TextStyle(
                            color: AppColor.secondaryColor2,
                            fontSize: 9.0.spV2,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  thickness: 1,
                  color: AppColor.secondaryColor1,
                ),

                // PIC
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.w),
                        child: Text(
                          "PIC",
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
                      child: TextFormField(
                        controller: controller.picController,
                        style: TextStyle(
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondaryColor1,
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          signed: true,
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter PIC",
                          hintStyle: TextStyle(
                            color: AppColor.secondaryColor2,
                            fontSize: 9.0.spV2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  thickness: 1,
                  color: AppColor.secondaryColor1,
                ),

                // Minimum Rate
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.w),
                        child: Text(
                          "Minimum Rate",
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
                      child: Row(
                        children: [
                          Text(
                            "\$",
                            style: TextStyle(
                              fontSize: 10.spV2,
                              fontWeight: FontWeight.bold,
                              color: AppColor.secondaryColor1,
                            ),
                          ),
                          Container(
                            width: 42.w,
                            margin: EdgeInsets.only(left: 3.w),
                            child: TextFormField(
                              controller: controller.minimumRateController,
                              style: TextStyle(
                                fontSize: 10.spV2,
                                fontWeight: FontWeight.bold,
                                color: AppColor.secondaryColor1,
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                signed: true,
                                decimal: false,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter Rate",
                                hintStyle:
                                    TextStyle(color: AppColor.secondaryColor2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  thickness: 1,
                  color: AppColor.secondaryColor1,
                ),

                // 12 month simulator current
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
                            color: AppColor.textColor1,
                            fontWeight: FontWeight.w500,
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
                                checkColor: AppColor.textColor2,
                                activeColor: AppColor.secondaryColor1,
                                onChanged: (_) {
                                  FocusScope.of(context).unfocus();
                                  controller.selectSimulatorYes();
                                },
                                value: controller.checkboxSimulatorYes.value,
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
                              data: ThemeData(
                                unselectedWidgetColor: AppColor.textColor1,
                              ),
                              child: Checkbox(
                                activeColor: AppColor.secondaryColor1,
                                checkColor: AppColor.textColor2,
                                onChanged: (_) {
                                  FocusScope.of(context).unfocus();
                                  controller.selectSimulatorNo();
                                },
                                value: controller.checkboxSimulatorNo.value,
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
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  thickness: 1,
                  color: AppColor.secondaryColor1,
                ),

                // Current
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.w),
                        child: Text(
                          "Current",
                          style: TextStyle(
                            color: AppColor.textColor1,
                            fontWeight: FontWeight.w500,
                            fontSize: 10.spV2,
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
                                onChanged: (value) {
                                  FocusScope.of(context).unfocus();
                                  controller.toggleCurrentPic(value);
                                },
                                value: controller.checkboxCurrentYes.value,
                              ),
                            ),
                            Text(
                              "PIC",
                              style: TextStyle(
                                fontSize: 10.spV2,
                                fontWeight: FontWeight.bold,
                                color: AppColor.secondaryColor1,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Theme(
                              data: ThemeData(
                                unselectedWidgetColor: AppColor.textColor1,
                              ),
                              child: Checkbox(
                                activeColor: AppColor.secondaryColor1,
                                checkColor: AppColor.textColor2,
                                onChanged: (value) {
                                  FocusScope.of(context).unfocus();
                                  controller.toggleCurrentSic(value);
                                },
                                value: controller.checkboxCurrentNo.value,
                              ),
                            ),
                            Text(
                              "SIC",
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
                Divider(
                  indent: 10,
                  endIndent: 10,
                  thickness: 1,
                  color: AppColor.secondaryColor1,
                ),

                SizedBox(height: 4.h),

                // Add button
                Obx(
                  () => SizedBox(
                    width: 85.w,
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
                      onPressed: controller.stopClicking.value
                          ? null
                          : () => controller.onAddPressed(context),
                      child: Text(
                        "Add",
                        style: TextStyle(fontSize: 10.spV2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}