import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.messageBadge = 0,
    this.notificationBadge = 0,
  });

  final int currentIndex;
  final void Function(int) onTap;
  final int messageBadge;
  final int notificationBadge;

  static const _gold = Color(0xFFD4AF37);
  static const _bg = Color(0xFFFFFFFF);
  static const _selected = Color(0xFF1A2B4A);
  static const _unselected = Color(0xFF9EA8C0);

  static const _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.search_outlined, activeIcon: Icons.search_rounded, label: 'Search'),
    _NavItem(icon: Icons.group_outlined, activeIcon: Icons.group_rounded, label: 'Crew'),
    _NavItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: 'Messages'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: Color(0xFFE8E8E8), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final selected = i == currentIndex;
              final badge = i == 3
                  ? messageBadge
                  : i == 4
                      ? notificationBadge
                      : 0;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIconWithPill(item, selected, badge),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected ? _selected : _unselected,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithPill(
      _NavItem item, bool selected, int badge) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 14 : 8,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: selected ? _gold.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            selected ? item.activeIcon : item.icon,
            color: selected ? _selected : _unselected,
            size: 22,
          ),
        ),
        if (badge > 0)
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: _gold,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  badge > 9 ? '9+' : '$badge',
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
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(
      {required this.icon,
      required this.activeIcon,
      required this.label});
}
