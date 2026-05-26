import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/shared/filter_chip_row.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  static const _bg = Color(0xFF0C0A08);
  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);
  static const _border = Color(0xFF2A2520);

  int _filterIdx = 0;
  final List<String> _filters = ['All', 'Pilots', 'FA', 'Instructors', 'Owners'];

  final List<_FavItem> _favs = [
    _FavItem(
      name: 'Alexander Reid',
      role: 'Captain / Pilot',
      sub: '8,500 hrs · \$1,200/day',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      type: 'Pilots',
      available: true,
    ),
    _FavItem(
      name: 'Sophia Lane',
      role: 'Flight Attendant',
      sub: '7 yrs · \$650/day',
      avatarUrl: 'https://i.pravatar.cc/150?img=47',
      type: 'FA',
      available: true,
    ),
    _FavItem(
      name: 'James Holloway',
      role: 'Flight Instructor · CFI',
      sub: '12,000 hrs · \$120/hr',
      avatarUrl: 'https://i.pravatar.cc/150?img=33',
      type: 'Instructors',
      available: false,
    ),
    _FavItem(
      name: 'Sarah Mitchell',
      role: 'Aircraft Owner',
      sub: 'KTEB · G650',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      type: 'Owners',
      available: true,
    ),
    _FavItem(
      name: 'Marcus Webb',
      role: 'First Officer',
      sub: '4,200 hrs · \$800/day',
      avatarUrl: 'https://i.pravatar.cc/150?img=15',
      type: 'Pilots',
      available: false,
    ),
  ];

  List<_FavItem> get _filtered {
    if (_filterIdx == 0) return _favs;
    final label = _filters[_filterIdx];
    return _favs.where((f) => f.type == label).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _cardBg,
                shape: BoxShape.circle,
                border: Border.all(
                    color: _gold.withValues(alpha: 0.45), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: _gold.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
        leadingWidth: 60,
        title: Text(
          'Favourites',
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _cardBg,
                shape: BoxShape.circle,
                border: Border.all(
                    color: _gold.withValues(alpha: 0.35), width: 1),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: _gold.withValues(alpha: 0.7),
                size: 16,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: _border, height: 1),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
            child: FilterChipRow(
              items: _filters,
              selected: [_filters[_filterIdx]],
              onTap: (item) =>
                  setState(() => _filterIdx = _filters.indexOf(item)),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? _emptyState
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, idx) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _favCard(_filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _favCard(_FavItem item) {
    return Dismissible(
      key: ValueKey(item.name),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFB33A3A).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.bookmark_remove_rounded,
            color: Color(0xFFB33A3A), size: 22),
      ),
      onDismissed: (_) => setState(() => _favs.remove(item)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            _avatar(item),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      _availDot(item.available),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.role,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.white54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.sub,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _gold.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _messageButton,
          ],
        ),
      ),
    );
  }

  Widget _avatar(_FavItem item) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _border),
        color: const Color(0xFF2A2520),
      ),
      child: ClipOval(
        child: item.avatarUrl != null
            ? Image.network(
                item.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, err, st) => _initial(item.name),
              )
            : _initial(item.name),
      ),
    );
  }

  Widget _initial(String name) => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.inter(
              color: _gold, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      );

  Widget _availDot(bool available) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: available
              ? const Color(0xFF3DAA57)
              : const Color(0xFF2A2520),
          shape: BoxShape.circle,
          border: available
              ? null
              : Border.all(color: Colors.white24),
        ),
      );

  Widget get _messageButton => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _gold.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: _gold.withValues(alpha: 0.3)),
        ),
        child: const Icon(Icons.chat_bubble_outline_rounded,
            size: 16, color: Color(0xFFD4AF37)),
      );

  Widget get _emptyState {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bookmark_border_rounded,
                color: Color(0xFFD4AF37), size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            'No Favourites',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save crew and owners here\nfor quick access.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

class _FavItem {
  const _FavItem({
    required this.name,
    required this.role,
    required this.sub,
    this.avatarUrl,
    required this.type,
    required this.available,
  });

  final String name;
  final String role;
  final String sub;
  final String? avatarUrl;
  final String type;
  final bool available;
}
