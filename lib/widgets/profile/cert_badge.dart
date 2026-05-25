import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CertStatus { valid, expiringSoon, expired }

class CertBadge extends StatelessWidget {
  const CertBadge({
    super.key,
    required this.name,
    required this.expiryDate,
  });

  final String name;
  final DateTime expiryDate;

  static const _green = Color(0xFF3DAA57);
  static const _amber = Color(0xFFF5A623);
  static const _red = Color(0xFFB33A3A);

  CertStatus get _status {
    final now = DateTime.now();
    if (expiryDate.isBefore(now)) return CertStatus.expired;
    if (expiryDate.difference(now).inDays < 60) return CertStatus.expiringSoon;
    return CertStatus.valid;
  }

  Color get _color => switch (_status) {
        CertStatus.valid => _green,
        CertStatus.expiringSoon => _amber,
        CertStatus.expired => _red,
      };

  IconData get _icon => switch (_status) {
        CertStatus.valid => Icons.verified_rounded,
        CertStatus.expiringSoon => Icons.schedule_rounded,
        CertStatus.expired => Icons.error_outline_rounded,
      };

  String get _expiryLabel {
    final now = DateTime.now();
    if (_status == CertStatus.expired) return 'Expired';
    final days = expiryDate.difference(now).inDays;
    if (days < 60) return 'Exp. ${days}d';
    return 'Valid';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 13, color: _color),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                _expiryLabel,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: _color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
