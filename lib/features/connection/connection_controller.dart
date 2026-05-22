import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/connection/connection_profile_model.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/features/message/chat_service.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crew_support/model/chat_message_list_model.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ConnectionController extends GetxController {
  /// Full list of requests as returned from API (after cleaning)
  final RxList<ConnectionProfile> requestList = <ConnectionProfile>[].obs;

  /// Filtered list used for search results; drives the ListView
  final RxList<ConnectionProfile> filteredRequestList = <ConnectionProfile>[].obs;

  /// Loading flag for the whole screen
  final RxBool isLoading = true.obs;

  /// Text controller for search field (optional, but handy)
  final TextEditingController searchController = TextEditingController();

  /// App type used to decide Firestore collection (live / local)
  late final String appType;

  /// Last message badge data (used for connectionCounter)
  MessageData chatMessageListModel = MessageData();

  final RxList<ConnectionProfile> acceptedConnectionList = <ConnectionProfile>[].obs;
  final RxList<ConnectionProfile> pendingReceivedRequestList = <ConnectionProfile>[].obs;

  final DashboardController dash = Get.find<DashboardController>();

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  void rebuildConnectionBuckets() {
    final accepted = requestList
        .where((r) => r.isAccepted == true)
        .toList();

    // Pending received requests are already returned by getConnections
    // with the latest request at the top, so do not alphabetically sort them.
    final pending = requestList
        .where((r) => r.isAccepted != true)
        .toList();

    acceptedConnectionList.assignAll(accepted);
    pendingReceivedRequestList.assignAll(pending);
    filteredRequestList.assignAll(accepted);
  }

  Future<ConnectionProfile?> getAllRequest() async {
    try {
      final result = await ParseCloudFunction('getConnections').execute(
        parameters: {
          'callerProfileType': dash.selectedProfileType.value,
          'callerProfileId': dash.selectedProfileId ?? '',
        },
      );

      if (result.success != true || result.result == null) {
        throw Exception(result.error?.message ?? 'Failed to load connections');
      }

      final data = Map<String, dynamic>.from(result.result as Map);

      final acceptedRaw = data['acceptedConnections'];
      final pendingRaw = data['pendingReceivedRequests'];

      final List<ConnectionProfile> loadedRequests = [];

      if (acceptedRaw is List) {
        loadedRequests.addAll(
          acceptedRaw.whereType<Map>().map(
                (item) => _requestFromConnectionMap(
                  Map<String, dynamic>.from(item),
                  isAccepted: true,
                ),
              ),
        );
      }

      if (pendingRaw is List) {
        loadedRequests.addAll(
          pendingRaw.whereType<Map>().map(
                (item) => _requestFromConnectionMap(
                  Map<String, dynamic>.from(item),
                  isAccepted: false,
                ),
              ),
        );
      }

      requestList.assignAll(loadedRequests);
      rebuildConnectionBuckets();

      return null;
    } catch (e) {
      debugPrint('getConnections error: $e');

      await showMyDialogNew(
        'Unable to load connections.\n\nReason: ${e is ParseError ? e.message : e.toString()}',
      );

      return null;
    }
  }

  ConnectionProfile _requestFromConnectionMap(
    Map<String, dynamic> data, {
    required bool isAccepted,
  }) {
    return ConnectionProfile.fromMap(
      data,
      isAccepted: isAccepted,
    );
  }

  /// Reload all data (used by RefreshIndicator and initial load)
  Future<void> getData() async {
    isLoading.value = true;
    await getAllRequest();
    isLoading.value = false;
  }

  /// Pull-to-refresh hook
  Future<void> refresh() => getData();

  /// Called from search TextFormField.onChanged
  void filterByName(String val) {
    final query = val.trim().toLowerCase();

    if (query.isEmpty) {
      filteredRequestList.assignAll(acceptedConnectionList);
      return;
    }

    filteredRequestList.assignAll(
      acceptedConnectionList.where((e) {
        return e.fullName.toLowerCase().contains(query);
      }).toList(),
    );
  }

  /// Helper: tap on the whole row → fetch profile then navigate
  Future<void> handleRowTap(ConnectionProfile request) async {

        final id = request.otherProfileId;
        final membershipType = request.otherProfileType;

        debugPrint('Connection row tapped: id=$id, membershipType=$membershipType');

        if (membershipType == MembershipType.pilot) {
          Get.toNamed(AppRoutes.pilotViewProfile, arguments: {
            'profileId': id,
            'userId': request.otherUserId,
          });
        } else if (membershipType == MembershipType.ownerOperator) {

          Get.toNamed(AppRoutes.ownerViewProfile, arguments: {
            'profileId': id,
            'userId': request.otherUserId,
          });

        // } else if (membershipType == MembershipType.instructor) {
        } else if (membershipType == MembershipType.flightAttendant) {
          Get.toNamed(AppRoutes.fAViewProfile, arguments: {
            'profileId': id,
            'userId': request.otherUserId,
          });
        } else {
          debugPrint('Unknown membershipType: $membershipType');
          return;
        }
  }

  /// Accepts a pending received connection request from the Requests overlay.
  ///
  /// After the cloud function succeeds, we reload the screen data so:
  /// - the accepted profile moves into the accepted connections list
  /// - the pending request count updates immediately
  Future<void> acceptConnectionRequest(ConnectionProfile request) async {
    try {
      // Open the loader on top of the requests overlay.
      showLoadingDialog(Get.context!, 'Accepting request...');

      final result = await ParseCloudFunction('acceptConnectionRequest').execute(
        parameters: {
          'connectionId': request.connectionId,
        },
      );

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (result.success != true) {
        throw Exception(result.error?.message ?? 'Unable to accept connection request');
      }

      await getData();

      await showMyDialogNew('${request.fullName} is now your connection.');
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      debugPrint('acceptConnectionRequest error: $e');

      await showMyDialogNew(
        'Unable to accept connection request.\n\nReason: ${e is ParseError ? e.message : e.toString()}',
      );
    }
  }

  /// Denies a pending received connection request from the Requests overlay.
  ///
  /// After the cloud function succeeds, we reload the screen data so the request
  /// disappears from the pending request list and the count updates immediately.
  Future<void> denyConnectionRequest(ConnectionProfile request) async {
    try {
      // Open the loader on top of the requests overlay.
      showLoadingDialog(Get.context!, 'Denying request...');

      final result = await ParseCloudFunction('denyConnectionRequest').execute(
        parameters: {
          'connectionId': request.connectionId,
        },
      );

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (result.success != true) {
        throw Exception(result.error?.message ?? 'Unable to deny connection request');
      }

      await getData();

      await showMyDialogNew('${request.fullName}\'s connection request was denied.');
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      debugPrint('denyConnectionRequest error: $e');

      await showMyDialogNew(
        'Unable to deny connection request.\n\nReason: ${e is ParseError ? e.message : e.toString()}',
      );
    }
  }

  /// Unfriends an accepted connection from the main connection list.
  ///
  /// After the cloud function succeeds, we reload the screen data so the row
  /// disappears from the accepted connections list and the count/list stay fresh.
  Future<void> unfriendConnection(ConnectionProfile request) async {
    try {
      // Use GetX-based loader so closeLoadingDialog() can reliably dismiss it.
      showLoadingDialogNew('Removing connection...');

      final result = await ParseCloudFunction('unfriendConnection').execute(
        parameters: {
          'connectionId': request.connectionId,
        },
      );

      closeLoadingDialog();

      if (result.success != true) {
        throw Exception(result.error?.message ?? 'Unable to remove connection');
      }

      await getData();

      await showMyDialogNew('${request.fullName} was removed from your connections.');
    } catch (e) {
      closeLoadingDialog();

      debugPrint('unfriendConnection error: $e');

      await showMyDialogNew(
        'Unable to remove connection.\n\nReason: ${e is ParseError ? e.message : e.toString()}',
      );
    }
  }

  /// Helper: open chat screen
  void openChat(ConnectionProfile request) {
    debugPrint("Tapped chat icon for userId: $request.otherUserId, membershipType: $request.otherProfileType, receiverName: $request.fullName");
    final ChatService chatService = ChatService();
    chatService.openChatForProfile(
      otherUserId: request.otherUserId,
      otherProfileType: request.otherProfileType,
      receiverName: request.fullName,
      photoPath: request.photoPath,
    );
  }
}