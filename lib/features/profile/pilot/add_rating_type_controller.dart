import 'package:crew_support/helper/user_helper.dart';
import 'package:crew_support/model/AircraftModel.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:sizer/sizer.dart';

class AddRatingTypeController extends GetxController {
  final TextEditingController certificateController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController hoursController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController picController = TextEditingController();
  final TextEditingController aircraftTypeController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController minimumRateController = TextEditingController();

  /// Checkbox states
  final RxBool checkboxCurrentNo = false.obs;
  final RxBool checkboxCurrentYes = false.obs;
  final RxBool checkboxSimulatorNo = false.obs;
  final RxBool checkboxSimulatorYes = true.obs;

  /// Aircraft list
  List<AircraftTypeList> aircraftTempList = [];
  int? airCrafeID;

  /// To prevent multiple taps on Add button
  final RxBool stopClicking = false.obs;

  @override
  void onInit() {
    super.onInit();
    aircraftTempList = aircraftTypeList;
  }

  @override
  void onClose() {
    certificateController.dispose();
    categoryController.dispose();
    hoursController.dispose();
    classController.dispose();
    picController.dispose();
    aircraftTypeController.dispose();
    searchController.dispose();
    minimumRateController.dispose();
    super.onClose();
  }

  /// --- Checkbox handlers ---

  void selectSimulatorYes() {
    checkboxSimulatorYes.value = true;
    checkboxSimulatorNo.value = false;
  }

