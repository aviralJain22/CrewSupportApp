import 'package:crew_support/features/home/subscreens/shared/owner_trips_tab_controller.dart';
import 'package:crew_support/model/trip_model.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

/// PendingController
/// -----------------
/// Owner trips tab controller bound to DashboardController.ownerPendingTrips.
class PendingController extends OwnerTripsTabController {
  @override
  String get tabName => 'PendingController';

  @override
  RxList<TripModel> get dashboardTrips => dash.pendingTrips;

  /// Backwards-compatible name used by PendingScreen
  Future<void> refreshPendingTrips() => refreshTrips();
}