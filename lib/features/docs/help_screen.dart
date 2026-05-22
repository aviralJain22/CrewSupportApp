import 'package:chewie/chewie.dart';
import 'package:crew_support/app/routes.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'help_controller.dart';

/// Help/Guide screen (GetX)
/// Matches the legacy Guide_Screen.dart including:
/// - Top FAQ card (border + arrow)
/// - "How to Operate Crew Support" title
/// - "There will be one video..." subtitle
/// - Expandable panels with videos below
class HelpScreen extends GetView<HelpController> {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HelpController());

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColor.bgColor1,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      appBar: AppBar(
        backgroundColor: AppColor.bgColor1,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.adaptive.arrow_back_rounded, color: AppColor.secondaryColor1),
        ),
        elevation: 0,
        title: Text(
          'Help Center', // legacy title
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColor.secondaryColor1),
        ),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),

      // Entire page scrolls as one surface; respects safe area.
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ---- Top content (FAQ card + headers) ------------------------------
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shadowColor: AppColor.secondaryColor1,
                      elevation: 2,
                      child: ListTile(
                        onTap: () => Get.toNamed(AppRoutes.faq),
                        tileColor: AppColor.bgColor1,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 2, color: AppColor.secondaryColor1),
                          borderRadius: BorderRadius.circular(2.sp),
                        ),
                        leading: Text('FAQ', style: TextStyle(fontSize: 10.spV2, color: AppColor.secondaryColor1)),
                        trailing: Icon(Icons.arrow_forward_ios, color: AppColor.secondaryColor1),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'How to Operate Crew Support',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.spV2,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textColor1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'There will be one video for a particular Question.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.5.spV2, color: AppColor.secondaryColor2),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // ---- Panels list as a SliverList (no nested scrollables) ------------
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = controller.items[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Column(
                      children: [
                        if (index != 0) ...[
                          Divider(thickness: 0.7, color: AppColor.secondaryColor1),
                          const SizedBox(height: 2),
                        ],
                        ExpandablePanel(
                          theme: ExpandableThemeData(
                            iconColor: AppColor.secondaryColor1,
                            headerAlignment: ExpandablePanelHeaderAlignment.center,
                            iconPlacement: ExpandablePanelIconPlacement.right,
                          ),
                          header: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColor.secondaryColor1,
                                fontSize: 11.spV2,
                              ),
                            ),
                          ),
                          collapsed: const Text('', softWrap: true, overflow: TextOverflow.ellipsis),
                          expanded: _VideoBlock(index: index),
                        ),
                      ],
                    ),
                  );
                },
                childCount: controller.items.length,
              ),
            ),

            // ---- Bottom safe padding so last item is tappable --------------------
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows spinner while initializing and then the Chewie player.
/// **Reactive** via Obx so the video appears without hot reload.
class _VideoBlock extends StatelessWidget {
  final int index;
  const _VideoBlock({required this.index});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HelpController>();

    // Lazily initialize when the block is first shown.
    WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.ensureInitialized(index));

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Obx(() {
        final isLoading = ctrl.loading[index] ?? false;
        final chewie = ctrl.chewieFor(index);

        return Container(
          decoration: BoxDecoration(
            color: AppColor.secondaryColor2,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 260, // legacy used 260
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: isLoading
                    ? CircularProgressIndicator(color: AppColor.secondaryColor1)
                    : (chewie == null
                        ? Text(
                            'Video unavailable',
                            style: TextStyle(color: AppColor.textColor1, fontSize: 9.spV2),
                          )
                        : Chewie(controller: chewie)),
              ),
            ),
          ),
        );
      }),
    );
  }
}