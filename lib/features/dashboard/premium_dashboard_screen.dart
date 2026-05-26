import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/routes.dart';
import '../../widgets/shared/trip_card.dart';
import '../../widgets/shared/empty_state.dart';
import '../../services/user_session.dart';

// ─── Mock data ────────────────────────────────────────────────────────────────

class _CrewMember {
  final String name, role;
  const _CrewMember(this.name, this.role);
}

class _MockTrip {
  final String fromCode, toCode, fromCity, toCity, date, aircraft;
  final String? tailNumber;
  final TripStatus status;
  final List<_CrewMember> crewList;
  final int crewMax;
  final List<int> avatarSeeds;
  final bool isPast;
  final bool isRated;
  const _MockTrip({
    required this.fromCode,
    required this.toCode,
    required this.fromCity,
    required this.toCity,
    required this.date,
    required this.status,
    required this.aircraft,
    this.tailNumber,
    this.crewList = const [],
    this.crewMax = 0,
    this.avatarSeeds = const [],
    this.isPast = false,
    this.isRated = false,
  });
}

const _mockTrips = [
  _MockTrip(
    fromCode: 'KTEB',
    toCode: 'KMIA',
    fromCity: 'Teterboro',
    toCity: 'Miami',
    date: 'Jun 2, 2026 · 10:30 AM',
    status: TripStatus.active,
    aircraft: 'Gulfstream G650',
    tailNumber: 'N550GS',
    crewList: [
      _CrewMember('Alex R.', 'Captain'),
      _CrewMember('Priya S.', 'Flight Attendant'),
    ],
    crewMax: 4,
    avatarSeeds: [12, 27],
  ),
  _MockTrip(
    fromCode: 'KSNA',
    toCode: 'KLAS',
    fromCity: 'John Wayne',
    toCity: 'Las Vegas',
    date: 'Jun 5, 2026 · 2:00 PM',
    status: TripStatus.confirmed,
    aircraft: 'Challenger 350',
    tailNumber: 'N650GD',
    crewList: [
      _CrewMember('James M.', 'Captain'),
    ],
    crewMax: 3,
    avatarSeeds: [5],
  ),
  _MockTrip(
    fromCode: 'KPBI',
    toCode: 'KJFK',
    fromCity: 'Palm Beach',
    toCity: 'New York',
    date: 'Jun 10, 2026 · 8:00 AM',
    status: TripStatus.pending,
    aircraft: 'Falcon 7X',
    tailNumber: 'N450PB',
    crewList: [],
    crewMax: 3,
    avatarSeeds: [],
  ),
  _MockTrip(
    fromCode: 'KSFO',
    toCode: 'KORD',
    fromCity: 'San Francisco',
    toCity: 'Chicago',
    date: 'Jun 15, 2026 · 11:00 AM',
    status: TripStatus.draft,
    aircraft: 'Phenom 300',
    tailNumber: 'N550SF',
    crewList: [],
    crewMax: 2,
    avatarSeeds: [],
  ),
  _MockTrip(
    fromCode: 'KBOS',
    toCode: 'KDCA',
    fromCity: 'Boston',
    toCity: 'Washington',
    date: 'May 20, 2026 · 9:00 AM',
    status: TripStatus.confirmed,
    aircraft: 'Global 7500',
    tailNumber: 'N650ER',
    crewList: [
      _CrewMember('Sophie L.', 'Captain'),
      _CrewMember('Ethan C.', 'SIC'),
    ],
    crewMax: 2,
    avatarSeeds: [33, 44],
    isPast: true,
    isRated: true,
  ),
  _MockTrip(
    fromCode: 'KLAX',
    toCode: 'KDEN',
    fromCity: 'Los Angeles',
    toCity: 'Denver',
    date: 'Apr 30, 2026 · 3:00 PM',
    status: TripStatus.active,
    aircraft: 'Citation X',
    tailNumber: 'N450CX',
    crewList: [
      _CrewMember('Alex R.', 'Captain'),
    ],
    crewMax: 3,
    avatarSeeds: [12],
    isPast: true,
    isRated: false,
  ),
];


// ─── Screen ───────────────────────────────────────────────────────────────────

class PremiumDashboardScreen extends StatefulWidget {
  const PremiumDashboardScreen({super.key});

  @override
  State<PremiumDashboardScreen> createState() => _PremiumDashboardScreenState();
}

