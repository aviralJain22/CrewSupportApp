import 'dart:math' as math;
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class PremiumHomeScreen extends StatefulWidget {
  const PremiumHomeScreen({super.key});

  @override
  State<PremiumHomeScreen> createState() => _PremiumHomeScreenState();
}

class _PremiumHomeScreenState extends State<PremiumHomeScreen> {
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();

  // ── Tokens ────────────────────────────────────────────────────────────────
  static const Color _bg      = Color(0xFF0C0A08);
  static const Color _cardBg  = Color(0xFF181410);
  static const Color _gold    = Color(0xFFD4AF37);
  static const Color _inputBg = Color(0xFF0F0C08);

  static const List<_JetModel> _jets = [
    _JetModel(
      name: 'Airliner / VIP',
      description: 'The most comfortable and spacious aircraft for large group journeys.',
      rating: 4.8,
      capacity: '100+',
      size: 'Large',
      price: 'from \$900/hr',
    ),
    _JetModel(
      name: 'Heavy Jet',
      description: 'Perfect and the fastest private aircraft for long-haul missions.',
      rating: 4.8,
      capacity: '8–19',
      size: 'Large',
      price: 'from \$700/hr',
    ),
    _JetModel(
      name: 'Midsize Jet',
      description: 'Ideal balance of range, comfort, and performance.',
      rating: 4.7,
      capacity: '6–9',
      size: 'Medium',
      price: 'from \$1,000/hr',
    ),
    _JetModel(
      name: 'Light Jet',
      description: 'Light jet for short trips and efficient business travel.',
      rating: 4.6,
      capacity: '4–6',
      size: 'Small',
      price: 'from \$600/hr',
    ),
    _JetModel(
      name: 'Turboprop',
      description: 'Efficient, reliable and perfect for regional routes.',
      rating: 4.5,
      capacity: '4–8',
      size: 'Small',
      price: 'from \$400/hr',
    ),
  ];

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHero()),
          SliverToBoxAdapter(child: _buildSearchStrip()),
          SliverToBoxAdapter(child: _buildJetsHeader()),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _buildJetCard(_jets[i], i),
              childCount: _jets.length,
            ),
          ),
          SliverToBoxAdapter(child: _buildExpertCallout()),
          SliverToBoxAdapter(child: SizedBox(height: 3.h)),
        ],
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────

  Widget _buildHero() {
    return SizedBox(
      height: 30.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0E0B07), Color(0xFF1C1508)],
              ),
            ),
          ),
          // Decorative gold curves
          CustomPaint(painter: _HeroDecorPainter()),
          // Aircraft silhouette — right side
          Positioned(
            right: -4.w,
            top: 0,
            bottom: 0,
            child: _buildHeroAircraft(),
          ),
          // Gradient veil over aircraft so text is readable
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF0E0B07),
                    const Color(0xFF0E0B07).withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.42, 0.72],
                ),
              ),
            ),
          ),
          // Text content
          Positioned(
            left: 4.w,
            top: 0,
            bottom: 0,
            right: 30.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose\nyour jet',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26.spV2,
                    fontWeight: FontWeight.w700,
                    color: _gold,
                    height: 1.2,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 1.2.h),
                Text(
                  'Select the perfect aircraft\nfor your journey',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 9.spV2,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          // Filter icon — top right
          Positioned(
            top: 2.h,
            right: 4.w,
            child: Container(
              padding: EdgeInsets.all(2.2.w),
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _gold.withValues(alpha: 0.35)),
              ),
              child: Icon(Icons.tune_rounded, color: _gold, size: 16.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAircraft() {
    return SizedBox(
      width: 58.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient glow
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _gold.withValues(alpha: 0.10),
                _gold.withValues(alpha: 0.03),
                Colors.transparent,
              ]),
            ),
          ),
          // Horizontal ground line
          Positioned(
            bottom: 7.h,
            left: 4.w,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  _gold.withValues(alpha: 0.3),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Main aircraft icon
          Transform.rotate(
            angle: -0.18,
            child: Icon(
              Icons.airplanemode_active_rounded,
              color: Colors.white.withValues(alpha: 0.82),
              size: 44.sp,
            ),
          ),
          // Reflection (faint)
          Positioned(
            bottom: 5.h,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(1.0, -0.25, 1.0)..rotateZ(-0.18),
              child: Icon(
                Icons.airplanemode_active_rounded,
                color: _gold.withValues(alpha: 0.12),
                size: 44.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search strip ──────────────────────────────────────────────────────────

  Widget _buildSearchStrip() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _gold.withValues(alpha: 0.25)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(child: _miniInput(ctrl: _fromCtrl, hint: 'From', icon: Icons.flight_takeoff_rounded)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Icon(Icons.arrow_forward_rounded, color: _gold.withValues(alpha: 0.6), size: 16.sp),
          ),
          Expanded(child: _miniInput(ctrl: _toCtrl, hint: 'To', icon: Icons.flight_land_rounded)),
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.3.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFB8960C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.search_rounded, color: Colors.black, size: 16.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniInput({required TextEditingController ctrl, required String hint, required IconData icon}) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: Colors.white, fontSize: 10.spV2),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: _gold.withValues(alpha: 0.65), size: 14.sp),
        prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white30, fontSize: 10.spV2),
        filled: true,
        fillColor: _inputBg,
        contentPadding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 2.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _gold.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _gold.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _gold, width: 1.2),
        ),
      ),
    );
  }

  // ── Jets section header ────────────────────────────────────────────────────

  Widget _buildJetsHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 1.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Available Aircraft',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16.spV2,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text('${_jets.length} types',
              style: TextStyle(color: _gold.withValues(alpha: 0.7), fontSize: 9.spV2)),
        ],
      ),
    );
  }

  // ── Jet card ──────────────────────────────────────────────────────────────

  Widget _buildJetCard(_JetModel jet, int idx) {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.2.h),
      height: 15.h,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {},
          splashColor: _gold.withValues(alpha: 0.04),
          child: Row(
            children: [
              // ── Aircraft image ─────────────────────────────────────────
              _buildCardImage(idx),
              // ── Info ──────────────────────────────────────────────────
              Expanded(child: _buildCardInfo(jet)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage(int idx) {
    // Slight variation per jet for visual variety
    const rotations = [-0.25, -0.18, -0.30, -0.38, -0.15];
    const scales    = [1.05, 0.95, 1.10, 0.90, 1.0];
    final rot   = rotations[idx % rotations.length];
    final scale = scales[idx % scales.length];

    return Container(
      width: 35.w,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF2A1F0A), Color(0xFF0F0C06)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient glow
          Container(
            width: 22.w,
            height: 22.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _gold.withValues(alpha: 0.13),
                Colors.transparent,
              ]),
            ),
          ),
          // Ground line
          Positioned(
            bottom: 2.8.h,
            left: 2.w,
            right: 0,
            child: Container(
              height: 0.5,
              color: _gold.withValues(alpha: 0.18),
            ),
          ),
          // Aircraft icon
          Transform.rotate(
            angle: rot,
            child: Transform.scale(
              scale: scale,
              child: Icon(
                Icons.airplanemode_active_rounded,
                color: Colors.white.withValues(alpha: 0.90),
                size: 26.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfo(_JetModel jet) {
    return Padding(
      padding: EdgeInsets.fromLTRB(3.w, 2.h, 3.w, 1.8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + rating row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  jet.name,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 13.spV2,
                    fontWeight: FontWeight.w600,
                    color: _gold,
                    height: 1.1,
                  ),
                ),
              ),
              SizedBox(width: 1.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(jet.rating.toStringAsFixed(1),
                          style: TextStyle(color: Colors.white70, fontSize: 9.spV2, fontWeight: FontWeight.w600)),
                      SizedBox(width: 0.8.w),
                      Icon(Icons.star_rounded, color: _gold, size: 11.sp),
                    ],
                  ),
                  Text(jet.price,
                      style: TextStyle(color: _gold, fontSize: 9.spV2, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          SizedBox(height: 0.7.h),
          // Description
          Expanded(
            child: Text(
              jet.description,
              style: TextStyle(color: Colors.white54, fontSize: 8.5.spV2, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Bottom row: capacity + Select button
          Row(
            children: [
              // Capacity pill
              _iconTag(Icons.people_alt_outlined, jet.capacity),
              SizedBox(width: 2.w),
              // Size pill
              _iconTag(Icons.luggage_outlined, jet.size),
              const Spacer(),
              // Select button
              _selectButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconTag(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _gold.withValues(alpha: 0.75), size: 10.sp),
        SizedBox(width: 1.w),
        Text(label,
            style: TextStyle(
                color: Colors.white54,
                fontSize: 8.5.spV2,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _selectButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.7.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _gold.withValues(alpha: 0.7)),
          color: _gold.withValues(alpha: 0.06),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select',
                style: TextStyle(
                    color: _gold,
                    fontSize: 9.spV2,
                    fontWeight: FontWeight.w600)),
            SizedBox(width: 1.w),
            Icon(Icons.arrow_forward_rounded, color: _gold, size: 10.sp),
          ],
        ),
      ),
    );
  }

  // ── Expert callout ────────────────────────────────────────────────────────

  Widget _buildExpertCallout() {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.25)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          splashColor: _gold.withValues(alpha: 0.04),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _gold.withValues(alpha: 0.1),
                    border: Border.all(color: _gold.withValues(alpha: 0.28)),
                  ),
                  child: Icon(Icons.headset_mic_outlined, color: _gold, size: 16.sp),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Need help choosing?',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.spV2,
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: 0.3.h),
                      Text('Our aviation experts are ready to assist',
                          style: TextStyle(color: Colors.white38, fontSize: 8.5.spV2)),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Contact our expert',
                        style: TextStyle(
                            color: _gold, fontSize: 9.spV2, fontWeight: FontWeight.w600)),
                    SizedBox(width: 1.w),
                    Icon(Icons.arrow_forward_rounded, color: _gold, size: 12.sp),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Decorative painter ─────────────────────────────────────────────────────────

class _HeroDecorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final thin = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha:0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final faint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha:0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Bottom-left sweeping arc
    final p1 = Path();
    p1.moveTo(-size.width * 0.05, size.height * 0.55);
    p1.cubicTo(
      size.width * 0.12, size.height * 0.20,
      size.width * 0.35, size.height * 0.75,
      size.width * 0.60, size.height * 1.05,
    );
    canvas.drawPath(p1, thin);

    // Secondary arc
    final p2 = Path();
    p2.moveTo(-size.width * 0.05, size.height * 0.72);
    p2.cubicTo(
      size.width * 0.08, size.height * 0.35,
      size.width * 0.28, size.height * 0.82,
      size.width * 0.55, size.height * 1.10,
    );
    canvas.drawPath(p2, faint);

    // Top-right accent
    final p3 = Path();
    p3.moveTo(size.width * 0.55, -size.height * 0.05);
    p3.cubicTo(
      size.width * 0.75, size.height * 0.30,
      size.width * 0.90, size.height * 0.55,
      size.width * 1.05, size.height * 0.40,
    );
    canvas.drawPath(p3, faint);

    // Small decorative circle hint
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.08, size.height * 0.88),
        width: size.width * 0.18,
        height: size.width * 0.18,
      ),
      -math.pi * 0.5,
      math.pi * 1.1,
      false,
      Paint()
        ..color = const Color(0xFFD4AF37).withValues(alpha:0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Data model ─────────────────────────────────────────────────────────────────

class _JetModel {
  final String name;
  final String description;
  final double rating;
  final String capacity;
  final String size;
  final String price;

  const _JetModel({
    required this.name,
    required this.description,
    required this.rating,
    required this.capacity,
    required this.size,
    required this.price,
  });
}
