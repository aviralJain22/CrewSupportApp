import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

// New AppColor import per project convention
import 'package:crew_support/utils/AppColor.dart';

import 'webview_stack_controller.dart';

/// Screen for WebViewStack converted to GetX.
/// The UI matches the legacy implementation:
/// - Same SafeArea + Scaffold background
/// - AppBar with a leading close button and navigation controls in actions
/// - LinearProgressIndicator shown until loading reaches 100
class WebviewStackScreen extends GetWidget<WebviewStackController> {
  const WebviewStackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: AppColor.bgColor1,
        appBar: AppBar(
          backgroundColor: AppColor.bgColor1,
          leading: IconButton(
            icon: const Icon(Icons.close,
            color: AppColor.secondaryColor1,
            ),
            onPressed: () => Get.back(),
          ),
          actions: const [
            _NavigationActions(),
          ],
        ),
        body: Stack(
          children: [
            // Web content
            WebViewWidget(controller: controller.webController),

            // Progress bar identical behavior: visible until 100%
            Obx(() {
              final progress = controller.loadingPercentage.value;
              if (progress >= 100) return const SizedBox.shrink();
              return LinearProgressIndicator(value: progress / 100.0);
            }),
          ],
        ),
      ),
    );
  }
}

/// Replacement for the old `NavigationControls` widget.
/// Uses controller.canGoBack / canGoForward and exposes back/forward/reload.
class _NavigationActions extends GetView<WebviewStackController> {
  const _NavigationActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() => IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: controller.canGoBack.value ? controller.goBack : null,
            )),
        Obx(() => IconButton(
              tooltip: 'Forward',
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed:
                  controller.canGoForward.value ? controller.goForward : null,
            )),
        IconButton(
          tooltip: 'Reload',
          icon: const Icon(Icons.refresh_rounded, color: AppColor.secondaryColor1,),
          onPressed: controller.reload,
        ),
      ],
    );
  }
}
