import 'package:crew_support/features/home/subscreens/shared/owner_trips_tab_controller.dart';
import 'package:crew_support/model/trip_model.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

/// FutureTripsController
/// ---------------------
/// Owner trips tab controller bound to DashboardController.ownerFutureTrips.
class FutureTripsController extends OwnerTripsTabController {
  @override
  String get tabName => 'FutureTripsController';

  @override
  RxList<TripModel> get dashboardTrips => dash.futureTrips;

  /// Backwards-compatible name used by FutureTripsScreen
  Future<void> fetchTrips() => refreshTrips();
}