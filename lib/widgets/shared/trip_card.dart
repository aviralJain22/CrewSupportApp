import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum TripStatus { active, pending, draft, confirmed }

class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.fromCode,
    required this.toCode,
    required this.fromCity,
    required this.toCity,
    required this.date,
    required this.status,
    this.assignedCrew,
    this.onTap,
  });

  final String fromCode;
  final String toCode;
  final String fromCity;
  final String toCity;
  final String date;
  final TripStatus status;
  final List<String>? assignedCrew;
  final VoidCallback? onTap;

  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);
  static const _border = Color(0xFF2A2520);

  Color get _statusColor => switch (status) {
        TripStatus.active => const Color(0xFF3DAA57),
        TripStatus.pending => const Color(0xFFF5A623),
        TripStatus.draft => const Color(0xFF777777),
        TripStatus.confirmed => const Color(0xFF4A90D9),
      };

  String get _statusLabel => switch (status) {
        TripStatus.active => 'Active',
        TripStatus.pending => 'Pending',
        TripStatus.draft => 'Draft',
        TripStatus.confirmed => 'Confirmed',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _routeRow),
                _statusBadge,
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: const Color(0xFF2A2520),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: Colors.white38),
                const SizedBox(width: 6),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
                const Spacer(),
                if (assignedCrew != null && assignedCrew!.isNotEmpty)
                  _crewAvatars,
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget get _routeRow => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fromCode,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              Text(
                fromCity,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 1,
                  color: _gold.withValues(alpha: 0.4),
                ),
                const Icon(Icons.flight, size: 16, color: _gold),
                Container(
                  width: 24,
                  height: 1,
                  color: _gold.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                toCode,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              Text(
                toCity,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ],
      );

  Widget get _statusBadge => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _statusColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _statusColor.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              _statusLabel,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _statusColor,
              ),
            ),
          ],
        ),
      );

  Widget get _crewAvatars {
    final crew = assignedCrew!.take(3).toList();
    return SizedBox(
      height: 24,
      width: crew.length * 18.0 + 6,
      child: Stack(
        children: List.generate(crew.length, (i) {
          return Positioned(
            left: i * 18.0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2A2520),
                border: Border.all(color: _cardBg, width: 1.5),
              ),
              child: Center(
                child: Text(
                  crew[i].isNotEmpty ? crew[i][0].toUpperCase() : '?',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _gold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
