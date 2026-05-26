import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileHero extends StatelessWidget {
  const ProfileHero({
    super.key,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.rating,
    this.reviewCount,
    this.readOnly = false,
    this.onAvatarTap,
  });

  final String name;
  final String role;
  final String? avatarUrl;
  final double? rating;
  final int? reviewCount;
  final bool readOnly;
  final VoidCallback? onAvatarTap;

  static const _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _avatar,
        const SizedBox(height: 14),
        Text(
          name,
          style: GoogleFonts.cinzel(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            role,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _gold,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (rating != null) ...[
          const SizedBox(height: 10),
          _ratingRow,
        ],
      ],
    );
  }

  Widget get _avatar {
    return Stack(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _gold, width: 2),
            color: const Color(0xFF2A2520),
          ),
          child: ClipOval(
            child: avatarUrl != null && avatarUrl!.isNotEmpty
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, err, st) => _initials,
                  )
                : _initials,
          ),
        ),
        if (!readOnly)
          Positioned(
            bottom: 2,
            right: 2,
            child: GestureDetector(
              onTap: onAvatarTap,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: _gold,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0C0A08), width: 2),
                ),
                child: const Icon(Icons.edit_rounded,
                    size: 13, color: Color(0xFF0C0A08)),
              ),
            ),
          ),
      ],
    );
  }

  Widget get _initials => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'A',
          style: GoogleFonts.inter(
            color: _gold,
            fontWeight: FontWeight.w700,
            fontSize: 32,
          ),
        ),
      );

  Widget get _ratingRow => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(5, (i) {
            final filled = i < rating!.floor();
            final half = !filled && (i < rating! && rating! - i > 0);
            return Icon(
              filled
                  ? Icons.star_rounded
                  : half
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded,
              color: _gold,
              size: 18,
            );
          }),
          const SizedBox(width: 6),
          Text(
            reviewCount != null
                ? '${rating!.toStringAsFixed(1)} ($reviewCount reviews)'
                : rating!.toStringAsFixed(1),
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
}
