import 'package:crew_support/widgets/airport/airport_search_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'add_availability_controller.dart';

class AddAvailabilityScreen extends GetView<AddAvailabilityController> {

  const AddAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // SizerUtil().toString(); // not needed with GetView; Sizer is initialized at app-level
    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.adaptive.arrow_back_rounded, color: AppColor.secondaryColor1),
        ),
        title: Text("Select Availability", style: TextStyle(color: AppColor.secondaryColor1)),
        backgroundColor: AppColor.bgColor1,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Keep the same loading look; if you used loading_animation_widget, you can keep it here too.
                SizedBox(height: 2.h),
                Text('Loading...', style: TextStyle(color: AppColor.textColor1, fontSize: 10.spV2)),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _rowField(
                label: "From",
                child: TextFormField(
                  controller: controller.fromController,
                  style: TextStyle(fontSize: 10.spV2, color: AppColor.secondaryColor1),
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColor.secondaryColor1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColor.secondaryColor1),
                    ),
                    hintText: "Select from date",
                    hintStyle: TextStyle(color: AppColor.secondaryColor2, fontSize: 9.spV2),
                  ),
                  readOnly: true,
                  onTap: controller.selectFromDate,
                ),
              ),

              _rowField(
                label: "To",
                child: TextFormField(
                  controller: controller.toController,
                  style: TextStyle(fontSize: 10.spV2, color: AppColor.secondaryColor1),
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColor.secondaryColor1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColor.secondaryColor1),
                    ),
                    hintText: "Select to date",
                    hintStyle: TextStyle(color: AppColor.secondaryColor2, fontSize: 9.spV2),
                  ),
                  readOnly: true,
                  onTap: controller.selectToDate,
                ),
              ),

              _rowField(
                label: "Nearest Airport",
                child: TextFormField(
                  controller: controller.nearestAirportController,
                  minLines: 1,
                  maxLines: null,
                  style: TextStyle(fontSize: 10.spV2, color: AppColor.secondaryColor1),
                  readOnly: true,
                  onTap: () {
                    controller.airportSearchController.clear();
                    controller.searchAirports('');
                    _showAirportDialog(context);
                  },
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColor.secondaryColor1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColor.secondaryColor1),
                    ),
                    hintText: " Select nearest airport",
                    alignLabelWithHint: true,
                    hintStyle: TextStyle(fontSize: 9.spV2, color: AppColor.secondaryColor2),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Show calendar to operators?",
                        style: TextStyle(color: AppColor.textColor1, fontWeight: FontWeight.w500, fontSize: 9.5.spV2),
                      ),
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
                                  value: controller.showCalendar.value,
                                  onChanged: (v) {
                                    FocusScope.of(context).unfocus();
                                    controller.showCalendar.value = true;
                                  },
                                ),
                              ),
                              Text("Yes", style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1)),
                              const SizedBox(width: 20),
                              Theme(
                                data: ThemeData(unselectedWidgetColor: AppColor.textColor1),
                                child: Checkbox(
                                  checkColor: AppColor.textColor2,
                                  activeColor: AppColor.secondaryColor1,
                                  value: !controller.showCalendar.value,
                                  onChanged: (v) {
                                    FocusScope.of(context).unfocus();
                                    controller.showCalendar.value = false;
                                  },
                                ),
                              ),
                              Text("No", style: TextStyle(fontSize: 10.spV2, color: AppColor.textColor1)),
                            ],
                          )),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Comment",
                        style: TextStyle(color: AppColor.textColor1, fontWeight: FontWeight.w500, fontSize: 10.spV2),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: EdgeInsets.only(top: 4.0.h, left: 5, right: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColor.secondaryColor1, width: 1.0, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(10.spV2),
                        ),
                        padding: EdgeInsets.only(left: 2.0.w, right: 2.0.w),
                        child: TextField(
                          controller: controller.commentController,
                          cursorColor: AppColor.secondaryColor1,
                          style: TextStyle(fontSize: 10.spV2, color: AppColor.secondaryColor1),
                          minLines: 4,
                          maxLines: 5,
                          decoration: const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 4.h),

              SizedBox(
                width: 85.w,
                child: Obx(() => MaterialButton(
                      disabledColor: AppColor.secondaryColor1,
                      disabledTextColor: AppColor.textColor2,
                      textColor: AppColor.textColor2,
                      color: AppColor.secondaryColor1,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      onPressed: controller.stopClicking.value ? null : controller.onSubmit,
                      child: Text("SUBMIT", style: TextStyle(fontSize: 10.spV2)),
                    )),
              ),

              SizedBox(height: 2.h),
            ],
          ),
        );
      }),
    );
  }

  // --------------------------------
  // Reusable row layout (matches legacy spacing exactly)
  // --------------------------------
  Widget _rowField({required String label, required Widget child}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.only(left: 5.w),
            child: Text(
              label,
              style: TextStyle(color: AppColor.textColor1, fontWeight: FontWeight.w500, fontSize: 10.spV2),
            ),
          ),
        ),
        Expanded(flex: 3, child: child),
      ],
    );
  }

  // ---------------------------
  // Airport selection dialog
  // ---------------------------

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
            title: Text("Select Nearest Airport", style: TextStyle(color: AppColor.secondaryColor1, fontSize: 13.0.spV2)),
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
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(() => ListView.separated(
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
                                controller.nearestAirportController.text = '${airport.ident} ${airport.name}, ${airport.municipality}, ${airport.region}';
                                Navigator.pop(context);
                              },
                            );
                          },
                        )),
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