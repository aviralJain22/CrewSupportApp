import 'dart:io';

import 'package:crew_support/database/airport_display_helper.dart';
import 'package:crew_support/model/pilot_availability_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'manage_availability_controller.dart';

class ManageAvailabilityScreen extends GetView<ManageAvailabilityController> {
  const ManageAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Keep colors and scaffold identical to legacy
    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Availability",
          style: TextStyle(color: AppColor.secondaryColor1, fontSize: 14.spV2),
        ),
        backgroundColor: AppColor.bgColor1,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColor.secondaryColor1,
          ),
        ),
      ),

      // Bottom "Add new availability" button — identical look
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
          left: 10.0.w,
          right: 10.0.w,
          bottom: Platform.isAndroid
            ? MediaQuery.of(context).padding.bottom + 1.0.h
            : 1.0.h,
          top: 2.0.h,
        ),
        child: MaterialButton(
          disabledColor: AppColor.secondaryColor1,
          disabledTextColor: AppColor.textColor2,
          textColor: AppColor.textColor2,
          color: AppColor.secondaryColor1,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
            borderRadius: BorderRadius.circular(2.w),
          ),
          onPressed: controller.goToAddAvailability,
          child: Text(
            "Add new availability",
            style: TextStyle(
              color: AppColor.textColor2,
              fontSize: 12.0.spV2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          // Loading section identical (spinner + "Loading...")
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingAnimationWidget.threeRotatingDots(
                  color: AppColor.secondaryColor1,
                  size: 50.sp,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Loading...',
                  style: TextStyle(color: AppColor.textColor1, fontSize: 12.spV2),
                ),
              ],
            ),
          );
        }

        // Main content: tabs + list (current/future)
        return Container(
          margin: EdgeInsets.only(top: 2.0.h),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                // Two-segment toggle, same look/size
                Obx(() => Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => controller.setTab(true),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getBoxColor(controller.isCurrent.value),
                              border: Border.all(color: AppColor.secondaryColor1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5),
                                bottomLeft: Radius.circular(5),
                              ),
                            ),
                            height: 3.5.h,
                            width: 35.0.w,
                            child: Center(
                              child: Text(
                                "Current",
                                style: TextStyle(
                                  color: _getTabTextColor(controller.isCurrent.value),
                                  fontSize: 12.spV2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => controller.setTab(false),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getBoxColor(controller.isFuture.value),
                              border: Border.all(color: AppColor.secondaryColor1),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(5),
                                bottomRight: Radius.circular(5),
                              ),
                            ),
                            height: 3.5.h,
                            width: 35.0.w,
                            child: Center(
                              child: Text(
                                "Future",
                                style: TextStyle(
                                  color: _getTabTextColor(controller.isFuture.value),
                                  fontSize: 12.spV2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),

                // Current / Future list
                Obx(() => controller.isCurrent.value
                    ? _CurrentList()
                    : _FutureList()),
              ],
            ),
          ),
        );
      }),
    );
  }

  Color _getTabTextColor(bool tab) {
    return tab ? AppColor.textColor1 : AppColor.textColor2;
  }

  Color _getBoxColor(bool tab) {
    return tab ? AppColor.secondaryColor1 : AppColor.textColor1;
  }
}

