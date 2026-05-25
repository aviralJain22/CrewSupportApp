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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _avatar,
            const SizedBox(width: 14),
            Expanded(child: _info),
          ],
        ),
      ),
    );
  }

  Widget get _avatar {
    return Stack(
      children: [
        Container(
          width: 54,
          height: 54,
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
                    errorBuilder: (_, err, e) => _initials,
                  )
                : _initials,
          ),
        ),
        Positioned(
          bottom: 1,
          right: 1,
          child: Container(
            width: 12,
            height: 12,
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

  Widget get _initials => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.inter(
            color: _gold,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      );

  Widget get _info {
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
            if (rating != null) _ratingBadge,
          ],
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            _rolePill,
            const SizedBox(width: 8),
            _availPill,
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (hours != null) _stat(Icons.flight, '${hours}h TT'),
            if (distanceMi != null)
              _stat(Icons.location_on_outlined,
                  '${distanceMi!.toStringAsFixed(0)} mi'),
            if (dayRate != null)
              _stat(Icons.attach_money, '\$${dayRate!}/day'),
          ],
        ),
      ],
    );
  }

  Widget get _ratingBadge => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: _gold),
          const SizedBox(width: 2),
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

  Widget get _rolePill => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

  Widget get _availPill => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _availColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
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

  Widget _stat(IconData icon, String label) => Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white38),
            const SizedBox(width: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      );
}
