import 'package:crew_support/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FilterChipRow extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.multiSelect = false,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    this.spacing = AppSpacing.sm,
  });

  final List<String> options;

  /// Set of currently selected option values.
  final Set<String> selected;

  /// Called with the full updated selection set after a tap.
  final ValueChanged<Set<String>> onChanged;

  /// When false only one chip can be active at a time (radio behaviour).
  final bool multiSelect;

  final EdgeInsets padding;
  final double spacing;

  void _onTap(String value) {
    final next = Set<String>.from(selected);
    if (next.contains(value)) {
      if (multiSelect) next.remove(value);
      // single-select: don't allow deselecting the only selected item
    } else {
      if (!multiSelect) next.clear();
      next.add(value);
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            _Chip(
              label: options[i],
              isSelected: selected.contains(options[i]),
              onTap: () => _onTap(options[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : AppColors.bg2,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.borderIdle,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? AppColors.bg0 : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
