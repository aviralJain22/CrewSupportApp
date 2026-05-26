import 'package:crew_support/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AvailabilityStatus { available, partial, unavailable }

class CrewCard extends StatelessWidget {
  const CrewCard({
    super.key,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.hours,
    this.distanceMi,
    this.dayRate,
    this.rating,
    this.availability = AvailabilityStatus.unavailable,
    this.onTap,
  });

  final String name;
  final String role;
  final String? avatarUrl;
  final int? hours;
  final double? distanceMi;
  final int? dayRate;
  final double? rating;
  final AvailabilityStatus availability;
  final VoidCallback? onTap;

  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);
  static const _border = Color(0xFF2A2520);

  Color get _availColor => switch (availability) {
        AvailabilityStatus.available => const Color(0xFF3DAA57),
        AvailabilityStatus.partial => const Color(0xFFF5A623),
        AvailabilityStatus.unavailable => const Color(0xFF555555),
      };

  String get _availLabel => switch (availability) {
        AvailabilityStatus.available => 'Available',
        AvailabilityStatus.partial => 'Partial',
        AvailabilityStatus.unavailable => 'Unavailable',
      };

  @override
  Widget build(BuildContext context) {
    final cardPad = AppSpacing.cardPadding(context);
    final cardBottomMargin = AppSpacing.cardMarginV(context);
    final avatarSize = AppSpacing.avatarMd(context);
    final avatarGap = AppSpacing.md(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: cardBottomMargin),
        padding: EdgeInsets.all(cardPad),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(context, avatarSize),
            SizedBox(width: avatarGap),
            Expanded(child: _buildInfo(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, double size) {
    final dotSize = AppSpacing.xs(context) + 2;
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2A2520),
            border: Border.all(
              color: _gold.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: avatarUrl != null
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, err, e) => _buildInitials(context),
                  )
                : _buildInitials(context),
          ),
        ),
        Positioned(
          bottom: 1,
          right: 1,
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: _availColor,
              shape: BoxShape.circle,
              border: Border.all(color: _cardBg, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitials(BuildContext context) => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.inter(
            color: _gold,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      );

  Widget _buildInfo(BuildContext context) {
    final roleGap = AppSpacing.xxs(context) + 1;
    final statsGap = AppSpacing.sm(context) + 2;
    final pillGap = AppSpacing.sm(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (rating != null) _buildRatingBadge(context),
          ],
        ),
        SizedBox(height: roleGap),
        Row(
          children: [
            _buildRolePill(context),
            SizedBox(width: pillGap),
            _buildAvailPill(context),
          ],
        ),
        SizedBox(height: statsGap),
        Row(
          children: [
            if (hours != null) _buildStat(context, Icons.flight, '${hours}h TT'),
            if (distanceMi != null)
              _buildStat(context, Icons.location_on_outlined,
                  '${distanceMi!.toStringAsFixed(0)} mi'),
            if (dayRate != null)
              _buildStat(context, Icons.attach_money, '\$${dayRate!}/day'),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingBadge(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded,
              size: AppSpacing.iconSm(context), color: _gold),
          SizedBox(width: AppSpacing.xxs(context)),
          Text(
            rating!.toStringAsFixed(1),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _gold,
            ),
          ),
        ],
      );

  Widget _buildRolePill(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm(context),
          vertical: AppSpacing.xxs(context),
        ),
        decoration: BoxDecoration(
          color: _gold.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          role,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: _gold,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  Widget _buildAvailPill(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSpacing.xs(context),
            height: AppSpacing.xs(context),
            decoration: BoxDecoration(
              color: _availColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.xxs(context) + 2),
          Text(
            _availLabel,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: _availColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );

  Widget _buildStat(BuildContext context, IconData icon, String label) =>
      Padding(
        padding: EdgeInsets.only(right: AppSpacing.md(context)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: AppSpacing.iconSm(context) - 2, color: Colors.white38),
            SizedBox(width: AppSpacing.xxs(context) + 1),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      );
}
