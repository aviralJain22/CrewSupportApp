import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/shared/app_header.dart';
import '../../widgets/chat/message_preview_row.dart';
import 'chat_screen.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  static const _bg = Color(0xFF0C0A08);
  static const _border = Color(0xFF2A2520);

  final _searchCtrl = TextEditingController();
  String _query = '';

  final List<_Convo> _convos = [
    _Convo(
      id: '1',
      name: 'Sarah Mitchell',
      role: 'Aircraft Owner',
      preview: 'Can you confirm arrival by 14:00 UTC?',
      time: '2m',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      unread: 3,
      online: true,
    ),
    _Convo(
      id: '2',
      name: 'Charter Wings LLC',
      role: 'Operator',
      preview: 'Contract sent — please review and sign.',
      time: '1h',
      avatarUrl: 'https://i.pravatar.cc/150?img=60',
      unread: 1,
      online: false,
    ),
    _Convo(
      id: '3',
      name: 'Marcus Webb',
      role: 'Pilot',
      preview: 'Available from the 28th onwards.',
      time: '3h',
      avatarUrl: 'https://i.pravatar.cc/150?img=15',
      unread: 0,
      online: true,
    ),
    _Convo(
      id: '4',
      name: 'Sophia Lane',
      role: 'Flight Attendant',
      preview: 'Happy to help — what aircraft type?',
      time: 'Yesterday',
      avatarUrl: 'https://i.pravatar.cc/150?img=47',
      unread: 0,
      online: false,
    ),
    _Convo(
      id: '5',
      name: 'James Holloway',
      role: 'Instructor',
      preview: 'Ground session confirmed for Tuesday.',
      time: 'Mon',
      avatarUrl: 'https://i.pravatar.cc/150?img=33',
      unread: 0,
      online: false,
    ),
    _Convo(
      id: '6',
      name: 'Elise Fontaine',
      role: 'Aircraft Owner',
      preview: 'Thanks for the smooth flight!',
      time: 'Sun',
      avatarUrl: 'https://i.pravatar.cc/150?img=9',
      unread: 0,
      online: false,
    ),
  ];

  List<_Convo> get _filtered {
    if (_query.isEmpty) return _convos;
    final q = _query.toLowerCase();
    return _convos.where((c) =>
        c.name.toLowerCase().contains(q) ||
        c.preview.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppHeader.title(screenTitle: 'Messages'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: _searchBar,
          ),
          Expanded(
            child: _filtered.isEmpty
                ? _emptyState
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, idx) =>
                        Divider(color: _border, height: 1, indent: 82),
                    itemBuilder: (context, i) {
                      final c = _filtered[i];
                      return MessagePreviewRow(
                        name: c.name,
                        preview: c.preview,
                        time: c.time,
                        avatarUrl: c.avatarUrl,
                        unreadCount: c.unread,
                        isOnline: c.online,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              contactId: c.id,
                              contactName: c.name,
                              contactRole: c.role,
                              avatarUrl: c.avatarUrl,
                              isOnline: c.online,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget get _searchBar {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF181410),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded, color: Colors.white38, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
              cursorColor: const Color(0xFFD4AF37),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search messages…',
                hintStyle: GoogleFonts.inter(
                    fontSize: 14, color: Colors.white38),
                isDense: true,
              ),
            ),
          ),
          if (_query.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                setState(() => _query = '');
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.close_rounded,
                    color: Colors.white38, size: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget get _emptyState {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                color: Color(0xFFD4AF37), size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            'No Conversations',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your messages with crew and owners\nwill appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

class _Convo {
  const _Convo({
    required this.id,
    required this.name,
    required this.role,
    required this.preview,
    required this.time,
    this.avatarUrl,
    this.unread = 0,
    this.online = false,
  });

  final String id;
  final String name;
  final String role;
  final String preview;
  final String time;
  final String? avatarUrl;
  final int unread;
  final bool online;
}
