import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum _NotifType { tripRequest, message, connection, review, system }

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const _bg = Color(0xFF0C0A08);
  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);
  static const _border = Color(0xFF2A2520);

  final List<_Notif> _notifs = [
    _Notif(
      type: _NotifType.tripRequest,
      title: 'New Trip Request',
      body: 'Sarah Mitchell sent you a trip request for KTEB → EGLL on Jun 28.',
      time: '2m ago',
      read: false,
    ),
    _Notif(
      type: _NotifType.message,
      title: 'New Message',
      body: 'Charter Wings LLC: "Contract sent — please review and sign."',
      time: '1h ago',
      read: false,
    ),
    _Notif(
      type: _NotifType.connection,
      title: 'Connection Request',
      body: 'Diego Torres wants to connect with you.',
      time: '3h ago',
      read: false,
    ),
    _Notif(
      type: _NotifType.review,
      title: 'New Review',
      body: 'Elise Fontaine left you a 5-star review: "Exceptional professionalism."',
      time: 'Yesterday',
      read: true,
    ),
    _Notif(
      type: _NotifType.tripRequest,
      title: 'Trip Confirmed',
      body: 'Your trip KLAX → KJFK on Jun 15 has been confirmed by the owner.',
      time: 'Yesterday',
      read: true,
    ),
    _Notif(
      type: _NotifType.system,
      title: 'Profile Boost Active',
      body: 'Your profile is featured in search results until Jun 30.',
      time: '2 days ago',
      read: true,
    ),
    _Notif(
      type: _NotifType.connection,
      title: 'Connection Accepted',
      body: 'Marcus Webb accepted your connection request.',
      time: '3 days ago',
      read: true,
    ),
  ];

  bool get _hasUnread => _notifs.any((n) => !n.read);

  void _markAllRead() {
    setState(() {
      for (final n in _notifs) {
        n.read = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: _border, height: 1),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          if (_hasUnread)
            GestureDetector(
              onTap: _markAllRead,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  'Mark all read',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _gold,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _notifs.isEmpty
          ? _emptyState
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _notifs.length,
              separatorBuilder: (_, idx) =>
                  Divider(color: _border, height: 1),
              itemBuilder: (_, i) => _notifTile(_notifs[i], i),
            ),
    );
  }

  Widget _notifTile(_Notif n, int index) {
    return Dismissible(
      key: ValueKey('$index-${n.title}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: const Color(0xFFB33A3A).withValues(alpha: 0.2),
        child: const Icon(Icons.delete_outline_rounded,
            color: Color(0xFFB33A3A), size: 22),
      ),
      onDismissed: (_) => setState(() => _notifs.removeAt(index)),
      child: GestureDetector(
        onTap: () => setState(() => n.read = true),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: n.read ? Colors.transparent : _gold.withValues(alpha: 0.04),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _iconContainer(n.type),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: n.read
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          n.time,
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.white38),
                        ),
                        if (!n.read) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: _gold,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.body,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white54,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconContainer(_NotifType type) {
    final (icon, color) = switch (type) {
      _NotifType.tripRequest => (Icons.flight_rounded, const Color(0xFF5B8DEF)),
      _NotifType.message => (Icons.chat_bubble_outline_rounded, _gold),
      _NotifType.connection => (Icons.person_add_outlined, const Color(0xFF3DAA57)),
      _NotifType.review => (Icons.star_rounded, const Color(0xFFF5A623)),
      _NotifType.system => (Icons.info_outline_rounded, Colors.white38),
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Icon(icon, size: 18, color: color),
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
              color: _cardBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded,
                color: Colors.white24, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            'All Caught Up',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No new notifications.',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

class _Notif {
  _Notif({
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.read,
  });

  final _NotifType type;
  final String title;
  final String body;
  final String time;
  bool read;
}
