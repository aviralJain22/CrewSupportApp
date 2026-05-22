// FAQ Screen (GetX) — mirrors the legacy screen’s visuals exactly,
// but powered by the controller and a single ListView for safe-area friendly scrolling.

import 'dart:math' as math;
import 'package:crew_support/utils/AppColor.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'faq_controller.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FaqController());
    // Wrap with SafeArea and use a ListView with bottom padding
    // so the last item stays tappable above the home indicator.
    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        backgroundColor: AppColor.bgColor1,
        elevation: 0,
        title: Text("FAQs", style: controller.appBarTitle),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColor.secondaryColor1,
          ),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: GetBuilder<FaqController>(
          builder: (_) {
            return ListView.builder(
              padding: const EdgeInsets.all(8.0).copyWith(
                // Ensures the last expandable remains fully tappable
                bottom: math.max(MediaQuery.of(context).padding.bottom + 24, 24),
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: controller.entries.length,
              itemBuilder: (context, index) {
                final entry = controller.entries[index];

                // Top intro blocks are special tiny classes with .build()
                if (entry is IntroTitleEntry) {
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: entry.build(),
                  );
                }
                if (entry is IntroSubtitleEntry) {
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: entry.build(),
                  );
                }

                switch (entry.type) {
                  case FaqEntryType.header:
                    final header = entry as FaqHeader;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                      child: Text(header.title, style: controller.headerH1),
                    );

                  case FaqEntryType.panel:
                    final p = entry as FaqPanelEntry;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExpandablePanel(
                          controller: p.controller,
                          theme: ExpandableThemeData(
                            iconColor: AppColor.secondaryColor1,
                            headerAlignment: ExpandablePanelHeaderAlignment.center,
                          ),
                          header: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(p.title, style: controller.h2),
                          ),
                          collapsed: const Text(
                            "",
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                          expanded: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: p.bodyBuilder(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                  case FaqEntryType.divider:
                    return Column(
                      children: [
                        Divider(
                          thickness: 0.7,
                          color: AppColor.secondaryColor1,
                        ),
                      ],
                    );

                  case FaqEntryType.spacer:
                    final sp = entry as FaqSpacer;
                    return SizedBox(height: sp.height);
                }
              },
            );
          },
        ),
      ),
    );
  }
}