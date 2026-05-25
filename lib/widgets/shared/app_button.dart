import 'package:crew_support/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, destructive }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expanded = true,
    this.height = 48,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expanded;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || loading;

    Widget child = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_foreground(isDisabled)),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: _foreground(isDisabled)),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: AppTextStyles.button.copyWith(color: _foreground(isDisabled)),
              ),
            ],
          );

    final button = SizedBox(
      height: height,
      child: switch (variant) {
        AppButtonVariant.primary => ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDisabled ? AppColors.goldDim : AppColors.gold,
              foregroundColor: AppColors.bg0,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              minimumSize: expanded ? const Size.fromHeight(48) : null,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            ),
            child: child,
          ),
        AppButtonVariant.secondary => OutlinedButton(
            onPressed: isDisabled ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: isDisabled ? AppColors.textDisabled : AppColors.gold,
              side: BorderSide(
                color: isDisabled ? AppColors.borderIdle : AppColors.gold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              minimumSize: expanded ? const Size.fromHeight(48) : null,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            ),
            child: child,
          ),
        AppButtonVariant.destructive => ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDisabled
                  ? AppColors.error.withValues(alpha: 0.4)
                  : AppColors.error,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              minimumSize: expanded ? const Size.fromHeight(48) : null,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            ),
            child: child,
          ),
      },
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }

  Color _foreground(bool isDisabled) {
    if (isDisabled) return AppColors.textDisabled;
    return switch (variant) {
      AppButtonVariant.primary     => AppColors.bg0,
      AppButtonVariant.secondary   => AppColors.gold,
      AppButtonVariant.destructive => AppColors.textPrimary,
    };
  }
}
