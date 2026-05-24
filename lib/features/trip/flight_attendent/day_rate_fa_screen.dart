import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart'; // for 10.spV2 etc.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'day_rate_fa_controller.dart';

class DayRateFAScreen extends GetWidget<DayRateFAController> {
  const DayRateFAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget _content() {
      return SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0.w, vertical: 2.h),
                            child: Text(
                              "Per Day",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColor.textColor1,
                                fontSize: 10.spV2,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
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
                                  cursorColor: AppColor.secondaryColor1,
                                  controller: controller.dayRateController,
                                  // Legacy: Screen1 integer only, Screen2 allowed decimals.
                                  // We mirror that using controller.isDraftMode flag.
                                  keyboardType: TextInputType.numberWithOptions(
                                    signed: true,
                                    decimal: controller.isDraftMode,
                                  ),
                                  style: TextStyle(
                                    fontSize: 10.spV2,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.secondaryColor1,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Enter Rate",
                                    hintStyle: TextStyle(color: AppColor.secondaryColor2),
                                    border: InputBorder.none,
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
                    SizedBox(height: 4.h),

                    // NEXT
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
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext ctx) {
                              int selectedOption = 0; // Initial selection
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                                  borderRadius: BorderRadius.circular(5.w),
                                ),
                                backgroundColor: AppColor.bgColor1,
                                content: StatefulBuilder(
                                  builder: (BuildContext context, StateSetter setState) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: AppColor.bgColor1, width: 1.0),
                                          ),
                                          child: ListTile(
                                            title: Text(
                                              'Search for crew matching your criteria.',
                                              style: TextStyle(
                                                color: AppColor.secondaryColor1,
                                                fontSize: 13.spV2,
                                              ),
                                            ),
                                            leading: Radio(
                                              value: 0,
                                              groupValue: selectedOption,
                                              fillColor: MaterialStateColor.resolveWith(
                                                (states) => AppColor.secondaryColor1,
                                              ),
                                              onChanged: (int? value) => setState(() => selectedOption = value!),
                                            ),
                                          ),
                                        ),
                                        // const SizedBox(height: 10),
                                        // Container(
                                        //   decoration: BoxDecoration(
                                        //     border: Border.all(color: AppColor.bgColor1, width: 1.0),
                                        //   ),
                                        //   child: ListTile(
                                        //     title: Text(
                                        //       'Post trip for crew to apply',
                                        //       style: TextStyle(
                                        //         color: AppColor.secondaryColor1,
                                        //         fontSize: 13.spV2,
                                        //       ),
                                        //     ),
                                        //     leading: Radio(
                                        //       value: 1,
                                        //       groupValue: selectedOption,
                                        //       fillColor: MaterialStateColor.resolveWith(
                                        //         (states) => AppColor.secondaryColor1,
                                        //       ),
                                        //       onChanged: (int? value) => setState(() => selectedOption = value!),
                                        //     ),
                                        //   ),
                                        // ),
                                      ],
                                    );
                                  },
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.secondaryColor1,
                                    ),
                                    child: Text('Cancel', style: TextStyle(color: AppColor.bgColor1)),
                                    onPressed: () => Navigator.of(ctx).pop(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColor.secondaryColor1,
                                      ),
                                      child: Text('OK', style: TextStyle(color: AppColor.bgColor1)),
                                      onPressed: () async {
                                        Navigator.of(ctx).pop(); // close dialog
                                        if (selectedOption == 0) {
                                          // showLoadingDialogNew('Loading...');
                                          try {
                                            await controller.onTapNext();
                                          } catch (e) {
                                            showMyDialogNew(e.toString().replaceFirst('Exception: ', ''));
                                          } finally {
                                            // closeLoadingDialog();
                                          }
                                        } else {
                                          // Show the confirmation dialog like legacy before posting
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext ctx2) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                                                  borderRadius: BorderRadius.circular(5.w),
                                                ),
                                                backgroundColor: AppColor.bgColor1,
                                                title: Text(
                                                  'Trip has been added to uncrewed tab.',
                                                  style: TextStyle(
                                                    color: AppColor.secondaryColor1,
                                                    fontSize: 12.spV2,
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: AppColor.secondaryColor1,
                                                      ),
                                                      child: Text('OK', style: TextStyle(color: AppColor.bgColor1)),
                                                      onPressed: () {
                                                        Navigator.of(ctx2).pop(); // close info dialog
                                                        controller.postUncrewed(context);
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text("Next", style: TextStyle(fontSize: 10.spV2)),
                      ),
                    ),

                    // SAVE AS DRAFT
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
                          child: Text("Save As Draft", style: TextStyle(fontSize: 10.spV2)),
                        ),
                      ),
                    ]
                    
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Day Rate - FA",
          style: TextStyle(color: AppColor.secondaryColor1),
        ),
        backgroundColor: AppColor.bgColor1,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.adaptive.arrow_back_rounded, color: AppColor.secondaryColor1),
        ),
      ),
      body: (() {
        final isDraft = controller.isDraftMode;
        if (!isDraft) {
          // Fresh mode (old DayRateFAScreen): no Rx needed here.
          return _content();
        }
        // Draft mode (old DayRateFAScreen2): listen to isLoading.
        return Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 2.h),
                  Text('Loading...', style: TextStyle(color: AppColor.textColor1, fontSize: 12.spV2)),
                ],
              ),
            );
          }
          return _content();
        });
      })(),
    );
  }
}