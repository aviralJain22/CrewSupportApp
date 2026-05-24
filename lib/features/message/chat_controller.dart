import 'dart:async';
import 'dart:io';
import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/model/chat_model.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crew_support/helper/user_helper.dart';
import 'package:crew_support/model/chat_message_list_model.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Controller for the one-to-one chat screen.
///
/// Responsibilities handled here:
/// - loading the current conversation membership row
/// - fetching and mapping existing messages from Parse
/// - subscribing to live message updates
/// - marking messages/conversation as read
/// - handling message selection/copy state for the UI
/// - preparing image attachments picked from gallery/camera
/// - sending plain-text messages
class ChatController extends GetxController {
  ChatController({
    required this.messageData,
    this.fromNotification = false,
    this.unreadMessage,
    this.conversationId,
    this.otherUserId,
    this.otherProfileType,
  });

  /// Data passed into the chat screen when it is opened.
  final Messages messageData;
  final bool fromNotification;
  final bool? unreadMessage;
  final String? conversationId;
  final String? otherUserId;
  final int? otherProfileType;

  /// Reactive values consumed by the chat UI.
  final RxInt msgCount = 0.obs;
  final RxBool isLongPressed = false.obs;
  final RxInt selectedIndex = (-1).obs;
  final RxBool copySelected = false.obs;
  final RxString copyText = ''.obs;

  /// True only while the first message fetch for this chat is in progress.
  ///
  /// This lets the UI distinguish between:
  /// - a real loading state, and
  /// - a valid empty conversation with no messages yet.
  final RxBool isInitialLoading = true.obs;

  /// Non-reactive helpers used internally by the controller.
  final String appType = UserHelper().getAppType().toString();
  final TextEditingController messageController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  /// Stores the currently selected image message, if any.
  ChatModel? deleteData;

  /// Cached copy of the current message list used by legacy UI code.
  List<ChatModel> dataList = [];

  /// Messages currently visible in the conversation.
  final RxList<ChatModel> messages = <ChatModel>[].obs;


  /// Profile context currently selected on the dashboard.
  final DashboardController _dashboardController = Get.find<DashboardController>();
  /// Current user's ConversationMember row for this conversation.
  final Rxn<ParseObject> myConversationMember = Rxn<ParseObject>();
  /// Read-receipt state for the other participant in a direct chat.
  final RxString otherLastReadMessageId = ''.obs;
  final Rxn<DateTime> otherLastReadAt = Rxn<DateTime>();

  ParseUser? _currentUser;
  LiveQuery? _liveQuery;
  Subscription<ParseObject>? _messageSubscription;
  Subscription<ParseObject>? _otherMemberSubscription;
  /// Prevents overlapping `markConversationRead` requests when the same
  /// conversation is updated from multiple entry points close together
  /// (initial load, live updates, back navigation, etc.).
  bool _isMarkingConversationRead = false;
  /// Debounces repeated read-mark requests when multiple incoming messages
  /// arrive close together while this chat screen is open.
  Timer? _markReadDebounce;

  /// Becomes true after the user explicitly marks this chat as unread from the
  /// chat screen. While this flag is set for the current screen session, we
  /// must not auto-mark the conversation as read again on back navigation or
  /// from live incoming-message updates, otherwise the manual unread action
  /// would be undone immediately.
  bool _manuallyMarkedUnreadThisSession = false;

  /// Read receipts are currently shown only for one-to-one chats.
  bool get _supportsReadReceipts => messageData.isGroup != true;

  /// Resolved conversation id, regardless of how the screen was opened.
  String get _activeConversationId => conversationId ?? messageData.conversationId ?? '';

  /// Active profile type (pilot/SIC/FA/etc.) currently selected by the user.
  int get _activeProfileType => _dashboardController.selectedProfileType.value;

  /// Composite key used by backend rows to identify a user-profile combination.
  String get _myProfileKey {
    final String userId = _currentUser?.objectId ?? '';
    return '$userId:${_activeProfileType.toString()}';
  }

  /// Exact participant key for the other side of this one-to-one conversation.
  ///
  /// Using the resolved participant key is safer than a `not equal` filter for
  /// read-receipt queries/subscriptions because it prevents this controller from
  /// accidentally treating the current user's own ConversationMember row as the
  /// remote participant's row.
  String get _otherProfileKey {
    final String userId = (otherUserId ?? messageData.otherUserId ?? '').trim();
    final int? profileType = otherProfileType ?? messageData.otherProfileType;
    if (userId.isEmpty || profileType == null) {
      return '';
    }
    return '$userId:$profileType';
  }


  /// Resolved Parse _User objectId for the other participant.
  String get _otherUserObjectId => (otherUserId ?? messageData.otherUserId ?? '').trim();

  /// Resolved membership/profile type for the other participant.
  int? get _otherResolvedProfileType => otherProfileType ?? messageData.otherProfileType;


  @override
  void onInit() {
    super.onInit();
    debugPrint('In the Live Chat ');
    debugPrint('conversationId -- $_activeConversationId');
    debugPrint('otherUserId -- ${otherUserId ?? messageData.otherUserId}');
    debugPrint('otherProfileType -- $otherProfileType');
    debugPrint(_supportsReadReceipts ? 'Read receipts: supported for this chat' : 'Read receipts: NOT supported for this chat');
    _initialLoad();
  }

