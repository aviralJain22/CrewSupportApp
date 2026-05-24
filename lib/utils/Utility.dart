import 'package:crew_support/utils/AppColor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class Utility {
  static String? validateMobile(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(pattern);
    if (value.length == 0) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter valid mobile number';
    }
    return null;
  }

  static bool isValidEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.'*+-/=?^_`{|}]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }
  static bool isValidBIC(String BIC) {
    return RegExp(
            r'/^[a-z]{6}[2-9a-z][0-9a-np-z]([a-z0-9]{3}|x{3})?$/i')
        .hasMatch(BIC);
  }
}

Future<void> showMyDialog(BuildContext context, String msg) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      debugPrint("msg 2 $msg");
      return Theme(
        data: ThemeData.dark(),
        child: CupertinoAlertDialog(
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 80.w,
              maxHeight: 35.h,
            ),
            child: SingleChildScrollView(
              child: Text(
                msg,
                softWrap: true,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: AppColor.secondaryColor1)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showLoadingDialog(BuildContext context, String msg) async {
  return showDialog(
      barrierDismissible: false,
      // barrierColor: AppColor.loadingBarrierColor,
      context: context,
      builder: (ctx) {
        return msg == ""
            ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 25.h),
                  child: Theme(
                    data: ThemeData.dark(),
                    child: CupertinoAlertDialog(
                      content: Builder(builder: (context) {
                        return LoadingAnimationWidget.threeRotatingDots(
                          color: AppColor.secondaryColor1,
                          size: 25.sp,
                        );
                      }),
                    ),
                  ),

            )
            : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 23.w, vertical: 25.h),
                  child: Theme(
                    data: ThemeData.dark(),
                    child: CupertinoAlertDialog(
                    content: Builder(builder: (context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          LoadingAnimationWidget.threeRotatingDots(
                            color: AppColor.secondaryColor1,
                            size: 25.sp,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          Text(msg,style: TextStyle(color: AppColor.textColor1)),
                        ],
                      );
                    }),
                  ),
                  ),

            );
      });
}

Future<void> showMyDialogNew(String msg) async {
  if (Get.isDialogOpen == true) return; // prevent stacking duplicates

  await Get.dialog(
    CupertinoAlertDialog(
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 80.w,
          maxHeight: 35.h,
        ),
        child: SingleChildScrollView(
          child: Text(
            msg,
            // Allow full error text; dialog becomes scrollable if long.
            softWrap: true,
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            'OK',
            style: TextStyle(color: AppColor.secondaryColor1),
          ),
          onPressed: () {
            if (Get.isDialogOpen == true) Get.back();
          },
        ),
      ],
    ),
    barrierDismissible: false,
  );
}

Future<void> showLoadingDialogNew(String msg) async {
  if (Get.isDialogOpen == true) return; // prevent double dialogs

  await Get.dialog(
    PopScope(
      canPop: false, // blocks back & gesture safely
      child: msg.isEmpty
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 25.h),
              child: Theme(
                data: ThemeData.dark(),
                child: CupertinoAlertDialog(
                  content: LoadingAnimationWidget.threeRotatingDots(
                    color: AppColor.secondaryColor1,
                    size: 25.sp,
                  ),
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 23.w, vertical: 25.h),
              child: Theme(
                data: ThemeData.dark(),
                child: CupertinoAlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LoadingAnimationWidget.threeRotatingDots(
                        color: AppColor.secondaryColor1,
                        size: 25.sp,
                      ),
                      SizedBox(height: 1.h),
                      Text(msg,
                          style: TextStyle(color: AppColor.textColor1)),
                    ],
                  ),
                ),
              ),
            ),
    ),
    barrierDismissible: false,
  );
}

void closeLoadingDialog() {
  if (Get.isDialogOpen == true) {
    Get.back();
  }
}

DateTime parseMmDdYyyy(String dateStr) {
    final formatter = DateFormat('MM/dd/yyyy');  
    return formatter.parse(dateStr);  // This produces local DateTime
  }

  /// Helper: convert a local calendar date to UTC ISO string.
  ///
  /// Assumes `date` represents a *date-only* (no time) in user's local time.
  /// We normalize to local midnight, then convert to UTC before sending.
  ///
  /// Example output: "2025-12-16T18:30:00.000Z"
  String dateOnlyToUtcIsoString(DateTime date) {
    // Local midnight for that date
    final localMidnight = DateTime(date.year, date.month, date.day);
    // Convert to UTC (Back4App stores Date in UTC)
    final utc = localMidnight.toUtc();
    return utc.toIso8601String();
  }