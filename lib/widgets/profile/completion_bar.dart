import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileCompletionBar extends StatelessWidget {
  const ProfileCompletionBar({
    super.key,
    required this.percent,
    this.missingFields = const [],
  });

  final int percent; // 0–100
  final List<String> missingFields;

  static const _gold = Color(0xFFD4AF37);
  static const _track = Color(0xFF2A2520);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181410),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2520), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$percent% complete',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              _statusChip,
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100.0,
              minHeight: 6,
              backgroundColor: _track,
              valueColor: AlwaysStoppedAnimation<Color>(
                percent >= 80 ? const Color(0xFF3DAA57) : _gold,
              ),
            ),
          ),
          if (missingFields.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 13, color: Colors.white38),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Missing: ${missingFields.join(', ')}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white38,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget get _statusChip {
    final label = percent >= 80
        ? 'Strong'
        : percent >= 50
            ? 'In progress'
            : 'Incomplete';
    final color = percent >= 80
        ? const Color(0xFF3DAA57)
        : percent >= 50
            ? _gold
            : const Color(0xFFB33A3A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