  void selectSimulatorNo() {
    checkboxSimulatorYes.value = false;
    checkboxSimulatorNo.value = true;
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

  /// Build "current" string same as old code:
  /// (_checkboxCurrentYes ? "PIC" : "") +
  /// (_checkboxCurrentYes && _checkboxCurrentNo ? "," : "") +
  /// (_checkboxCurrentNo ? "SIC" : "")
  String get currentString {
    final String pic = checkboxCurrentYes.value ? "PIC" : "";
    final String sic = checkboxCurrentNo.value ? "SIC" : "";
    if (pic.isNotEmpty && sic.isNotEmpty) {
      return "$pic,$sic";
    }
    return pic + sic;
  }

  /// --- Pickers & Dialogs ---

  void showCertificatePicker(BuildContext context) {
    final action = Theme(
      data: ThemeData.dark(),
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            isDefaultAction: false,
            onPressed: () {
              certificateController.text = "Commercial";
              Navigator.pop(context);
            },
            child: Text(
              "Commercial",
              style: TextStyle(color: AppColor.textColor1, fontSize: 10.spV2),
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: false,
            onPressed: () {
              certificateController.text = "ATP";
              Navigator.pop(context);
            },
            child: Text(
              "ATP",
              style: TextStyle(color: AppColor.textColor1, fontSize: 10.spV2),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: AppColor.secondaryColor1, fontSize: 10.spV2),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  void showCategoryPicker(BuildContext context) {
    final action = Theme(
      data: ThemeData.dark(),
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            isDefaultAction: false,
            onPressed: () {
              categoryController.text = "Airplane";
              Navigator.pop(context);
            },
            child: Text(
              "Airplane",
              style: TextStyle(color: AppColor.textColor1, fontSize: 10.spV2),
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: false,
            onPressed: () {
              categoryController.text = "Helicopter";
              Navigator.pop(context);
            },
            child: Text(
              "Helicopter",
              style: TextStyle(color: AppColor.textColor1, fontSize: 10.spV2),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: AppColor.secondaryColor1, fontSize: 10.spV2),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  void showClassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Theme(
          data: ThemeData.dark(),
          child: AlertDialog(
            title: Text(
              "Select Class",
              style: TextStyle(fontSize: 11.spV2),
            ),
            content: SizedBox(
              height: 30.h,
              width: 15.w,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: classList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      classList[index],
                      style: TextStyle(fontSize: 10.spV2),
                    ),
                    onTap: () {
                      classController.text = classList[index];
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void showModelListDialog(BuildContext context) {
    // Local search state so only this aircraft dialog gets the custom picker UI.
    // The controller-level searchController is not reused here to avoid lifecycle
    // issues while the dialog route is being dismissed.
    final TextEditingController localSearchController = TextEditingController();
    List<AircraftTypeList> tempList = List<AircraftTypeList>.from(aircraftTypeList);

    final Future<void> dialogFuture = showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              backgroundColor: AppColor.bgColor2,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              child: SizedBox(
                height: 70.h,
                width: 90.w,
                child: Column(
                  children: [
                    // Title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.w),
                      child: Text(
                        'Select Aircraft Type',
                        style: TextStyle(
                          color: AppColor.secondaryColor1,
                          fontSize: 13.spV2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Search field styled like CreateTripScreen's _showAircraftPicker.
                    Padding(
                      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.w),
                      child: TextField(
                        controller: localSearchController,
                        autocorrect: false,
                        enableSuggestions: false,
                        style: TextStyle(
                          color: AppColor.textColor1,
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.w600,
                        ),
                        onChanged: (text) {
                          setState(() {
                            final String query = text.trim().toLowerCase();
                            if (query.isEmpty) {
                              tempList = List<AircraftTypeList>.from(aircraftTypeList);
                            } else {
                              tempList = aircraftTypeList
                                  .where((aircraft) => aircraft.name.toLowerCase().contains(query))
                                  .toList();
                            }
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search Aircraft',
                          hintStyle: TextStyle(
                            color: AppColor.secondaryColor2,
                            fontSize: 9.spV2,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColor.secondaryColor1),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColor.secondaryColor1, width: 1.2),
                          ),
                        ),
                      ),
                    ),

                    Divider(color: AppColor.secondaryColor1, height: 1),

                    Expanded(
                      child: tempList.isEmpty
                          ? Center(
                              child: Text(
                                'No aircraft found',
                                style: TextStyle(
                                  color: AppColor.secondaryColor2,
                                  fontSize: 10.spV2,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: tempList.length,
                              itemBuilder: (_, index) {
                                final AircraftTypeList aircraft = tempList[index];

                                return Column(
                                  children: [
                                    ListTile(
                                      dense: true,
                                      title: Text(
                                        aircraft.name,
                                        style: TextStyle(
                                          color: AppColor.textColor1,
                                          fontSize: 10.spV2,
                                        ),
                                      ),
                                      onTap: () {
                                        aircraftTypeController.text = aircraft.name;
                                        airCrafeID = aircraft.id;
                                        Navigator.pop(dialogContext);
                                      },
                                    ),
                                    Divider(
                                      indent: 10,
                                      endIndent: 10,
                                      thickness: 1,
                                      color: AppColor.textColor1,
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),

                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: MaterialButton(
                          textColor: AppColor.textColor2,
                          color: AppColor.secondaryColor1,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text('Cancel', style: TextStyle(fontSize: 10.spV2)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    dialogFuture.whenComplete(() async {
      // Let the dialog dismissal finish before disposing the local controller.
      // This prevents TextEditingController lifecycle crashes after typing search text.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      localSearchController.dispose();
    });
  }

  /// --- Add button handler ---

  Future<void> onAddPressed(BuildContext context) async {
    if (stopClicking.value) return;

    stopClicking.value = true;

    // Same UX as old: show custom loading dialog
    showLoadingDialog(context, 'Adding...');

    // Validations (exact same checks & messages as old code)
    if (certificateController.text.isEmpty) {
      Navigator.pop(context);
      showMyDialog(context, "Please select certificate");
      stopClicking.value = false;
      return;
    } else if (categoryController.text.isEmpty) {
      Navigator.pop(context);
      showMyDialog(context, "Please select category");
      stopClicking.value = false;
      return;
    } else if (classController.text.isEmpty) {
      Navigator.pop(context);
      showMyDialog(context, "Please select class");
      stopClicking.value = false;
      return;
    } else if (aircraftTypeController.text.isEmpty) {
      Navigator.pop(context);
      showMyDialog(context, "Please select Aircraft Type ");
      stopClicking.value = false;
      return;
    } else if (hoursController.text.isEmpty) {
      Navigator.pop(context);
      showMyDialog(context, "Please Enter Hours");
      stopClicking.value = false;
      return;
    } else if (picController.text.isEmpty) {
      Navigator.pop(context);
      showMyDialog(context, "Please enter PIC ");
      stopClicking.value = false;
      return;
    } else if (minimumRateController.text.isEmpty) {
      Navigator.pop(context);
      showMyDialog(context, "Please enter Minimum Rate");
      stopClicking.value = false;
      return;
    }

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
        stopClicking.value = false;
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
      stopClicking.value = false;
      return;
    }

    final double? picNum = double.tryParse(picStr);
    if (picNum == null) {
      Navigator.pop(context);
      showMyDialog(context, "Please enter a valid numeric PIC.");
      stopClicking.value = false;
      return;
    }

    try {
      // -----------------------------
      // 1. Build parameters for cloud function
      // -----------------------------

      // If you're adding a NEW rating, keep ratingCertiId = null.
      // If editing, set ratingCertiId to the objectId of existing ratingCertification row.
      final Map<String, dynamic> params = {
        "ratingCertiId": null, // null for insert, objectId for update

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
      String successMsg = "Rating / Certification saved successfully.";

      // Try to pick ratingName from the returned object, if possible
      try {
        final result = response.result;

        // Case 1: Cloud function returned a ParseObject
        if (result is ParseObject) {
          final name = result.get<String>("ratingName");
          if (name != null && name.isNotEmpty) {
            successMsg = 'Rating / Certification "$name" saved successfully.';
          }
        }
        // Case 2: Cloud function returned a Map
        else if (result is Map && result["ratingName"] != null) {
          successMsg =
              'Rating / Certification "${result["ratingName"]}" saved successfully.';
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

      // Show generic error (you can log e.toString() for debugging)
      showMyDialog(context, "Something went wrong. Please try again.");
    } finally {
      // Re-enable button
      stopClicking.value = false;
    }
  }
}