import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/shared/app_header.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFF0C0A08);
  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);
  static const _border = Color(0xFF2A2520);

  late final TabController _tab = TabController(length: 3, vsync: this);

  final List<_Connection> _connections = [
    _Connection(name: 'Sarah Mitchell', role: 'Aircraft Owner', mutual: 4, avatarUrl: 'https://i.pravatar.cc/150?img=5', connected: true),
    _Connection(name: 'Marcus Webb', role: 'Pilot', mutual: 7, avatarUrl: 'https://i.pravatar.cc/150?img=15', connected: true),
    _Connection(name: 'Sophia Lane', role: 'Flight Attendant', mutual: 2, avatarUrl: 'https://i.pravatar.cc/150?img=47', connected: true),
    _Connection(name: 'James Holloway', role: 'Instructor', mutual: 5, avatarUrl: 'https://i.pravatar.cc/150?img=33', connected: true),
    _Connection(name: 'Elise Fontaine', role: 'Aircraft Owner', mutual: 1, avatarUrl: 'https://i.pravatar.cc/150?img=9', connected: true),
  ];

  final List<_Connection> _pending = [
    _Connection(name: 'Diego Torres', role: 'Pilot', mutual: 3, avatarUrl: 'https://i.pravatar.cc/150?img=22', connected: false),
    _Connection(name: 'Mia Johansson', role: 'Flight Attendant', mutual: 0, avatarUrl: 'https://i.pravatar.cc/150?img=44', connected: false),
  ];

  final List<_Connection> _suggested = [
    _Connection(name: 'Thomas King', role: 'Instructor', mutual: 8, avatarUrl: 'https://i.pravatar.cc/150?img=11', connected: false),
    _Connection(name: 'Aisha Patel', role: 'Aircraft Owner', mutual: 6, avatarUrl: 'https://i.pravatar.cc/150?img=29', connected: false),
    _Connection(name: 'Lucas Mercer', role: 'Pilot', mutual: 2, avatarUrl: 'https://i.pravatar.cc/150?img=17', connected: false),
    _Connection(name: 'Clara Ngo', role: 'Flight Attendant', mutual: 4, avatarUrl: 'https://i.pravatar.cc/150?img=38', connected: false),
  ];

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppHeader.title(screenTitle: 'Connections'),
      body: Column(
        children: [
          _tabBar,
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _connectionsList(_connections, showRemove: true),
                _pendingList,
                _connectionsList(_suggested, showAdd: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget get _tabBar {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: TabBar(
        controller: _tab,
        indicatorColor: _gold,
        indicatorWeight: 2,
        labelColor: _gold,
        unselectedLabelColor: Colors.white38,
        labelStyle: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
        tabs: [
          Tab(text: 'Connected (${_connections.length})'),
          Tab(text: 'Pending (${_pending.length})'),
          const Tab(text: 'Suggested'),
        ],
      ),
    );
  }

  Widget _connectionsList(
    List<_Connection> list, {
    bool showRemove = false,
    bool showAdd = false,
  }) {
    if (list.isEmpty) return _emptyState('No connections yet');
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: list.length,
      separatorBuilder: (_, idx) =>
          Divider(color: _border, height: 1, indent: 78),
      itemBuilder: (_, i) =>
          _connectionTile(list[i], showRemove: showRemove, showAdd: showAdd),
    );
  }

  Widget get _pendingList {
    if (_pending.isEmpty) return _emptyState('No pending requests');
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _pending.length,
      separatorBuilder: (_, idx) =>
          Divider(color: _border, height: 1, indent: 78),
      itemBuilder: (_, i) => _pendingTile(_pending[i], i),
    );
  }

  Widget _connectionTile(
    _Connection c, {
    bool showRemove = false,
    bool showAdd = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _avatar(c),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text(c.role,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.white38)),
                if (c.mutual > 0) ...[
                  const SizedBox(height: 2),
                  Text('${c.mutual} mutual connections',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: _gold.withValues(alpha: 0.7))),
                ],
              ],
            ),
          ),
          if (showAdd)
            _actionButton('Connect', _gold, () {})
          else if (showRemove)
            _actionButton('Remove', Colors.white24, () {}),
        ],
      ),
    );
  }

  Widget _pendingTile(_Connection c, int idx) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _avatar(c),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text(c.role,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.white38)),
              ],
            ),
          ),
          Row(
            children: [
              _iconButton(Icons.close_rounded, Colors.white38,
                  () => setState(() => _pending.removeAt(idx))),
              const SizedBox(width: 8),
              _iconButton(Icons.check_rounded, _gold,
                  () {
                    setState(() {
                      _connections.add(_pending[idx]);
                      _pending.removeAt(idx);
                    });
                  }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: color),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _avatar(_Connection c) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _border),
        color: _cardBg,
      ),
      child: ClipOval(
        child: c.avatarUrl != null
            ? Image.network(c.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, err, st) => _initial(c.name))
            : _initial(c.name),
      ),
    );
  }

  Widget _initial(String name) => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.inter(
              color: _gold, fontWeight: FontWeight.w700, fontSize: 16),
        ),
      );

  Widget _emptyState(String msg) {
    return Center(
      child: Text(msg,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white38)),
    );
  }
}

class _Connection {
  _Connection({
    required this.name,
    required this.role,
    required this.mutual,
    this.avatarUrl,
    required this.connected,
  });

  final String name;
  final String role;
  final int mutual;
  final String? avatarUrl;
  bool connected;
}