  @override
  void onClose() {
    EasyLoading.dismiss();
    messageController.dispose();
    _markReadDebounce?.cancel();
    _unsubscribeLiveQuery();
    debugPrint('dispose live chat (GetX)');
    super.onClose();
  }

  /// Performs the initial chat bootstrap when the screen opens.
  Future<void> _initialLoad() async {
    isInitialLoading.value = true;
    try {
      _currentUser = await ParseUser.currentUser() as ParseUser?;
      if (_currentUser == null) {
        throw Exception('User must be logged in to open chat.');
      }

      if (_activeConversationId.isEmpty) {
        throw Exception('Missing conversation id.');
      }

      await _loadConversationMember();
      await _loadOtherConversationReadState();
      await _loadMessages();
      await _subscribeToMessages();
      await _markConversationRead();
    } catch (e) {
      debugPrint('$e');
      Get.snackbar('Chat', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isInitialLoading.value = false;
      update();
    }
  }

  /// Loads the ConversationMember row for the current user in this chat.
  Future<void> _loadConversationMember() async {
    final QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('ConversationMember'))
      ..whereEqualTo('conversation', ParseObject('Conversation')..objectId = _activeConversationId)
      ..whereEqualTo('profileKey', _myProfileKey)
      ..setLimit(1);

    final ParseResponse response = await query.query();
    if (!response.success) {
      throw Exception(response.error?.message ?? 'Failed to load chat state.');
    }

    final ParseObject? member = (response.results ?? <dynamic>[])
        .whereType<ParseObject>()
        .cast<ParseObject?>()
        .firstWhere((ParseObject? row) => row != null, orElse: () => null);

    if (member == null) {
      throw Exception('Conversation membership not found.');
    }

    myConversationMember.value = member;
  }

  /// Fetches messages from Parse and maps them into `ChatModel` objects.
  Future<void> _loadMessages() async {
    final QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('Message'))
      ..whereEqualTo('conversation', ParseObject('Conversation')..objectId = _activeConversationId)
      ..orderByAscending('createdAt')
      ..setLimit(500);

    final DateTime? lastClearedAt = myConversationMember.value?.get<DateTime>('lastClearedAt');
    if (lastClearedAt != null) {
      query.whereGreaterThan('createdAt', lastClearedAt);
    }

    final ParseResponse response = await query.query();
    if (!response.success) {
      throw Exception(response.error?.message ?? 'Failed to load messages.');
    }

    final List<ParseObject> rows = (response.results ?? <dynamic>[])
        .whereType<ParseObject>()
        .toList();

    final List<ChatModel> parsed = rows.map(_mapMessageObjectToChatModel).toList()
      ..sort((ChatModel a, ChatModel b) {
        final DateTime aDate = a.EntryDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        final DateTime bDate = b.EntryDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
      });


