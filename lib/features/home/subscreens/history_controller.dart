import 'package:crew_support/features/home/subscreens/shared/owner_trips_tab_controller.dart';
import 'package:crew_support/model/trip_model.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

/// HistoryController
/// ----------------
/// Owner trips tab controller bound to DashboardController.ownerHistoryTrips.
class HistoryController extends OwnerTripsTabController {
  @override
  String get tabName => 'HistoryController';

  @override
  RxList<TripModel> get dashboardTrips => dash.historyTrips;

  /// Backwards-compatible name used by HistoryScreen
  Future<void> refreshHistoryTrips() => refreshTrips();
}