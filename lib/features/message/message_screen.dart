import 'package:crew_support/app/routes.dart';
import 'package:crew_support/model/chat_message_list_model.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'message_controller.dart';

/// Conversation list UI for the messages tab.
///
/// This screen renders:
/// - a loading state while conversations are fetched
/// - an empty state when no conversations are available
/// - a swipe-to-delete list of conversations
/// - navigation into the one-to-one chat screen
class MessageScreen extends GetView<MessageController> {
  const MessageScreen({super.key});

  /// Shows a user-visible alert for delete failures so the message stays on
  /// screen until the user dismisses it.
  Future<void> _showDeleteErrorDialog(
    BuildContext context,
    Object error,
  ) async {
    if (!context.mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Theme(
          data: ThemeData.dark(),
          child: CupertinoAlertDialog(
            title: Text(
              'Messages',
              style: TextStyle(color: AppColor.textColor1),
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                error.toString(),
                style: TextStyle(color: AppColor.textColor1),
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: AppColor.secondaryColor1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows a small action menu for a conversation row when it is long-pressed.
  ///
  /// For now we expose Delete from this menu, and then reuse the same
  /// confirmation dialog before actually deleting the conversation.
  Future<void> _showConversationActions(
    BuildContext context,
    MessageController controller,
    Messages msg,
  ) async {
    final String? action = await showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext popupContext) {
        return CupertinoActionSheet(
          actions: <Widget>[
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(popupContext).pop('delete');
              },
              child: const Text('Delete'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(popupContext).pop();
            },
            child: const Text('Cancel'),
          ),
        );
      },
    );

    if (action != 'delete') {
      return;
    }

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Theme(
          data: ThemeData.dark(),
          child: CupertinoAlertDialog(
            content: Text(
              "Are you sure you want to delete ?",
              style: TextStyle(color: AppColor.textColor1),
            ),
            actions: <Widget>[
              MaterialButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(color: AppColor.secondaryColor1),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
              ),
              MaterialButton(
                child: Text(
                  "Delete",
                  style: TextStyle(color: AppColor.secondaryColor1),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
              ),
            ],
          ),
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await controller.deleteConversation(msg);
    } catch (e) {
      await _showDeleteErrorDialog(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(
      builder: (controller) {
        final List<Messages>? messages = controller.chatMessageListModel.messages;

        if (controller.isLoading) {
          return SizedBox(
            height: 55.h,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.threeRotatingDots(
                    color: AppColor.secondaryColor1,
                    size: 50.spV2,
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Text(
                    'Loading...',
                    style: TextStyle(color: AppColor.textColor1),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state shown when there are no conversations to display.
        if (messages == null || messages.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/logoNewGolden.png"),
                colorFilter: ColorFilter.mode(
                    AppColor.bgColor1.withOpacity(0.9), BlendMode.srcOver),
              ),
            ),
            child: Center(
              child: Text(
                "Your messages will appear here",
                style: TextStyle(
                  fontSize: 10.spV2,
                  color: AppColor.secondaryColor1,
                ),
              ),
            ),
          );
        }

        // Conversation list.
        return Stack(
          children: [
            ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];

            // Swipe left to delete a conversation for the current profile.
            return Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.endToStart,
              background: Container(
                color: AppColor.historyRead,
              ),
              secondaryBackground: Container(
                color: AppColor.textColor1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.delete,
                      color: AppColor.deleteColor,
                    ),
                  ),
                ),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  // Confirm before removing the conversation from this profile's list.
                  final bool? shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return Theme(
                        data: ThemeData.dark(),
                        child: CupertinoAlertDialog(
                          content: Text(
                            "Are you sure you want to delete ?",
                            style: TextStyle(color: AppColor.textColor1),
                          ),
                          actions: <Widget>[
                            MaterialButton(
                              child: Text(
                                "Cancel",
                                style: TextStyle(color: AppColor.secondaryColor1),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                            MaterialButton(
                              child: Text(
                                "Delete",
                                style: TextStyle(color: AppColor.secondaryColor1),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );

                  if (shouldDelete != true) {
                    return false;
                  }

                  try {
                    // The backend clears the conversation only for the active profile.
                    await controller.deleteConversation(msg);
                    return true;
                  } catch (e) {
                    await _showDeleteErrorDialog(context, e);
                    return false;
                  }
                }
                return null;
              },
              child: Container(
                margin: EdgeInsets.all(3.0.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColor.secondaryColor1,
                      AppColor.secondaryColor1,
                    ],
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.all(0.4.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColor.bgColor1,
                  ),
                  padding: EdgeInsets.only(
                    top: 1.0.h,
                    bottom: 1.0.h,
                    left: 2.0.w,
                    right: 2.0.w,
                  ),
                  child: ListTile(
                    title: Text(
                      msg.receivername.toString(),
                      style: TextStyle(
                        fontSize: 11.spV2,
                        fontWeight: FontWeight.bold,
                        color: AppColor.secondaryColor1,
                      ),
                    ),
                    subtitle: _latestMsgText(msg.message ?? ''),
                    trailing: SizedBox(
                      width: 6.w,
                      height: 3.h,
                      child: Builder(
                        builder: (_) {
                          final dataCount = msg.isUnReadCount ?? 0;

                          // Cache the current unread count for controller-side bookkeeping.
                          controller.setUnreadCountForIndex(index, dataCount);

                          // Show unread badge when this conversation has unread messages.
                          if (dataCount != 0) {
                            return CircleAvatar(
                              backgroundColor: AppColor.secondaryColor1,
                              child: Text(
                                dataCount <= 99 ? "$dataCount" : '99+',
                                style: TextStyle(
                                  fontSize: dataCount <= 99 ? 10.spV2 : 8.spV2,
                                  color: AppColor.textColor2,
                                ),
                              ),
                            );
                          }

                          // Hide the placeholder once the tapped row becomes selected.
                          if (controller.selectedIndex == index) {
                            return Text("");
                          }

                          // Preserve layout spacing when there is no unread badge.
                          return Container(
                            height: 2.5.h,
                            width: 7.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60),
                              color: AppColor.bgColor1,
                            ),
                            child: Text(
                              "",
                              style: TextStyle(
                                color: AppColor.textColor2,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColor.secondaryColor1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: SizedBox(
                          height: 60.0.spV2,
                          width: 60.0.spV2,
                          child: (msg.photoPath ?? '').trim().isEmpty
                            ? CircleAvatar(
                                backgroundColor: AppColor.secondaryColor1,
                                child: Icon(
                                  Icons.person,
                                  color: AppColor.bgColor1,
                                ),
                              )
                            : Image.network(
                                msg.photoPath.toString(),
                                fit: BoxFit.fill,
                                height: 4.h,
                                width: 4.w,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: AppColor.bgColor1,
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                  return CircleAvatar(
                                    backgroundColor: AppColor.secondaryColor1,
                                    child: Icon(
                                      Icons.person,
                                      color: AppColor.bgColor1,
                                    ),
                                  );
                                },
                              ),
                        ),
                      ),
                    ),
                    onLongPress: () async {
                      // Show a small action menu on long press before taking
                      // any destructive action.
                      await _showConversationActions(context, controller, msg);
                    },
                    onTap: () {
                      // Keep track of the tapped row before opening the chat.
                      controller.markSelected(index);

                      // Open the chat screen with the row data needed by ChatController.
                      Get.toNamed(
                        AppRoutes.chat,
                        arguments: {
                          'messageData': msg,
                          'fromNotification': false,
                          'unreadMessage': controller.messageRead,
                          'conversationId': msg.conversationId,
                          'otherUserId': msg.otherUserId,
                          'otherProfileType': msg.otherProfileType,
                        },
                      )?.then((_) {
                        // Refresh the list after returning so unread counts and previews stay current.
                        controller.getData();
                      });
                    },
                  ),
                ),
              ),
            );
              },
            ),
            if (controller.isDeletingConversation)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LoadingAnimationWidget.threeRotatingDots(
                          color: AppColor.secondaryColor1,
                          size: 50.spV2,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Deleting...',
                          style: TextStyle(color: AppColor.textColor1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Builds the one-line preview text shown under each conversation title.
Text _latestMsgText(String text) {
  final displayText =
      text.contains('\n') ? '${text.split('\n').first} ...' : text;
  return Text(
    displayText,
    maxLines: 1,
    style: TextStyle(
      fontSize: 9.0.spV2,
      fontWeight: FontWeight.w400,
      color: AppColor.secondaryColor2,
    ),
    overflow: TextOverflow.ellipsis,
  );
}

/// Legacy delete helper kept only as a fallback utility.
void showDeleteMessageLegacy(
    BuildContext context, int index, MessageData chatMessageListModel) {
  Widget cancelButton = TextButton(
    child: Text(
      "No",
      style: TextStyle(color: AppColor.secondaryColor1),
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  Widget yesButton = TextButton(
    child: Text(
      "Yes",
      style: TextStyle(color: AppColor.secondaryColor1),
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  CupertinoAlertDialog alert = CupertinoAlertDialog(
    content: Text(
      "Are you sure you want to delete ?",
      style: TextStyle(fontSize: 17),
    ),
    actions: [
      cancelButton,
      yesButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}