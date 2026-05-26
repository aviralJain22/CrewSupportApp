import 'package:crew_support/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.autofocus = false,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  static const _gold = Color(0xFFD4AF37);
  static const _fieldBg = Color(0xFF1A1612);
  static const _border = Color(0xFF2E2A22);

  late final FocusNode _focus;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final borderColor =
        hasError ? const Color(0xFFB33A3A) : _focused ? _gold : _border;

    final hPad = AppSpacing.md(context);
    final vPad = AppSpacing.md(context);
    final labelGap = AppSpacing.xs(context);
    final errorGap = AppSpacing.xs(context);
    final errorIconGap = AppSpacing.xxs(context) + 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _focused ? _gold : Colors.white54,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: labelGap),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _fieldBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focus,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            textCapitalization: widget.textCapitalization,
            autofocus: widget.autofocus,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
            cursorColor: _gold,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white30,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: vPad,
              ),
              border: InputBorder.none,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: errorGap),
          Row(
            children: [
              Icon(Icons.error_outline,
                  size: AppSpacing.iconSm(context) + 1,
                  color: const Color(0xFFB33A3A)),
              SizedBox(width: errorIconGap),
              Text(
                widget.errorText!,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFFB33A3A),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
