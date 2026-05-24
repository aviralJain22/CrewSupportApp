import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_support/features/message/chat_image_viewer_screen.dart';
import 'package:crew_support/utils/url_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'chat_controller.dart';

/// GetX Screen version of LiveChatScreen.
/// UI is kept intentionally very close to old layout.
class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColor.bgColor1,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // SizerUtil().toString();

    return WillPopScope(
      onWillPop: () => controller.handleWillPop(context),
      child: Scaffold(
        backgroundColor: AppColor.bgColor1,
        appBar: AppBar(
          toolbarHeight: 70.0,
          elevation: 2,
          backgroundColor: AppColor.bgColor2,
          centerTitle: true,
          leadingWidth: 30.0.w,
          title: GestureDetector(
            onTap: () => controller.goToProfileScreen(context),
            child: const Padding(
              padding: EdgeInsets.only(left: 18.0),
              child: _ReceiverName(),
            ),
          ),
          actions: [
            GetBuilder<ChatController>(
              builder: (c) {
                return Row(
                  children: [
                    PopupMenuButton<String>(
                      color: AppColor.bgColor2,
                      icon: Icon(Icons.more_vert, color: AppColor.textColor1),
                      onSelected: (String value) {
                        if (value == 'mark_unread') {
                          c.markConversationAsUnread(context);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'mark_unread',
                          child: Text(
                            'Mark as unread',
                            style: TextStyle(color: AppColor.textColor1),
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: c.copySelected.value == true,
                      child: Tooltip(
                        message: 'Copy',
                        child: IconButton(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: c.copyText.value),
                            ).then((_) {
                              c.showSnackBarLiveChat();
                              c.clearSelection();
                            });
                          },
                          icon: Icon(Icons.copy, color: AppColor.textColor1),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: false,
                      child: Tooltip(
                        message: 'Delete',
                        child: IconButton(
                          onPressed: () {
                            c.clearSelection();
                          },
                          icon: Icon(Icons.delete, color: AppColor.textColor1),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
          leading: Row(
            children: [
              IconButton(
                onPressed: () async {
                  if (controller.isLongPressed.value == true) {
                    controller.clearSelection();
                    return;
                  }
                  // Same behavior as old: set online false then pop/back routing.
                  await controller.handleWillPop(context);
                },
                icon: Platform.isIOS
                    ? const Icon(Icons.arrow_back_ios)
                    : const Icon(Icons.arrow_back),
                color: AppColor.secondaryColor1,
              ),
              GestureDetector(
                onTap: () => controller.goToProfileScreen(context),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColor.secondaryColor1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: SizedBox(
                      height: 60.0.sp, // dimension, keep old .sp usage
                      width: 60.0.sp,
                      child: (controller.messageData.photoPath ?? '').trim().isEmpty
                        ? CircleAvatar(
                            backgroundColor: AppColor.secondaryColor1,
                            child: Icon(Icons.person, color: AppColor.bgColor1),
                          )
                        : Image.network(
                            controller.messageData.photoPath.toString(),
                            fit: BoxFit.fill,
                            height: 2.h,
                            width: 4.w,
                            loadingBuilder: (ctx, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: AppColor.bgColor1,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (ctx, _, __) {
                              return CircleAvatar(
                                backgroundColor: AppColor.secondaryColor1,
                                child: Icon(Icons.person, color: AppColor.bgColor1),
                              );
                            },
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                SingleChildScrollView(
                  reverse: true,
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Container(
                      padding: EdgeInsets.only(bottom: 7.0.h),
                      child: GetBuilder<ChatController>(
                        builder: (c) {
                          final elements = c.getDummyMessagesSorted();

                          if (c.isInitialLoading.value) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  LoadingAnimationWidget.threeRotatingDots(
                                    color: AppColor.secondaryColor1,
                                    size: 25.sp,
                                  ),
                                ],
                              ),
                            );
                          }

                          if (elements.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: Text(
                                  'No messages yet',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.spV2,
                                    color: AppColor.secondaryColor2,
                                  ),
                                ),
                              ),
                            );
                          }

                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: StickyGroupedListView(
                              physics: const ClampingScrollPhysics(),
                              elements: elements,
                              reverse: false,
                              shrinkWrap: true,
                              floatingHeader: true,
                              groupBy: (dynamic element) {
                                // Normalize to local time before extracting the calendar date.
                                // Parse stores dates in UTC, but the chat UI should group messages
                                // by the user's local day so grouping matches what is displayed.
                                final DateTime localDate =
                                    (element as dynamic).EntryDate!.toLocal();
                                return DateTime(
                                  localDate.year,
                                  localDate.month,
                                  localDate.day,
                                );
                              },
                              groupComparator: (DateTime v1, DateTime v2) => v2.compareTo(v1),
                              itemComparator: (dynamic e1, dynamic e2) {
                                // Compare using local timestamps directly. Re-parsing the DateTime
                                // as a string is unnecessary and makes timezone behavior harder to follow.
                                final DateTime e1Local = e1.EntryDate!.toLocal();
                                final DateTime e2Local = e2.EntryDate!.toLocal();
                                return e2Local.compareTo(e1Local);
                              },
                              order: StickyGroupedListOrder.DESC,
                              groupSeparatorBuilder: (dynamic value) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 5.0,
                                          horizontal: 8.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColor.recieveChatColor,
                                          borderRadius: BorderRadius.circular(5.0),
                                        ),
                                        margin: const EdgeInsets.symmetric(horizontal: 25.0),
                                        child: Text(
                                          // `groupSeparatorBuilder` receives one element from the group,
                                          // not the grouped `DateTime` key itself. So convert that
                                          // element's timestamp to local time and then format only the
                                          // calendar date. This keeps the separator label aligned with
                                          // the local-day grouping logic used in `groupBy` above.
                                          DateFormat('MM/dd/yyyy').format(
                                            (value as dynamic).EntryDate!.toLocal(),
                                          ),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: AppColor.textColor1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              indexedItemBuilder: (context, element, index) {
                                final data = element;

                                return Container(
                                  margin: EdgeInsets.only(left: 1.0.w, right: 1.0.w),
                                  child: Column(
                                    crossAxisAlignment: data.IsSend == true
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 1.5.h),
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        // Display each message time in local time so it matches the
                                        // local-day grouping logic used for date separators.
                                        DateFormat('hh:mm a').format(data.EntryDate!.toLocal()),
                                        style: TextStyle(
                                          fontSize: 7.spV2, // keep spV2 for font
                                          color: AppColor.textColor1,
                                        ),
                                      ),
                                      _ChatBubble(
                                        data: data,
                                        index: index,
                                      ),
                                      Visibility(
                                        visible: c.shouldShowSeenReceipt(data),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 0.4.h),
                                          child: Text(
                                            'Seen',
                                            style: TextStyle(
                                              fontSize: 7.spV2,
                                              color: AppColor.secondaryColor2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                /// Bottom input (same positioning as old)
                Positioned(
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppColor.secondaryColor1,
                          width: 1,
                        ),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: TextFormField(
                      controller: controller.messageController,
                      cursorColor: AppColor.secondaryColor1,
                      style: TextStyle(color: AppColor.secondaryColor1),
                      minLines: 1,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.newline,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'typeSomething';
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: GestureDetector(
                          onTap: () => controller.showChoiceDialog(context),
                          child: Icon(
                            Icons.attach_file,
                            size: 18.0.sp,
                            color: AppColor.secondaryColor1,
                          ),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () => controller.handleSendPressed(context),
                          child: Container(
                            margin: EdgeInsets.only(right: 2.0.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.secondaryColor1,
                            ),
                            child: Icon(
                              Icons.send,
                              color: AppColor.bgColor2,
                            ),
                          ),
                        ),
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: AppColor.secondaryColor2),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 15.0,
                        ),
                        filled: true,
                        fillColor: AppColor.bgColor1,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiverName extends StatelessWidget {
  const _ReceiverName();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ChatController>();
    return Text(
      c.messageData.receivername.toString(),
      style: TextStyle(color: AppColor.secondaryColor1),
    );
  }
}

/// One bubble (text or image) with the same tap/long-press behaviors.
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.data,
    required this.index,
  });

  final dynamic data; // FirebaseChatModel
  final int index;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ChatController>();

    return GestureDetector(
      onTap: () {
        if (data.MessageType == true) {
          if (c.isLongPressed.value == true) {
            c.clearSelection();
            return;
          }

          if (data.IsImageAttachment == true &&
              (data.AttachmentUrl ?? '').toString().trim().isNotEmpty) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatImageViewerScreen(
                  imageUrl: data.AttachmentUrl.toString(),
                ),
              ),
            );
          }
        } else {
          if (c.isLongPressed.value == true) {
            c.clearSelection();
          }
        }
      },
      onLongPress: () {
        if (data.MessageType == true) {
          if (c.isLongPressed.value == false) {
            c.isLongPressed.value = true;
            c.deleteData = data;
            c.selectedIndex.value = index;
            c.copySelected.value = false;
            c.copyText.value = '';
          } else {
            c.clearSelection();
          }
          debugPrint('''${data.myMsgId} \n ${data.Message}''');
        } else {
          if (c.isLongPressed.value == false) {
            c.isLongPressed.value = true;
            c.deleteData = null;
            c.selectedIndex.value = index;
            c.copySelected.value = true;
            c.copyText.value = data.Message.toString();
          } else {
            c.clearSelection();
          }
        }
        c.update();
      },
      child: GetBuilder<ChatController>(
        builder: (_) {
          final bool isSelected = c.selectedIndex.value == index;

          return Container(
            constraints: BoxConstraints(minWidth: 20.w, maxWidth: 70.w),
            padding: const EdgeInsets.only(left: 9, right: 9, top: 7, bottom: 7),
            decoration: (data.IsSend == true)
                ? BoxDecoration(
                    color: isSelected
                        ? AppColor.chatSelectedColor
                        : AppColor.sendChatColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                  )
                : BoxDecoration(
                    color: isSelected
                        ? AppColor.chatSelectedColor
                        : AppColor.recieveChatColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                  ),
            child: data.MessageType == true
                ? (data.IsImageAttachment == true
                    ? _ImageMessage(data: data, index: index, isSelected: isSelected)
                    : _FileMessage(data: data, isSelected: isSelected))
                : _TextMessage(data: data, index: index, isSelected: isSelected),
          );
        },
      ),
    );
  }
}

class _ImageMessage extends StatelessWidget {
  const _ImageMessage({
    required this.data,
    required this.index,
    required this.isSelected,
  });

  final dynamic data;
  final int index;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    // final c = Get.find<ChatController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          semanticContainer: true,
          child: CachedNetworkImage(
            imageUrl: (data.AttachmentUrl ?? '').toString().trim().isNotEmpty
                ? data.AttachmentUrl.toString()
                : data.Message.toString(),
            progressIndicatorBuilder: (ctx, url, downloadProgress) {
              return Center(
                child: SizedBox(
                  height: 15.0.h,
                  width: 30.0.w,
                  child: Center(
                    child: SizedBox(
                      height: 5.0.h,
                      width: 10.0.w,
                      child: CircularProgressIndicator(
                        color: AppColor.secondaryColor1,
                        value: downloadProgress.progress,
                        strokeWidth: 1.sp,
                      ),
                    ),
                  ),
                ),
              );
            },
            errorWidget: (ctx, url, error) {
              return Container(
                height: 15.0.h,
                width: 30.0.w,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColor.chatSelectedColor
                      : (data.IsSend == true
                          ? AppColor.sendChatColor
                          : AppColor.recieveChatColor),
                  borderRadius: BorderRadius.circular(2.0),
                ),
                child: Icon(Icons.error_outline_rounded, color: AppColor.bgColor1),
              );
            },
          ),
        ),
        (data.TextWithImg == null || data.TextWithImg.toString().isEmpty)
            ? const SizedBox()
            : Padding(
                padding: EdgeInsets.symmetric(vertical: 2.sp, horizontal: 1.sp),
                child: Linkify(
                  onOpen: (link) async {
                    if (await canLaunchUrl(Uri.parse(link.url))) {
                      await launchUrl(
                        Uri.parse(link.url),
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      throw 'Could not launch $link';
                    }
                  },
                  text: data.TextWithImg ?? "",
                  style: TextStyle(
                    fontSize: 12.spV2, // font size -> spV2
                    color: isSelected
                        ? AppColor.textColor2
                        : (data.IsSend == true
                            ? AppColor.textColor2
                            : AppColor.textColor1),
                  ),
                  linkStyle: TextStyle(
                    fontSize: 12.spV2,
                    color: isSelected ? Colors.white : Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  options: const LinkifyOptions(
                    humanize: false,
                    removeWww: true,
                    looseUrl: true,
                  ),
                ),
              ),
      ],
    );
  }
}

class _FileMessage extends StatelessWidget {
  const _FileMessage({
    required this.data,
    required this.isSelected,
  });

  final dynamic data;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final Color textColor = isSelected
        ? AppColor.textColor2
        : (data.IsSend == true ? AppColor.textColor2 : AppColor.textColor1);

    return InkWell(
      onTap: () async {
        final String url = (data.AttachmentUrl ?? '').toString();
        if (url.isEmpty) {
          return;
        }
        if (await canLaunchUrl(Uri.parse(url))) {
          UrlHelper.openInAppNoContext(url);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_file,
              color: textColor,
              size: 18,
            ),
            SizedBox(width: 2.w),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (data.AttachmentName == null || data.AttachmentName.toString().trim().isEmpty)
                        ? 'Attachment'
                        : data.AttachmentName.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.spV2,
                      color: textColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  if ((data.TextWithImg ?? '').toString().trim().isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 0.6.h),
                      child: Text(
                        data.TextWithImg.toString(),
                        style: TextStyle(
                          fontSize: 11.spV2,
                          color: textColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextMessage extends StatelessWidget {
  const _TextMessage({
    required this.data,
    required this.index,
    required this.isSelected,
  });

  final dynamic data;
  final int index;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ChatController>();

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Linkify(
        onOpen: (link) async {
          // same special-case as old: if selection is active, clear selection instead of opening
          if (c.isLongPressed.value == true && c.copySelected.value == true) {
            c.clearSelection();
            return;
          }
          if (await canLaunchUrl(Uri.parse(link.url))) {
            await launchUrl(
              Uri.parse(link.url),
              mode: LaunchMode.externalApplication,
            );
          } else {
            throw 'Could not launch $link';
          }
        },
        text: data.Message.toString(),
        style: TextStyle(
          fontSize: 12.spV2, // font size -> spV2
          color: isSelected
              ? AppColor.textColor2
              : (data.IsSend == true ? AppColor.textColor2 : AppColor.textColor1),
        ),
        linkStyle: TextStyle(
          fontSize: 12.spV2,
          color: isSelected ? Colors.white : Colors.blue,
          decoration: TextDecoration.underline,
        ),
        options: const LinkifyOptions(
          humanize: false,
          removeWww: true,
          looseUrl: true,
        ),
      ),
    );
  }
}