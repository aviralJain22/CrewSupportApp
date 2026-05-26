import 'package:crew_support/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleCard extends StatelessWidget {
  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);
  static const _border = Color(0xFF2A2520);

  @override
  Widget build(BuildContext context) {
    final cardPad = AppSpacing.cardPadding(context);
    final iconContainerSize = AppSpacing.avatarSm(context) + 10;
    final iconSize = AppSpacing.iconMd(context);
    final iconGap = AppSpacing.md(context);
    final titleGap = AppSpacing.xxs(context) + 1;
    final checkboxGap = AppSpacing.sm(context) + 2;
    final checkboxSize = AppSpacing.iconMd(context) + 2;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(cardPad),
        decoration: BoxDecoration(
          color: selected ? _gold.withValues(alpha: 0.08) : _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _gold : _border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                color: selected
                    ? _gold.withValues(alpha: 0.15)
                    : const Color(0xFF2A2520),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: selected ? _gold : Colors.white54,
                size: iconSize,
              ),
            ),
            SizedBox(width: iconGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: titleGap),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: checkboxGap),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: checkboxSize,
              height: checkboxSize,
              decoration: BoxDecoration(
                color: selected ? _gold : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: selected ? _gold : const Color(0xFF555555),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Icon(Icons.check_rounded,
                      size: checkboxSize * 0.6,
                      color: const Color(0xFF0C0A08))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
