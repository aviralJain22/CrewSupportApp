import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagePreviewRow extends StatelessWidget {
  const MessagePreviewRow({
    super.key,
    required this.name,
    required this.preview,
    required this.time,
    this.avatarUrl,
    this.unreadCount = 0,
    this.isOnline = false,
    this.onTap,
  });

  final String name;
  final String preview;
  final String time;
  final String? avatarUrl;
  final int unreadCount;
  final bool isOnline;
  final VoidCallback? onTap;

  static const _gold = Color(0xFFD4AF37);
  static const _border = Color(0xFF2A2520);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            _avatar,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: unreadCount > 0 ? _gold : Colors.white38,
                          fontWeight: unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: unreadCount > 0
                                ? Colors.white70
                                : Colors.white38,
                            fontWeight: unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        _badge,
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _avatar {
    return Stack(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _border, width: 1),
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
        if (isOnline)
          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: const Color(0xFF3DAA57),
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFF0C0A08), width: 2),
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
            fontSize: 18,
          ),
        ),
      );

  Widget get _badge => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: _gold,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          unreadCount > 99 ? '99+' : '$unreadCount',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0C0A08),
          ),
        ),
      );
}