class _PremiumDashboardScreenState extends State<PremiumDashboardScreen> {
  static const _bg = Color(0xFF0C0A08);
  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);
  static const _border = Color(0xFF2A2520);

  String _activeFilter = 'All';
  String _searchQuery = '';

  static const _filters = ['All', 'Current', 'Future', 'Pending', 'Draft', 'History'];

  List<_MockTrip> get _filtered {
    return _mockTrips.where((t) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!t.fromCode.toLowerCase().contains(q) &&
            !t.toCode.toLowerCase().contains(q) &&
            !t.fromCity.toLowerCase().contains(q) &&
            !t.toCity.toLowerCase().contains(q)) {
          return false;
        }
      }
      return switch (_activeFilter) {
        'Current' => t.status == TripStatus.active && !t.isPast,
        'Future'  => t.status == TripStatus.confirmed && !t.isPast,
        'Pending' => t.status == TripStatus.pending && !t.isPast,
        'Draft'   => t.status == TripStatus.draft,
        'History' => t.isPast,
        _ => true,
      };
    }).toList();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainHeader(),
            _buildGreetingSection(),
            const SizedBox(height: 16),
            _buildSearchAndFilter(),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: KeyedSubtree(
                  key: ValueKey(_activeFilter),
                  child: _buildBody(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ── Main header: avatar | CREW SUPPORT logo | bell + heart ───────────────────

  Widget _buildMainHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: _cardBg,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          _buildProfileCircle(),
          Expanded(child: _buildLogo()),
          _iconBtn(Icons.favorite_border_rounded, () {}),
        ],
      ),
    );
  }

  Widget _buildProfileCircle() {
    final initials = UserSession.instance.initials;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _gold.withValues(alpha: 0.6), width: 1.5),
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
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Wings row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _wingLine(reverse: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: const Icon(Icons.flight, color: _gold, size: 18),
            ),
            _wingLine(reverse: false),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          'CREW SUPPORT',
          style: GoogleFonts.cinzel(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 2.2,
          ),
        ),
      ],
    );
  }

  Widget _wingLine({required bool reverse}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final opacity = reverse ? (0.3 + i * 0.25) : (0.8 - i * 0.25);
        final width = reverse ? (6.0 + i * 4) : (14.0 - i * 4);
        return Padding(
          padding: EdgeInsets.only(
              left: reverse ? 2 : 0, right: reverse ? 0 : 2),
          child: Container(
            width: width.clamp(6.0, 14.0),
            height: 1.5,
            color: _gold.withValues(alpha: opacity.clamp(0.2, 0.9)),
          ),
        );
      }),
    );
  }

  // ── Greeting + Invite Crew ───────────────────────────────────────────────────

  Widget _buildGreetingSection() {
    final name = UserSession.instance.firstName.isNotEmpty
        ? UserSession.instance.firstName.toUpperCase()
        : 'CAPTAIN';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$name ✈',
                  style: GoogleFonts.cinzel(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Manage your trips and connect with crew.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.crewSearch),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _gold.withValues(alpha: 0.18),
                    _gold.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _gold.withValues(alpha: 0.4)),
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
                      color: _gold,
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

  // ── Search + filter ──────────────────────────────────────────────────────────

  Widget _buildSearchAndFilter() {
    final isFiltered = _activeFilter != 'All';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1612),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2E2A22)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded,
                      color: Colors.white38, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                      cursorColor: _gold,
                      decoration: InputDecoration(
                        hintText: 'Search trips, routes…',
                        hintStyle: GoogleFonts.inter(
                            fontSize: 14, color: Colors.white30),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _showStatusFilterSheet,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isFiltered
                        ? _gold.withValues(alpha: 0.12)
                        : const Color(0xFF1A1612),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isFiltered ? _gold : const Color(0xFF2E2A22),
                      width: isFiltered ? 1.5 : 1,
                    ),
                  ),
                  child: Icon(Icons.tune_rounded,
                      size: 20,
                      color: isFiltered ? _gold : Colors.white38),
                ),
                if (isFiltered)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                          color: _gold, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181410),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _StatusFilterSheet(
        filters: _filters,
        current: _activeFilter,
        onSelect: (f) {
          setState(() => _activeFilter = f);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showTripDetail(_MockTrip trip) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TripDetailSheet(trip: trip),
    );
  }

  // ── Body: section label + trip cards ─────────────────────────────────────────

  Widget _buildBody() {
    final trips = _filtered;
    if (trips.isEmpty) return _buildEmptyForFilter();
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildTripsLabel(),
        ),
        const SizedBox(height: 14),
        ...trips.map(
          (t) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TripCard(
              fromCode: t.fromCode,
              toCode: t.toCode,
              fromCity: t.fromCity,
              toCity: t.toCity,
              date: t.date,
              status: t.status,
              aircraft: t.aircraft,
              tailNumber: t.tailNumber,
              crewFilled: t.crewList.length,
              crewMax: t.crewMax,
              avatarSeeds: t.avatarSeeds,
              onTap: () => _showTripDetail(t),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTripsLabel() {
    final label = _activeFilter == 'All' ? 'YOUR TRIPS' : _activeFilter.toUpperCase();
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _gold,
            letterSpacing: 1.6,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {},
          child: Text(
            'View all →',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: _gold.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyForFilter() {
    final Map<String, (IconData, String, String)> config = {
      'Current': (Icons.flight_takeoff_rounded, 'No active trips',
          'Your current flights will appear here.'),
      'Future': (Icons.event_available_rounded, 'Nothing scheduled',
          'Book upcoming trips and they\'ll show here.'),
      'Pending': (Icons.hourglass_empty_rounded, 'No pending trips',
          'Trips awaiting crew confirmation appear here.'),
      'Draft': (Icons.edit_note_rounded, 'No drafts saved',
          'Start a trip and save it as a draft.'),
      'History': (Icons.history_rounded, 'No past trips',
          'Completed trips will be recorded here.'),
    };
    final c = config[_activeFilter] ??
        (Icons.airplanemode_off_rounded, 'No trips', 'Nothing to show here.');
    return EmptyState(
      icon: c.$1,
      title: c.$2,
      subtitle: c.$3,
      ctaLabel: 'Create Trip',
      onCta: () => Get.toNamed(AppRoutes.tripCreation),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.tripCreation),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8C547), _gold],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Color(0xFF0C0A08), size: 28),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _bg,
          shape: BoxShape.circle,
          border: Border.all(color: _border),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}

// ─── Status filter sheet ──────────────────────────────────────────────────────

class _StatusFilterSheet extends StatefulWidget {
  const _StatusFilterSheet({
    required this.filters,
    required this.current,
    required this.onSelect,
  });

  final List<String> filters;
  final String current;
  final ValueChanged<String> onSelect;

  @override
  State<_StatusFilterSheet> createState() => _StatusFilterSheetState();
}

class _StatusFilterSheetState extends State<_StatusFilterSheet> {
  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);
  static const _border = Color(0xFF2A2520);

  late String _selected;

  static const _descriptions = <String, String>{
    'All': 'Show every trip regardless of status',
    'Current': 'Trips that are currently active / in progress',
    'Future': 'Upcoming confirmed trips',
    'Pending': 'Trips awaiting crew confirmation',
    'Draft': 'Saved drafts not yet posted',
    'History': 'Completed or past trips',
  };

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'FILTER TRIPS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _gold,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.filters.map((f) => _filterTile(f)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: GestureDetector(
              onTap: () => widget.onSelect(_selected),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8C547), _gold],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Apply Filter',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0C0A08),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterTile(String label) {
    final isSelected = _selected == label;
    final desc = _descriptions[label] ?? '';
    return GestureDetector(
      onTap: () => setState(() => _selected = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _gold.withValues(alpha: 0.08) : _cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _gold : _border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? _gold : Colors.white,
                    ),
                  ),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.white38, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? _gold.withValues(alpha: 0.15)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? _gold : _border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 12, color: _gold)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Trip detail sheet ────────────────────────────────────────────────────────

