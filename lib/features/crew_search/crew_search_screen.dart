import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/shared/crew_card.dart';
import '../../widgets/shared/empty_state.dart';
import '../../widgets/shared/section_header.dart';

// ─── Mock data ────────────────────────────────────────────────────────────────

class _MockCrew {
  final String name, role;
  final String? avatarUrl;
  final int hours;
  final double distanceMi, rating;
  final int dayRate;
  final AvailabilityStatus availability;
  const _MockCrew({
    required this.name,
    required this.role,
    this.avatarUrl,
    required this.hours,
    required this.distanceMi,
    required this.rating,
    required this.dayRate,
    required this.availability,
  });
}

const _allCrew = [
  _MockCrew(
    name: 'Alexander Reid',
    role: 'Captain',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
    hours: 8500,
    distanceMi: 12,
    rating: 4.9,
    dayRate: 1200,
    availability: AvailabilityStatus.available,
  ),
  _MockCrew(
    name: 'Priya Sharma',
    role: 'Flight Attendant',
    avatarUrl: 'https://i.pravatar.cc/150?img=47',
    hours: 3200,
    distanceMi: 28,
    rating: 4.7,
    dayRate: 650,
    availability: AvailabilityStatus.available,
  ),
  _MockCrew(
    name: 'James Mitchell',
    role: 'Captain',
    avatarUrl: 'https://i.pravatar.cc/150?img=3',
    hours: 12400,
    distanceMi: 45,
    rating: 5.0,
    dayRate: 1500,
    availability: AvailabilityStatus.partial,
  ),
  _MockCrew(
    name: 'Sophie Laurent',
    role: 'Flight Attendant',
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
    hours: 2100,
    distanceMi: 8,
    rating: 4.8,
    dayRate: 600,
    availability: AvailabilityStatus.available,
  ),
  _MockCrew(
    name: 'Ethan Calloway',
    role: 'SIC',
    avatarUrl: 'https://i.pravatar.cc/150?img=8',
    hours: 4800,
    distanceMi: 62,
    rating: 4.6,
    dayRate: 900,
    availability: AvailabilityStatus.partial,
  ),
  _MockCrew(
    name: 'Isabella Torres',
    role: 'Flight Instructor',
    avatarUrl: 'https://i.pravatar.cc/150?img=9',
    hours: 6700,
    distanceMi: 15,
    rating: 4.9,
    dayRate: 1100,
    availability: AvailabilityStatus.unavailable,
  ),
  _MockCrew(
    name: 'Marcus Webb',
    role: 'SIC',
    avatarUrl: 'https://i.pravatar.cc/150?img=11',
    hours: 3900,
    distanceMi: 33,
    rating: 4.5,
    dayRate: 850,
    availability: AvailabilityStatus.available,
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class CrewSearchScreen extends StatefulWidget {
  const CrewSearchScreen({super.key});

  @override
  State<CrewSearchScreen> createState() => _CrewSearchScreenState();
}

class _CrewSearchScreenState extends State<CrewSearchScreen> {
  static const _bg = Color(0xFF0C0A08);
  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);

  final _searchCtrl = TextEditingController();
  final _roleFilters = ['All', 'Captain', 'SIC', 'FA', 'Instructor'];
  final List<String> _selectedRoles = ['All'];
  final List<String> _quickFilters = [];

  final bool _isLoading = false;
  String _sortLabel = 'Rating';

  final _quickOptions = [
    'Available now',
    'Within 50 mi',
    'Rating 4+',
  ];

  List<_MockCrew> get _filtered {
    var list = List<_MockCrew>.from(_allCrew);
    final q = _searchCtrl.text.toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.role.toLowerCase().contains(q)).toList();
    }
    if (!_selectedRoles.contains('All')) {
      list = list.where((c) {
        final role = c.role.toLowerCase();
        return _selectedRoles.any((r) {
          return switch (r) {
            'Captain' => role.contains('captain'),
            'SIC' => role.contains('sic'),
            'FA' => role.contains('attendant'),
            'Instructor' => role.contains('instructor'),
            _ => true,
          };
        });
      }).toList();
    }
    if (_quickFilters.contains('Available now')) {
      list = list
          .where((c) => c.availability == AvailabilityStatus.available)
          .toList();
    }
    if (_quickFilters.contains('Within 50 mi')) {
      list = list.where((c) => c.distanceMi <= 50).toList();
    }
    if (_quickFilters.contains('Rating 4+')) {
      list = list.where((c) => c.rating >= 4.0).toList();
    }
    list.sort((a, b) => switch (_sortLabel) {
          'Rating' => b.rating.compareTo(a.rating),
          'Distance' => a.distanceMi.compareTo(b.distanceMi),
          'Day Rate' => a.dayRate.compareTo(b.dayRate),
          _ => 0,
        });
    return list;
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
      appBar: _appBar,
      body: Column(
        children: [
          _buildSearch(),
          const SizedBox(height: 16),
          _buildResultsBar(),
          const SizedBox(height: 12),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  AppBar get _appBar => AppBar(
        backgroundColor: _bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: GestureDetector(
          onTap: Get.back,
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
        ),
        title: Text(
          'Find Crew',
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFF2A2520), height: 1),
        ),
        actions: [
          // Filters button with active-count badge
          GestureDetector(
            onTap: _showFilterPanel,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _activeFilterCount > 0
                        ? _gold.withValues(alpha: 0.12)
                        : _cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _activeFilterCount > 0
                          ? _gold
                          : const Color(0xFF2A2520),
                      width: _activeFilterCount > 0 ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune_rounded,
                          color: _activeFilterCount > 0
                              ? _gold
                              : Colors.white54,
                          size: 16),
                      const SizedBox(width: 5),
                      Text(
                        'Filters',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _activeFilterCount > 0
                              ? _gold
                              : Colors.white54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_activeFilterCount > 0)
                  Positioned(
                    top: -4,
                    right: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                          color: _gold, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          '$_activeFilterCount',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0C0A08),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Sort button
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A2520), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort_rounded,
                      color: Colors.white54, size: 15),
                  const SizedBox(width: 4),
                  Text(
                    _sortLabel,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
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
            const Icon(Icons.search_rounded, color: Colors.white38, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() {}),
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                cursorColor: _gold,
                decoration: InputDecoration(
                  hintText: 'Search by name or role…',
                  hintStyle:
                      GoogleFonts.inter(fontSize: 14, color: Colors.white30),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_searchCtrl.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  setState(() {});
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.close_rounded,
                      color: Colors.white38, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsBar() {
    final count = _filtered.length;
    final hasActiveFilters = !_selectedRoles.contains('All') || _quickFilters.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          SectionHeader(
            title: '$count result${count == 1 ? '' : 's'}',
          ),
          if (hasActiveFilters) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Clear',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFFD4AF37),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 5,
        itemBuilder: (_, i) => _buildSkeleton(),
      );
    }
    final crew = _filtered;
    if (crew.isEmpty) {
      return EmptyState(
        icon: Icons.group_off_rounded,
        title: 'No crew found',
        subtitle: 'Try adjusting your filters\nor search for a different role.',
        ctaLabel: 'Clear filters',
        onCta: _clearFilters,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
      itemCount: crew.length,
      itemBuilder: (_, i) {
        final c = crew[i];
        return CrewCard(
          name: c.name,
          role: c.role,
          avatarUrl: c.avatarUrl,
          hours: c.hours,
          distanceMi: c.distanceMi,
          dayRate: c.dayRate,
          rating: c.rating,
          availability: c.availability,
          onTap: () => _navigateToProfile(c),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181410),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _shimmer(54, 54, radius: 27),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmer(140, 14),
                const SizedBox(height: 8),
                _shimmer(90, 10),
                const SizedBox(height: 10),
                Row(children: [
                  _shimmer(70, 10),
                  const SizedBox(width: 10),
                  _shimmer(70, 10),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmer(double w, double h, {double radius = 6}) {
    return _ShimmerBox(width: w, height: h, borderRadius: radius);
  }

  void _clearFilters() {
    setState(() {
      _selectedRoles
        ..clear()
        ..add('All');
      _quickFilters.clear();
      _searchCtrl.clear();
    });
  }

  int get _activeFilterCount {
    int count = 0;
    if (!_selectedRoles.contains('All')) count += _selectedRoles.length;
    count += _quickFilters.length;
    return count;
  }

  void _navigateToProfile(_MockCrew crew) {
    Get.toNamed('/pendingPilotProfile');
  }

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181410),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CrewFilterSheet(
        roleOptions: _roleFilters,
        quickOptions: _quickOptions,
        selectedRoles: List.from(_selectedRoles),
        selectedQuick: List.from(_quickFilters),
        onApply: (roles, quick) {
          setState(() {
            _selectedRoles
              ..clear()
              ..addAll(roles);
            _quickFilters
              ..clear()
              ..addAll(quick);
          });
          Navigator.pop(context);
        },
        onReset: () {
          setState(() {
            _selectedRoles
              ..clear()
              ..add('All');
            _quickFilters.clear();
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181410),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SortSheet(
        current: _sortLabel,
        onSelect: (s) {
          setState(() => _sortLabel = s);
          Navigator.pop(context);
        },
      ),
    );
  }

}

// ─── Shimmer box ─────────────────────────────────────────────────────────────

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 6,
  });
  final double width, height, borderRadius;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
            const Color(0xFF2A2520),
            const Color(0xFF3A3530),
            _anim.value,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

// ─── Sort sheet ───────────────────────────────────────────────────────────────

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.current, required this.onSelect});
  final String current;
  final void Function(String) onSelect;

  static const _options = ['Rating', 'Distance', 'Day Rate'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SORT BY',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFD4AF37),
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 16),
          ..._options.map((o) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  o,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: o == current
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                trailing: o == current
                    ? const Icon(Icons.check_rounded,
                        color: Color(0xFFD4AF37))
                    : null,
                onTap: () => onSelect(o),
              )),
        ],
      ),
    );
  }
}

