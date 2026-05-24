import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/model/chat_message_list_model.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ChatService {
  final DashboardController _dashboardController = Get.find<DashboardController>();

  /// Shows a simple blocking loader while conversation creation is in progress.
  void _showLoader() {
    if (Get.isDialogOpen == true) return;

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          color: AppColor.secondaryColor1,
        ),
        
      ),
      barrierDismissible: false,
    );
  }

  /// Safely closes the loader if it is currently open.
  void _hideLoader() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  Future<String> createOrOpenConversation({
    required String otherUserId,
    required int otherProfileType,
  }) async {
    final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) {
      throw Exception('User must be logged in.');
    }

    final int myProfileType = _dashboardController.selectedProfileType.value;
    if (myProfileType == 0) {
      throw Exception('No active profile selected.');
    }

    final ParseCloudFunction function = ParseCloudFunction('createConversation');

    final ParseResponse response = await function.execute(
      parameters: <String, dynamic>{
        'type': 'dm',
        'creatorProfileType': myProfileType,
        'participants': <Map<String, dynamic>>[
          <String, dynamic>{
            'userId': currentUser.objectId,
            'profileType': myProfileType,
          },
          <String, dynamic>{
            'userId': otherUserId,
            'profileType': otherProfileType,
          },
        ],
      },
    );

    if (!response.success || response.result == null) {
      throw Exception(response.error?.message ?? 'Failed to create conversation.');
    }

    final dynamic result = response.result;
    if (result is Map<String, dynamic>) {
      final String? conversationId = result['conversationId']?.toString();
      if (conversationId != null && conversationId.isNotEmpty) {
        return conversationId;
      }
    }

    throw Exception('Conversation id missing in response.');
  }

  Future<void> openChatForProfile({
    required String otherUserId,
    required int otherProfileType,
    required String receiverName,
    String photoPath = '',
  }) async {
    try {
      _showLoader();

      final String conversationId = await createOrOpenConversation(
        otherUserId: otherUserId,
        otherProfileType: otherProfileType,
      );

      final Messages messageData = Messages(
        conversationId: conversationId,
        otherUserId: otherUserId,
        otherProfileType: otherProfileType,
        receivername: receiverName,
        message: '',
        isUnReadCount: 0,
        photoPath: photoPath,
      );

      _hideLoader();

      await Get.toNamed(
        AppRoutes.chat,
        arguments: <String, dynamic>{
          'messageData': messageData,
          'fromNotification': false,
          'unreadMessage': false,
          'conversationId': conversationId,
          'otherUserId': otherUserId,
          'otherProfileType': otherProfileType,
        },
      );
    } catch (e) {
      _hideLoader();

      Get.snackbar(
        'Unable to open chat',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }
}