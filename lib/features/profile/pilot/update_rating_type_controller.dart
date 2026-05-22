import 'package:crew_support/helper/user_helper.dart';
import 'package:crew_support/model/rating_certification.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:crew_support/model/AircraftModel.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class UpdateRatingTypeController extends GetxController {
  // The RatingCertificate model passed from previous screen via Get.arguments
  late RatingCertification ratingModel;

  // Text controllers
  final TextEditingController certificateController =
      TextEditingController(text: "Commercial");
  final TextEditingController categoryController =
      TextEditingController(text: "Airplane");
  final TextEditingController hoursController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController aircraftTypeController = TextEditingController();
  final TextEditingController picController = TextEditingController();
  final TextEditingController minimumRateController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // Checkboxes (reactive)
  final RxBool checkboxCurrentNo = false.obs;
  final RxBool checkboxCurrentYes = false.obs;
  final RxBool checkboxSimulatorNo = false.obs;
  final RxBool checkboxSimulatorYes = false.obs;

  // Aircraft lists
  List<AircraftTypeList> aircraftTempList = [];
  List<AircraftTypeList> aircraftFilterList = [];
  int? airCrafeID;

  // Button state
  final RxBool isPressed = true.obs;

  @override
  void onInit() {
    super.onInit();

    // Expecting RatingCertificate via Get.arguments
    ratingModel = Get.arguments as RatingCertification;

    // Initialize from model
    _setDataFromModel();

    // Copy full aircraft list initially
    aircraftTempList = aircraftTypeList;
  }

  @override
  void onClose() {
    // Dispose controllers and dismiss any loaders
    certificateController.dispose();
    categoryController.dispose();
    hoursController.dispose();
    classController.dispose();
    aircraftTypeController.dispose();
    picController.dispose();
    minimumRateController.dispose();
    searchController.dispose();

    EasyLoading.dismiss();
    super.onClose();
  }

  /// Initialize controllers and checkbox states from the incoming ratingModel
  void _setDataFromModel() {
    debugPrint("Certificate ID- ${ratingModel.objectId.toString()}");

    certificateController.text = ratingModel.ratingName.toString();
    categoryController.text = getCategoryTextFromId(ratingModel.categoryId);
    hoursController.text = ratingModel.totalHours?.toString() ?? "";
    aircraftTypeController.text = ratingModel.aircraftType.toString();
    classController.text = getClassRatingTextFromId(ratingModel.classId);
    picController.text = ratingModel.pic?.toString() ?? "";

    if (ratingModel.minimumRate != null) {
      // same formatting as old code
      minimumRateController.text = ratingModel.minimumRate!.toStringAsFixed(2);
    }

    // Current (PIC/SIC) flags
    final currentInType = ratingModel.currentInType ?? "";

    if (currentInType.contains("PIC")) {
      checkboxCurrentYes.value = true;
    }
    if (currentInType.contains("SIC")) {
      checkboxCurrentNo.value = true;
    }

    // 12-month simulator current
    if (ratingModel.isReqPrev12MonthTraining == true) {
      checkboxSimulatorYes.value = true;
      checkboxSimulatorNo.value = false;
    } else if (ratingModel.isReqPrev12MonthTraining == false) {
      checkboxSimulatorYes.value = false;
      checkboxSimulatorNo.value = true;
    }
  }

  /// Build "current" string from PIC/SIC checkboxes, same as old code.
  String get currentString {
    return (checkboxCurrentYes.value ? "PIC" : "") +
        (checkboxCurrentYes.value && checkboxCurrentNo.value ? "," : "") +
        (checkboxCurrentNo.value ? "SIC" : "");
  }

  void toggleCurrentPic(bool? value) {
    final bool isPicSelected = value ?? false;

    checkboxCurrentYes.value = isPicSelected;

    // A PIC qualification also covers SIC, so automatically select SIC
    // whenever PIC is selected.
    if (isPicSelected) {
      checkboxCurrentNo.value = true;
    }
  }

  void toggleCurrentSic(bool? value) {
    // PIC also covers SIC, so do not allow SIC to be unchecked while PIC is selected.
    if (checkboxCurrentYes.value) {
      checkboxCurrentNo.value = true;
      return;
    }

    checkboxCurrentNo.value = value ?? false;
  }

  // /// Map category string to numeric id, same as old code.
  // int get categoryId {
  //   if (categoryController.text == "Airplane") {
  //     return 1;
  //   } else if (categoryController.text == "Helicopter") {
  //     return 3;
  //   } else {
  //     return 0;
  //   }
  // }

  /// Map class text to string code, same as old code.
  // String get classRatingCode {
  //   switch (classController.text) {
  //     case "Multi Engine land":
  //       return "1";
  //     case "Single Engine land":
  //       return "2";
  //     case "Multi Engine sea":
  //       return "3";
  //     case "Single Engine Sea":
  //       return "4";
  //     default:
  //       return "";
  //   }
  // }

  /// Called from the "Update" button.
  /// Handles validation, shows loading dialog, calls API, and shows result dialog.
  Future<void> onUpdatePressed(BuildContext context) async {
    if (!isPressed.value) return;

    isPressed.value = false;

    // Unfocus any fields
    FocusScope.of(context).unfocus();

    // Show loading dialog (same text as old code)
    showLoadingDialog(context, 'Updating...');

    // ---------- Validation (same sequence as old code) ----------
    if (certificateController.text.isEmpty) {
      Navigator.pop(context); // close "Updating..." dialog
      showMyDialog(context, "Please select certificate");
      isPressed.value = true;
      return;
    } else if (categoryController.text.isEmpty) {
      Navigator.pop(context);
      showMyDialog(context, "Please select category");
      isPressed.value = true;
      return;
    } else if (classController.text.isEmpty) {
      Navigator.pop(context);
      showMyDialog(context, "Please select class");
      isPressed.value = true;
      return;
    } else if (aircraftTypeController.text.isEmpty) {
      Navigator.pop(context);
      showMyDialog(context, "Please select Air craft Type ");
      isPressed.value = true;
      return;
    } else if (hoursController.text.isEmpty) {
      Navigator.pop(context);
      showMyDialog(context, "Please Enter Hours");
      isPressed.value = true;
      return;
    } else if (picController.text.isEmpty) {
      Navigator.pop(context);
      showMyDialog(context, "Please enter PIC ");
      isPressed.value = true;
      return;
    } else if (minimumRateController.text.isEmpty) {
      Navigator.pop(context);
      showMyDialog(context, "Please enter Minimum Rate");
      isPressed.value = true;
      return;
    }

    debugPrint("Certificate called- ${certificateController.text}");

    // Map category string to int (same logic as old code)
    int categoryValue = getCategoryValueFromText(categoryController.text);

    // Map class string to rating string (same logic as old code)
    int classRating = getClassRatingFromText(classController.text);

    // minimumRateController.text → string input from user
    final String minRateStr = minimumRateController.text.trim();

    // Parse to double (preferred), null if empty or invalid
    double? minRate;

    if (minRateStr.isEmpty) {
      minRate = null; // user left it blank → store null
    } else {
      minRate = double.tryParse(minRateStr);
      if (minRate == null) {
        // Input was not numeric → handle gracefully
        Navigator.pop(context);
        showMyDialog(context, "Please enter a valid numeric Minimum Rate.");
        isPressed.value = true;
        return; // stop execution so user fixes it
      }
    }

    // Parse hours + PIC as Numbers (cloud function now rejects numeric strings)
    final String totalHoursStr = hoursController.text.trim();
    final String picStr = picController.text.trim();

    final double? totalHoursNum = double.tryParse(totalHoursStr);
    if (totalHoursNum == null) {
      Navigator.pop(context);
      showMyDialog(context, "Please enter a valid numeric Hours.");
      isPressed.value = true;
      return;
    }

    final double? picNum = double.tryParse(picStr);
    if (picNum == null) {
      Navigator.pop(context);
      showMyDialog(context, "Please enter a valid numeric PIC.");
      isPressed.value = true;
      return;
    }

    try {
      // -----------------------------
      // 1. Build parameters for cloud function
      // -----------------------------

      // If you're adding a NEW rating, keep ratingCertiId = null.
      // If editing, set ratingCertiId to the objectId of existing ratingCertification row.
      final Map<String, dynamic> params = {
        "ratingCertiId": ratingModel.objectId, // null for insert, objectId for update

        // Map your UI fields → cloud code params
        "ratingName": certificateController.text.trim(),
        "categoryId": categoryValue, // int or null
        "classId": classRating,      // int or null

        "aircraftType": aircraftTypeController.text.trim(),
        "totalHours": totalHoursNum,
        "pic": picNum,

        "minimumRate": minRate,

        // This matches your `currentString` from old code
        "currentInType": currentString,

        // Reusing your simulator checkbox for this flag
        "isReqPrev12MonthTraining": checkboxSimulatorYes.value,

        // Default values for flags/index/date – adjust as needed
        "isVoid": false,
        // "entryDate": DateTime.now().toIso8601String(),
        // "certiIndex": certiIndex, // any index you maintain for ordering; can be null
      };

      // -----------------------------
      // 2. Call Back4App Cloud Function
      // -----------------------------
      final function = ParseCloudFunction('saveRatingCertification');
      final ParseResponse response = await function.execute(parameters: params);

      // Dismiss loading dialog (same as your old code)
      Navigator.pop(context);

      isPressed.value = true;

      // -----------------------------
      // 3. Handle errors from cloud function
      // -----------------------------
      if (!response.success || response.result == null) {
        // If Parse returned an error → show message from server if available
        final String errorMessage =
            response.error?.message ?? "Something went wrong. Please try again.";

        showMyDialog(context, errorMessage);
        return;
      }

      // -----------------------------
      // 4. Build a friendly success message
      // -----------------------------
      String successMsg = "Rating / Certification updated successfully.";

      // Try to pick ratingName from the returned object, if possible
      try {
        final result = response.result;

        // Case 1: Cloud function returned a ParseObject
        if (result is ParseObject) {
          final name = result.get<String>("ratingName");
          if (name != null && name.isNotEmpty) {
            successMsg = 'Rating / Certification "$name" updated successfully.';
          }
        }
        // Case 2: Cloud function returned a Map
        else if (result is Map && result["ratingName"] != null) {
          successMsg =
              'Rating / Certification "${result["ratingName"]}" updated successfully.';
        }
      } catch (_) {
        // Fallback: keep generic success message
      }

      // -----------------------------
      // 5. Show the same Cupertino-style dialog as old code
      // -----------------------------
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          return Theme(
            data: ThemeData.dark(),
            child: CupertinoAlertDialog(
              content: Text(
                successMsg,
                style: TextStyle(fontSize: 10.spV2),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(color: AppColor.secondaryColor1),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);     // close dialog
                    Navigator.pop(context); // close screen
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      // If something blows up BEFORE we dismiss the loading dialog,
      // it's safer to try popping it in a guarded way.
      try {
        Navigator.pop(context); // dismiss loading dialog if still open
      } catch (_) {}

      isPressed.value = true;

      // Show generic error (you can log e.toString() for debugging)
      showMyDialog(context, "Something went wrong. Please try again.");
    } finally {
    }

    // try {
    //   // Call same API helper as old code (implementation now lives in Api_service.dart)
    //   final value = await updateRatingCertificate(
    //     pkRatingCertiId: ratingModel.pkRatingCertiId.toString(),
    //     certificate: certificateController.text,
    //     category: categoryId,
    //     classRating: classRatingCode,
    //     modelAircraft: aircraftTypeController.text,
    //     hours: hoursController.text,
    //     piC: picController.text,
    //     minimumRate: minimumRateController.text,
    //     current: currentString,
    //     simulatorMonth: checkboxSimulatorYes.value ? "true" : "false",
    //   );

    //   print("value!.msg ${value!.data}");

    //   // Close "Updating..." dialog
    //   Navigator.pop(context);

    //   isPressed.value = true;

    //   if (value == null) {
    //     showMyDialog(context, "Something went wrong. Please try again.");
    //     return;
    //   }

    //   // Same CupertinoAlertDialog as in old code
    //   await showDialog<void>(
    //     context: context,
    //     barrierDismissible: false, // user must tap button!
    //     builder: (BuildContext dialogContext) {
    //       return Theme(
    //         data: ThemeData.dark(),
    //         child: CupertinoAlertDialog(
    //           content: SizedBox(
    //             height: 5.h,
    //             width: 60.w,
    //             child: Text(
    //               value.msg.toString() == 'Certificate added successfully.'
    //                   ? 'Certificate Updated sucessfully'
    //                   : value.msg.toString(),
    //             ),
    //           ),
    //           actions: <Widget>[
    //             TextButton(
    //               child: Text(
    //                 'Ok',
    //                 style: TextStyle(color: AppColor.secondaryColor1),
    //               ),
    //               onPressed: () {
    //                 Navigator.pop(dialogContext); // close dialog
    //                 Navigator.pop(context); // go back to previous screen
    //               },
    //             ),
    //           ],
    //         ),
    //       );
    //     },
    //   );
    // } catch (e) {
    //   // Ensure loading dialog is closed on error as well
    //   Navigator.pop(context);
    //   isPressed.value = true;
    //   print("updateRatingCertificate error: $e");
    //   showMyDialog(context, "Something went wrong. Please try again.");
    // }

  }
}

class UpdateRatingTypeBinding extends Bindings {
  @override
  void dependencies() {
    // Controller reads Get.arguments in onInit(), so no params needed here
    Get.lazyPut<UpdateRatingTypeController>(
      () => UpdateRatingTypeController(),
    );
  }
}