// ─── Crew filter sheet ────────────────────────────────────────────────────────

class _CrewFilterSheet extends StatefulWidget {
  const _CrewFilterSheet({
    required this.roleOptions,
    required this.quickOptions,
    required this.selectedRoles,
    required this.selectedQuick,
    required this.onApply,
    required this.onReset,
  });

  final List<String> roleOptions;
  final List<String> quickOptions;
  final List<String> selectedRoles;
  final List<String> selectedQuick;
  final void Function(List<String> roles, List<String> quick) onApply;
  final VoidCallback onReset;

  @override
  State<_CrewFilterSheet> createState() => _CrewFilterSheetState();
}

class _CrewFilterSheetState extends State<_CrewFilterSheet> {
  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);
  static const _border = Color(0xFF2A2520);

  late List<String> _roles;
  late List<String> _quick;

  @override
  void initState() {
    super.initState();
    _roles = List.from(widget.selectedRoles);
    _quick = List.from(widget.selectedQuick);
  }

  void _toggleRole(String role) {
    setState(() {
      if (role == 'All') {
        _roles
          ..clear()
          ..add('All');
      } else {
        _roles.remove('All');
        if (_roles.contains(role)) {
          _roles.remove(role);
          if (_roles.isEmpty) _roles.add('All');
        } else {
          _roles.add(role);
        }
      }
    });
  }

  void _toggleQuick(String filter) {
    setState(() {
      if (_quick.contains(filter)) {
        _quick.remove(filter);
      } else {
        _quick.add(filter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
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
          // Header row
          Row(
            children: [
              Text(
                'FILTER CREW',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _gold,
                  letterSpacing: 1.8,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: widget.onReset,
                child: Text(
                  'Reset all',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Role section
          _sectionLabel('ROLE'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.roleOptions
                .map((r) => _chip(r, _roles.contains(r), () => _toggleRole(r)))
                .toList(),
          ),
          const SizedBox(height: 20),
          // Quick filters section
          _sectionLabel('QUICK FILTERS'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.quickOptions
                .map((q) => _chip(q, _quick.contains(q), () => _toggleQuick(q)))
                .toList(),
          ),
          const SizedBox(height: 28),
          // Apply button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: GestureDetector(
              onTap: () => widget.onApply(_roles, _quick),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8C547), _gold],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Apply Filters',
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

  Widget _sectionLabel(String label) => Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white38,
          letterSpacing: 1.2,
        ),
      );

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active ? _gold.withValues(alpha: 0.12) : _cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: active ? _gold : _border,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active) ...[
              const Icon(Icons.check_rounded, size: 13, color: _gold),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? _gold : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
