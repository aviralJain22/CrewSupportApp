import 'package:flutter/foundation.dart';

class CrewConvo {
  const CrewConvo({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    this.isOnline = false,
    required this.preview,
    required this.time,
    this.unread = 0,
  });

  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final bool isOnline;
  final String preview;
  final String time;
  final int unread;
}

class CrewConnectionState {
  CrewConnectionState._();
  static final instance = CrewConnectionState._();

  final conversations = ValueNotifier<List<CrewConvo>>([
    const CrewConvo(
      id: 'pre1',
      name: 'Captain James Mitchell',
      role: 'Captain / Pilot',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      isOnline: true,
      preview: 'Available for Dubai route tomorrow',
      time: '2m',
      unread: 2,
    ),
    const CrewConvo(
      id: 'pre2',
      name: 'Alexander Reid',
      role: 'SIC / First Officer',
      avatarUrl: 'https://i.pravatar.cc/150?img=15',
      isOnline: false,
      preview: 'Sent aircraft documents for review',
      time: '1h',
      unread: 1,
    ),
  ]);

  void accept(CrewConvo convo) {
    if (conversations.value.any((c) => c.id == convo.id)) return;
    conversations.value = [convo, ...conversations.value];
  }
}