/// Current tab list (split to keep Obx scopes tight)
class _CurrentList extends GetView<ManageAvailabilityController> {
  @override
  Widget build(BuildContext context) {
    final items = controller.currentList;

    return Expanded(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: items.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No data found.',
                    style: TextStyle(
                      color: AppColor.secondaryColor1,
                      fontSize: 12.spV2,
                    ),
                  ),
                ],
              )
            : ListView.builder(
                itemCount: controller.all.length,
                itemBuilder: (context, index) {
                  final item = controller.all[index];
                  if ((item.isCurrent) != true) return const SizedBox();

                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _PassData(
                              date: item.fromDate.toString(),
                              toDate: item.toDate.toString(),
                              airportCode: item.airportCode?.toString() ?? "",
                              comment: item.comment?.toString() ?? "",
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => controller.goToEditAvailability(item),
                                  icon: Icon(Icons.edit, color: AppColor.secondaryColor1),
                                ),
                                IconButton(
                                  onPressed: () => _showDeleteDialog(context, item),
                                  icon: Icon(Icons.delete_forever, color: AppColor.deleteColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 1.0.h, bottom: 1.0.h),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColor.secondaryColor1,
                              width: 0.2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          height: 1.1,
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// Future tab list
class _FutureList extends GetView<ManageAvailabilityController> {
  @override
  Widget build(BuildContext context) {
    final items = controller.futureList;

    return Expanded(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: items.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No data found.',
                    style: TextStyle(
                      color: AppColor.secondaryColor1,
                      fontSize: 12.spV2,
                    ),
                  ),
                ],
              )
            : ListView.builder(
                itemCount: controller.all.length,
                itemBuilder: (context, index) {
                  final item = controller.all[index];
                  if ((item.isFuture) != true) return const SizedBox();

                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _PassData(
                              date: item.fromDate.toString(),
                              toDate: item.toDate.toString(),
                              airportCode: item.airportCode?.toString() ?? "",
                              comment: item.comment?.toString() ?? "",
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => controller.goToEditAvailability(item),
                                  icon: Icon(Icons.edit, color: AppColor.secondaryColor1),
                                ),
                                IconButton(
                                  onPressed: () => _showDeleteDialog(context, item),
                                  icon: Icon(Icons.delete_forever, color: AppColor.deleteColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 1.0.h, bottom: 1.0.h),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColor.secondaryColor1,
                              width: 0.2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          height: 1.1,
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// Row group renderer (kept identical to legacy)
class _PassData extends StatelessWidget {
  final String date;
  final String toDate;
  final String airportCode;
  final String comment;

  const _PassData({
    required this.date,
    required this.toDate,
    required this.airportCode,
    required this.comment,
  });

  // Removed _getAirportFromCode; now handled by controller

  @override
  Widget build(BuildContext context) {
    final manageController = Get.find<ManageAvailabilityController>();
    Text _label(String t) => Text(t,
        style: TextStyle(color: AppColor.textColor1, fontSize: 12.spV2));
    Text _value(String t) => Text(t,
        style: TextStyle(color: AppColor.secondaryColor1, fontSize: 12.spV2));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 30.0.w, margin: EdgeInsets.only(top: 1.h), child: _label("From date :")),
            Container(
              margin: EdgeInsets.only(top: 1.h),
              child: _value(DateFormat('MM/dd/yyyy').format(DateTime.parse(date))),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 30.0.w, margin: EdgeInsets.only(top: 1.h), child: _label("To date :")),
            Container(
              margin: EdgeInsets.only(top: 1.h),
              child: _value(DateFormat('MM/dd/yyyy').format(DateTime.parse(toDate))),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 30.0.w, margin: EdgeInsets.only(top: 1.h), child: _label("Nearest Airport:")),
            Container(
              width: 35.0.w,
              margin: EdgeInsets.only(top: 1.h),
              child: Obx(() {
                final airport = manageController.airportByCode[airportCode.trim()];
                final display = formatAirportDisplay(
                  airport,
                  fallbackCode: airportCode,
                );

                return Text(
                  display,
                  style: TextStyle(
                    color: AppColor.secondaryColor1,
                    fontSize: 12.spV2,
                  ),
                );
              }),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 30.0.w, margin: EdgeInsets.only(top: 1.h), child: _label("Comment :")),
            Container(
              width: 35.0.w,
              margin: EdgeInsets.only(top: 1.h),
              child: Text(
                comment,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(color: AppColor.secondaryColor1, fontSize: 12.spV2),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Legacy-styled Cupertino confirmation dialog
void _showDeleteDialog(BuildContext context, AvailabilityItem item) {
  final c = Get.find<ManageAvailabilityController>();
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return Theme(
        data: ThemeData.dark(),
        child: CupertinoAlertDialog(
          content: SizedBox(
            height: 5.h,
            width: 60.w,
            child: Text(
              "Do you want to delete availability?",
              style: TextStyle(color: AppColor.textColor1, fontSize: 12.spV2),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No', style: TextStyle(color: AppColor.secondaryColor1, fontSize: 12.spV2)),
              onPressed: () => Navigator.pop(ctx),
            ),
            TextButton(
              child: Text('Yes', style: TextStyle(color: AppColor.secondaryColor1, fontSize: 12.spV2)),
              onPressed: () async {
                // Close the alert first to match legacy's nested pops cleanly
                Navigator.pop(ctx);
                await c.confirmAndDelete(item);
              },
            ),
          ],
        ),
      );
    },
  );
}