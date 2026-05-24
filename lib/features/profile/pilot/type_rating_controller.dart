import 'package:crew_support/model/rating_certification.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Controller for Type Rating list screen.
/// Handles:
/// - Loading rating certificates from API
/// - Reordering items and updating order on server
/// - Deleting a certificate
class TypeRatingController extends GetxController {
  /// List of rating certificates
  final RxList<RatingCertification> ratingData = <RatingCertification>[].obs;

  /// Loading state for initial fetch
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRatingCertificates();
  }

  /// Fetch rating certificates from API for current pilot
  Future<void> fetchRatingCertificates() async {
    try {
      isLoading.value = true;

      final result = await fetchRatingCertifications();

      ratingData
        ..clear()
        ..addAll(result);
    } catch (e) {
      // You can also log to sheet here if you want
      // logToSheet('TypeRatingController.fetchRatingCertificates error: $e');
      ratingData.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch all rating certifications for logged-in pilot
  Future<List<RatingCertification>> fetchRatingCertifications() async {
    final ParseCloudFunction function =
        ParseCloudFunction('getRatingCertifications');

    // Call cloud function
    final ParseResponse response = await function.execute();

    if (!response.success || response.result == null) {
      return [];
    }

    // Convert JSON list to Dart model list
    final List<dynamic> data = response.result;

    return data.map((item) => RatingCertification.fromJson(item)).toList();
  }

  /// Public method for screen to refresh data after add / update
  Future<void> refreshData() async {
    await fetchRatingCertificates();
  }

  /// Delete certificate at [index].
  ///
  /// This:
  /// - shows the "Deleting..." loading dialog
  /// - calls deleteRatingCertificate API
  /// - closes both dialogs (loading + confirmation)
  /// - shows the result dialog
  /// - removes item from list on success
  Future<void> deleteCertificate(
    BuildContext context,
    int index,
  ) async {
    if (index < 0 || index >= ratingData.length) return;

    try {
      // Show loading dialog on top of the CupertinoAlertDialog
      showLoadingDialog(context, 'Deleting...');

      final cert = ratingData[index];

      final ok = await deleteRatingCertification(cert.objectId);

      // First pop: loading dialog
      Navigator.of(context).pop();
      // Second pop: CupertinoAlertDialog
      Navigator.of(context).pop();

      if (ok) {
        // Show result message
        await showMyDialog(context, 'Certification deleted successfully');
        // Remove from local list
        ratingData.removeAt(index);
      } else {
        await showMyDialog(context, 'Failed to delete certification. Please try again.');
      }

    } catch (e) {
      // Close dialogs safely if something goes wrong
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      await showMyDialog(context, 'Something went wrong. Please try again.');
    }
  }

  /// Delete a rating certification by its objectId.
  /// Returns true if delete succeeded, false otherwise.
  Future<bool> deleteRatingCertification(String certificationId) async {
    final ParseCloudFunction function =
        ParseCloudFunction('deleteRatingCertification');

    final ParseResponse response = await function.execute(
      parameters: {
        'certificationId': certificationId,
      },
    );

    if (!response.success || response.result == null) {
      debugPrint('deleteRatingCertification failed: ${response.error?.message}');
      return false;
    }

    // Expecting: { success: true, deletedId: "<id>" }
    final result = response.result as Map<String, dynamic>;
    final bool success = result['success'] == true;

    if (!success) {
      debugPrint('deleteRatingCertification result not successful: $result');
    }

    return success;
  }

  /// Handle reorder of list items.
  ///
  /// This:
  /// - Shows loading dialog
  /// - Adjusts list order locally
  /// - Builds "id-index" CSV string (e.g. "12-0,9-1,7-2")
  /// - Calls updateTypeRatingIndex API
  /// - Closes loading dialog
  // Future<void> handleReorder(
  //   BuildContext context,
  //   int oldIndex,
  //   int newIndex,
  // ) async {
  //   try {
  //     showLoadingDialog(context, 'Loading...');

  //     // Same adjustment as old code
  //     if (oldIndex < newIndex) {
  //       newIndex -= 1;
  //     }

  //     // Reorder locally
  //     final RatingCertification item = ratingData.removeAt(oldIndex);
  //     ratingData.insert(newIndex, item);

  //     // Build "id-index" list
  //     final List<String> dataList = [];
  //     for (int i = 0; i < ratingData.length; i++) {
  //       final id = ratingData[i].objectId;
  //       if (id != null) {
  //         dataList.add('$id-$i');
  //       }
  //     }
  //     final data = dataList.join(',');

  //     // await updateTypeRatingIndex(typeRatingWithIndex: data);
  //   } catch (e) {
  //     // Optionally refresh data on error
  //     // await fetchRatingCertificates();
  //   } finally {
  //     // Close loading dialog
  //     Navigator.of(context).pop();
  //   }
  // }
}