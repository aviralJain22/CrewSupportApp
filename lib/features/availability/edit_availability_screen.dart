import 'package:crew_support/features/availability/edit_availability_controller.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:crew_support/widgets/airport/airport_search_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class EditAvailabilityScreen extends GetView<EditAvailabilityController> {
  const EditAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColor.secondaryColor1,
          ),
        ),
        title: Text(
          "Select Availability",
          style: TextStyle(color: AppColor.secondaryColor1),
        ),
        backgroundColor: AppColor.bgColor1,
      ),
      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      LoadingAnimationWidget.threeRotatingDots(
                        color: AppColor.secondaryColor1,
                        size: 50.sp,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Loading...',
                        style: TextStyle(color: AppColor.textColor1),
                      ),
                    ],
                  ),
                )
              : GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          top: 2.0.h,
                          left: 3.0.w,
                          right: 3.0.w,
                        ),
                        child: Obx(
                          // Wrap the whole column to react to isCityLoaded, isDefault etc.
                          () => Column(
                            children: [
                              // FROM
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 5.w),
                                      child: Text(
                                        "From",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.textColor1,
                                          fontSize: 10.spV2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      controller: controller.fromController,
                                      style: TextStyle(
                                        fontSize: 10.spV2,
                                        color: AppColor.secondaryColor1,
                                      ),
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColor.secondaryColor1,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColor.secondaryColor1,
                                          ),
                                        ),
                                        hintText: "Select from date",
                                        hintStyle: TextStyle(
                                          color: AppColor.secondaryColor2,
                                          fontSize: 9.spV2,
                                        ),
                                      ),
                                      readOnly: true,
                                      onTap: () {
                                        controller.selectFromDate();
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              // TO
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 5.w),
                                      child: Text(
                                        "To",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.textColor1,
                                          fontSize: 10.spV2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      controller: controller.toController,
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColor.secondaryColor1,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColor.secondaryColor1,
                                          ),
                                        ),
                                        hintText: "Select to date",
                                        hintStyle: TextStyle(
                                          fontSize: 9.spV2,
                                          color: AppColor.secondaryColor2,
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 10.spV2,
                                        color: AppColor.secondaryColor1,
                                      ),
                                      readOnly: true,
                                      onTap: () {
                                        if (controller
                                            .fromController.text.isEmpty) {
                                          // Keep same behaviour
                                          final ctx = Get.context;
                                          if (ctx != null) {
                                            showMyDialog(ctx,
                                                "Please select From date first!");
                                          }
                                        } else {
                                          controller.selectToDate();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              // NEAREST AIRPORT
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 5.w),
                                      child: Text(
                                        "Nearest Airport",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.textColor1,
                                          fontSize: 10.spV2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      controller: controller.nearestAirportController,
                                      minLines: 1,
                                      maxLines: null,
                                      style: TextStyle(
                                        fontSize: 10.spV2,
                                        color: AppColor.secondaryColor1,
                                      ),
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColor.secondaryColor1,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColor.secondaryColor1,
                                          ),
                                        ),
                                        hintText: "Select nearest airport",
                                        alignLabelWithHint: true,
                                        hintStyle: TextStyle(
                                          fontSize: 9.spV2,
                                          color: AppColor.secondaryColor2,
                                        ),
                                      ),
                                      readOnly: true,
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        controller.airportSearchController.clear();
                                        controller.searchAirports('');
                                        _showAirportDialog(context);
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              // Show calendar toggle
                              Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Show calendar to operators?",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.textColor1,
                                          fontSize: 9.5.spV2,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          Theme(
                                            data: ThemeData(
                                              unselectedWidgetColor:
                                                  AppColor.textColor1,
                                            ),
                                            child: Checkbox(
                                              checkColor: AppColor.textColor2,
                                              activeColor:
                                                  AppColor.secondaryColor1,
                                              value: controller.isDefault.value,
                                              onChanged: (value) {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                controller.setShowCalendar(true);
                                              },
                                            ),
                                          ),
                                          Text(
                                            "Yes",
                                            style: TextStyle(
                                              fontSize: 10.spV2,
                                              color: AppColor.textColor1,
                                            ),
                                          ),
                                          SizedBox(width: 2.w),
                                          Theme(
                                            data: ThemeData(
                                              unselectedWidgetColor:
                                                  AppColor.textColor1,
                                            ),
                                            child: Checkbox(
                                              checkColor: AppColor.textColor2,
                                              activeColor:
                                                  AppColor.secondaryColor1,
                                              value: !controller.isDefault.value,
                                              onChanged: (value) {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                controller.setShowCalendar(false);
                                              },
                                            ),
                                          ),
                                          Text(
                                            "No",
                                            style: TextStyle(
                                              fontSize: 10.spV2,
                                              color: AppColor.textColor1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // COMMENT
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 5.w),
                                      child: Text(
                                        "Comment",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.textColor1,
                                          fontSize: 10.spV2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      margin: EdgeInsets.only(top: 4.0.h),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColor.secondaryColor1,
                                          width: 1.0,
                                          style: BorderStyle.solid,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10.sp),
                                      ),
                                      padding: EdgeInsets.only(
                                        left: 2.0.w,
                                        right: 2.0.w,
                                      ),
                                      child: TextField(
                                        controller:
                                            controller.commentController,
                                        cursorColor: AppColor.secondaryColor1,
                                        style: TextStyle(
                                          fontSize: 10.spV2,
                                          color: AppColor.secondaryColor1,
                                        ),
                                        minLines: 4,
                                        maxLines: 5,
                                        spellCheckConfiguration:
                                            SpellCheckConfiguration(
                                          misspelledTextStyle: TextStyle(
                                            decorationStyle:
                                                TextDecorationStyle.wavy,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                AppColor.deleteColor,
                                          ),
                                          spellCheckService:
                                              DefaultSpellCheckService(),
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 4.h),

                              // SUBMIT BUTTON
                              SizedBox(
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
                                  onPressed: () {
                                    controller.submit();
                                  },
                                  child: Text(
                                    "SUBMIT",
                                    style: TextStyle(fontSize: 10.spV2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  void _showAirportDialog(BuildContext context) {
    final ScrollController resultsScrollController = ScrollController();
    final Future<void> dialogFuture = showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Theme(
          data: ThemeData.dark(),
          child: AlertDialog(
            insetPadding: EdgeInsets.zero,
            title: Text(
              "Select Nearest Airport",
              style: TextStyle(color: AppColor.secondaryColor1, fontSize: 13.0.spV2),
            ),
            content: SizedBox(
              height: 90.h,
              width: 75.0.w,
              child: Column(
                children: [
                  SizedBox(
                    height: 6.h,
                    child: TextField(
                      controller: controller.airportSearchController,
                      onChanged: (text) {
                        controller.searchAirports(text);
                        if (resultsScrollController.hasClients) {
                          resultsScrollController.jumpTo(0);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Search",
                        contentPadding: const EdgeInsets.all(5),
                        prefixIcon: Icon(Icons.search, color: AppColor.secondaryColor1),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: AppColor.secondaryColor1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: AppColor.secondaryColor1),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () => ListView.separated(
                            controller: resultsScrollController,
                            itemCount: controller.airportResults.length,
                            separatorBuilder: (_, __) => Divider(
                              indent: 10,
                              endIndent: 10,
                              thickness: 1,
                              color: AppColor.textColor1,
                            ),
                            itemBuilder: (context, index) {
                              final airport = controller.airportResults[index];
                              return ListTile(
                                dense: true,
                                title: AirportSearchUi.buildAirportResultTitle(
                                  airport: airport,
                                  query: controller.airportSearchController.text,
                                ),
                                subtitle: Text(
                                  AirportSearchUi.airportMatchesSearchSummary(
                                    airport,
                                    controller.airportSearchController.text,
                                  ),
                                  style: TextStyle(
                                    color: AppColor.secondaryColor2,
                                    fontSize: 8.5.spV2,
                                  ),
                                ),
                                onTap: () {
                                  controller.selectedAirport.value = airport;
                                  controller.nearestAirportController.text =
                                      '${airport.ident} ${airport.name}, ${airport.municipality}, ${airport.region}';
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              MaterialButton(
                textColor: AppColor.textColor2,
                color: AppColor.secondaryColor1,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  controller.airportSearchController.clear();
                },
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
    dialogFuture.whenComplete(() {
      resultsScrollController.dispose();
    });
  }
}