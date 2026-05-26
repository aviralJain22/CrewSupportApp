import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/shared/app_button.dart';
import '../../widgets/shared/app_header.dart';
import '../../widgets/shared/section_header.dart';
import '../../widgets/profile/cert_badge.dart';
import '../../widgets/profile/profile_hero.dart';

/// Read-only profile view shown when browsing another user's profile.
class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key, this.profileData});

  // Optionally inject profile data; falls back to mock data.
  final Map<String, dynamic>? profileData;

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  static const _bg = Color(0xFF0C0A08);
  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);
  static const _border = Color(0xFF2A2520);

  bool _isFavourited = false;

  // Mock profile — replaced by widget.profileData in a real implementation.
  late final Map<String, dynamic> _profile = widget.profileData ?? {
    'name': 'Alexander Reid',
    'role': 'Captain / Pilot in Command',
    'avatarUrl': 'https://i.pravatar.cc/150?img=12',
    'rating': 4.9,
    'reviewCount': 47,
    'totalHours': '8,500',
    'pic': '6,200',
    'dayRate': '\$1,200',
    'tripRate': '\$3,500',
    'availability': 'available',
    'location': 'Los Angeles, CA',
    'certExpiry': {
      'ATP': DateTime(2026, 9, 15),
      'CPL': DateTime(2025, 12, 1),
      'IR': DateTime(2027, 3, 20),
      'ME': DateTime(2026, 1, 10),
    },
    'flightTypes': ['Charter', 'Corporate', 'International'],
    'about': 'Experienced Captain with 8,500+ hours across charter, corporate, '
        'and international operations. Specialising in long-range ultra-high '
        'net-worth client transport.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppHeader.title(screenTitle: 'Profile'),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            children: [
              ProfileHero(
                name: _profile['name'] as String,
                role: _profile['role'] as String,
                avatarUrl: _profile['avatarUrl'] as String?,
                rating: (_profile['rating'] as num).toDouble(),
                reviewCount: _profile['reviewCount'] as int,
                readOnly: true,
              ),
              const SizedBox(height: 20),
              _availabilityBadge,
              const SizedBox(height: 28),
              _section('About', [_aboutCard]),
              const SizedBox(height: 24),
              _section('Certifications', [_certBadgesRow]),
              const SizedBox(height: 24),
              _section('Flight Times', [_statsGrid]),
              const SizedBox(height: 24),
              _section('Rates', [_ratesRow]),
              const SizedBox(height: 24),
              _section('Flight Types', [_flightTypeChips]),
              const SizedBox(height: 24),
              _section('Location', [_locationRow]),
              const SizedBox(height: 24),
              _section('Reviews', [_reviewsPreview]),
            ],
          ),
          _stickyActions,
        ],
      ),
    );
  }

  Widget get _availabilityBadge {
    final avail = _profile['availability'] as String;
    final Color color;
    final String label;
    switch (avail) {
      case 'available':
        color = const Color(0xFF3DAA57);
        label = 'Available Now';
      case 'partial':
        color = const Color(0xFFF5A623);
        label = 'Partially Available';
      default:
        color = const Color(0xFFB33A3A);
        label = 'Unavailable';
    }
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _aboutCard {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Text(
        _profile['about'] as String,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: Colors.white70,
          height: 1.6,
        ),
      ),
    );
  }

  Widget get _certBadgesRow {
    final expiry = _profile['certExpiry'] as Map<String, DateTime>;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: expiry.entries
          .map((e) => CertBadge(name: e.key, expiryDate: e.value))
          .toList(),
    );
  }

  Widget get _statsGrid {
    return Row(
      children: [
        _statCard('Total Hours', _profile['totalHours'] as String),
        const SizedBox(width: 10),
        _statCard('PIC', _profile['pic'] as String),
      ],
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.cinzel(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _gold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white38,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _ratesRow {
    return Row(
      children: [
        _rateCard('Day Rate', _profile['dayRate'] as String),
        const SizedBox(width: 10),
        _rateCard('Trip Rate', _profile['tripRate'] as String),
      ],
    );
  }

  Widget _rateCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _flightTypeChips {
    final types = _profile['flightTypes'] as List<String>;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types
          .map(
            (t) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _border),
              ),
              child: Text(
                t,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget get _locationRow {
    return Row(
      children: [
        const Icon(Icons.location_on_rounded, size: 16, color: Colors.white38),
        const SizedBox(width: 8),
        Text(
          _profile['location'] as String,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

  Widget get _reviewsPreview {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: List.generate(2, (i) => _reviewItem(i)),
      ),
    );
  }

  Widget _reviewItem(int index) {
    final reviews = [
      ('Sarah M.', 'Exceptional professionalism. Will book again.', 5.0),
      ('Tom B.', 'Smooth flight, very communicative pre-trip.', 4.8),
    ];
    final (reviewer, text, stars) = reviews[index];
    return Padding(
      padding: EdgeInsets.only(bottom: index == 0 ? 14 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (index == 1)
            Divider(color: _border, height: 1),
          if (index == 1) const SizedBox(height: 14),
          Row(
            children: [
              Text(
                reviewer,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.star_rounded, size: 13, color: _gold),
              const SizedBox(width: 3),
              Text(
                stars.toStringAsFixed(1),
                style: GoogleFonts.inter(
                    fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _stickyActions {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: _bg,
          border: Border(top: BorderSide(color: _border)),
        ),
        child: Row(
          children: [
            // Favourite toggle button
            GestureDetector(
              onTap: () => setState(() => _isFavourited = !_isFavourited),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _isFavourited
                      ? _gold.withValues(alpha: 0.12)
                      : _cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isFavourited ? _gold : _border,
                    width: _isFavourited ? 1.5 : 1,
                  ),
                ),
                child: Icon(
                  _isFavourited ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: _isFavourited ? _gold : Colors.white38,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Message',
                state: AppButtonState.idle,
                onTap: () {},
                height: 52,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title),
          const SizedBox(height: 14),
          ...children,
        ],
      );
}
