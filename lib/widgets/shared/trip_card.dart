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
    this.aircraft,
    this.tailNumber,
    this.crewFilled = 0,
    this.crewMax = 0,
    this.avatarSeeds = const [],
    this.onTap,
  });

  final String fromCode;
  final String toCode;
  final String fromCity;
  final String toCity;
  final String date;
  final TripStatus status;
  final String? aircraft;
  final String? tailNumber;
  final int crewFilled;
  final int crewMax;
  final List<int> avatarSeeds;
  final VoidCallback? onTap;

  static const _gold    = Color(0xFFD4AF37);
  static const _cardBg  = Color(0xFF141210);
  static const _border  = Color(0xFF2A2520);

  // Deterministic gradient based on route codes
  List<Color> get _jetGradient {
    final hash = (fromCode + toCode).codeUnits.fold(0, (a, b) => a + b);
    const opts = [
      [Color(0xFF2A1A08), Color(0xFF0A0905)],
      [Color(0xFF08182A), Color(0xFF0A0905)],
      [Color(0xFF1A081A), Color(0xFF0A0905)],
      [Color(0xFF08180A), Color(0xFF0A0905)],
      [Color(0xFF1A1408), Color(0xFF0A0905)],
    ];
    return opts[hash % opts.length];
  }

  double get _jetAngle {
    const angles = [-0.20, -0.15, -0.25, -0.18, -0.22];
    final hash = fromCode.codeUnits.fold(0, (a, b) => a + b);
    return angles[hash % angles.length];
  }

  Color get _statusColor => switch (status) {
        TripStatus.active    => const Color(0xFF3DAA57),
        TripStatus.pending   => const Color(0xFFF5A623),
        TripStatus.draft     => const Color(0xFF777777),
        TripStatus.confirmed => const Color(0xFF4A90D9),
      };

  String get _statusLabel => switch (status) {
        TripStatus.active    => 'Active',
        TripStatus.pending   => 'Pending',
        TripStatus.draft     => 'Draft',
        TripStatus.confirmed => 'Confirmed',
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildJetPane(),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  // ── Jet image pane ───────────────────────────────────────────────────────────

  Widget _buildJetPane() {
    return Container(
      width: 108,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          bottomLeft: Radius.circular(14),
        ),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: _jetGradient,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _gold.withValues(alpha: 0.14),
                Colors.transparent,
              ]),
            ),
          ),
          Positioned(
            bottom: 22,
            left: 6,
            right: 0,
            child: Container(
              height: 0.5,
              color: _gold.withValues(alpha: 0.22),
            ),
          ),
          Transform.rotate(
            angle: _jetAngle,
            child: Icon(
              Icons.airplanemode_active_rounded,
              color: Colors.white.withValues(alpha: 0.88),
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  // ── Content ──────────────────────────────────────────────────────────────────

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route + status
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _buildRouteRow()),
              const SizedBox(width: 8),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 3),
          // City names
          Row(
            children: [
              Text(fromCity,
                  style: GoogleFonts.inter(
                      fontSize: 10.5, color: Colors.white38)),
              const Spacer(),
              Text(toCity,
                  style: GoogleFonts.inter(
                      fontSize: 10.5, color: Colors.white38)),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: _border, height: 1),
          const SizedBox(height: 8),
          // Meta info
          _buildMetaRow(),
        ],
      ),
    );
  }

  Widget _buildRouteRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(fromCode,
            style: GoogleFonts.cinzel(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              Container(width: 10, height: 1,
                  color: _gold.withValues(alpha: 0.45)),
              const Icon(Icons.flight, size: 13, color: _gold),
              Container(width: 10, height: 1,
                  color: _gold.withValues(alpha: 0.45)),
            ],
          ),
        ),
        Text(toCode,
            style: GoogleFonts.cinzel(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            )),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final sc = _statusColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: sc.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: sc.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: sc, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(_statusLabel,
              style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: sc)),
        ],
      ),
    );
  }

  Widget _buildMetaRow() {
    final parts = date.split('·');
    final dateLine1 = parts.first.trim();
    final dateLine2 = parts.length > 1 ? parts.last.trim() : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _metaIcon(Icons.calendar_today_outlined),
        const SizedBox(width: 4),
        Flexible(
          flex: 2,
          child: _metaTexts(dateLine1, dateLine2),
        ),
        if (aircraft != null) ...[
          const SizedBox(width: 8),
          _metaIcon(Icons.airplanemode_active_rounded),
          const SizedBox(width: 4),
          Flexible(
            flex: 2,
            child: _metaTexts(aircraft!, tailNumber ?? ''),
          ),
        ],
        if (crewMax > 0) ...[
          const SizedBox(width: 8),
          _metaIcon(Icons.people_alt_outlined),
          const SizedBox(width: 4),
          Text('$crewFilled / $crewMax',
              style: GoogleFonts.inter(
                  fontSize: 10, color: Colors.white70, height: 1.25)),
        ],
        if (avatarSeeds.isNotEmpty) ...[
          const Spacer(),
          _buildAvatarStack(),
        ],
      ],
    );
  }

  Widget _metaIcon(IconData icon) => Icon(icon,
      color: _gold.withValues(alpha: 0.65), size: 12);

  Widget _metaTexts(String line1, String line2) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(line1,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
                fontSize: 10, color: Colors.white70, height: 1.25)),
        if (line2.isNotEmpty)
          Text(line2,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                  fontSize: 9.5, color: Colors.white38, height: 1.25)),
      ],
    );
  }

  Widget _buildAvatarStack() {
    final seeds = avatarSeeds.take(3).toList();
    final overflow = (crewFilled - seeds.length).clamp(0, 99);
    final totalWidth =
        seeds.length * 18.0 + (overflow > 0 ? 26.0 : 4.0);

    return SizedBox(
      height: 24,
      width: totalWidth,
      child: Stack(
        children: [
          ...List.generate(seeds.length, (i) {
            return Positioned(
              left: i * 18.0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: _cardBg, width: 1.5),
                  color: const Color(0xFF2A2520),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://i.pravatar.cc/48?img=${seeds[i]}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Center(
                      child: Text(
                        String.fromCharCode(65 + i),
                        style: GoogleFonts.inter(
                            color: _gold,
                            fontSize: 9,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          if (overflow > 0)
            Positioned(
              left: seeds.length * 18.0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _gold.withValues(alpha: 0.15),
                  border: Border.all(
                      color: _gold.withValues(alpha: 0.4)),
                ),
                child: Center(
                  child: Text('+$overflow',
                      style: GoogleFonts.inter(
                          fontSize: 8,
                          color: _gold,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
