import 'dart:async';
import 'package:crew_support/database/airport_code_model.dart';
import 'package:crew_support/features/trip/create_direct_trip_controller.dart';
import 'package:crew_support/model/AircraftModel.dart';
import 'package:crew_support/widgets/airport/airport_search_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/AppColor.dart'; // <- NEW import for colors
import 'package:intl/intl.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart'; // <- NEW import for spV2
import 'package:crew_support/utils/Utility.dart' show showLoadingDialog, showMyDialog;

enum _ExitChoice { exitWithoutSaving, cancel }

class CreateDirectTripScreen extends GetWidget<CreateDirectTripController> {
  const CreateDirectTripScreen({super.key});
  Future<bool> _confirmExitIfUnsaved(BuildContext context) async {

    // If coming from Drafts tab, no need to confirm exit since changes are already saved as a draft.
    if (controller.isFromDraftTab) return true;

    // If trip already exists on server (draft saved / trip created), allow exit without prompting.
    final hasServerTrip = (controller.draft.tripObjectId ?? '').trim().isNotEmpty;
    if (hasServerTrip) return true;

    final choice = await showCupertinoDialog<_ExitChoice>(
      context: context,
      builder: (_) => Theme(
        data: ThemeData.dark(),
        child: CupertinoAlertDialog(
          title: Text('Unsaved Trip'),
          content: Text('Are you sure you want to exit?'),
          actions: [
            // CupertinoDialogAction(
            //   isDefaultAction: true,
            //   onPressed: () => Navigator.of(context).pop(_ExitChoice.saveAndExit),
            //   child: Text('Save & Exit', style: TextStyle(color: AppColor.secondaryColor1)),
            // ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(_ExitChoice.exitWithoutSaving),
              child: Text('Exit'),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(_ExitChoice.cancel),
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );

    final resolved = choice ?? _ExitChoice.cancel;

    if (resolved == _ExitChoice.cancel) return false;

    if (resolved == _ExitChoice.exitWithoutSaving) return true;

    // Save & Exit
    try {
      // Basic validations before saving a draft
      if (controller.startDateController.text.isEmpty) {
        await showMyDialog(context, "Please select start date");
        return false;
      }
      if (controller.endDateController.text.isEmpty) {
        await showMyDialog(context, "Please select end date");
        return false;
      }
      if (controller.tripNameController.text.isEmpty) {
        await showMyDialog(context, "Please enter trip name");
        return false;
      }
      if (controller.departAirportCodeController.text.isEmpty) {
        await showMyDialog(context, "Please select departure airport code");
        return false;
      }
      if (controller.destAirportCodeController.text.isEmpty) {
        await showMyDialog(context, "Please select destination airport code");
        return false;
      }
      if (controller.aircraftTypeController.text.isEmpty) {
        await showMyDialog(context, "Please select aircraft type");
        return false;
      }

      await controller.saveDraft(ctx: context, showSuccessDialog: false);
      return true;
    } catch (_) {
      // If save failed, stay on screen.
      return false;
    }
  }

  // --------------------------
  // Small helpers for Cupertino date pickers
  // --------------------------
  Future<void> _pickStartDate(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2050),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColor.secondaryColor1,
              onPrimary: AppColor.textColor1,
              onSurface: AppColor.textColor1,
              surface: AppColor.bgColor2,
              background: AppColor.bgColor2,
            ),
            dialogBackgroundColor: AppColor.bgColor2,
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      controller.setStartDate(pickedDate);
    }
  }

