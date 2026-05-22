import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:crew_support/features/trip/trip_draft_flow_service.dart';

/// Contract each screen implements so it can save its local form state into draft.
abstract class DraftCommitter {
  void commitToDraft();
}

/// Centralized draft saving logic used by all screens.
class TripDraftSaveService {
  TripDraftSaveService(this._flow);

  final TripDraftFlowService _flow;

  /// Saves draft:
  /// 1) asks current screen to commit its form state into shared draft
  /// 2) if mode == createNew: creates Trip on server if not created yet
  /// 3) if mode == editDraft: updates Trip on server (always)
  Future<void> saveDraft({required DraftCommitter committer}) async {
    // 1) let screen store its fields into draft
    committer.commitToDraft();

    final draft = _flow.draft.value;
    final isEditDraft = _flow.mode.value == TripFlowMode.editDraft;
    final isAddCrew = _flow.mode.value == TripFlowMode.addCrew;

    final existingObjectId = (draft.tripObjectId ?? '').trim();

    // Create flow: if trip already created, nothing to do.
    if (!isEditDraft && !isAddCrew && existingObjectId.isNotEmpty) return;

    // Edit flow: must have objectId to update.
    if ((isEditDraft || isAddCrew) && existingObjectId.isEmpty) {
      throw 'Failed to update trip (missing objectId).';
    }

    final params = <String, dynamic>{
      // IMPORTANT: when editing, send objectId so Cloud Code updates the same Trip
      if (isEditDraft || isAddCrew) 'tripId': existingObjectId,

      'tripName': (draft.tripName ?? '').trim(),
      'departureSourceId': draft.departureSourceId,
      'destinationSourceId': draft.destinationSourceId,
      'enrouteSourceIds': draft.enrouteSourceIds,
      // Send as explicit UTC ISO strings (with 'Z') to avoid server-local parsing.
      'startDate': draft.startDate?.toUtc().toIso8601String(),
      'endDate': draft.endDate?.toUtc().toIso8601String(),
      'aircraft': (draft.aircraftName ?? '').trim(),
      'radius': draft.radius ?? 0,

      // store roleRequirements as a JSON object; Cloud Code saves it as a File in trip.requirements
      'requirements': draft.roleRequirements,

      // Role flags
      'isCaptain': draft.isCaptain,
      'isSIC': draft.isSIC,
      'isAttendant': draft.isAttendant,
      'isInstructor': draft.isInstructor,

      // Rates (optional)
      'pilotRate': draft.pilotRate,
      'SICRate': draft.sicRate,
      'attendantRate': draft.attendantRate,
      'instructorRate': draft.instructorRate,

      // Status flags
      'isStarted': draft.isStarted,
      'isCompleted': draft.isCompleted,
      'isVoid': draft.isVoid,
      'isRead': draft.isRead,
      'isDirect': draft.isDirect,
    };

    // Remove null/empty values so we don't send meaningless fields.
    params.removeWhere((k, v) {
      if (v == null) return true;
      if (v is String && v.trim().isEmpty) return true;
      return false;
    });

    final functionName = (isEditDraft || isAddCrew) ? 'updateTrip' : 'createTrip';
    final function = ParseCloudFunction(functionName);

    final response = await function.execute(parameters: params);

    if (!response.success || response.result == null) {
      throw 'Failed to ${(isEditDraft || isAddCrew) ? 'update' : 'create'} trip.';
    }

    final result = response.result as Map<String, dynamic>;
    if (result['success'] != true) {
      throw (result['message']?.toString().isNotEmpty == true)
          ? result['message'].toString()
          : 'Failed to ${(isEditDraft || isAddCrew) ? 'update' : 'create'} trip.';
    }

    final objectId = result['objectId']?.toString();
    if (objectId == null || objectId.isEmpty) {
      throw 'Failed to ${(isEditDraft || isAddCrew) ? 'update' : 'create'} trip (missing objectId).';
    }

    // Only set tripObjectId when creating a new trip.
    if (!(isEditDraft || isAddCrew)) {
      _flow.updateDraft(_flow.draft.value.copyWith(tripObjectId: objectId));
    }

    debugPrint(
      'TripDraftSaveService: Trip ${(isEditDraft || isAddCrew) ? 'updated' : 'created'} with objectId=$objectId',
    );
  }
}