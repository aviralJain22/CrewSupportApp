import 'package:get/get.dart';

/// HomeController
/// --------------
/// Mirrors legacy Home tab state:
/// - currentPage: 0..5  (Current, Future, History, Pending, Uncrewed, Draft)
/// - isClicked* flags (kept only to match legacy visual logic)
/// - badge counts (reactive). Replace with your Firebase stream assignments later.
class HomeController extends GetxController {
  /// 0: Current, 1: Future, 2: History, 3: Pending, 4: Uncrewed, 5: Draft
  final RxInt currentPage = 0.obs;

  // Legacy boolean flags (used in color helpers)
  final RxBool isClickedCurrent = true.obs;
  final RxBool isClickedFuture = false.obs;
  final RxBool isClickedHistory = false.obs;
  final RxBool isPending = false.obs;
  final RxBool isUncrewedTrips = false.obs;
  final RxBool isClickedFinished = false.obs;

  final RxInt uncrewedCount = 0.obs;

  void selectTab(int page) {
    currentPage.value = page;

    isClickedCurrent.value   = page == 0;
    isClickedFuture.value    = page == 1;
    isClickedHistory.value   = page == 2;
    isPending.value          = page == 3;
    isUncrewedTrips.value    = page == 4;
    isClickedFinished.value  = page == 5;
  }

  /// Example: call these from your Firebase listeners to update badges.
  void setCounts({
    int? uncrewed,
  }) {
    if (uncrewed != null) uncrewedCount.value = uncrewed;
  }
}