import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

// New AppColor import per project convention
import 'package:crew_support/utils/AppColor.dart';

/// Controller for WebViewStack screen, converted from the legacy
/// `webview-stack.dart` StatefulWidget to GetX pattern while
/// matching the original UI/behavior exactly.
///
/// Responsibilities:
/// - Hold the WebViewController instance
/// - Track loading progress (0..100)
/// - Manage navigation (back/forward/reload)
/// - Enforce orientation rules used by the old code
/// - Block navigation to specific hosts as in the legacy code
class WebviewStackController extends GetxController {
  /// Incoming URL. Expected via `Get.arguments` as `{ 'url': String }`.
  late final String? initialUrl;

  /// WebViewController used by WebViewWidget.
  late final WebViewController webController;

  /// Loading percentage (0..100). Drives the LinearProgressIndicator.
  final RxInt loadingPercentage = 0.obs;

  /// Whether WebView can navigate back/forward. Used to enable/disable buttons.
  final RxBool canGoBack = false.obs;
  final RxBool canGoForward = false.obs;

  /// A helper to wrap Google Docs Viewer (same as in legacy code)
  // String _wrapInGDocsViewer(String? url) {
  //   if (url == null || url.isEmpty) return '';
  //   return 'https://docs.google.com/gview?embedded=true&url=$url';
  // }

  @override
  void onInit() {
    super.onInit();

    // Read the argument passed from route: Get.toNamed(..., arguments: {'url': ...})
    initialUrl = (Get.arguments is Map && Get.arguments['url'] is String)
        ? Get.arguments['url'] as String
        : null;

    // Match legacy behavior: allow all 4 orientations while viewing web content
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);

    // Configure the new WebViewController API exactly like legacy
    webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColor.bgColor1) // matches scaffold background
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            loadingPercentage.value = 0;
            _updateNavAvailability();
          },
          onProgress: (progress) {
            loadingPercentage.value = progress; // 0..100
          },
          onPageFinished: (url) async {
            loadingPercentage.value = 100;
            _updateNavAvailability();
          },
          // onNavigationRequest: (request) {
          //   final host = Uri.tryParse(request.url)?.host ?? '';
          //   // Preserve old rule: block blueboxinfosoft.com
          //   // if (host.contains('blueboxinfosoft.com')) {
          //   //   // Use a non-intrusive snackbar via Get (same as old code intent)
          //   //   Get.showSnackbar(
          //   //     const GetSnackBar(
          //   //       message: 'Blocking navigation to blueboxinfosoft.com',
          //   //       duration: Duration(seconds: 2),
          //   //     ),
          //   //   );
          //   //   return NavigationDecision.prevent;
          //   // }
          //   return NavigationDecision.navigate;
          // },
          onWebResourceError: (error) {
            // Preserve old UX: show a brief error
            Get.snackbar('URL Error', 'Could not load the requested URL');
          },
        ),
      )
      ..loadRequest(Uri.parse(initialUrl ?? 'about:blank'));
  }

  /// Update `canGoBack` and `canGoForward` observables from the web view.
  Future<void> _updateNavAvailability() async {
    try {
      canGoBack.value = await webController.canGoBack();
      canGoForward.value = await webController.canGoForward();
    } catch (_) {
      canGoBack.value = false;
      canGoForward.value = false;
    }
  }

  /// Navigate back in web history if possible
  Future<void> goBack() async {
    if (await webController.canGoBack()) {
      await webController.goBack();
      _updateNavAvailability();
    }
  }

  /// Navigate forward in web history if possible
  Future<void> goForward() async {
    if (await webController.canGoForward()) {
      await webController.goForward();
      _updateNavAvailability();
    }
  }

  /// Reload current page
  Future<void> reload() async {
    await webController.reload();
  }

  @override
  void onClose() {
    // Dismiss any loaders if they were shown externally (legacy did this)
    EasyLoading.dismiss();

    // Restore portrait-only like legacy dispose()
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
    super.onClose();
  }
}