    messages.assignAll(parsed);
    dataList = List<ChatModel>.from(parsed);
    _updateNewMessageBannerCount();
    _debugPrintReadReceiptSnapshot(reason: '_loadMessages');
    update();
  }

  /// Subscribes to live create/update/delete events for this conversation.
  Future<void> _subscribeToMessages() async {
    _unsubscribeLiveQuery();

    _liveQuery = LiveQuery();

    final QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('Message'))
      ..whereEqualTo('conversation', ParseObject('Conversation')..objectId = _activeConversationId)
      ..orderByAscending('createdAt');

    final DateTime? lastClearedAt = myConversationMember.value?.get<DateTime>('lastClearedAt');
    if (lastClearedAt != null) {
      query.whereGreaterThan('createdAt', lastClearedAt);
    }

    _messageSubscription = await _liveQuery!.client.subscribe(query);
    await _subscribeToOtherConversationMember();

    _messageSubscription!.on(LiveQueryEvent.create, (ParseObject value) async {
      debugPrint('[ChatController] (MessageLiveQueryEvent) message created: $value');
      final ChatModel incoming = _mapMessageObjectToChatModel(value);
      final bool exists = messages.any((ChatModel item) => item.objectId == incoming.objectId);

      if (!exists) {
        messages.add(incoming);
        messages.sort((ChatModel a, ChatModel b) {
          final DateTime aDate = a.EntryDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          final DateTime bDate = b.EntryDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          return aDate.compareTo(bDate);
        });


        dataList = List<ChatModel>.from(messages);
        _updateNewMessageBannerCount();
        _debugPrintReadReceiptSnapshot(reason: 'LiveQueryEvent.create');
        update();
      }

      if (incoming.IsReceive == true) {
        _scheduleMarkConversationRead();
      }
    });

    _messageSubscription!.on(LiveQueryEvent.update, (ParseObject value) {
      debugPrint('[ChatController] (MessageLiveQueryEvent) message updated: $value');
      final int index = messages.indexWhere((ChatModel item) => item.objectId == value.objectId);
      if (index != -1) {
        messages[index] = _mapMessageObjectToChatModel(value);
        dataList = List<ChatModel>.from(messages);
        update();
      }
    });

    _messageSubscription!.on(LiveQueryEvent.delete, (ParseObject value) {
      debugPrint('[ChatController] (MessageLiveQueryEvent) message deleted: $value');
      messages.removeWhere((ChatModel item) => item.objectId == value.objectId);
      dataList = List<ChatModel>.from(messages);
      _updateNewMessageBannerCount();
      update();
    });
  }

  /// Safely tears down the active live query subscription.
  void _unsubscribeLiveQuery() {
    if (_messageSubscription != null && _liveQuery != null) {
      _liveQuery!.client.unSubscribe(_messageSubscription!);
      _messageSubscription = null;
      debugPrint('Unsubscribed from message live query');
    }
    if (_otherMemberSubscription != null && _liveQuery != null) {
      _liveQuery!.client.unSubscribe(_otherMemberSubscription!);
      _otherMemberSubscription = null;
      debugPrint('Unsubscribed from other member live query');
    }
  }

  /// Loads the other participant's current read state for direct-chat receipts.
  Future<void> _loadOtherConversationReadState() async {
    if (!_supportsReadReceipts) {
      debugPrint('[ChatController] skipping load of other read state - read receipts not supported for this chat');
      otherLastReadMessageId.value = '';
      otherLastReadAt.value = null;
      return;
    }

    if (_otherUserObjectId.isEmpty || _otherResolvedProfileType == null) {
      debugPrint('[ChatController] skipping load of other read state - other participant identity is incomplete');
      otherLastReadMessageId.value = '';
      otherLastReadAt.value = null;
      return;
    }

    final QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('ConversationMember'))
      ..whereEqualTo('conversation', ParseObject('Conversation')..objectId = _activeConversationId)
      ..whereEqualTo('user', ParseUser.forQuery()..objectId = _otherUserObjectId)
      ..whereEqualTo('profileType', _otherResolvedProfileType)
      ..includeObject(['lastReadMessage'])
      ..setLimit(1);

    debugPrint('[ChatController] loading other read state with query: ${query.buildQuery().toString()}');

    final ParseResponse response = await query.query();
    if (!response.success) {
      debugPrint(response.error?.message ?? 'Failed to load other read state.');
      return;
    }

    debugPrint('[ChatController] raw other member query response: ${response.results}');

    final ParseObject? member = (response.results ?? <dynamic>[])
        .whereType<ParseObject>()
        .cast<ParseObject?>()
        .firstWhere((ParseObject? row) => row != null, orElse: () => null);

    debugPrint('[ChatController] parsed other member: $member');

    _applyOtherConversationReadState(member);
  }

  /// Subscribes to the other participant's ConversationMember row so read
  /// receipts update live while the current user is sitting on this screen.
  Future<void> _subscribeToOtherConversationMember() async {
    if (!_supportsReadReceipts) {
      return;
    }

    if (_otherUserObjectId.isEmpty || _otherResolvedProfileType == null) {
      debugPrint('[ChatController] skipping other read-state subscription - other participant identity is incomplete');
      return;
    }

    debugPrint('[ChatController] subscribing to other ConversationMember with conversationId=$_activeConversationId user=$_otherUserObjectId profileType=$_otherResolvedProfileType myProfileKey=$_myProfileKey otherProfileKey=$_otherProfileKey');

    final QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('ConversationMember'))
      ..whereEqualTo('conversation', ParseObject('Conversation')..objectId = _activeConversationId)
      ..whereEqualTo('user', ParseUser.forQuery()..objectId = _otherUserObjectId)
      ..whereEqualTo('profileType', _otherResolvedProfileType)
      ..includeObject(['lastReadMessage'])
      ..setLimit(1);

    debugPrint('[ChatController] other member live query: ${query.buildQuery().toString()}');
    _otherMemberSubscription = await _liveQuery!.client.subscribe(query);

    _otherMemberSubscription!.on(LiveQueryEvent.create, (ParseObject value) {
      debugPrint('[ChatController] (ConversationMemberLiveQueryEvent) other member created/updated: $value');
      _applyOtherConversationReadState(value);
    });

    _otherMemberSubscription!.on(LiveQueryEvent.update, (ParseObject value) {
      debugPrint('[ChatController] (ConversationMemberLiveQueryEvent) other member updated: $value');
      _applyOtherConversationReadState(value);
    });

    _otherMemberSubscription!.on(LiveQueryEvent.enter, (ParseObject value) {
      debugPrint('[ChatController] (ConversationMemberLiveQueryEvent) other member entered: $value');
      _applyOtherConversationReadState(value);
    });

    _otherMemberSubscription!.on(LiveQueryEvent.leave, (ParseObject value) {
      debugPrint('[ChatController] (ConversationMemberLiveQueryEvent) other member left: $value');
      otherLastReadMessageId.value = '';
      otherLastReadAt.value = null;
      update();
    });

    _otherMemberSubscription!.on(LiveQueryEvent.delete, (ParseObject value) {
      debugPrint('[ChatController] (ConversationMemberLiveQueryEvent) other member deleted: $value');
    });

    _otherMemberSubscription!.on(LiveQueryEvent.error, (Object error) {
      debugPrint('[ChatController] (ConversationMemberLiveQueryEvent) subscription error: $error');
    });
  }

  void _applyOtherConversationReadState(ParseObject? member) {
    final String incomingProfileKey = (member?.get<String>('profileKey') ?? '').trim();
    final String incomingUserId = member?.get<ParseUser>('user')?.objectId ?? '';
    final int? incomingProfileType = member?.get<int>('profileType');

    if (incomingProfileKey.isEmpty) {
      debugPrint('[ChatController] ignoring other read state update - empty profileKey');
      return;
    }

    if (incomingProfileKey == _myProfileKey) {
      debugPrint(
        '[ChatController] ignoring other read state update - received my own ConversationMember row: '
        '$incomingProfileKey',
      );
      return;
    }

    if (_otherUserObjectId.isNotEmpty && incomingUserId != _otherUserObjectId) {
      debugPrint(
        '[ChatController] ignoring other read state update - unexpected user: '
        '$incomingUserId expected=$_otherUserObjectId',
      );
      return;
    }

    if (_otherResolvedProfileType != null && incomingProfileType != _otherResolvedProfileType) {
      debugPrint(
        '[ChatController] ignoring other read state update - unexpected profileType: '
        '$incomingProfileType expected=$_otherResolvedProfileType',
      );
      return;
    }

    debugPrint(
      '[ChatController] applying other read state update '
      'for user=$incomingUserId '
      'profileType=$incomingProfileType '
      'profileKey=$incomingProfileKey '
      'member=$member',
    );
    final ParseObject? lastReadMessage = member?.get<ParseObject>('lastReadMessage');
    otherLastReadMessageId.value = lastReadMessage?.objectId ?? '';
    otherLastReadAt.value = member?.get<DateTime>('lastReadAt');

    debugPrint(
      '[ChatController] other read state updated: '
      'lastReadMessageId=${otherLastReadMessageId.value} '
      'lastReadAt=${otherLastReadAt.value?.toIso8601String()}',
    );
    _debugPrintReadReceiptSnapshot(reason: '_applyOtherConversationReadState');
    update();
  }

  /// Debug helper to understand which outgoing message the current read cursor
  /// points to, especially after reopening the chat from MessageScreen.
  void _debugPrintReadReceiptSnapshot({required String reason}) {
    final List<ChatModel> sentMessages = messages
        .where((ChatModel item) => item.IsSend == true)
        .toList()
      ..sort((ChatModel a, ChatModel b) {
        final DateTime aDate = a.EntryDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        final DateTime bDate = b.EntryDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
      });

    final String cursorMessageId = otherLastReadMessageId.value;
    final DateTime? cursorReadAt = otherLastReadAt.value;

    debugPrint('[ChatController] ---- Read receipt snapshot ($reason) ----');
    debugPrint('[ChatController] supportsReadReceipts=$_supportsReadReceipts');
    debugPrint('[ChatController] cursorMessageId=$cursorMessageId');
    debugPrint('[ChatController] cursorReadAt=${cursorReadAt?.toIso8601String()}');
    debugPrint('[ChatController] sentMessagesCount=${sentMessages.length}');

    for (final ChatModel item in sentMessages) {
      final DateTime itemDate = item.EntryDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bool cursorMatches = item.objectId == cursorMessageId;
      final bool passesTimeCheck = cursorReadAt != null && !itemDate.isAfter(cursorReadAt);
      debugPrint(
        '[ChatController] sentMessage '
        'id=${item.objectId} '
        'time=${itemDate.toIso8601String()} '
        'cursorMatches=$cursorMatches '
        'passesTimeCheck=$passesTimeCheck '
        'text=${item.Message}',
      );
    }

    debugPrint('[ChatController] ---- End read receipt snapshot ----');
  }

  /// Returns true for the exact outgoing message that the other participant has
  /// most recently read.
  ///
  /// This intentionally allows "Seen" to remain on an older outgoing message
  /// even when newer outgoing messages exist and are still unread. That matches
  /// the requested behavior and gives a clearer signal about the true read
  /// boundary.
  bool shouldShowSeenReceipt(ChatModel data) {
    if (!_supportsReadReceipts) {
      debugPrint('[ChatController] shouldShowSeenReceipt=FALSE - read receipts not supported for this chat');
      return false;
    }
    if (data.IsSend != true) {
      debugPrint('[ChatController] shouldShowSeenReceipt=FALSE - message is not outgoing');
      return false;
    }
    if (otherLastReadMessageId.value.isEmpty) {
      debugPrint('[ChatController] shouldShowSeenReceipt=FALSE - no read message found');
      return false;
    }

    // Only the exact message pointed to by the backend read cursor can show a receipt.
    if (data.objectId != otherLastReadMessageId.value) {
      debugPrint('[ChatController] shouldShowSeenReceipt=FALSE - message does not match read cursor');
      return false;
    }

    final DateTime? readAt = otherLastReadAt.value;
    final DateTime? messageAt = data.EntryDate;
    if (readAt == null || messageAt == null) {
      debugPrint('[ChatController] shouldShowSeenReceipt=FALSE - null date found');
      return false;
    }

    final bool isSeen = !messageAt.isAfter(readAt);

    if (isSeen) {
      debugPrint(
        '[ChatController] shouldShowSeenReceipt=TRUE '
        'messageId=${data.objectId} '
        'messageAt=${messageAt.toIso8601String()} '
        'readAt=${readAt.toIso8601String()}',
      );
    } else {
      debugPrint(
        '[ChatController] shouldShowSeenReceipt=FALSE - message not yet read by other participant '
        'messageId=${data.objectId} '
        'messageAt=${messageAt.toIso8601String()} '
        'readAt=${readAt.toIso8601String()}',
      );
    }

    return isSeen;
  }

  /// Converts a Parse `Message` row into the UI-friendly `ChatModel` shape.
  ChatModel _mapMessageObjectToChatModel(ParseObject row) {
    final String senderKey = (row.get<String>('senderKey') ?? '').trim();
    final bool isSend = senderKey == _myProfileKey;
    final DateTime entryDate = row.createdAt ?? DateTime.now();
    final ParseFileBase? file = row.get<ParseFileBase>('file');
    final String text = (row.get<String>('text') ?? '').trim();
    final String attachmentUrl = (file?.url ?? '').trim();
    final String attachmentName = _normalizeAttachmentDisplayName((file?.name ?? '').trim());

    final String lowerName = attachmentName.toLowerCase();
    final bool isImageAttachment = attachmentUrl.isNotEmpty &&
        (lowerName.endsWith('.jpg') ||
            lowerName.endsWith('.jpeg') ||
            lowerName.endsWith('.png') ||
            lowerName.endsWith('.gif') ||
            lowerName.endsWith('.webp') ||
            lowerName.endsWith('.heic'));

    final bool hasAttachment = attachmentUrl.isNotEmpty;

    return ChatModel(
      objectId: row.objectId ?? '',
      myMsgId: row.objectId ?? '',
      Message: isImageAttachment
          ? attachmentUrl
          : (hasAttachment ? (attachmentName.isNotEmpty ? attachmentName : 'Attachment') : text),
      SenderId: senderKey,
      IsRead: isSend ? true : false,
      IsReceive: !isSend,
      EntryDate: entryDate,
      IsSend: isSend,
      MessageType: hasAttachment,
      TextWithImg: hasAttachment ? text : '',
      OppositeId: otherUserId ?? messageData.otherUserId ?? '',
      IsDelete: false,
      AttachmentUrl: attachmentUrl,
      AttachmentName: attachmentName,
      IsImageAttachment: isImageAttachment,
    );
  }

  /// Parse file storage may prefix uploaded file names with a generated hash,
  /// for example: `43700afe90de51d8120c23d5d5a13c3d_sample.pdf`.
  ///
  /// For chat UI display, we only want the original user-facing file name,
  /// so strip that generated prefix when present.
  String _normalizeAttachmentDisplayName(String rawName) {
    if (rawName.isEmpty) {
      return rawName;
    }

    // Common Parse-style prefix: 32+ hex chars followed by underscore.
    final RegExp prefixedNamePattern = RegExp(r'^[a-fA-F0-9]{32,}_(.+)$');
    final Match? match = prefixedNamePattern.firstMatch(rawName);
    if (match != null) {
      final String cleaned = (match.group(1) ?? '').trim();
      if (cleaned.isNotEmpty) {
        return cleaned;
      }
    }

    return rawName;
  }

  void _updateNewMessageBannerCount() {
    final int unreadReceivedCount =
        messages.where((ChatModel item) => item.IsReceive == true && item.IsRead == false).length;
    msgCount.value = unreadReceivedCount;
  }

  /// Returns messages sorted by timestamp for rendering.
  List<ChatModel> getDummyMessagesSorted() {
    final list = List<ChatModel>.from(messages);
    list.sort((a, b) {
      final aDt = a.EntryDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDt = b.EntryDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aDt.toUtc().toLocal().compareTo(bDt.toUtc().toLocal());
    });
    return list;
  }

  /// Handles both system back and app-bar back actions.
  Future<bool> handleWillPop(BuildContext context) async {
    if (isLongPressed.value == true) {
      clearSelection();
      return false;
    }

    try {
      if (!_manuallyMarkedUnreadThisSession) {
        await _markConversationRead();
      }
      Navigator.pop(context);
      return true;
    } catch (e) {
      debugPrint('$e');
      return false;
    }
  }

  /// Clears any currently selected message bubble.
  void clearSelection() {
    isLongPressed.value = false;
    copySelected.value = false;
    copyText.value = '';
    selectedIndex.value = -1;
    deleteData = null;
    update(); // for GetBuilder usage
  }


  void showSnackBarLiveChat() {
    EasyLoading.showToast(
      "Copied!",
      toastPosition: EasyLoadingToastPosition.center,
    );
  }


  /// Shows the legacy delete dialog placeholder.
  void showDeleteMessage(BuildContext context, ChatModel data) {
    final TextButton cancelButton = TextButton(
      onPressed: () {
        Navigator.pop(context);
        clearSelection();
      },
      child: Text(
        'Cancel',
        style: TextStyle(color: AppColor.secondaryColor1),
      ),
    );

    final TextButton okButton = TextButton(
      onPressed: () {
        Navigator.pop(context);
        clearSelection();
      },
      child: Text(
        'OK',
        style: TextStyle(color: AppColor.secondaryColor1),
      ),
    );

    final CupertinoAlertDialog alert = CupertinoAlertDialog(
      content: const Text(
        'Message deletion is no longer supported here.',
        style: TextStyle(fontSize: 17),
      ),
      actions: <Widget>[okButton, cancelButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext c) => Theme(
        data: ThemeData.dark(),
        child: alert,
      ),
    );
  }

  /// Lets the user choose whether to attach from gallery or camera.
  void showChoiceDialog(BuildContext context) {
    final action = Theme(
      data: ThemeData.dark(),
      child: CupertinoActionSheet(
        title: Text(
          "Choose option",
          style: TextStyle(fontSize: 15, color: AppColor.textColor1),
        ),
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              openGallery(context);
            },
            child: Text(
              "Gallery",
              style: TextStyle(fontSize: 15, color: AppColor.textColor1),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              openCamera(context);
            },
            child: Text(
              "Camera",
              style: TextStyle(fontSize: 15, color: AppColor.textColor1),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              pickDocument(context);
            },
            child: Text(
              "Files",
              style: TextStyle(fontSize: 15, color: AppColor.textColor1),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: TextStyle(fontSize: 15, color: AppColor.secondaryColor1),
          ),
        ),
      ),
    );

    showCupertinoModalPopup(context: context, builder: (_) => action);
  }

  /// Picks an image from gallery, compresses it, and sends it to the current chat.
  Future<void> openGallery(BuildContext context) async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      EasyLoading.dismiss();
      return;
    }

    showLoadingDialog(context, 'Loading...');

    try {
      final File compressedFile = File((await compressImage(File(pickedFile.path))).path);
      // Enforce maximum image size of 5 MB after compression
      const int maxImageSizeBytes = 5 * 1024 * 1024; // 5 MB
      final int imageSize = await compressedFile.length();

      if (imageSize > maxImageSizeBytes) {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        EasyLoading.dismiss();
        showMyDialog(context, 'Image size must be 5 MB or less.');
        return;
      }
      final String caption = messageController.text.trim();

      await sendMessage(
        message: '',
        messageType: true,
        textWithImg: caption,
        attachmentFile: compressedFile,
      );
      _manuallyMarkedUnreadThisSession = false;
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      messageController.clear();


      EasyLoading.dismiss();
    } catch (e) {
      debugPrint('$e');
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      EasyLoading.dismiss();
      showMyDialog(context, e.toString());
    }
  }

  /// Captures an image with the camera, compresses it, and sends it to the current chat.
  Future<void> openCamera(BuildContext context) async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) {
      EasyLoading.dismiss();
      return;
    }

    showLoadingDialog(context, 'Loading...');

    try {
      final File compressedFile = File((await compressImage(File(pickedFile.path))).path);
      // Enforce maximum image size of 5 MB after compression
      const int maxImageSizeBytes = 5 * 1024 * 1024; // 5 MB
      final int imageSize = await compressedFile.length();

      if (imageSize > maxImageSizeBytes) {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        EasyLoading.dismiss();
        showMyDialog(context, 'Image size must be 5 MB or less.');
        return;
      }
      final String caption = messageController.text.trim();

      await sendMessage(
        message: '',
        messageType: true,
        textWithImg: caption,
        attachmentFile: compressedFile,
      );
      _manuallyMarkedUnreadThisSession = false;
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      messageController.clear();


      EasyLoading.dismiss();
    } catch (e) {
      debugPrint('$e');
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      EasyLoading.dismiss();
      showMyDialog(context, e.toString());
    }
  }

  /// Picks a generic file (for example PDF) and sends it to the current chat.
  Future<void> pickDocument(BuildContext context) async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty || result.files.single.path == null) {
      EasyLoading.dismiss();
      return;
    }

    showLoadingDialog(context, 'Loading...');

    try {
      // Enforce maximum file size of 10 MB
      const int maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB
      final int fileSize = result.files.single.size;

      if (fileSize > maxFileSizeBytes) {
        EasyLoading.dismiss();
        showMyDialog(context, 'File size must be 10 MB or less.');
        return;
      }

      final File pickedFile = File(result.files.single.path!);
      final String originalFileName = result.files.single.name;
      final String caption = messageController.text.trim();

      await sendMessage(
        message: '',
        messageType: true,
        textWithImg: caption,
        attachmentFile: pickedFile,
        attachmentName: originalFileName,
      );
      _manuallyMarkedUnreadThisSession = false;
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      EasyLoading.dismiss();
    } catch (e) {
      debugPrint('$e');
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      EasyLoading.dismiss();
      showMyDialog(context, e.toString());
    }
  }

  /// Compresses an image file and returns the compressed output.
  Future<XFile> compressImage(File file) async {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.png|.jp'));
    final splitted = filePath.substring(0, lastIndex);
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    if (lastIndex == filePath.lastIndexOf(RegExp(r'.png'))) {
      return (await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: 70,
        format: CompressFormat.png,
      ))!;
    }

    return (await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: 70,
    ))!;
  }

  /// Refreshes local unread-count state from the backend row.
  Future<void> updateMessageCount({required dynamic oppId}) async {
    await _loadConversationMember();
    _updateNewMessageBannerCount();
  }

  /// Opens the other participant's profile detail screen from the chat header.
  ///
  /// We route based on the other participant's membership type, using the same
  /// profile detail routes that are already used from search results.
  Future<void> goToProfileScreen(BuildContext context) async {
    EasyLoading.dismiss();

    final String userId = (otherUserId ?? messageData.otherUserId ?? '').trim();
    final int? membershipType = otherProfileType;

    debugPrint('goToProfileScreen: userId=$userId, membershipType=$membershipType');

    if (userId.isEmpty || membershipType == null) {
      showMyDialog(context, 'Unable to open profile.');
      return;
    }

    if (membershipType == MembershipType.pilot) {
      Get.toNamed(
        AppRoutes.pilotViewProfile,
        arguments: {
          'userId': userId,
        },
      );
    } else if (membershipType == MembershipType.flightAttendant) {
      Get.toNamed(
        AppRoutes.fAViewProfile,
        arguments: {
          'userId': userId,
        },
      );
    } else if (membershipType == MembershipType.ownerOperator) {
      Get.toNamed(
        AppRoutes.ownerViewProfile,
        arguments: {
          'userId': userId,
        },
      );
    } else {
      debugPrint('Unsupported membershipType for chat profile open: $membershipType');
      showMyDialog(context, 'Profile detail is not available for this user.');
    }
  }

  /// Sends either a plain-text message or an attachment using the Parse cloud function.
  Future<void> sendMessage({
    required String message,
    required bool messageType,
    String? textWithImg,
    File? attachmentFile,
    String? attachmentName,
  }) async {
    final ParseCloudFunction function = ParseCloudFunction('sendMessage');
    final Map<String, dynamic> params = <String, dynamic>{
      'conversationId': _activeConversationId,
      'senderProfileType': _activeProfileType,
    };

    if (messageType) {
      if (attachmentFile == null) {
        throw Exception('Missing attachment file.');
      }

      // Determine the attachment name to use
      final String resolvedAttachmentName =
          (attachmentName ?? '').trim().isNotEmpty
              ? attachmentName!.trim()
              : attachmentFile.path.split(Platform.pathSeparator).last;

      // Upload the file first so the cloud function receives a fully-saved
      // Parse File reference (with a real URL) instead of a local placeholder.
      final ParseFile parseFile = ParseFile(
        attachmentFile,
        name: resolvedAttachmentName,
      );
      final ParseResponse fileUploadResponse = await parseFile.save();
      if (!fileUploadResponse.success) {
        throw Exception(fileUploadResponse.error?.message ?? 'Failed to upload attachment.');
      }

      params['file'] = parseFile;

      final String caption = (textWithImg ?? '').trim();
      if (caption.isNotEmpty) {
        params['text'] = caption;
      }
    } else {
      final String trimmedMessage = message.trim();
      if (trimmedMessage.isEmpty) {
        throw Exception('Please enter message');
      }
      params['text'] = trimmedMessage;
    }

    final ParseResponse response = await function.execute(parameters: params);
    if (!response.success) {
      throw Exception(response.error?.message ?? 'Failed to send message.');
    }
  }

  /// Validates input and sends the current text field message.
  Future<void> handleSendPressed(BuildContext context) async {
    EasyLoading.show(status: 'Sending...');

    if (messageController.text.trim().isEmpty) {
      showMyDialog(context, "please enter message");
      EasyLoading.dismiss();
      return;
    }

    final msg = messageController.text.trim();
    messageController.clear();
    try {
      await sendMessage(message: msg, messageType: false);
      _manuallyMarkedUnreadThisSession = false;
      // Do not mark the conversation read after sending your own message.
      // Only incoming messages can become unread for the current user.


      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
      showMyDialog(context, e.toString());
    }
  }

  /// Marks the current conversation as unread only for the active user.
  ///
  /// This sets the current user's `ConversationMember.unreadCount` to 1 so the
  /// conversation list can show it as unread after the user leaves the chat.
  /// The unread state is intentionally local to the current user's membership
  /// row and does not affect the other participant.
  Future<void> markConversationAsUnread(BuildContext context) async {
    final ParseObject? member = myConversationMember.value;
    if (member == null) {
      showMyDialog(context, 'Unable to mark conversation as unread.');
      return;
    }

    if (_activeConversationId.isEmpty || _activeProfileType == 0) {
      showMyDialog(context, 'Unable to mark conversation as unread.');
      return;
    }

    EasyLoading.show(status: 'Marking unread...');

    try {
      final ParseCloudFunction function = ParseCloudFunction('markConversationUnread');
      final ParseResponse response = await function.execute(
        parameters: <String, dynamic>{
          'conversationId': _activeConversationId,
          'profileType': _activeProfileType,
        },
      );

      if (!response.success) {
        throw Exception(response.error?.message ?? 'Failed to mark conversation as unread.');
      }

      // Mirror the expected server-side result locally so the chat list and
      // current screen state update immediately without requiring a refetch.
      member.set<int>('unreadCount', 1);
      myConversationMember.value = member;
      _manuallyMarkedUnreadThisSession = true;
      _markReadDebounce?.cancel();
      _updateNewMessageBannerCount();
      update();

      EasyLoading.dismiss();
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      EasyLoading.dismiss();
      showMyDialog(context, e.toString());
    }
  }

  /// Schedules a single debounced read-mark request while incoming live
  /// messages continue to arrive. This avoids calling the backend once per
  /// message when multiple messages are received in quick succession.
  void _scheduleMarkConversationRead() {
    debugPrint('[ChatController] scheduling mark conversation read with debounce');
    if (_manuallyMarkedUnreadThisSession) {
      debugPrint('[ChatController] skipping mark conversation read - conversation manually marked unread this session');
      return;
    }
    _markReadDebounce?.cancel();
    _markReadDebounce = Timer(const Duration(milliseconds: 500), () async {
      debugPrint('[ChatController] debounce timer fired - marking conversation read');
      await _markConversationRead();
    });
  }

  /// Marks the conversation as read and updates local message state.
  Future<void> _markConversationRead({String? lastReadMessageId}) async {
    debugPrint('[ChatController] attempting to mark conversation read with lastReadMessageId=$lastReadMessageId');
    // Avoid firing the same cloud function again while a previous
    // `markConversationRead` request is still in progress.
    if (_isMarkingConversationRead) {
      debugPrint('[ChatController] skipping mark conversation read - already in progress');
      return;
    }

    if (_manuallyMarkedUnreadThisSession) {
      debugPrint('[ChatController] skipping mark conversation read - conversation manually marked unread this session');
      return;
    }

    if (_activeConversationId.isEmpty || _activeProfileType == 0) {
      debugPrint('[ChatController] skipping mark conversation read - missing active conversation context');
      return;
    }

    // Only call the backend when there is actually something unread to mark.
    // The explicit `lastReadMessageId` override is still allowed for callers
    // that want to push a specific read position.
    final bool hasUnreadIncoming = messages.any(
      (ChatModel item) => item.IsReceive == true && item.IsRead == false,
    );

    if (!hasUnreadIncoming && (lastReadMessageId == null || lastReadMessageId.isEmpty)) {
      return;
    }

    debugPrint('[ChatController] scheduling markConversationRead with lastReadMessageId=$lastReadMessageId');

    // Lock before the async cloud call starts so rapid repeated triggers do not overlap.
    _isMarkingConversationRead = true;

    try {
      // If the caller did not provide an explicit last-read message id,
      // use only the newest incoming message currently loaded in the
      // conversation. This is critical for correct read receipts:
      //
      // - `lastReadMessage` should represent the latest message FROM THE OTHER
      //   participant that the current user has actually seen.
      // - It must never be advanced to the latest overall message in the chat,
      //   because that can incorrectly mark the current user's own newer
      //   outgoing message as "Seen" by the other participant after the chat
      //   is reopened.
      String? finalLastReadMessageId = lastReadMessageId;
      if (finalLastReadMessageId == null || finalLastReadMessageId.isEmpty) {
        final List<ChatModel> incomingMessages = messages
            .where((ChatModel item) => item.IsReceive == true)
            .toList();

        if (incomingMessages.isNotEmpty) {
          ChatModel latestIncoming = incomingMessages.first;
          for (final ChatModel item in incomingMessages) {
            final DateTime itemDate = item.EntryDate ?? DateTime.fromMillisecondsSinceEpoch(0);
            final DateTime latestDate = latestIncoming.EntryDate ?? DateTime.fromMillisecondsSinceEpoch(0);
            if (itemDate.isAfter(latestDate)) {
              latestIncoming = item;
            }
          }

          finalLastReadMessageId = latestIncoming.objectId;
        }
      }

      // If there is still no incoming message boundary to mark as read, do not
      // advance the backend read cursor.
      if (finalLastReadMessageId == null || finalLastReadMessageId.isEmpty) {
        return;
      }

      final ParseCloudFunction function = ParseCloudFunction('markConversationRead');
      final Map<String, dynamic> params = <String, dynamic>{
        'conversationId': _activeConversationId,
        'profileType': _activeProfileType,
      };
      if (finalLastReadMessageId.isNotEmpty) {
        params['lastReadMessageId'] = finalLastReadMessageId;
      }

      debugPrint('[ChatController] calling markConversationRead with params: $params');

      final ParseResponse response = await function.execute(parameters: params);
      if (!response.success) {
        debugPrint(response.error?.message ?? 'Failed to mark conversation read.');
        return;
      }

      if (myConversationMember.value != null) {
        // Mirror the server-side read result locally so the UI can update
        // immediately without waiting for a fresh ConversationMember fetch.
        myConversationMember.value!.set('unreadCount', 0);
        myConversationMember.value!.set('lastReadAt', DateTime.now());
      }

      debugPrint('[ChatController] marked conversation read up to incomingMessageId=$finalLastReadMessageId');

      // Mark all incoming messages in local state as read so backend-driven
      // unread counters are cleared. The session-only unread divider is not
      // cleared here on purpose; it has its own lifecycle and should remain
      // visible until the user sends a message or reopens the chat.
      final List<ChatModel> updated = messages.map((ChatModel item) {
        if (item.IsReceive == true) {
          return item.copyWith(IsRead: true);
        }
        return item;
      }).toList();

      messages.assignAll(updated);
      dataList = List<ChatModel>.from(updated);
      _updateNewMessageBannerCount();
      _debugPrintReadReceiptSnapshot(reason: '_markConversationRead');
      update();
    } finally {
      // Always release the lock, even if the cloud call fails,
      // so future legitimate read updates are not blocked.
      _isMarkingConversationRead = false;
    }
  }
}