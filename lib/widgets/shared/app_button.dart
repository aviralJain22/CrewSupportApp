import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppButtonVariant { primary, secondary, destructive }

enum AppButtonState { idle, loading, success, disabled }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = AppButtonVariant.primary,
    this.state = AppButtonState.idle,
    this.width,
    this.height = 50,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final AppButtonState state;
  final double? width;
  final double height;
  final IconData? icon;

  static const _gold = Color(0xFFD4AF37);
  static const _darkBg = Color(0xFF0C0A08);
  static const _red = Color(0xFFB33A3A);

  bool get _isDisabled =>
      state == AppButtonState.disabled || state == AppButtonState.loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: _decoration,
        child: Center(child: _child),
      ),
    );
  }

  BoxDecoration get _decoration {
    switch (variant) {
      case AppButtonVariant.primary:
        return BoxDecoration(
          gradient: _isDisabled
              ? const LinearGradient(
                  colors: [Color(0xFF5A4E20), Color(0xFF3A3118)],
                )
              : state == AppButtonState.success
                  ? const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE8C547), _gold],
                    ),
          borderRadius: BorderRadius.circular(10),
        );
      case AppButtonVariant.secondary:
        return BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: _isDisabled
                ? const Color(0xFF5A4E20)
                : state == AppButtonState.success
                    ? const Color(0xFF2E7D32)
                    : _gold,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        );
      case AppButtonVariant.destructive:
        return BoxDecoration(
          color: _isDisabled
              ? const Color(0xFF3A1A1A)
              : state == AppButtonState.success
                  ? const Color(0xFF1B5E20)
                  : _red,
          borderRadius: BorderRadius.circular(10),
        );
    }
  }

  Widget get _child {
    if (state == AppButtonState.loading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: variant == AppButtonVariant.primary ? _darkBg : _gold,
        ),
      );
    }

    if (state == AppButtonState.success) {
      return Icon(
        Icons.check_rounded,
        color: variant == AppButtonVariant.primary ? _darkBg : Colors.white,
        size: 22,
      );
    }

    final textColor = _isDisabled
        ? Colors.white38
        : variant == AppButtonVariant.primary
            ? _darkBg
            : variant == AppButtonVariant.secondary
                ? _gold
                : Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
