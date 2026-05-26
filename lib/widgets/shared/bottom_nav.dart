import 'package:crew_support/utils/app_spacing.dart';
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

  static const _bg = Color(0xFF0E0C0A);
  static const _gold = Color(0xFFD4AF37);
  static const _topBorder = Color(0xFF2A2520);

  static const _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.group_outlined, activeIcon: Icons.group_rounded, label: 'Connections'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
    _NavItem(icon: Icons.notifications_none_rounded, activeIcon: Icons.notifications_rounded, label: 'Alerts'),
    _NavItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: 'Messages'),
  ];

  @override
  Widget build(BuildContext context) {
    final navH = AppSpacing.bottomNavH(context);
    final iconSize = AppSpacing.iconMd(context) + 2;
    final badgeSize = AppSpacing.iconSm(context) + 2;
    final iconGap = AppSpacing.xxs(context) + 2;
    final selHPad = AppSpacing.md(context);
    final unselHPad = AppSpacing.sm(context);
    final vPad = AppSpacing.xxs(context) + 3;

    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: _topBorder, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: navH,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final selected = i == currentIndex;
              final badge = i == 3
                  ? notificationBadge
                  : i == 4
                      ? messageBadge
                      : 0;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIcon(
                        item, selected, badge,
                        iconSize: iconSize,
                        badgeSize: badgeSize,
                        selHPad: selHPad,
                        unselHPad: unselHPad,
                        vPad: vPad,
                      ),
                      SizedBox(height: iconGap),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 180),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? _gold : Colors.white38,
                        ),
                        child: Text(item.label),
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

  Widget _buildIcon(
    _NavItem item,
    bool selected,
    int badge, {
    required double iconSize,
    required double badgeSize,
    required double selHPad,
    required double unselHPad,
    required double vPad,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: selected ? selHPad : unselHPad,
            vertical: vPad,
          ),
          decoration: BoxDecoration(
            color: selected
                ? _gold.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            selected ? item.activeIcon : item.icon,
            color: selected ? _gold : Colors.white38,
            size: iconSize,
          ),
        ),
        if (badge > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: badgeSize,
              height: badgeSize,
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
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
