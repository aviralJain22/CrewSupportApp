// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:crew_support/helper/user_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:crew_support/model/AircraftModel.dart';
import 'update_rating_type_controller.dart';

class UpdateRatingTypeScreen extends GetView<UpdateRatingTypeController> {
  const UpdateRatingTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Update Rating Type",
          style: TextStyle(color: AppColor.secondaryColor1),
        ),
        backgroundColor: AppColor.bgColor1,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColor.secondaryColor1,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
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
                          hintStyle: TextStyle(
                            color: AppColor.secondaryColor2,
                            fontSize: 9.0.spV2,
                          ),
                        ),
                        onTap: () {
                          _certificatePicker(context);
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
                        ),
                        onTap: () {
                          _categoryPicker(context);
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
                        style: TextStyle(
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondaryColor1,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: AppColor.secondaryColor2,
                            fontSize: 9.0.spV2,
                          ),
                        ),
                        readOnly: true,
                        onTap: () {
                          _showClassDialog(context);
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

                // Make / Model
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
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: AppColor.secondaryColor2,
                            fontSize: 9.0.spV2,
                          ),
                        ),
                        onTap: () {
                          controller.searchController.clear();
                          _modelListDialog(context);
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
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                          decimal: false,
                        ),
                        decoration: InputDecoration(
                          hintText: "Hours",
                          border: InputBorder.none,
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
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                          decimal: false,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "PIC",
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
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                signed: true,
                                decimal: false,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: AppColor.secondaryColor2,
                                  fontSize: 9.0.spV2,
                                ),
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
                                onChanged: (value) {
                                  FocusScope.of(context).unfocus();
                                  controller.checkboxSimulatorYes.value = true;
                                  controller.checkboxSimulatorNo.value = false;
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
                                checkColor: AppColor.textColor2,
                                activeColor: AppColor.secondaryColor1,
                                onChanged: (value) {
                                  FocusScope.of(context).unfocus();
                                  controller.checkboxSimulatorNo.value = true;
                                  controller.checkboxSimulatorYes.value = false;
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

                // Current (PIC/SIC)
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
                                checkColor: AppColor.textColor2,
                                activeColor: AppColor.secondaryColor1,
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

                // Update button
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
                      onPressed: controller.isPressed.value
                          ? () => controller.onUpdatePressed(context)
                          : null,
                      child: Text(
                        "Update",
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

  // ------------------------
  // Helpers: pickers/dialogs
  // ------------------------

  void _certificatePicker(BuildContext context) {
    var action = Theme(
      data: ThemeData.dark(),
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            isDefaultAction: false,
            onPressed: () {
              controller.certificateController.text = "Commercial";
              Navigator.pop(context);
            },
            child: Text(
              "Commercial",
              style: TextStyle(color: AppColor.textColor1),
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: false,
            onPressed: () {
              controller.certificateController.text = "ATP";
              Navigator.pop(context);
            },
            child: Text(
              "ATP",
              style: TextStyle(color: AppColor.textColor1),
            ),
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: AppColor.secondaryColor1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
    showCupertinoModalPopup(context: context, builder: (ctx) => action);
  }

  void _categoryPicker(BuildContext context) {
    var action = Theme(
      data: ThemeData.dark(),
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            isDefaultAction: false,
            onPressed: () {
              controller.categoryController.text = "Airplane";
              Navigator.pop(context);
            },
            child: Text(
              "Airplane",
              style: TextStyle(color: AppColor.textColor1),
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: false,
            onPressed: () {
              controller.categoryController.text = "Helicopter";
              Navigator.pop(context);
            },
            child: Text(
              "Helicopter",
              style: TextStyle(color: AppColor.textColor1),
            ),
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: AppColor.secondaryColor1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
    showCupertinoModalPopup(context: context, builder: (ctx) => action);
  }

  void _showClassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Theme(
          data: ThemeData.dark(),
          child: AlertDialog(
            title: const Text("Select Class"),
            content: SizedBox(
              height: 30.h,
              width: 15.w,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: classList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(classList[index]),
                    onTap: () {
                      controller.classController.text =
                          classList[index];
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

  void _modelListDialog(BuildContext context) {
    // Local dialog state so only this aircraft picker gets the custom UI.
    // This avoids reusing the controller-level searchController while the dialog
    // route is being dismissed.
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
                                        controller.aircraftTypeController.text = aircraft.name;
                                        controller.airCrafeID = aircraft.id;
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
}