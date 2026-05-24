import 'dart:async';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:crew_support/model/chat_message_list_model.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Controller for the conversation list screen.
///
/// Responsibilities handled here:
/// - loading the current user's conversation list for the selected profile
/// - mapping the secure cloud-function response into the existing UI model
/// - tracking screen-level loading state
/// - deleting a conversation for the active profile
/// - keeping lightweight UI selection state used by the list screen
/// - refreshing automatically via LiveQuery when conversation membership changes
class MessageController extends GetxController {
  /// Whether the conversation list is currently being fetched.
  bool isLoading = true;

  /// Whether a delete conversation request is currently in progress.
  bool isDeletingConversation = false;

  /// Legacy flag passed into chat navigation when a row is opened.
  bool messageRead = false;

  /// Currently selected conversation row in the list.
  int selectedIndex = 0;

  /// Total unread count across all visible conversations.
  int unreadCount = 0;

  /// Data model backing the conversation list UI.
  MessageData chatMessageListModel = MessageData(messages: <Messages>[]);

  /// Cached unread counts by row index for legacy list behavior.
  final Map<int, int> datacountList = {};

  /// Dashboard-selected profile context currently active in the app.
  final DashboardController _dashboardController = Get.find<DashboardController>();

  /// Reacts to profile-type changes so the list refreshes automatically.
  Worker? _profileTypeWorker;

  /// LiveQuery instance used to refresh the list in real time.
  LiveQuery? _liveQuery;

  /// Subscription on ConversationMember for the active user/profile pair.
  Subscription<ParseObject>? _conversationMemberSubscription;

  /// Debounces repeated full-list refreshes into a single refresh.
  Timer? _liveQueryRefreshDebounce;

  /// Debounces per-conversation row refreshes coming from LiveQuery events.
  final Map<String, Timer> _rowRefreshDebounceMap = <String, Timer>{};

  /// Prevents overlap between an active fetch and a LiveQuery-triggered refresh.
  bool _isFetching = false;

  @override
  void onInit() {
    super.onInit();
    selectedIndex = 0;

    _profileTypeWorker = ever<int>(_dashboardController.selectedProfileType, (_) async {
      await _resubscribeForActiveProfile();
    });

    unawaited(_initializeMessageList());
  }

  @override
  void onClose() {
    _profileTypeWorker?.dispose();
    _liveQueryRefreshDebounce?.cancel();
    for (final Timer timer in _rowRefreshDebounceMap.values) {
      timer.cancel();
    }
    _rowRefreshDebounceMap.clear();
    _unsubscribeConversationMemberLiveQuery();
    EasyLoading.dismiss();
    super.onClose();
  }

  Future<void> _initializeMessageList() async {
    await getData();
    await _subscribeConversationMemberLiveQuery();
  }

  Future<void> _resubscribeForActiveProfile() async {
    await _unsubscribeConversationMemberLiveQuery();
    await getData();
    await _subscribeConversationMemberLiveQuery();
  }

  Future<void> _subscribeConversationMemberLiveQuery() async {
    final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) {
      debugPrint('[MessageController] LiveQuery skipped: no current user');
      return;
    }

    final int selectedProfileType = _dashboardController.selectedProfileType.value;
    if (selectedProfileType == 0) {
      debugPrint('[MessageController] LiveQuery skipped: selectedProfileType is 0');
      return;
    }

    _liveQuery ??= LiveQuery();

    final QueryBuilder<ParseObject> query =
        QueryBuilder<ParseObject>(ParseObject('ConversationMember'))
          ..whereEqualTo('user', currentUser.toPointer())
          ..whereEqualTo('profileType', selectedProfileType)
          ..includeObject(['conversation'])
          ..setLimit(500);

    debugPrint(
      '[MessageController] Subscribing LiveQuery for user=${currentUser.objectId} profileType=$selectedProfileType',
    );

    _conversationMemberSubscription = await _liveQuery!.client.subscribe(query);

