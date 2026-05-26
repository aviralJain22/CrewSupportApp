import 'package:crew_support/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.ctaLabel,
    this.onCta,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final iconContainerSize = AppSpacing.avatarLg(context);
    final iconSize = iconContainerSize * 0.42;
    final hPad = AppSpacing.screenH(context) + 16;
    final vPad = AppSpacing.xxl(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1A14),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Icon(icon,
                  color: const Color(0xFFD4AF37), size: iconSize),
            ),
            SizedBox(height: AppSpacing.xl(context)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: AppSpacing.sm(context)),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white54,
                height: 1.5,
              ),
            ),
            if (ctaLabel != null && onCta != null) ...[
              SizedBox(height: AppSpacing.xxl(context)),
              AppButton(
                label: ctaLabel!,
                onTap: onCta,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
