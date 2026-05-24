import 'package:get/get.dart';
import 'package:crew_support/model/trip_draft_payload.dart';

/// Indicates how the trip-creation flow was opened.
enum TripFlowMode { createNew, editDraft, addCrew }

/// Holds the shared TripDraftPayload for the active Trip-creation flow.
/// This avoids passing draft back/forward between screens.
class TripDraftFlowService extends GetxService {
  final Rx<TripDraftPayload> draft = TripDraftPayload().obs;

  final Rx<TripFlowMode> mode = TripFlowMode.createNew.obs;

  bool get isFromDraftTab => mode.value == TripFlowMode.editDraft;

  bool get isFromAddCrew => mode.value == TripFlowMode.addCrew;

  /// Start a brand new trip flow (CreateTripScreen entry).
  void startNew(TripDraftPayload initial) {
    mode.value = TripFlowMode.createNew;
    draft.value = initial;
  }

  /// Start editing an existing draft trip (Drafts tab entry).
  void startEditDraft(TripDraftPayload initial) {
    mode.value = TripFlowMode.editDraft;
    draft.value = initial;
  }

  /// Start adding crew to an existing trip.
  void startAddCrew(TripDraftPayload initial) {
    mode.value = TripFlowMode.addCrew;
    draft.value = initial;
  }

  /// Backward-compatible alias: defaults to createNew.
  void start(TripDraftPayload initial) {
    startNew(initial);
  }

  void updateDraft(TripDraftPayload next) {
    draft.value = next;
  }

  void clear() {
    mode.value = TripFlowMode.createNew;
    draft.value = TripDraftPayload();
  }
}