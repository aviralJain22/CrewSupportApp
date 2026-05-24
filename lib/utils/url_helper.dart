import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

class UrlHelper {
  /// Opens [url] inside the app using an in-app WebView.
  ///
  /// - Uses LaunchMode.inAppWebView so the user doesn't leave the app.
  /// - Enables JavaScript (often needed for modern sites).
  /// - Shows a SnackBar if opening fails (optional but useful UX).
  static Future<bool> openInApp(
    BuildContext context,
    String url, {
    bool enableJavaScript = true,
    bool enableDomStorage = true,
    String? fallbackErrorMessage,
  }) async {
    return await _openInAppInternal(
      context,
      url,
      enableJavaScript: enableJavaScript,
      enableDomStorage: enableDomStorage,
      fallbackErrorMessage: fallbackErrorMessage,
    );
  }

  /// Opens [url] inside the app using an in-app WebView, without requiring a BuildContext.
  /// Uses Get.context if available, or shows error using Get.snackbar.
  static Future<bool> openInAppNoContext(
    String url, {
    bool enableJavaScript = true,
    bool enableDomStorage = true,
    String? fallbackErrorMessage,
  }) async {
    final context = Get.context;
    if (context == null) {
      // Cannot open without context for in-app webview; show error.
      _showError(null, fallbackErrorMessage ?? 'Unable to open link: no context available.');
      return false;
    }
    return await _openInAppInternal(
      context,
      url,
      enableJavaScript: enableJavaScript,
      enableDomStorage: enableDomStorage,
      fallbackErrorMessage: fallbackErrorMessage,
    );
  }

  static Future<bool> _openInAppInternal(
    BuildContext? context,
    String url, {
    required bool enableJavaScript,
    required bool enableDomStorage,
    String? fallbackErrorMessage,
  }) async {
    // Basic cleanup: avoids issues with accidental spaces.
    final trimmed = url.trim();

    Uri? uri;
    try {
      uri = Uri.parse(trimmed);
    } catch (_) {
      _showError(context, fallbackErrorMessage ?? 'Invalid URL.');
      return false;
    }

    // Optional: if user passes "example.com" without scheme, prepend https://
    if (uri.scheme.isEmpty) {
      uri = Uri.parse('https://$trimmed');
    }

    // canLaunchUrl is optional; launchUrl generally returns false if it fails.
    final ok = await launchUrl(
      uri,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: WebViewConfiguration(
        enableJavaScript: enableJavaScript,
        enableDomStorage: enableDomStorage,
      ),
    );

    if (!ok) {
      debugPrint('[UrlHelper] Could not launch: $uri');
      _showError(context, fallbackErrorMessage ?? 'Could not open the link.');
      return false;
    }

    return true;
  }

  static void _showError(BuildContext? context, String message) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else {
      // Use Get.snackbar for error display if context is not available
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}