class _TripDetailSheet extends StatefulWidget {
  const _TripDetailSheet({required this.trip});
  final _MockTrip trip;

  @override
  State<_TripDetailSheet> createState() => _TripDetailSheetState();
}

class _TripDetailSheetState extends State<_TripDetailSheet> {
  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF141210);
  static const _border = Color(0xFF2A2520);
  static const _green = Color(0xFF4FC870);
  static const _red = Color(0xFFB33A3A);

  bool _isCompleting = false;
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141210),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.of(context).padding.bottom + 28),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHandle(),
            _buildRouteHeader(),
            _buildDivider(),
            _buildInfoRows(),
            _buildDivider(),
            _buildCrewSection(),
            const SizedBox(height: 20),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildRouteHeader() {
    final t = widget.trip;
    final sc = _statusColor(t);
    final sl = _statusLabel(t);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _codeCol(t.fromCode, t.fromCity),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Container(
                          width: 20,
                          height: 1,
                          color: _gold.withValues(alpha: 0.4)),
                      const Icon(Icons.flight, size: 18, color: _gold),
                      Container(
                          width: 20,
                          height: 1,
                          color: _gold.withValues(alpha: 0.4)),
                    ],
                  ),
                ),
                _codeCol(t.toCode, t.toCity),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: sc.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: sc.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration:
                      BoxDecoration(color: sc, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(sl,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sc)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _codeCol(String code, String city) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(code,
            style: GoogleFonts.cinzel(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1)),
        Text(city,
            style:
                GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
      ],
    );
  }

  Widget _buildInfoRows() {
    final t = widget.trip;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          _infoRow(Icons.calendar_today_outlined, 'Date', t.date),
          const SizedBox(height: 10),
          _infoRow(Icons.airplanemode_active_rounded, 'Aircraft', t.aircraft),
          if (t.tailNumber != null) ...[
            const SizedBox(height: 10),
            _infoRow(Icons.tag_rounded, 'Tail', t.tailNumber!),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _gold.withValues(alpha: 0.7)),
        const SizedBox(width: 10),
        Text('$label  ',
            style:
                GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
        Expanded(
          child: Text(value,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildCrewSection() {
    final t = widget.trip;
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CREW',
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _gold.withValues(alpha: 0.7),
                      letterSpacing: 1.4)),
              if (!t.isPast)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline_rounded,
                          size: 14, color: _gold),
                      const SizedBox(width: 4),
                      Text('Add Crew',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: _gold,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (t.crewList.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: Text(
                'No crew assigned yet. Tap + Add Crew to send requests.',
                style: GoogleFonts.inter(
                    fontSize: 12, color: Colors.white38, height: 1.5),
              ),
            )
          else
            ...t.crewList.map(_crewTile),
        ],
      ),
    );
  }

  Widget _crewTile(_CrewMember member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Color(0xFF2A2520)),
            child: Center(
              child: Text(
                member.name.isNotEmpty
                    ? member.name[0].toUpperCase()
                    : '?',
                style: GoogleFonts.inter(
                    color: _gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(member.name,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: _gold.withValues(alpha: 0.25)),
            ),
            child: Text(member.role,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _gold)),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final t = widget.trip;

    if (t.isPast) {
      if (!t.isRated) {
        return _goldBtn(
            'Rate Crew',
            Icons.star_border_rounded,
            () => Navigator.pop(context));
      }
      return Center(
        child: Text('Trip completed & rated',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white38)),
      );
    }

    return switch (t.status) {
      TripStatus.active => Column(
          children: [
            _isCompleted
                ? _completedBadge()
                : _goldBtn(
                    _isCompleting ? 'Completing…' : 'Mark as Complete',
                    Icons.check_circle_outline_rounded,
                    _isCompleting
                        ? null
                        : () async {
                            setState(() => _isCompleting = true);
                            await Future.delayed(
                                const Duration(milliseconds: 1200));
                            setState(() {
                              _isCompleting = false;
                              _isCompleted = true;
                            });
                            await Future.delayed(
                                const Duration(milliseconds: 700));
                            if (context.mounted) Navigator.pop(context);
                          },
                  ),
            const SizedBox(height: 10),
            _outlineBtn('Cancel Trip', Icons.close_rounded, _red,
                () => Navigator.pop(context)),
          ],
        ),
      TripStatus.confirmed => Column(
          children: [
            _outlineBtn('Edit Dates', Icons.edit_calendar_outlined, _gold,
                () => Navigator.pop(context)),
            const SizedBox(height: 10),
            _outlineBtn('Cancel Trip', Icons.close_rounded, _red,
                () => Navigator.pop(context)),
          ],
        ),
      TripStatus.pending => _outlineBtn('Cancel Trip', Icons.close_rounded,
          _red, () => Navigator.pop(context)),
      TripStatus.draft => Column(
          children: [
            _goldBtn('Post Trip', Icons.send_rounded,
                () => Navigator.pop(context)),
            const SizedBox(height: 10),
            _outlineBtn('Delete Draft', Icons.delete_outline_rounded, _red,
                () => Navigator.pop(context)),
          ],
        ),
    };
  }

  Widget _completedBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _green.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, color: _green, size: 18),
          const SizedBox(width: 8),
          Text('Trip Completed!',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _green)),
        ],
      ),
    );
  }

  Widget _goldBtn(String label, IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: onTap != null
              ? const LinearGradient(
                  colors: [Color(0xFFE8C547), _gold])
              : null,
          color: onTap == null ? const Color(0xFF2A2520) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: onTap != null
                    ? const Color(0xFF0C0A08)
                    : Colors.white38),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: onTap != null
                        ? const Color(0xFF0C0A08)
                        : Colors.white38)),
          ],
        ),
      ),
    );
  }

  Widget _outlineBtn(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => const Divider(color: _border, height: 1);

  Color _statusColor(_MockTrip t) {
    if (t.isPast) return const Color(0xFF4FC870);
    return switch (t.status) {
      TripStatus.active => const Color(0xFF3DAA57),
      TripStatus.pending => const Color(0xFFF5A623),
      TripStatus.draft => const Color(0xFF777777),
      TripStatus.confirmed => const Color(0xFF4A90D9),
    };
  }

  String _statusLabel(_MockTrip t) {
    if (t.isPast) return 'Completed';
    return switch (t.status) {
      TripStatus.active => 'Active',
      TripStatus.pending => 'Pending',
      TripStatus.draft => 'Draft',
      TripStatus.confirmed => 'Confirmed',
    };
  }
}
