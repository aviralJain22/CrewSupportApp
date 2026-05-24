import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/model/trip_model.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Base controller for Owner trip tabs:
/// Current / Future / Draft / Pending / History / Uncrewed
///
/// Responsibilities:
/// - Bind `trips` to a dashboard RxList (provided by subclasses)
/// - Mirror `isLoadingOwnerTrips` and `selectedProfileType`
/// - Provide pull-to-refresh handler
/// - Run the legacy unread pulsing animation only when there is at least 1 unread trip
abstract class OwnerTripsTabController extends GetxController
    with GetSingleTickerProviderStateMixin {
  /// Loading flag for this tab
  final RxBool isLoading = false.obs;

  /// Trips shown in this tab
  final RxList<TripModel> trips = <TripModel>[].obs;

  /// Selected profile type (mirrors dashboard)
  final RxInt selectedProfileType = 0.obs;

  late final DashboardController dash;

  /// Animation controller used to mimic the legacy pulsing/unread highlight.
  late final AnimationController resizableController;

  /// The animated color value (used only for unread trips)
  late final Animation<Color?> unreadColorAnimation;

  /// Subclasses must provide which dashboard RxList this tab binds to.
  RxList<TripModel> get dashboardTrips;

  /// Used only for debug logging.
  String get tabName;

  @override
  void onInit() {
    super.onInit();

    dash = Get.find<DashboardController>();

    // Legacy-like unread pulse animation:
    // - Duration: 700ms
    // - Curve: linear
    // - Loops forever via status listener (forward/reverse)
    resizableController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    final CurvedAnimation curve = CurvedAnimation(
      parent: resizableController,
      curve: Curves.linear,
    );

    unreadColorAnimation = ColorTween(
      begin: AppColor.orangeAccent,
      end: AppColor.red[900],
    ).animate(curve);

    resizableController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        resizableController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        resizableController.forward();
      }
    });

    // Initial copy from dashboard
    selectedProfileType.value = dash.selectedProfileType.value;
    isLoading.value = dash.isLoadingTrips.value;

    // if (selectedProfileType.value == MembershipType.ownerOperator) {
      trips.assignAll(dashboardTrips);
    // } else {
    //   trips.clear();
    // }
    _syncUnreadPulseRunning();

    // Profile switching
    ever<int>(dash.selectedProfileType, (type) {
      selectedProfileType.value = type;
      _onProfileChanged(type);
    });

    // Bind to the dashboard list for this tab
    ever<List<TripModel>>(dashboardTrips, (list) {
      // if (selectedProfileType.value == MembershipType.ownerOperator) {
        trips
          ..clear()
          ..addAll(list);
      // } else {
      //   trips.clear();
      // }
      _syncUnreadPulseRunning();
    });

    // Loading flag
    ever<bool>(dash.isLoadingTrips, (loading) {
      isLoading.value = loading;
    });

    // Gate animation (start only when needed)
    ever<List<TripModel>>(trips, (_) {
      _syncUnreadPulseRunning();
    });

    // Initial fetch if needed
    if (trips.isEmpty &&
        !dash.isLoadingTrips.value) {
      // ignore: discarded_futures
      refreshTrips();
    }
  }

  /// Starts/stops the pulsing highlight depending on whether any trip is unread.
  void _syncUnreadPulseRunning() {
    final bool hasUnread = trips.any((t) => t.isRead == false);

    if (hasUnread) {
      if (!resizableController.isAnimating) {
        resizableController.forward();
      }
    } else {
      if (resizableController.isAnimating) {
        resizableController.stop();
      }
      // Reset so when an unread appears later, the pulse starts from the beginning.
      resizableController.value = 0.0;
    }
  }

  void _onProfileChanged(int type) {
    debugPrint('$tabName: profile changed to $type');

    // if (type == MembershipType.ownerOperator) {
      trips
        ..clear()
        ..addAll(dashboardTrips);
      _syncUnreadPulseRunning();

      if (!dash.isLoadingTrips.value) {
        // ignore: discarded_futures
        refreshTrips();
      }
    // } else {
    //   trips.clear();
    //   _syncUnreadPulseRunning();
    // }
  }

  /// Pull-to-refresh handler.
  Future<void> refreshTrips() async {
    await dash.loadTrips();
  }

  @override
  void onClose() {
    resizableController.dispose();
    super.onClose();
  }
}