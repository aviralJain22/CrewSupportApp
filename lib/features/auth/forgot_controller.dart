// import 'package:crew_support/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:crew_support/utils/Utility.dart'; // showLoadingDialog(...)
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ForgotController extends GetxController {
  /// Email text controller (disposed in onClose)
  final TextEditingController emailController = TextEditingController();

  /// Loading flag so the Submit button can be disabled while the call runs
  final RxBool loading = false.obs;

  /// Simple email validator.
  bool _isValidEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) return false;
    // Very small regex, just to catch obviously invalid values.
    final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+");
    return emailRegex.hasMatch(email);
  }

  /// Trigger Back4App / Parse password reset using the email.
  ///
  /// Mirrors the legacy style: shows a loading dialog via `showLoadingDialog`,
  /// and uses EasyLoading for success / error toasts.
  Future<void> submitForgot() async {
    final ctx = Get.context!;
    final email = emailController.text.trim();

    // Basic validation
    if (!_isValidEmail(email)) {
      EasyLoading.showError(
        'Please enter a valid email address',
        maskType: EasyLoadingMaskType.custom,
      );
      return;
    }

    loading.value = true;

    // Legacy loader dialog
    showLoadingDialog(ctx, 'Submitting...');

    try {
      // Back4App / Parse: request password reset
      final user = ParseUser(null, null, email);
      final ParseResponse response = await user.requestPasswordReset();

      // Close the loading dialog if still open
      // if (Get.isOverlaysOpen) {
        Get.back();
      // }

      if (response.success) {
        // Match legacy behaviour: show a success toast
        EasyLoading.showSuccess(
          'Password reset email sent. Please check your inbox.',
          maskType: EasyLoadingMaskType.custom,
        );

        // Optionally, navigate back to login after success
        // Get.back();
      } else {
        final msg = response.error?.message ?? 'Failed to send reset email.';
        EasyLoading.showError(
          msg,
          maskType: EasyLoadingMaskType.custom,
        );
      }
    } catch (e) {
      // Ensure dialog is closed on exception
      if (Get.isOverlaysOpen) {
        Get.back();
      }

      EasyLoading.showError(
        e.toString(),
        maskType: EasyLoadingMaskType.custom,
      );
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}