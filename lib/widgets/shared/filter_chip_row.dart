import 'package:crew_support/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterChipRow extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.items,
    required this.selected,
    required this.onTap,
    this.multiSelect = false,
    this.padding,
  });

  final List<String> items;
  final List<String> selected;
  final void Function(String item) onTap;
  final bool multiSelect;
  final EdgeInsetsGeometry? padding;

  static const _gold = Color(0xFFD4AF37);
  static const _darkBg = Color(0xFF0C0A08);
  static const _surface = Color(0xFF1E1A14);
  static const _border = Color(0xFF2E2A22);

  @override
  Widget build(BuildContext context) {
    final hPad = AppSpacing.screenH(context);
    final chipHPad = AppSpacing.md(context);
    final chipVPad = AppSpacing.sm(context);
    final chipGap = AppSpacing.sm(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding ?? EdgeInsets.symmetric(horizontal: hPad),
      child: Row(
        children: items.map((item) {
          final isSelected = selected.contains(item);
          return Padding(
            padding: EdgeInsets.only(right: chipGap),
            child: GestureDetector(
              onTap: () => onTap(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(
                  horizontal: chipHPad,
                  vertical: chipVPad,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? _gold : _surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? _gold : _border,
                    width: 1,
                  ),
                ),
                child: Text(
                  item,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? _darkBg : Colors.white70,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
