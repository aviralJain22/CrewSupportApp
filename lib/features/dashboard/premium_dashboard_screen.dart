import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/routes.dart';
import '../../widgets/shared/section_header.dart';
import '../../widgets/shared/trip_card.dart';
import '../../widgets/shared/empty_state.dart';

// ─── Mock data ────────────────────────────────────────────────────────────────

enum _UserRole { owner, crewMember }

class _MockTrip {
  final String fromCode, toCode, fromCity, toCity, date;
  final TripStatus status;
  final List<String> crew;
  final bool isPast;
  const _MockTrip({
    required this.fromCode,
    required this.toCode,
    required this.fromCity,
    required this.toCity,
    required this.date,
    required this.status,
    this.crew = const [],
    this.isPast = false,
  });
}

const _mockTrips = [
  _MockTrip(
    fromCode: 'KTEB',
    toCode: 'KMIA',
    fromCity: 'Teterboro',
    toCity: 'Miami',
    date: 'Jun 2, 2026 · 10:30 AM',
    status: TripStatus.confirmed,
    crew: ['Alex R.', 'Priya S.'],
  ),
  _MockTrip(
    fromCode: 'KSNA',
    toCode: 'KLAS',
    fromCity: 'John Wayne',
    toCity: 'Las Vegas',
    date: 'Jun 5, 2026 · 2:00 PM',
    status: TripStatus.active,
    crew: ['James M.'],
  ),
  _MockTrip(
    fromCode: 'KPBI',
    toCode: 'KJFK',
    fromCity: 'Palm Beach',
    toCity: 'New York',
    date: 'Jun 10, 2026 · 8:00 AM',
    status: TripStatus.pending,
    crew: [],
  ),
  _MockTrip(
    fromCode: 'KSFO',
    toCode: 'KORD',
    fromCity: 'San Francisco',
    toCity: 'Chicago',
    date: 'Jun 15, 2026 · 11:00 AM',
    status: TripStatus.draft,
    crew: [],
  ),
  _MockTrip(
    fromCode: 'KBOS',
    toCode: 'KDCA',
    fromCity: 'Boston',
    toCity: 'Washington',
    date: 'May 20, 2026 · 9:00 AM',
    status: TripStatus.confirmed,
    crew: ['Sophie L.', 'Ethan C.'],
    isPast: true,
  ),
  _MockTrip(
    fromCode: 'KLAX',
    toCode: 'KDEN',
    fromCity: 'Los Angeles',
    toCity: 'Denver',
    date: 'Apr 30, 2026 · 3:00 PM',
    status: TripStatus.active,
    crew: ['Alex R.'],
    isPast: true,
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

  final _role = _UserRole.owner;
  String _activeFilter = 'All';
  String _searchQuery = '';

  List<String> get _ownerFilters =>
      ['All', 'Current', 'Future', 'Pending', 'Draft', 'History'];
  List<String> get _crewFilters =>
      ['All', 'Current', 'Future', 'Pending', 'History'];

  List<String> get _filters => switch (_role) {
        _UserRole.owner => _ownerFilters,
        _UserRole.crewMember => _crewFilters,
      };

  List<_MockTrip> get _filtered {
    var list = _mockTrips.where((t) {
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
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSearchAndFilter(),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: child,
                ),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning,',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Akshita ✈',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          _iconBtn(Icons.favorite_border_rounded, () {}),
          const SizedBox(width: 8),
          _iconBtn(Icons.notifications_none_rounded, () {
            Get.toNamed(AppRoutes.notification);
          }),
          const SizedBox(width: 10),
          _avatar,
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    final isFiltered = _activeFilter != 'All';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1612),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2E2A22), width: 1),
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
                      style:
                          GoogleFonts.inter(fontSize: 14, color: Colors.white),
                      cursorColor: _gold,
                      decoration: InputDecoration(
                        hintText: 'Search trips, routes…',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white30,
                        ),
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
          // Filter button
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
                  child: Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: isFiltered ? _gold : Colors.white38,
                  ),
                ),
                if (isFiltered)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: _gold,
                        shape: BoxShape.circle,
                      ),
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

  Widget _buildBody() {
    final trips = _filtered;
    if (trips.isEmpty) {
      return _buildEmptyForFilter();
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        SectionHeader(
          title: _activeFilter == 'All' ? 'Your Trips' : _activeFilter,
          actionLabel: 'View all',
        ),
        const SizedBox(height: 14),
        ...trips.map(
          (t) => TripCard(
            fromCode: t.fromCode,
            toCode: t.toCode,
            fromCity: t.fromCity,
            toCity: t.toCity,
            date: t.date,
            status: t.status,
            assignedCrew: t.crew,
            onTap: () => Get.toNamed(AppRoutes.tripSummary),
          ),
        ),
        const SizedBox(height: 16),
        _buildCreateCTA(),
      ],
    );
  }

  Widget _buildEmptyForFilter() {
    final Map<String, (IconData, String, String)> config = {
      'Current': (
        Icons.flight_takeoff_rounded,
        'No active trips',
        'Your current flights will appear here.'
      ),
      'Future': (
        Icons.event_available_rounded,
        'Nothing scheduled',
        'Book upcoming trips and they\'ll show here.'
      ),
      'Pending': (
        Icons.hourglass_empty_rounded,
        'No pending trips',
        'Trips awaiting crew confirmation appear here.'
      ),
      'Draft': (
        Icons.edit_note_rounded,
        'No drafts saved',
        'Start a trip and save it as a draft.'
      ),
      'History': (
        Icons.history_rounded,
        'No past trips',
        'Completed trips will be recorded here.'
      ),
    };
    final c = config[_activeFilter] ??
        (Icons.airplanemode_off_rounded, 'No trips', 'Nothing to show here.');
    return EmptyState(
      icon: c.$1,
      title: c.$2,
      subtitle: c.$3,
      ctaLabel: 'Create Trip',
      onCta: () => Get.toNamed(AppRoutes.createTrip),
    );
  }

  Widget _buildCreateCTA() {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.createTrip),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _gold.withValues(alpha: 0.12),
              _gold.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _gold.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: _gold, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create New Trip',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Post a flight and find the perfect crew',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: _gold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.createTrip),
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
        child: const Icon(Icons.add_rounded,
            color: Color(0xFF0C0A08), size: 28),
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
          color: _cardBg,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF2A2520), width: 1),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }

  Widget get _avatar => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _gold, width: 1.5),
          color: const Color(0xFF2A2520),
        ),
        child: Center(
          child: Text(
            'A',
            style: GoogleFonts.inter(
              color: _gold,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      );
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
          // Handle
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
                        fontSize: 11,
                        color: Colors.white38,
                        height: 1.4,
                      ),
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
