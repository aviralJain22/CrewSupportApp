import 'package:crew_support/features/home/subscreens/shared/owner_trips_tab_controller.dart';
import 'package:crew_support/model/trip_model.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

/// CurrentController
/// -----------------
/// Owner trips tab controller bound to DashboardController.ownerCurrentTrips.
class CurrentController extends OwnerTripsTabController {
  @override
  String get tabName => 'CurrentController';

  @override
  RxList<TripModel> get dashboardTrips => dash.currentTrips;

  /// Backwards-compatible name used by CurrentScreen
  Future<void> fetchTrips() => refreshTrips();
}