import 'package:crew_support/features/home/subscreens/shared/owner_trips_tab_controller.dart';
import 'package:crew_support/model/trip_model.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

/// UncrewedController
/// -----------------
/// Owner trips tab controller bound to DashboardController.ownerUncrewedTrips.
class UncrewedController extends OwnerTripsTabController {
  @override
  String get tabName => 'UncrewedController';

  @override
  RxList<TripModel> get dashboardTrips => dash.uncrewedTrips;

  /// Backwards-compatible name used by UncrewedScreen
  Future<void> refreshUncrewedTrips() => refreshTrips();
}