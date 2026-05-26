import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/crew_connection_state.dart';
import '../../services/user_session.dart';
import '../chat/chat_screen.dart';

// ─── Favourite person model ────────────────────────────────────────────────

class _FavPerson {
  const _FavPerson({
    required this.name,
    required this.role,
    required this.roleTag,
    required this.avatarUrl,
    required this.online,
    required this.rating,
    required this.hours,
    required this.rate,
  });
  final String name, role, roleTag, avatarUrl, hours, rate;
  final bool online;
  final double rating;
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  static const _bg     = Color(0xFF0A0905);
  static const _gold   = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF141210);
  static const _border = Color(0xFF2A2520);
  static const _green  = Color(0xFF4FC870);

  final _searchCtrl = TextEditingController();
  String _query      = '';
  String _roleFilter = 'All';

  final Set<String> _acceptedIds = {};
  final Set<String> _declinedIds = {};

  // ─── Filter categories ────────────────────────────────────────────────────

  static const _roleOptions = [
    'All', 'Captain', 'Flight Attendant', 'Pilot',
    'Crew Member', 'Owner', 'Operator', 'Engineer', 'Traveller', 'VIP Member',
  ];

  // ─── Favourite people (top strip) ────────────────────────────────────────

  static const _favouritePeople = [
    _FavPerson(
      name: 'James Mitchell', role: 'Captain / ATP', roleTag: 'Captain',
      avatarUrl: 'https://i.pravatar.cc/150?img=11', online: true,
      rating: 5.0, hours: '12,400h TT', rate: '\$500/day',
    ),
    _FavPerson(
      name: 'Sophia Laurent', role: 'Lead Flight Attendant', roleTag: 'Flight Attendant',
      avatarUrl: 'https://i.pravatar.cc/150?img=47', online: true,
      rating: 4.9, hours: '6,700h TT', rate: '\$1,100/day',
    ),
    _FavPerson(
      name: 'Ethan Brooks', role: 'First Officer / Pilot', roleTag: 'Pilot',
      avatarUrl: 'https://i.pravatar.cc/150?img=12', online: false,
      rating: 4.8, hours: '4,200h TT', rate: '\$800/day',
    ),
    _FavPerson(
      name: 'Priya Sharma', role: 'Cabin Crew Member', roleTag: 'Crew Member',
      avatarUrl: 'https://i.pravatar.cc/150?img=44', online: true,
      rating: 4.7, hours: '5 yrs exp.', rate: '\$420/day',
    ),
    _FavPerson(
      name: 'Ryan Blake', role: 'Aircraft Owner / Operator', roleTag: 'Owner',
      avatarUrl: 'https://i.pravatar.cc/150?img=68', online: true,
      rating: 4.9, hours: '7,200h TT', rate: 'By arrangement',
    ),
    _FavPerson(
      name: 'Isabella Torres', role: 'VIP Concierge', roleTag: 'VIP Member',
      avatarUrl: 'https://i.pravatar.cc/150?img=49', online: false,
      rating: 4.9, hours: '8 yrs exp.', rate: '\$950/day',
    ),
    _FavPerson(
      name: 'Marcus Webb', role: 'Avionics Engineer', roleTag: 'Engineer',
      avatarUrl: 'https://i.pravatar.cc/150?img=15', online: true,
      rating: 4.7, hours: '14 yrs exp.', rate: '\$320/day',
    ),
    _FavPerson(
      name: 'Natalie Chen', role: 'Charter Operator', roleTag: 'Operator',
      avatarUrl: 'https://i.pravatar.cc/150?img=25', online: true,
      rating: 4.8, hours: '11 yrs exp.', rate: '\$500/day',
    ),
    _FavPerson(
      name: 'Omar Hassan', role: 'Ground Operations Lead', roleTag: 'Crew Member',
      avatarUrl: 'https://i.pravatar.cc/150?img=18', online: false,
      rating: 4.6, hours: '9,100h ops', rate: '\$380/day',
    ),
    _FavPerson(
      name: 'Alexander Reid', role: 'Captain / PIC', roleTag: 'Captain',
      avatarUrl: 'https://i.pravatar.cc/150?img=57', online: true,
      rating: 4.9, hours: '8,500h TT', rate: '\$1,200/day',
    ),
  ];

  // ─── Crew profiles ────────────────────────────────────────────────────────

  final List<_CrewProfile> _invitations = const [
    _CrewProfile(
      id: 'inv1', name: 'James Mitchell', role: 'Captain / ATP',
      roleTag: 'Captain', hours: '12,400h TT', distance: '45 mi',
      rate: '\$500/day', rating: 5.0,
      avatarUrl: 'https://i.pravatar.cc/150?img=11', available: true,
    ),
    _CrewProfile(
      id: 'inv2', name: 'Alexander Reid', role: 'Captain / PIC',
      roleTag: 'Captain', hours: '8,500h TT', distance: '12 mi',
      rate: '\$1,200/day', rating: 4.9,
      avatarUrl: 'https://i.pravatar.cc/150?img=57', available: true,
    ),
    _CrewProfile(
      id: 'inv3', name: 'Isabella Torres', role: 'Lead Flight Attendant',
      roleTag: 'Flight Attendant', hours: '6,700h TT', distance: '15 mi',
      rate: '\$1,100/day', rating: 4.9,
      avatarUrl: 'https://i.pravatar.cc/150?img=47', available: false,
    ),
    _CrewProfile(
      id: 'inv4', name: 'Daniel Harper', role: 'First Officer / Pilot',
      roleTag: 'Pilot', hours: '5,600h TT', distance: '20 mi',
      rate: '\$900/day', rating: 4.8,
      avatarUrl: 'https://i.pravatar.cc/150?img=52', available: true,
    ),
    _CrewProfile(
      id: 'inv5', name: 'Sophia Lane', role: 'Senior Flight Attendant',
      roleTag: 'Flight Attendant', hours: '4,200h TT', distance: '30 mi',
      rate: '\$750/day', rating: 4.7,
      avatarUrl: 'https://i.pravatar.cc/150?img=44', available: true,
    ),
    _CrewProfile(
      id: 'inv6', name: 'Marcus Webb', role: 'Ground Operations Lead',
      roleTag: 'Crew Member', hours: '9,100h ops', distance: '8 mi',
      rate: '\$380/day', rating: 4.8,
      avatarUrl: 'https://i.pravatar.cc/150?img=14', available: true,
    ),
    _CrewProfile(
      id: 'inv7', name: 'Elise Fontaine', role: 'Co-Pilot / Pilot',
      roleTag: 'Pilot', hours: '3,800h TT', distance: '55 mi',
      rate: '\$800/day', rating: 4.6,
      avatarUrl: 'https://i.pravatar.cc/150?img=25', available: false,
    ),
    _CrewProfile(
      id: 'inv8', name: 'Ryan Blake', role: 'Aircraft Owner / Operator',
      roleTag: 'Owner', hours: '7,200h TT', distance: '18 mi',
      rate: 'By arrangement', rating: 4.9,
      avatarUrl: 'https://i.pravatar.cc/150?img=68', available: true,
    ),
    _CrewProfile(
      id: 'inv9', name: 'Natalie Chen', role: 'Charter Operator',
      roleTag: 'Operator', hours: '11 yrs exp.', distance: '22 mi',
      rate: '\$500/day', rating: 4.8,
      avatarUrl: 'https://i.pravatar.cc/150?img=31', available: true,
    ),
    _CrewProfile(
      id: 'inv10', name: 'Omar Hassan', role: 'Avionics Engineer',
      roleTag: 'Engineer', hours: '14 yrs exp.', distance: '35 mi',
      rate: '\$320/day', rating: 4.7,
      avatarUrl: 'https://i.pravatar.cc/150?img=18', available: false,
    ),
    _CrewProfile(
      id: 'inv11', name: 'Lena Park', role: 'Cabin Crew Member',
      roleTag: 'Crew Member', hours: '5 yrs exp.', distance: '10 mi',
      rate: '\$420/day', rating: 4.6,
      avatarUrl: 'https://i.pravatar.cc/150?img=36', available: true,
    ),
    _CrewProfile(
      id: 'inv12', name: 'Victoria Osei', role: 'VIP Concierge',
      roleTag: 'VIP Member', hours: '8 yrs exp.', distance: '28 mi',
      rate: '\$950/day', rating: 4.9,
      avatarUrl: 'https://i.pravatar.cc/150?img=40', available: true,
    ),
  ];

  // ─── Derived lists ────────────────────────────────────────────────────────

  List<_CrewProfile> get _filtered {
    var list = _invitations
        .where((p) => !_declinedIds.contains(p.id))
        .toList();
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.role.toLowerCase().contains(q)).toList();
    }
    if (_roleFilter != 'All') {
      list = list.where((p) => p.roleTag == _roleFilter).toList();
    }
    return list;
  }

  List<_CrewProfile> get _acceptedList =>
      _filtered.where((p) => _acceptedIds.contains(p.id)).toList();
  List<_CrewProfile> get _pendingList =>
      _filtered.where((p) => !_acceptedIds.contains(p.id)).toList();

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  void _accept(_CrewProfile p) {
    HapticFeedback.lightImpact();
    if (_acceptedIds.contains(p.id)) return;
    setState(() => _acceptedIds.add(p.id));
    CrewConnectionState.instance.accept(CrewConvo(
      id: p.id, name: p.name, role: p.role,
      avatarUrl: p.avatarUrl ?? '', isOnline: p.available,
      preview: 'Thanks for connecting — ready to fly!',
      time: 'now', unread: 1,
    ));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: _cardBg,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: _border),
      ),
      content: Row(children: [
        const Icon(Icons.check_circle_outline_rounded, color: _green, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${p.name.split(' ').first} connected · Now in Messages',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
          ),
        ),
      ]),
      duration: const Duration(seconds: 2),
    ));
  }

  void _decline(_CrewProfile p) {
    HapticFeedback.lightImpact();
    setState(() => _declinedIds.add(p.id));
  }

  void _chat(_CrewProfile p) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChatScreen(
        contactId: p.id, contactName: p.name,
        contactRole: p.role, avatarUrl: p.avatarUrl,
        isOnline: p.available,
      ),
    ));
  }

  // ─── Favourites bottom sheet ──────────────────────────────────────────────

  void _showFavouritesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F0D0B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle + close row
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 16, 4),
                child: Row(
                  children: [
                    Center(
                      child: Container(
                        width: 38, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 15, color: Colors.white54),
                      ),
                    ),
                  ],
                ),
              ),
              // Sheet header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(
                  children: [
                    Container(
                      width: 3, height: 20,
                      decoration: BoxDecoration(
                        color: _gold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'FAVOURITE PEOPLE',
                      style: GoogleFonts.cinzel(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _gold.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '${_favouritePeople.length} saved',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: _gold,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                  color: _border, height: 1,
                  indent: 20, endIndent: 20),
              const SizedBox(height: 4),
              // Cards list
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: _favouritePeople.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 12),
                  itemBuilder: (_, i) =>
                      _buildFavSheetCard(_favouritePeople[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavSheetCard(_FavPerson p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: p.online
              ? _gold.withValues(alpha: 0.22)
              : _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Stack(children: [
            Container(
              width: 62, height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: p.online
                    ? LinearGradient(colors: [
                        _gold.withValues(alpha: 0.55),
                        _gold.withValues(alpha: 0.15),
                      ])
                    : null,
                border: p.online
                    ? null
                    : Border.all(color: _border, width: 1.5),
                color: const Color(0xFF2A2520),
                boxShadow: p.online
                    ? [BoxShadow(
                        color: _gold.withValues(alpha: 0.2),
                        blurRadius: 12)]
                    : null,
              ),
              child: Padding(
                padding: p.online
                    ? const EdgeInsets.all(2)
                    : EdgeInsets.zero,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2A2520),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      p.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Center(
                        child: Text(
                          p.name[0].toUpperCase(),
                          style: GoogleFonts.inter(
                            color: _gold,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 2, right: 2,
              child: Container(
                width: 13, height: 13,
                decoration: BoxDecoration(
                  color: p.online ? _green : Colors.grey.shade700,
                  shape: BoxShape.circle,
                  border: Border.all(color: _cardBg, width: 1.5),
                ),
              ),
            ),
          ]),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      p.name,
                      style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star_rounded,
                        color: _gold, size: 13),
                    const SizedBox(width: 3),
                    Text(
                      p.rating.toStringAsFixed(1),
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _gold),
                    ),
                  ]),
                ]),
                const SizedBox(height: 5),
                Row(children: [
                  _sheetRolePill(p.roleTag),
                  const SizedBox(width: 8),
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      color: p.online ? _green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    p.online ? 'Online' : 'Offline',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: p.online ? _green : Colors.white38,
                        fontWeight: FontWeight.w500),
                  ),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.flight_rounded,
                      size: 11, color: Colors.white38),
                  const SizedBox(width: 4),
                  Text(p.hours,
                      style: GoogleFonts.inter(
                          fontSize: 11.5, color: Colors.white54)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text('·',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.white24)),
                  ),
                  Text(
                    p.rate,
                    style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: _gold.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600),
                  ),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 34,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFD4AF37),
                              Color(0xFFB8960C)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: _gold.withValues(alpha: 0.22),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 13,
                                color: Color(0xFF0A0905)),
                            const SizedBox(width: 5),
                            Text('Message',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0A0905))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB33A3A).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFFB33A3A)
                              .withValues(alpha: 0.35)),
                    ),
                    child: const Icon(Icons.favorite_rounded,
                        size: 15,
                        color: Color(0xFFB33A3A)),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetRolePill(String tag) {
    const bgMap = <String, Color>{
      'Captain':          Color(0xFF1A2C48),
      'Pilot':            Color(0xFF17273D),
      'Flight Attendant': Color(0xFF271B38),
      'Crew Member':      Color(0xFF251A1A),
      'Owner':            Color(0xFF2A1A08),
      'Operator':         Color(0xFF1A1A2A),
      'Engineer':         Color(0xFF152520),
      'Traveller':        Color(0xFF201A2A),
      'VIP Member':       Color(0xFF2A1A1A),
    };
    const fgMap = <String, Color>{
      'Captain':          Color(0xFF6AABFF),
      'Pilot':            Color(0xFF5A9BEF),
      'Flight Attendant': Color(0xFFAF8FE0),
      'Crew Member':      Color(0xFFE08F8F),
      'Owner':            Color(0xFFD4AF37),
      'Operator':         Color(0xFF8FB8E0),
      'Engineer':         Color(0xFF7AB8A0),
      'Traveller':        Color(0xFFC07AAF),
      'VIP Member':       Color(0xFFE0C47A),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bgMap[tag] ?? const Color(0xFF2A2520),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tag,
        style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: fgMap[tag] ?? Colors.white54),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final accepted = _acceptedList;
    final pending  = _pendingList;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Combined header + favourites strip
            SliverToBoxAdapter(child: _buildTopSection()),
            // Page title + Invite Crew
            SliverToBoxAdapter(child: _buildPageHeader()),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            // Single search bar
            SliverToBoxAdapter(child: _buildSearchBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Connected ─────────────────────────────────────────────
            if (accepted.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _sectionLabel('CONNECTED', accepted.length,
                    color: _green),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _buildCard(accepted[i]),
                  ),
                  childCount: accepted.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],

            // ── All crew ──────────────────────────────────────────────
            if (pending.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _sectionLabel('ALL CREW', pending.length,
                    color: _gold),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _buildCard(pending[i]),
                  ),
                  childCount: pending.length,
                ),
              ),
            ] else if (accepted.isEmpty)
              SliverToBoxAdapter(child: _buildEmpty()),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // ─── Top section: header row + favourite people strip ────────────────────

  Widget _buildTopSection() {
    final initials = UserSession.instance.initials;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User avatar
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: _gold.withValues(alpha: 0.5), width: 1.5),
              color: const Color(0xFF2A2520),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.inter(
                  color: _gold,
                  fontWeight: FontWeight.w700,
                  fontSize: initials.length > 1 ? 12 : 15,
                ),
              ),
            ),
          ),
          const Spacer(),
          // CREW SUPPORT logo
          Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.flight_rounded, color: _gold, size: 15),
            const SizedBox(height: 2),
            Text(
              'CREW SUPPORT',
              style: GoogleFonts.cinzel(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: _gold,
                letterSpacing: 1.6,
              ),
            ),
          ]),
          const Spacer(),
          // Heart / Favourites button
          GestureDetector(
            onTap: () => _showFavouritesSheet(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: _bg,
                shape: BoxShape.circle,
                border: Border.all(
                    color: _gold.withValues(alpha: 0.45), width: 1.2),
              ),
              child: const Icon(
                  Icons.favorite_rounded, color: _gold, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page header ──────────────────────────────────────────────────────────

  Widget _buildPageHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connections',
                  style: GoogleFonts.cinzel(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Discover & connect with aviation professionals',
                  style: GoogleFonts.inter(
                      fontSize: 12.5, color: Colors.white38),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border:
                    Border.all(color: _gold.withValues(alpha: 0.7)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_add_alt_1_rounded,
                      color: _gold, size: 15),
                  const SizedBox(width: 6),
                  Text(
                    'Invite Crew',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _gold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Search bar + filter button ──────────────────────────────────────────

  Widget _buildSearchBar() {
    final isFiltered = _roleFilter != 'All';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: _border),
              ),
              child: Row(children: [
                const SizedBox(width: 14),
                Icon(Icons.search_rounded,
                    color: Colors.white30, size: 19),
                const SizedBox(width: 9),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    style: GoogleFonts.inter(
                        fontSize: 14, color: Colors.white),
                    cursorColor: _gold,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search crew…',
                      hintStyle: GoogleFonts.inter(
                          fontSize: 14, color: Colors.white24),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
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
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.close_rounded,
                          color: Colors.white30, size: 15),
                    ),
                  )
                else
                  const SizedBox(width: 12),
              ]),
            ),
          ),
          const SizedBox(width: 10),
          // Filter button
          GestureDetector(
            onTap: _showRoleFilterSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isFiltered
                    ? _gold.withValues(alpha: 0.14)
                    : _cardBg,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: isFiltered ? _gold : _border,
                  width: isFiltered ? 1.5 : 1,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.tune_rounded,
                      size: 19,
                      color: isFiltered ? _gold : Colors.white38),
                  if (isFiltered)
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        width: 7, height: 7,
                        decoration: const BoxDecoration(
                          color: _gold, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRoleFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RoleFilterSheet(
        options: _roleOptions,
        selected: _roleFilter,
        onSelect: (role) {
          setState(() => _roleFilter = role);
          Navigator.pop(context);
        },
      ),
    );
  }

  // ─── Section label ────────────────────────────────────────────────────────

  Widget _sectionLabel(String title, int count, {required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Container(
          width: 8, height: 8,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text(
          '$title  ·  $count',
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 1.3,
          ),
        ),
      ]),
    );
  }

  // ─── Crew card ────────────────────────────────────────────────────────────

  Widget _buildCard(_CrewProfile p) {
    final isAccepted = _acceptedIds.contains(p.id);
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAccepted
              ? _green.withValues(alpha: 0.35)
              : _gold.withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: isAccepted
                ? _green.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.28),
            blurRadius: 12, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAccepted)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: _green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: _green, size: 13),
                    const SizedBox(width: 5),
                    Text('Connected',
                        style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: _green)),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(p, isAccepted: isAccepted),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(p.name,
                              style: GoogleFonts.inter(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.star_rounded,
                              color: _gold, size: 14),
                          const SizedBox(width: 3),
                          Text(p.rating.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: _gold)),
                        ]),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        Container(
                          width: 7, height: 7,
                          decoration: BoxDecoration(
                            color: p.available ? _green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          p.available ? 'Available' : 'Unavailable',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: p.available ? _green : Colors.grey,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        const Icon(Icons.flight_rounded,
                            size: 12, color: Colors.white38),
                        const SizedBox(width: 4),
                        Text(p.hours,
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.white54)),
                        _pipe(),
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: Colors.white38),
                        const SizedBox(width: 3),
                        Text(p.distance,
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.white54)),
                        _pipe(),
                        Text(p.rate,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: _gold.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500)),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(color: _border, height: 1),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: _connectBtn(
                  isAccepted: isAccepted,
                  onTap: isAccepted ? null : () => _accept(p),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _rejectBtn(() => _decline(p))),
              const SizedBox(width: 8),
              Expanded(child: _chatBtn(() => _chat(p))),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _pipe() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text('|',
            style: GoogleFonts.inter(
                fontSize: 11, color: Colors.white24)),
      );

  Widget _buildAvatar(_CrewProfile p, {bool isAccepted = false}) {
    return Stack(children: [
      Container(
        width: 70, height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isAccepted
                ? _green.withValues(alpha: 0.6)
                : p.available
                    ? _gold.withValues(alpha: 0.5)
                    : _border,
            width: 2,
          ),
          color: const Color(0xFF2A2520),
          boxShadow: [
            BoxShadow(
              color: isAccepted
                  ? _green.withValues(alpha: 0.12)
                  : _gold.withValues(alpha: 0.07),
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipOval(
          child: p.avatarUrl != null
              ? Image.network(p.avatarUrl!, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _initials(p.name))
              : _initials(p.name),
        ),
      ),
      Positioned(
        bottom: 3, right: 3,
        child: Container(
          width: 14, height: 14,
          decoration: BoxDecoration(
            color: p.available ? _green : Colors.grey.shade700,
            shape: BoxShape.circle,
            border: Border.all(color: _bg, width: 2),
          ),
        ),
      ),
    ]);
  }

  Widget _initials(String name) => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.inter(
              color: _gold, fontWeight: FontWeight.w700, fontSize: 22),
        ),
      );

  // ─── Buttons ──────────────────────────────────────────────────────────────

  Widget _connectBtn({required bool isAccepted, required VoidCallback? onTap}) {
    if (isAccepted) {
      return Container(
        height: 42,
        decoration: BoxDecoration(
          color: _green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _green.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, color: _green, size: 15),
            const SizedBox(width: 6),
            Text('Connected',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _green)),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFB8960C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: 0.22),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 17, height: 17,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: const Color(0xFF0A0905), width: 1.5),
              ),
              child: const Icon(Icons.check_rounded,
                  size: 10, color: Color(0xFF0A0905)),
            ),
            const SizedBox(width: 6),
            Text('Connect',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0A0905))),
          ],
        ),
      ),
    );
  }

  Widget _rejectBtn(VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _gold.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 17, height: 17,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _gold, width: 1.5),
                ),
                child: const Icon(Icons.close_rounded,
                    size: 10, color: _gold),
              ),
              const SizedBox(width: 6),
              Text('Reject',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _gold)),
            ],
          ),
        ),
      );

  Widget _chatBtn(VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _gold.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chat_bubble_outline_rounded,
                  size: 14, color: _gold),
              const SizedBox(width: 6),
              Text('Chat',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _gold)),
            ],
          ),
        ),
      );

  // ─── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmpty() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.group_outlined,
                  color: _gold.withValues(alpha: 0.3), size: 48),
              const SizedBox(height: 16),
              Text('No crew found',
                  style: GoogleFonts.inter(
                      fontSize: 15, color: Colors.white38)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() {
                  _roleFilter = 'All';
                  _searchCtrl.clear();
                  _query = '';
                }),
                child: Text(
                  'Clear filters',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _gold.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

// ─── Role filter sheet ────────────────────────────────────────────────────────

class _RoleFilterSheet extends StatefulWidget {
  const _RoleFilterSheet({
    required this.options,
    required this.selected,
    required this.onSelect,
  });
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  State<_RoleFilterSheet> createState() => _RoleFilterSheetState();
}

class _RoleFilterSheetState extends State<_RoleFilterSheet> {
  static const _gold   = Color(0xFFD4AF37);
  static const _bg     = Color(0xFF0F0D0B);
  static const _cardBg = Color(0xFF1A1612);
  static const _border = Color(0xFF2A2520);

  late String _selected;

  static const _icons = <String, IconData>{
    'All':              Icons.apps_rounded,
    'Captain':          Icons.flight_rounded,
    'Pilot':            Icons.airplanemode_active_rounded,
    'Flight Attendant': Icons.airline_seat_recline_extra_rounded,
    'Crew Member':      Icons.groups_rounded,
    'Owner':            Icons.business_center_rounded,
    'Operator':         Icons.settings_rounded,
    'Engineer':         Icons.build_rounded,
    'Traveller':        Icons.luggage_rounded,
    'VIP Member':       Icons.star_rounded,
  };

  static const _fgMap = <String, Color>{
    'All':              Color(0xFFD4AF37),
    'Captain':          Color(0xFF6AABFF),
    'Pilot':            Color(0xFF5A9BEF),
    'Flight Attendant': Color(0xFFAF8FE0),
    'Crew Member':      Color(0xFFE08F8F),
    'Owner':            Color(0xFFD4AF37),
    'Operator':         Color(0xFF8FB8E0),
    'Engineer':         Color(0xFF7AB8A0),
    'Traveller':        Color(0xFFC07AAF),
    'VIP Member':       Color(0xFFE0C47A),
  };

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.of(context).padding.bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 38, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Row(
            children: [
              Container(
                width: 3, height: 20,
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'FILTER BY ROLE',
                style: GoogleFonts.cinzel(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.4,
                ),
              ),
              const Spacer(),
              if (_selected != 'All')
                GestureDetector(
                  onTap: () => setState(() => _selected = 'All'),
                  child: Text(
                    'Clear',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _gold.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: _border, height: 1),
          const SizedBox(height: 16),
          // Role options grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3.2,
            ),
            itemCount: widget.options.length,
            itemBuilder: (_, i) {
              final label = widget.options[i];
              final isActive = _selected == label;
              final color = _fgMap[label] ?? _gold;
              final icon  = _icons[label] ?? Icons.circle_outlined;
              return GestureDetector(
                onTap: () => setState(() => _selected = label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: isActive
                        ? color.withValues(alpha: 0.14)
                        : _cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? color.withValues(alpha: 0.55)
                          : _border,
                      width: isActive ? 1.5 : 1,
                    ),
                    boxShadow: isActive
                        ? [BoxShadow(
                            color: color.withValues(alpha: 0.12),
                            blurRadius: 10,
                          )]
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(icon,
                          size: 16,
                          color: isActive ? color : Colors.white38),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isActive ? color : Colors.white54,
                          ),
                        ),
                      ),
                      if (isActive)
                        Icon(Icons.check_circle_rounded,
                            size: 14, color: color),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // Apply button
          GestureDetector(
            onTap: () => widget.onSelect(_selected),
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8C547), _gold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _gold.withValues(alpha: 0.30),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _selected == 'All' ? 'Show All Crew' : 'Apply Filter',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0A0905),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data models ──────────────────────────────────────────────────────────────

class _CrewProfile {
  const _CrewProfile({
    required this.id, required this.name, required this.role,
    required this.roleTag, required this.hours, required this.distance,
    required this.rate, required this.rating, this.avatarUrl,
    required this.available,
  });
  final String id, name, role, roleTag, hours, distance, rate;
  final double rating;
  final String? avatarUrl;
  final bool available;
}