    _conversationMemberSubscription!.on(LiveQueryEvent.create, (ParseObject value) {
      debugPrint('[MessageController] LiveQuery CREATE conversationMemberId=${value.objectId}');
      _handleConversationMemberEvent(value, eventName: 'CREATE');
    });

    _conversationMemberSubscription!.on(LiveQueryEvent.update, (ParseObject value) {
      debugPrint('[MessageController] LiveQuery UPDATE conversationMemberId=${value.objectId}');
      _handleConversationMemberEvent(value, eventName: 'UPDATE');
    });

    _conversationMemberSubscription!.on(LiveQueryEvent.delete, (ParseObject value) {
      debugPrint('[MessageController] LiveQuery DELETE conversationMemberId=${value.objectId}');
      _handleConversationMemberEvent(value, eventName: 'DELETE');
    });

    _conversationMemberSubscription!.on(LiveQueryEvent.enter, (ParseObject value) {
      debugPrint('[MessageController] LiveQuery ENTER conversationMemberId=${value.objectId}');
      _handleConversationMemberEvent(value, eventName: 'ENTER');
    });

    _conversationMemberSubscription!.on(LiveQueryEvent.leave, (ParseObject value) {
      debugPrint('[MessageController] LiveQuery LEAVE conversationMemberId=${value.objectId}');
      _handleConversationMemberEvent(value, eventName: 'LEAVE');
    });
  }

  Future<void> _unsubscribeConversationMemberLiveQuery() async {
    _liveQueryRefreshDebounce?.cancel();
    _liveQueryRefreshDebounce = null;
    for (final Timer timer in _rowRefreshDebounceMap.values) {
      timer.cancel();
    }
    _rowRefreshDebounceMap.clear();

    if (_conversationMemberSubscription != null && _liveQuery != null) {
      debugPrint('[MessageController] Unsubscribing previous ConversationMember LiveQuery');
      _liveQuery!.client.unSubscribe(_conversationMemberSubscription!);
      _conversationMemberSubscription = null;
    }
  }

  void _handleConversationMemberEvent(ParseObject value, {required String eventName}) {
    final ParseObject? conversation = value.get<ParseObject>('conversation');
    final String? conversationId = conversation?.objectId;

    debugPrint('[MessageController] _handleConversationMemberEvent($eventName) conversationId=$conversationId');

    if (conversationId == null || conversationId.isEmpty) {
      _scheduleRefreshFromLiveQuery();
      return;
    }

    _scheduleRowRefreshFromLiveQuery(conversationId);
  }

  void _scheduleRowRefreshFromLiveQuery(String conversationId) {
    _rowRefreshDebounceMap[conversationId]?.cancel();
    _rowRefreshDebounceMap[conversationId] = Timer(const Duration(milliseconds: 250), () async {
      _rowRefreshDebounceMap.remove(conversationId);

      if (_isFetching) {
        debugPrint('[MessageController] Row refresh skipped because fetch already in progress. conversationId=$conversationId');
        return;
      }

      await _refreshSingleConversationRow(conversationId);
    });
  }

  Future<void> _refreshSingleConversationRow(String conversationId) async {
    try {
      debugPrint('[MessageController] _refreshSingleConversationRow() start conversationId=$conversationId');

      final Messages? row = await getMessageListRow(conversationId);
      final List<Messages> current = List<Messages>.from(chatMessageListModel.messages ?? <Messages>[]);
      final int existingIndex = current.indexWhere((Messages item) => item.conversationId == conversationId);

      if (row == null) {
        if (existingIndex != -1) {
          current.removeAt(existingIndex);
          debugPrint('[MessageController] Removed row locally because it is no longer visible. conversationId=$conversationId');
        } else {
          debugPrint('[MessageController] Row not visible and not present locally. conversationId=$conversationId');
        }
      } else {
        if (existingIndex != -1) {
          current[existingIndex] = row;
          debugPrint('[MessageController] Updated existing row locally. conversationId=$conversationId');
        } else {
          current.add(row);
          debugPrint('[MessageController] Added new row locally. conversationId=$conversationId');
        }
      }

      current.sort((Messages a, Messages b) {
        final DateTime? aTime = a.lastMessageAt;
        final DateTime? bTime = b.lastMessageAt;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      chatMessageListModel = MessageData(messages: current);
      unreadCount = current.fold<int>(0, (int sum, Messages item) => sum + (item.isUnReadCount ?? 0));
      update();
    } catch (e) {
      debugPrint('[MessageController] _refreshSingleConversationRow() error=$e');
      _scheduleRefreshFromLiveQuery();
    }
  }

  Future<Messages?> getMessageListRow(String conversationId) async {
    final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) {
      throw Exception('User must be logged in to view messages.');
    }

    final int selectedProfileType = _dashboardController.selectedProfileType.value;
    if (selectedProfileType == 0) {
      return null;
    }

    final ParseCloudFunction function = ParseCloudFunction('getMessageListRow');
    final ParseResponse response = await function.execute(
      parameters: <String, dynamic>{
        'profileType': selectedProfileType,
        'conversationId': conversationId,
      },
    );

    debugPrint('[MessageController] getMessageListRow success=${response.success} conversationId=$conversationId');
    if (!response.success) {
      throw Exception(response.error?.message ?? 'Failed to load conversation row.');
    }

    final dynamic rawResult = response.result;
    if (rawResult == null) {
      return null;
    }

    if (rawResult is Map<String, dynamic>) {
      if (rawResult['conversation'] == null) return null;
      return _mapConversationItem(Map<dynamic, dynamic>.from(rawResult['conversation'] as Map));
    }

    if (rawResult is Map) {
      if (rawResult['conversation'] == null) return null;
      return _mapConversationItem(Map<dynamic, dynamic>.from(rawResult['conversation'] as Map));
    }

    return null;
  }

  void _scheduleRefreshFromLiveQuery() {
    _liveQueryRefreshDebounce?.cancel();
    _liveQueryRefreshDebounce = Timer(const Duration(milliseconds: 250), () async {
      if (_isFetching) {
        debugPrint('[MessageController] LiveQuery refresh skipped because fetch already in progress');
        return;
      }
      await getData();
    });
  }

  /// Loads the current user's conversations for the selected profile type.
  ///
  /// This data now comes from a secure cloud function so the client no longer
  /// queries any locked-down profile classes directly.
  Future<MessageData> getChatMessageList() async {
    final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) {
      throw Exception('User must be logged in to view messages.');
    }

    final int selectedProfileType = _dashboardController.selectedProfileType.value;
    debugPrint('[MessageController] getChatMessageList() start');
    debugPrint(
      '[MessageController] currentUserId=${currentUser.objectId} selectedProfileType=$selectedProfileType',
    );

    if (selectedProfileType == 0) {
      return MessageData(messages: <Messages>[]);
    }

    final ParseCloudFunction function = ParseCloudFunction('getMessageList');
    final ParseResponse response = await function.execute(
      parameters: <String, dynamic>{
        'profileType': selectedProfileType,
      },
    );

    debugPrint('[MessageController] getMessageList success=${response.success}');
    if (!response.success) {
      debugPrint('[MessageController] getMessageList error=${response.error?.message}');
      throw Exception(response.error?.message ?? 'Failed to load conversations.');
    }

    final dynamic rawResult = response.result;
    debugPrint('[MessageController] getMessageList rawResultType=${rawResult.runtimeType}');

    final List<dynamic> rawItems;
    if (rawResult is List) {
      rawItems = rawResult;
    } else if (rawResult is Map<String, dynamic> && rawResult['conversations'] is List) {
      rawItems = rawResult['conversations'] as List<dynamic>;
    } else if (rawResult is Map && rawResult['conversations'] is List) {
      rawItems = List<dynamic>.from(rawResult['conversations'] as List);
    } else {
      debugPrint('[MessageController] getMessageList unexpected result shape=$rawResult');
      return MessageData(messages: <Messages>[]);
    }

    final List<Messages> items = rawItems
        .whereType<Map>()
        .map<Messages>((Map item) => _mapConversationItem(item))
        .toList();

    debugPrint('[MessageController] mapped item count=${items.length}');
    for (final Messages item in items) {
      debugPrint(
        '[MessageController] finalRow conversationId=${item.conversationId} title=${item.receivername} otherUserId=${item.otherUserId} otherProfileType=${item.otherProfileType} unread=${item.isUnReadCount}',
      );
    }

    return MessageData(messages: items);
  }

  /// Refreshes the conversation list and recalculates the total unread count.
  Future<void> getData() async {
    try {
      _isFetching = true;
      isLoading = true;
      update();

      chatMessageListModel = await getChatMessageList();
      debugPrint(
        '[MessageController] getData() loaded messageCount=${chatMessageListModel.messages?.length ?? 0}',
      );
      unreadCount = (chatMessageListModel.messages ?? <Messages>[])
          .fold<int>(0, (int sum, Messages item) => sum + (item.isUnReadCount ?? 0));
      debugPrint('[MessageController] total unreadCount=$unreadCount');
    } catch (e) {
      debugPrint('[MessageController] getData() error=$e');
      chatMessageListModel = MessageData(messages: <Messages>[]);
      unreadCount = 0;
      Get.snackbar('Messages', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isFetching = false;
      isLoading = false;
      update();
    }
  }

  /// Deletes a conversation only for the currently active profile.
  Future<void> deleteConversation(Messages message) async {
    final int selectedProfileType = _dashboardController.selectedProfileType.value;
    if (selectedProfileType == 0) {
      throw Exception('No active profile selected.');
    }

    final String? conversationId = message.conversationId;
    if (conversationId == null || conversationId.isEmpty) {
      throw Exception('Missing conversation id.');
    }

    try {
      isDeletingConversation = true;
      update();

      final ParseCloudFunction function = ParseCloudFunction('deleteConversationForMe');
      final ParseResponse response = await function.execute(
        parameters: <String, dynamic>{
          'conversationId': conversationId,
          'profileType': selectedProfileType,
        },
      );

      if (!response.success) {
        throw Exception(response.error?.message ?? 'Failed to delete conversation.');
      }

      await getData();
    } finally {
      isDeletingConversation = false;
      update();
    }
  }

  /// Stores which row was tapped before navigating into the chat screen.
  void markSelected(int index) {
    selectedIndex = index;
    messageRead = true;
    update();
  }

  /// Caches the unread badge count for a given visible row.
  void setUnreadCountForIndex(int index, int count) {
    datacountList[index] = count;
  }

  Messages _mapConversationItem(Map item) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(item.cast<dynamic, dynamic>());

    final dynamic lastMessageAtRaw = data['lastMessageAt'];
    DateTime? lastMessageAt;
    if (lastMessageAtRaw is String && lastMessageAtRaw.trim().isNotEmpty) {
      lastMessageAt = DateTime.tryParse(lastMessageAtRaw);
    }

    return Messages(
      conversationId: _stringValue(data['conversationId']),
      otherUserId: _stringValue(data['otherUserId']),
      otherProfileType: _intValue(data['otherProfileType']),
      receivername: _stringValue(data['receivername']),
      message: _stringValue(data['message']),
      isUnReadCount: _intValue(data['isUnReadCount']) ?? 0,
      photoPath: _stringValue(data['photoPath']),
      lastMessageAt: lastMessageAt,
      isGroup: _boolValue(data['isGroup']) ?? false,
    );
  }

  String _stringValue(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  int? _intValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  bool? _boolValue(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    return null;
  }
}