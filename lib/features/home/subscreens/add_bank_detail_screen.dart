import 'package:crew_support/features/home/subscreens/add_bank_detail_controller.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';

class AddBankDetailScreen extends GetWidget<AddBankDetailController> {
  const AddBankDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Add Bank Detail",
          style: TextStyle(color: AppColor.secondaryColor1),
        ),
        backgroundColor: AppColor.bgColor1,
        leading: IconButton(
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColor.secondaryColor1,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                // Select Country
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.w),
                        child: Text(
                          "Select Country",
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
                        style: TextStyle(
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondaryColor1,
                        ),
                        controller: controller.countryController,
                        readOnly: true,
                        onTap: controller.openCountryListDialog,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Select country",
                          hintStyle: TextStyle(
                            fontSize: 10.spV2,
                            color: AppColor.secondaryColor2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _divider(),

                // Currency
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.w),
                        child: Text(
                          "Currency",
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
                      child: TextField(
                        controller: controller.currencyController,
                        style: TextStyle(
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondaryColor1,
                        ),
                        readOnly: true,
                        onTap: controller.openCurrencySheet,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: " Select currency",
                          hintStyle: TextStyle(
                            color: AppColor.secondaryColor2,
                            fontSize: 9.spV2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _divider(),

                // Bank Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Text(
                          "Bank Name",
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
                      child: TextField(
                        controller: controller.bankNameController,
                        style: TextStyle(
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondaryColor1,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Bank Name",
                          hintStyle:
                              TextStyle(color: AppColor.secondaryColor2),
                        ),
                      ),
                    ),
                  ],
                ),
                _divider(),

                // Account Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Text(
                          "Account Name",
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
                      child: TextField(
                        controller: controller.accountNameController,
                        style: TextStyle(
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondaryColor1,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Account Name",
                          hintStyle:
                              TextStyle(color: AppColor.secondaryColor2),
                        ),
                      ),
                    ),
                  ],
                ),
                _divider(),

                // BIC Code
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Text(
                          "BIC Code",
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
                      child: TextField(
                        controller: controller.bicCodeController,
                        style: TextStyle(
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondaryColor1,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "BIC Code",
                          hintStyle: TextStyle(
                            color: AppColor.secondaryColor2,
                            fontSize: 9.spV2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _divider(),

                // Account Number
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Text(
                          "Account Number",
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
                      child: TextField(
                        controller: controller.accountNumberController,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                          decimal: false,
                        ),
                        style: TextStyle(
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondaryColor1,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Account Number",
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

                // IFSC Code
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Text(
                          "IFSC Code",
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
                      child: TextField(
                        controller: controller.ifscCodeController,
                        style: TextStyle(
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondaryColor1,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "IFSC Code",
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

                // Initial escrow requested
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Text(
                          "Initial escrow requested",
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
                        children: [
                          SizedBox(
                            width: 30.w,
                            child: TextFormField(
                              controller: controller.initialEscrowController,
                              readOnly: controller.dash.selectedProfileType.value == MembershipType.ownerOperator,
                              style: TextStyle(
                                fontSize: 10.spV2,
                                fontWeight: FontWeight.bold,
                                color: AppColor.secondaryColor1,
                              ),
                              decoration: InputDecoration(
                                hintText: "Percentage",
                                hintStyle: TextStyle(
                                  fontSize: 9.spV2,
                                  color: AppColor.secondaryColor2,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Text(
                            "%",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColor.secondaryColor1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _divider(),

                SizedBox(height: 3.h),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 35.w,
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
                        onPressed: controller.showSkipDialog,
                        child:
                            Text("Skip", style: TextStyle(fontSize: 10.spV2)),
                      ),
                    ),
                    SizedBox(
                      width: 35.w,
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
                        onPressed: controller.submitBankDetails,
                        child: Text("Submit",
                            style: TextStyle(fontSize: 10.spV2)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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