  Future<void> _pickEndDate(BuildContext context) async {
    // The earliest allowed End Date should be the selected Start Date.
    final firstAllowedDate = controller.currentDate.value;

    // When editing End Date, initially highlight the already selected End Date
    // instead of jumping back to Start Date.
    DateTime initialEndDate = firstAllowedDate;
    final endDateText = controller.endDateController.text.trim();
    if (endDateText.isNotEmpty) {
      try {
        final parsedEndDate = DateFormat('MM/dd/yyyy').parseStrict(endDateText);
        if (!parsedEndDate.isBefore(firstAllowedDate)) {
          initialEndDate = parsedEndDate;
        }
      } catch (_) {
        // Keep Start Date as a safe fallback if the saved End Date text is malformed.
      }
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialEndDate,
      firstDate: firstAllowedDate,
      lastDate: DateTime(2050),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColor.secondaryColor1,
              onPrimary: AppColor.textColor1,
              onSurface: AppColor.textColor1,
              surface: AppColor.bgColor2,
              background: AppColor.bgColor2,
            ),
            dialogBackgroundColor: AppColor.bgColor2,
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      controller.setEndDate(pickedDate);
    }
  }

  // --------------------------
  // Cupertino radius picker (new version)
  // --------------------------
  // void _showRadiusPicker(BuildContext context) {
  //   final options = <String>[
  //     '<10 miles',
  //     '<50 miles',
  //     '<100 miles',
  //     '<150 miles',
  //     '<200 miles',
  //     'Any distance',
  //   ];

  //   int initialIndex = 0;
  //   final currentText = controller.radiusController.text.trim();
  //   final idx = options.indexOf(currentText);
  //   if (idx >= 0) {
  //     initialIndex = idx;
  //   }

  //   showCupertinoModalPopup(
  //     context: context,
  //     builder: (_) => Container(
  //       color: AppColor.bgColor1,
  //       height: 260,
  //       child: Column(
  //         children: [
  //           Container(
  //             color: AppColor.bgColor2,
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 CupertinoButton(
  //                   child: Text("Cancel", style: TextStyle(color: AppColor.secondaryColor1)),
  //                   onPressed: () => Navigator.pop(context),
  //                 ),
  //                 CupertinoButton(
  //                   child: Text("Done", style: TextStyle(color: AppColor.secondaryColor1)),
  //                   onPressed: () => Navigator.pop(context),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Expanded(
  //             child: CupertinoPicker(
  //               itemExtent: 40,
  //               scrollController: FixedExtentScrollController(initialItem: initialIndex),
  //               onSelectedItemChanged: (i) {
  //                 controller.setRadiusDisplayAndValue(options[i]);
  //               },
  //               children: options
  //                   .map((e) => Center(
  //                         child: Text(
  //                           e,
  //                           style: TextStyle(color: AppColor.textColor1, fontSize: 10.spV2),
  //                         ),
  //                       ))
  //                   .toList(),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _showDepartureDialog(BuildContext context) {
    // Persist local dialog state across setState calls inside StatefulBuilder
    final ScrollController resultsScrollController = ScrollController();
    List<AirportLite> tempList = [];
    bool isLoading = true;
    bool didInit = false;
    String searchText = '';

    final Future<AirportLite?> dialogFuture = showDialog<AirportLite>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            if (!didInit) {
              didInit = true;
              () async {
                final initial = await AirportCache.instance.searchByIdent('');
                setState(() {
                  tempList = initial;
                  isLoading = false;
                });
              }();
            }
            return Dialog(
            backgroundColor: AppColor.bgColor2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            child: SizedBox(
              height: 60.h, // fixed height avoids intrinsic dimension calc
              width: 90.w,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.w),
                    child: Text(
                      "Select Departure Code",
                      style: TextStyle(
                        color: AppColor.secondaryColor1,
                        fontSize: 13.0.spV2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: SizedBox(
                      height: 6.h,
                      child: TextField(
                        autocorrect: false,
                        enableSuggestions: false,
                        style: TextStyle(
                          color: AppColor.textColor1,
                          fontSize: 10.spV2,
                        ),
                        onChanged: (text) async {
                          searchText = text;
                          final results = await AirportCache.instance.searchByIdent(text);
                          setState(() => tempList = results);
                          if (resultsScrollController.hasClients) {
                            resultsScrollController.jumpTo(0);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyle(
                            color: AppColor.secondaryColor2,
                            fontSize: 9.spV2,
                          ),
                          contentPadding: EdgeInsets.all(5),
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
                  ),
                  SizedBox(height: 2.h),
                  Divider(color: AppColor.secondaryColor1, height: 1),
                  Expanded(
                    child: isLoading
                        ? Center(child: CupertinoActivityIndicator())
                        : ListView.builder(
                            controller: resultsScrollController,
                            shrinkWrap: true, // important inside Dialogs
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: tempList.length,
                            itemBuilder: (_, i) {
                              final airport = tempList[i];
                              return Column(
                                children: [
                                  ListTile(
                                    dense: true,
                                    title: AirportSearchUi.buildAirportResultTitle(
                                      airport: airport,
                                      query: searchText,
                                      showFullDetails: true,
                                    ),
                                    subtitle: searchText.trim().isEmpty
                                        ? null
                                        : Text(
                                            AirportSearchUi.airportMatchesSearchSummary(
                                              airport,
                                              searchText,
                                            ),
                                            style: TextStyle(
                                              color: AppColor.secondaryColor2,
                                              fontSize: 8.5.spV2,
                                            ),
                                          ),
                                    onTap: () {
                                      Navigator.pop(context, airport);
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel", style: TextStyle(fontSize: 10.spV2)),
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
    dialogFuture.then((selectedAirport) {
      if (selectedAirport != null) {
        controller.setDepartureAirport(selectedAirport);
      }
    }).whenComplete(() {
      resultsScrollController.dispose();
    });
  }

  void _showEnrouteDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final ScrollController resultsScrollController = ScrollController();
    List<AirportLite> tempList = [];
    bool isLoading = true;
    bool didInit = false;

    // Local staged selection so Cancel can discard changes.
    final Map<int, AirportLite> stagedSelectionById = <int, AirportLite>{};
    bool didInitSelection = false;

    final Future<void> dialogFuture = showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) {
          if (!didInit) {
            didInit = true;
            () async {
              final initial = await AirportCache.instance.searchByIdent('');
              setState(() {
                tempList = initial;
                isLoading = false;
              });
            }();
          }

          // Initialize staged selection from controller only once.
          if (!didInitSelection) {
            didInitSelection = true;
            stagedSelectionById
              ..clear()
              ..addAll(controller.selectedEnrouteById);
          }

          return Dialog(
            backgroundColor: AppColor.bgColor2,
            child: SizedBox(
              height: 70.h,
              width: 90.w,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Text(
                      "Select Enroute Airports (${stagedSelectionById.length})",
                      style: TextStyle(
                        color: AppColor.textColor1,
                        fontSize: 11.spV2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: SizedBox(
                      height: 6.h,
                      child: TextField(
                        controller: searchController,
                        autocorrect: false,
                        enableSuggestions: false,
                        style: TextStyle(color: AppColor.textColor1, fontSize: 10.spV2),
                        onChanged: (text) async {
                          final results = await AirportCache.instance.searchByIdent(text);
                          setState(() => tempList = results);
                          if (resultsScrollController.hasClients) {
                            resultsScrollController.jumpTo(0);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyle(color: AppColor.secondaryColor2, fontSize: 9.spV2),
                          contentPadding: EdgeInsets.all(5),
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
                  ),
                  Divider(color: AppColor.secondaryColor1, height: 1),
                  Expanded(
                    child: isLoading
                        ? Center(child: CupertinoActivityIndicator())
                        : Builder(
                            builder: (_) {
                              // Split list into two sections: Selected (pinned) and Others.
                              // IMPORTANT: Selected must come from the stagedSelectionById itself,
                              // not from tempList (which is just the current search result).
                              final String query = searchController.text.trim().toLowerCase();

                              // Always show all selected when query is empty.
                              // If query is not empty, show only the selected items that match the same
                              // fields used by local airport search: ident, name, municipality, or region.
                              final List<AirportLite> selectedList = stagedSelectionById.values
                                  .where((a) {
                                    if (query.isEmpty) return true;
                                    return a.ident.toLowerCase().startsWith(query) ||
                                        // NOTE: Name-based matching disabled to stay consistent with search layer
                                        // a.name.toLowerCase().contains(query) ||
                                        a.municipality.toLowerCase().contains(query) ||
                                        a.region.toLowerCase().contains(query);
                                  })
                                  .toList();

                              // "Others" are the current tempList results excluding any already-selected airport.
                              final List<AirportLite> otherList = tempList
                                  .where((a) => !stagedSelectionById.containsKey(a.sourceId))
                                  .toList();

                              // Stable keys so AnimatedSwitcher can animate when selection/search changes
                              final String selectedKey = selectedList.map((e) => e.sourceId).join(',');
                              final String otherKey = otherList.map((e) => e.sourceId).join(',');

                              Widget buildSectionHeader(String title) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      color: AppColor.secondaryColor2,
                                      fontSize: 9.spV2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }

                              Widget buildCheckboxTile(AirportLite airport) {
                                final bool selected = stagedSelectionById.containsKey(airport.sourceId);

                                // Key includes selected-state so AnimatedSwitcher can animate the swap
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  switchInCurve: Curves.easeOut,
                                  switchOutCurve: Curves.easeIn,
                                  transitionBuilder: (child, anim) {
                                    final slide = Tween<Offset>(
                                      begin: const Offset(0, 0.03),
                                      end: Offset.zero,
                                    ).animate(anim);
                                    return FadeTransition(
                                      opacity: anim,
                                      child: SlideTransition(position: slide, child: child),
                                    );
                                  },
                                  child: CheckboxListTile(
                                    key: ValueKey('enroute_${airport.sourceId}_${selected ? 'sel' : 'oth'}'),
                                    value: selected,
                                    side: BorderSide(
                                      color: AppColor.secondaryColor2,
                                      width: 1.2,
                                    ),
                                    fillColor: MaterialStateProperty.resolveWith<Color?>(
                                      (states) {
                                        if (states.contains(MaterialState.selected)) {
                                          return AppColor.secondaryColor1;
                                        }
                                        return Colors.transparent;
                                      },
                                    ),
                                    controlAffinity: ListTileControlAffinity.leading,
                                    onChanged: (_) {
                                      if (stagedSelectionById.containsKey(airport.sourceId)) {
                                        stagedSelectionById.remove(airport.sourceId);
                                      } else {
                                        stagedSelectionById[airport.sourceId] = airport;
                                      }
                                      setState(() {}); // refresh dialog UI
                                    },
                                    title: AirportSearchUi.buildAirportResultTitle(
                                      airport: airport,
                                      query: searchController.text,
                                      showFullDetails: true,
                                    ),
                                    subtitle: searchController.text.trim().isEmpty
                                      ? null
                                      : Text(
                                          AirportSearchUi.airportMatchesSearchSummary(
                                            airport,
                                            searchController.text,
                                          ),
                                          style: TextStyle(
                                            color: AppColor.secondaryColor2,
                                            fontSize: 8.5.spV2,
                                          ),
                                        ),
                                    activeColor: AppColor.secondaryColor1,
                                    checkColor: AppColor.textColor2,
                                  ),
                                );
                              }

                              // Animate the "movement" by switching the entire list with a subtle fade/slide.
                              // This feels smooth without introducing extra packages.
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                transitionBuilder: (child, anim) {
                                  final slide = Tween<Offset>(
                                    begin: const Offset(0, 0.02),
                                    end: Offset.zero,
                                  ).animate(anim);
                                  return FadeTransition(
                                    opacity: anim,
                                    child: SlideTransition(position: slide, child: child),
                                  );
                                },
                                child: ListView(
                                  controller: resultsScrollController,
                                  key: ValueKey('enroute_list_$selectedKey|$otherKey'),
                                  shrinkWrap: true,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    if (selectedList.isNotEmpty) ...[
                                      buildSectionHeader('Selected'),
                                      ...selectedList.map(buildCheckboxTile),

                                      // Show divider only if both sections exist
                                      if (otherList.isNotEmpty)
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
                                          child: Divider(
                                            height: 1,
                                            thickness: 0.8,
                                            color: AppColor.secondaryColor2.withOpacity(0.35),
                                          ),
                                        ),
                                    ],

                                    if (otherList.isNotEmpty) ...[
                                      buildSectionHeader('Others'),
                                      ...otherList.map(buildCheckboxTile),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MaterialButton(
                            textColor: AppColor.textColor2,
                            color: AppColor.secondaryColor1,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
                              borderRadius: BorderRadius.circular(2.w),
                            ),
                            onPressed: () {
                              // searchController.clear();
                              Navigator.pop(context);
                            },
                            child: Text("Cancel", style: TextStyle(fontSize: 10.spV2)),
                          ),
                          CupertinoButton.filled(
                            child: Text("Done", style: TextStyle(fontSize: 10.spV2)),
                            onPressed: () {
                              controller.setEnrouteSelection(stagedSelectionById);
                              Navigator.pop(context);
                              // (refresh will now be handled after dialog is fully dismissed)
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    dialogFuture.then((_) {
      // Ensure the underlying field refreshes after the dialog is fully dismissed.
      // Using a post-frame callback is more reliable than calling update immediately,
      // because the route dismissal animation can delay repaint until the next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.update(['depDestEnroute']);
      });
    }).whenComplete(() {
      searchController.dispose();
      resultsScrollController.dispose();
    });
  }

  void _showDestinationDialog(BuildContext context) {
    final ScrollController resultsScrollController = ScrollController();
    List<AirportLite> tempList = [];
    bool isLoading = true;
    bool didInit = false;
    String searchText = '';

    final Future<AirportLite?> dialogFuture = showDialog<AirportLite>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) {
          if (!didInit) {
            didInit = true;
            () async {
              final initial = await AirportCache.instance.searchByIdent('');
              setState(() {
                tempList = initial;
                isLoading = false;
              });
            }();
          }
          return Dialog(
            backgroundColor: AppColor.bgColor2,
            child: SizedBox(
              height: 60.h,
              width: 90.w,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Text("Select Destination Code",
                        style: TextStyle(color: AppColor.textColor1, fontSize: 11.spV2, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: SizedBox(
                      height: 6.h,
                      child: TextField(
                        autocorrect: false,
                        enableSuggestions: false,
                        style: TextStyle(color: AppColor.textColor1, fontSize: 10.spV2),
                        onChanged: (text) async {
                          searchText = text;
                          final results = await AirportCache.instance.searchByIdent(text);
                          setState(() => tempList = results);
                          if (resultsScrollController.hasClients) {
                            resultsScrollController.jumpTo(0);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyle(color: AppColor.secondaryColor2, fontSize: 9.spV2),
                          contentPadding: EdgeInsets.all(5),
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
                  ),
                  Divider(color: AppColor.secondaryColor1, height: 1),
                  Expanded(
                    child: isLoading
                        ? Center(child: CupertinoActivityIndicator())
                        : ListView.builder(
                            controller: resultsScrollController,
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: tempList.length,
                            itemBuilder: (_, i) {
                              final airport = tempList[i];
                              return Column(
                                children: [
                                  ListTile(
                                    dense: true,
                                    title: AirportSearchUi.buildAirportResultTitle(
                                      airport: airport,
                                      query: searchText,
                                      showFullDetails: true,
                                    ),
                                    subtitle: searchText.trim().isEmpty
                                        ? null
                                        : Text(
                                            AirportSearchUi.airportMatchesSearchSummary(
                                              airport,
                                              searchText,
                                            ),
                                            style: TextStyle(
                                              color: AppColor.secondaryColor2,
                                              fontSize: 8.5.spV2,
                                            ),
                                          ),
                                    onTap: () {
                                      Navigator.pop(context, airport);
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel", style: TextStyle(fontSize: 10.spV2)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } ),
    );
    dialogFuture.then((selectedAirport) {
      if (selectedAirport != null) {
        controller.setDestinationAirport(selectedAirport);
      }
    }).whenComplete(() {
      resultsScrollController.dispose();
    });
  }

  void _showAircraftPicker(BuildContext context) {
    // Local dialog state (avoids GetBuilder/controller instance mismatch)
    final TextEditingController searchController = TextEditingController();
    List<AircraftTypeList> tempList = List<AircraftTypeList>.from(aircraftTypeList);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                        "Select Aircraft",
                        style: TextStyle(
                          color: AppColor.secondaryColor1,
                          fontSize: 13.spV2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Search (underline style)
                    Padding(
                      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.w),
                      child: TextField(
                        controller: searchController,
                        style: TextStyle(
                          color: AppColor.textColor1,
                          fontSize: 10.spV2,
                          fontWeight: FontWeight.w600,
                        ),
                        onChanged: (text) {
                          setState(() {
                            final q = text.trim().toLowerCase();
                            if (q.isEmpty) {
                              tempList = List<AircraftTypeList>.from(aircraftTypeList);
                            } else {
                              tempList = aircraftTypeList
                                  .where((e) => e.name.toLowerCase().contains(q))
                                  .toList();
                            }
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search Aircraft",
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

                    // Divider
                    Divider(color: AppColor.secondaryColor1, height: 1),

                    // List
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: tempList.length,
                        itemBuilder: (_, i) {
                          final item = tempList[i];
                          return Column(
                            children: [
                              ListTile(
                                dense: true,
                                title: Text(
                                  item.name,
                                  style: TextStyle(
                                    color: AppColor.textColor1,
                                    fontSize: 10.spV2,
                                  ),
                                ),
                                onTap: () {
                                  controller.aircraftTypeController.text = item.name;
                                  controller.aircraftID = item.id; // preserve ID like legacy
                                  Navigator.pop(context);
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

                    // Cancel button
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
                          onPressed: () {
                            searchController.clear();
                            Navigator.pop(context);
                          },
                          child: Text("Cancel", style: TextStyle(fontSize: 10.spV2)),
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
  }

  // --------------------------
  // Navigate to SearchBy* as in legacy "Update" flow when trip is out of date
  // --------------------------
  void _navigateToRoleSearchScreens(BuildContext context) {
    final first = controller.firstTrip;
    if (first == null) {
      Navigator.of(context).pop(); // safety
      return;
    }

    // Only single-role quick switch preserved precisely (based on your legacy code block)
    if (controller.selectList.length == 1) {
      if (controller.selectList.contains('Captain')) {
        
      } else if (controller.selectList.contains('Second In Command')) {
        
      } else if (controller.selectList.contains('Flight Attendant')) {
        
      } else if (controller.selectList.contains('Flight Instructor') ||
          controller.selectList.contains('Instructor')) {
        
      } else {
        Navigator.of(context).pop();
      }
    } else {
      // Multiple roles: keep default behavior (close or customize as needed)
      Navigator.of(context).pop();
    }
  }

  // --------------------------
  // Build
  // --------------------------
  @override
  Widget build(BuildContext context) {
    // Show the info-only popup once when trip is out-of-date (legacy behavior)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.shouldShowOutdatedInfoOnce) {
        controller.markOutdatedInfoShown();
        showCupertinoDialog(
          context: context,
          builder: (_) => Theme(
            data: ThemeData.dark(),
            child: CupertinoAlertDialog(
              content: Text('You can only edit Start Date and End Date.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Ok', style: TextStyle(color: AppColor.secondaryColor1)),
                ),
              ],
            ),
          ),
        );
      }
    });

    return WillPopScope(
      onWillPop: () => _confirmExitIfUnsaved(context),
      child: Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            final ok = await _confirmExitIfUnsaved(context);
            if (ok) Get.back(); // Just go back to previous screen (which is either dashboard or search results depending on how user got here)
            // if (ok) Get.find<DashboardController>().goBackToDashboardAndReloadTrips(); //Go back to dashboard and reload trips to reflect any changes (especially important if user came from "Update" flow where trip is out of date)
          },
          icon: Icon(Icons.adaptive.arrow_back_rounded, color: AppColor.secondaryColor1),
        ),
        elevation: 0,
        title: Obx(
          () => Text(
            controller.isTripOutOfDate.value ? "Update Trip" : "Create Direct Trip",
            style: TextStyle(color: AppColor.secondaryColor1, fontSize: 11.spV2, fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: AppColor.bgColor1,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Obx(
            () => controller.isLoading.value
                ? Center(child: CupertinoActivityIndicator())
                : Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            // Trip Name
                            _rowTwoCol(
                              left: "Trip Name",
                              rightChild: TextFormField(
                                controller: controller.tripNameController,
                                textCapitalization: TextCapitalization.words,
                                readOnly: controller.isTripOutOfDate.value,
                                style: TextStyle(
                                  fontSize: 10.spV2,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.secondaryColor1,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Enter Name",
                                  hintStyle: TextStyle(
                                    fontSize: 9.spV2,
                                    color: AppColor.secondaryColor2,
                                  ),
                                ),
                              ),
                            ),
                            _divider(),

                            // Departure
                            _rowTwoCol(
                              left: "Departure Airport Code",
                              rightChild: TextFormField(
                                controller: controller.departAirportCodeController,
                                style: TextStyle(
                                  fontSize: 10.spV2,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.secondaryColor1,
                                ),
                                readOnly: true,
                                onTap: controller.isTripOutOfDate.value
                                    ? null
                                    : () => _showDepartureDialog(context),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Select Code",
                                  hintStyle: TextStyle(
                                    fontSize: 9.spV2,
                                    color: AppColor.secondaryColor2,
                                  ),
                                ),
                              ),
                            ),
                            _divider(),

                            // Enroute
                            _rowTwoCol(
                              left: "Enroute Airports",
                              rightChild: Obx(() {
                                final codes = controller.airportCodeChecked
                                    .where((e) => e.trim().isNotEmpty)
                                    .toList();

                                final txt = codes.isNotEmpty ? codes.join(",") : "Enter Enroute Airport";
                                final isPlaceholder = codes.isEmpty;

                                return GestureDetector(
                                  onTap: controller.isTripOutOfDate.value ? null : () => _showEnrouteDialog(context),
                                  child: Text(
                                    txt,
                                    style: TextStyle(
                                      fontSize: isPlaceholder ? 9.spV2 : 10.spV2,
                                      fontWeight: isPlaceholder ? FontWeight.w400 : FontWeight.bold,
                                      color: isPlaceholder ? AppColor.secondaryColor2 : AppColor.secondaryColor1,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            _divider(),

                            // Destination
                            _rowTwoCol(
                              left: "Destination Airport Code",
                              rightChild: TextFormField(
                                controller: controller.destAirportCodeController,
                                style: TextStyle(
                                  fontSize: 10.spV2,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.secondaryColor1,
                                ),
                                readOnly: true,
                                onTap: controller.isTripOutOfDate.value
                                    ? null
                                    : () => _showDestinationDialog(context),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Select Code",
                                  hintStyle: TextStyle(
                                    fontSize: 9.spV2,
                                    color: AppColor.secondaryColor2,
                                  ),
                                ),
                              ),
                            ),
                            _divider(),

                            // Start Date
                            _rowTwoCol(
                              left: "Start Date",
                              rightChild: GetBuilder<CreateDirectTripController>(
                                id: 'dates',
                                builder: (_) => TextFormField(
                                  controller: controller.startDateController,
                                  style: TextStyle(
                                    fontSize: 10.spV2,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.secondaryColor1,
                                  ),
                                  readOnly: true,
                                  onTap: () {
                                    controller.endDateController.clear();
                                    _pickStartDate(context);
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Select Start Date",
                                    hintStyle: TextStyle(
                                      fontSize: 9.spV2,
                                      color: AppColor.secondaryColor2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            _divider(),

                            // End Date
                            _rowTwoCol(
                              left: "End Date",
                              rightChild: GetBuilder<CreateDirectTripController>(
                                id: 'dates',
                                builder: (_) => TextFormField(
                                  controller: controller.endDateController,
                                  style: TextStyle(
                                    fontSize: 10.spV2,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.secondaryColor1,
                                  ),
                                  readOnly: true,
                                  onTap: () {
                                    if (controller.startDateController.text.isEmpty) {
                                      showMyDialog(context, "Please select Start date first!");
                                    } else {
                                      _pickEndDate(context);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Select End Date",
                                    hintStyle: TextStyle(
                                      fontSize: 9.spV2,
                                      color: AppColor.secondaryColor2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            _divider(),

                            // Pilot Role Selector (only for pilot profiles)
                            if (controller.shouldShowPilotRoleSelector) ...[
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 5.w),
                                      child: Text(
                                        'Select Role',
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
                                    child: Obx(
                                      () {
                                        final bool isCaptain =
                                            controller.selectedPilotTripRole.value == 'Captain';
                                        final bool isSic =
                                            controller.selectedPilotTripRole.value == 'SIC';

                                        return Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                onTap: () => controller.setSelectedPilotTripRole('Captain'),
                                                child: Row(
                                                  children: [
                                                    Theme(
                                                      data: ThemeData(
                                                        unselectedWidgetColor: AppColor.textColor1,
                                                      ),
                                                      child: Checkbox(
                                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                        activeColor: AppColor.secondaryColor1,
                                                        checkColor: AppColor.textColor2,
                                                        value: isCaptain,
                                                        onChanged: (_) =>
                                                            controller.setSelectedPilotTripRole('Captain'),
                                                      ),
                                                    ),
                                                    Text(
                                                      'Captain',
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
                                            Expanded(
                                              child: GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                onTap: () => controller.setSelectedPilotTripRole('SIC'),
                                                child: Row(
                                                  children: [
                                                    Theme(
                                                      data: ThemeData(
                                                        unselectedWidgetColor: AppColor.textColor1,
                                                      ),
                                                      child: Checkbox(
                                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                        activeColor: AppColor.secondaryColor1,
                                                        checkColor: AppColor.textColor2,
                                                        value: isSic,
                                                        onChanged: (_) =>
                                                            controller.setSelectedPilotTripRole('SIC'),
                                                      ),
                                                    ),
                                                    Text(
                                                      'SIC',
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
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              _divider(),
                            ],

                            // Radius
                            // _rowTwoCol(
                            //   left: "Departure Airport Radius",
                            //   rightChild: GetBuilder<CreateDirectTripController>(
                            //     id: 'radius',
                            //     builder: (_) => TextFormField(
                            //       controller: controller.radiusController,
                            //       style: TextStyle(
                            //         fontSize: 10.spV2,
                            //         fontWeight: FontWeight.bold,
                            //         color: AppColor.secondaryColor1,
                            //       ),
                            //       readOnly: true,
                            //       onTap: controller.isTripOutOfDate.value ? null : () => _showRadiusPicker(context),
                            //       decoration: InputDecoration(
                            //         border: InputBorder.none,
                            //         hintText: "Crew Proximity",
                            //         hintStyle: TextStyle(
                            //           fontSize: 9.spV2,
                            //           color: AppColor.secondaryColor2,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // _divider(),

                            // Aircraft Type
                            _rowTwoCol(
                              left: "Aircraft Type",
                              rightChild: TextFormField(
                                controller: controller.aircraftTypeController,
                                style: TextStyle(
                                  fontSize: 10.spV2,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.secondaryColor1,
                                ),
                                readOnly: true,
                                // Allow long aircraft names to wrap onto multiple lines instead of clipping.
                                minLines: 1,
                                maxLines: 3,
                                onTap: controller.isTripOutOfDate.value
                                    ? null
                                    : () => _showAircraftPicker(context),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Select Aircraft",
                                  hintStyle: TextStyle(
                                    fontSize: 9.spV2,
                                    color: AppColor.secondaryColor2,
                                  ),
                                ),
                              ),
                            ),
                            _divider(),

                            // Rate per day
                            _rowTwoCol(
                              left: "Per Day",
                              rightChild: Row(
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
                                        hintText: "Enter Rate",
                                        hintStyle: TextStyle(
                                          color: AppColor.secondaryColor2,
                                          fontSize: 9.spV2,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _divider(),

                            SizedBox(height: 2.h),

                            // Primary button area
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                              child: controller.isTripOutOfDate.value
                                  ? _updateDatesButton(context)
                                  : _createTripButton(context), // You can hook actual Create Trip here
                            ),
                            SizedBox(height: 2.h),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
      ),
    );
  }

  // --------------------------
  // Widgets
  // --------------------------

  Widget _rowTwoCol({required String left, required Widget rightChild}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Text(
              left,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColor.textColor1,
                fontSize: 9.5.spV2,
              ),
            ),
          ),
        ),
        Expanded(flex: 2, child: rightChild),
      ],
    );
  }

  Widget _divider() => Divider(
        indent: 10,
        endIndent: 10,
        thickness: 1,
        color: AppColor.secondaryColor1,
      );

  Widget _updateDatesButton(BuildContext context) {
    return Obx(
      () => MaterialButton(
        minWidth: 100.w,
        disabledColor: AppColor.secondaryColor1,
        disabledTextColor: AppColor.textColor2,
        textColor: AppColor.textColor2,
        color: AppColor.secondaryColor1,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
          borderRadius: BorderRadius.circular(2.w),
        ),
        onPressed: controller.stopUpdateBtnClicking.value
            ? null
            : () async {
                final error = controller.validateDatesForUpdate();
                if (error != null) {
                  await showMyDialog(context, error);
                  return;
                }
                _navigateToRoleSearchScreens(context);
              },
        child: Text("Update", style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _createTripButton(BuildContext context) {
    return MaterialButton(
      minWidth: 100.w,
      disabledColor: AppColor.secondaryColor1,
      disabledTextColor: AppColor.textColor2,
      textColor: AppColor.textColor2,
      color: AppColor.secondaryColor1,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColor.secondaryColor1, width: 0.6.w),
        borderRadius: BorderRadius.circular(2.w),
      ),
      onPressed: () async {
        // ===== Validations (match legacy messages) =====
          
        if (controller.startDateController.text.isEmpty) {
          await showMyDialog(context, "Please select start date");
          return;
        }
        if (controller.endDateController.text.isEmpty) {
          await showMyDialog(context, "Please select end date");
          return;
        }
        if (controller.tripNameController.text.isEmpty) {
          await showMyDialog(context, "Please enter trip name");
          return;
        }
        if (controller.departAirportCodeController.text.isEmpty) {
          await showMyDialog(context, "Please select departure airport code");
          return;
        }
        if (controller.destAirportCodeController.text.isEmpty) {
          await showMyDialog(context, "Please select destination airport code");
          return;
        }
        if (controller.aircraftTypeController.text.isEmpty) {
          await showMyDialog(context, "Please select aircraft type");
          return;
        }
        if (controller.dayRateController.text.isEmpty) {
          await showMyDialog(context, "Please enter rate");
          return;
        }

        // Prevent double taps
        if (controller.isButtonLocked) return;
        controller.isButtonLocked = true;

        try {
          showLoadingDialog(context, "Loading...");

          // await controller.createTrip();
          // Merge CreateDirectTripScreen fields into shared draft WITHOUT wiping changes from later screens
          controller.commitToDraft();

          Navigator.pop(context); // close loader

          // final tripIdArg = controller.createdTripId?? "";
          // final roles = controller.selectList;
          // final milesArg = controller.radiusFinal?.toString() ?? "";
          // final airId = controller.aircraftID;
          // final acText = controller.aircraftTypeController.text.trim();

          if (controller.selectList.contains('Captain')){
              controller.createdCaptain = true;
          }
          if (controller.selectList.contains('Second In Command')){
              controller.createdSecondInCommand = true;
          }
          if (controller.selectList.contains('Flight Attendant')){
              controller.createdFlightAttendant = true;
          }
          if (controller.selectList.contains('Flight Instructor')){
              controller.createdFlightInstructor = true;
          }

          await controller.sendTripRequest(context);
        } catch (e) {
          try { Navigator.pop(context); } catch (_) {}
          await showMyDialog(context, "Error: $e");
        } finally {
          controller.isButtonLocked = false;
        }
      },
      child: Text("Send Trip Request", style: TextStyle(fontSize: 10.spV2, fontWeight: FontWeight.w600)),
    );
  }
}