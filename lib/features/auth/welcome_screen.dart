import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../app/routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const _bg = Color(0xFF010A09);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Jet photo background ────────────────────────────────────
          // Replace this Container with your jet photo:
          //
          //   Image.asset('assets/jet_dusk.jpg', fit: BoxFit.cover)
          //
          // The gradient overlay below will blend it into the dark UI.
          _DuskBackground(size: size),

          // ── 2. Full-height gradient: sky → dark at bottom ─────────────
          _GradientOverlay(),

          // ── 3. Content ────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 7.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 3.h),

                  // ── Heading ───────────────────────────────────────────
                  _Heading(),

                  const Spacer(),

                  // ── Tagline ───────────────────────────────────────────
                  Text(
                    'Private jet for your life,\nwork and other goals',
                    style: GoogleFonts.cinzel(
                      fontSize: 13.0.spV2,
                      color: Colors.white.withValues(alpha: 0.78),
                      height: 1.55,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  SizedBox(height: 3.2.h),

                  // ── Buttons ───────────────────────────────────────────
                  _OutlinedActionButton(
                    label: 'Sign In',
                    onTap: () => Get.toNamed(AppRoutes.login),
                    filled: true,
                  ),
                  SizedBox(height: 1.5.h),
                  _OutlinedActionButton(
                    label: 'Sign Up',
                    onTap: () => Get.toNamed(AppRoutes.register),
                    filled: false,
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fake dusk sky background (replace with Image.asset when you have the photo)

class _DuskBackground extends StatelessWidget {
  const _DuskBackground({required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Sky gradient — mimics a dusk horizon
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A2035), // deep blue-grey sky
                Color(0xFF2B2D3A), // twilight mid
                Color(0xFF3D3020), // warm amber horizon
                Color(0xFF1A0D05), // near-black ground
                Color(0xFF010A09), // pure background
              ],
              stops: [0.0, 0.28, 0.55, 0.78, 1.0],
            ),
          ),
        ),

        // Moon accent
        Positioned(
          top: size.height * 0.10,
          right: size.width * 0.18,
          child: const _CrescentMoon(),
        ),

        // Horizon warm glow
        Positioned(
          top: size.height * 0.42,
          left: -size.width * 0.2,
          right: -size.width * 0.2,
          child: Container(
            height: size.height * 0.22,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.5,
                colors: [
                  const Color(0xFFF2A11F).withValues(alpha: 0.18),
                  const Color(0xFFE05C00).withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Silhouette plane wing (drawn with paths)
        Positioned(
          bottom: size.height * 0.16,
          left: 0,
          right: 0,
          child: SizedBox(
            height: size.height * 0.38,
            child: CustomPaint(painter: _WingSilhouettePainter()),
          ),
        ),
      ],
    );
  }
}

// ─── Crescent moon widget

class _CrescentMoon extends StatelessWidget {
  const _CrescentMoon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _MoonPainter()),
    );
  }
}

class _MoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF2D68A)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path.combine(PathOperation.difference,
          Path()
            ..addOval(Rect.fromCircle(
                center: Offset(size.width * 0.5, size.height * 0.5),
                radius: size.width * 0.46)),
          Path()
            ..addOval(Rect.fromCircle(
                center: Offset(size.width * 0.72, size.height * 0.44),
                radius: size.width * 0.38))),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Wing silhouette painter

class _WingSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0A0806)
      ..style = PaintingStyle.fill;

    final path = Path();
    // Large wing shape — left side sweeping from lower-right to upper-left
    path.moveTo(size.width * 0.95, size.height * 1.0);
    path.quadraticBezierTo(
        size.width * 0.55, size.height * 0.7, size.width * 0.0, size.height * 0.18);
    path.lineTo(size.width * 0.0, size.height * 1.0);
    path.close();

    canvas.drawPath(path, paint);

    // Engine nacelle
    final enginePaint = Paint()
      ..color = const Color(0xFF111111)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(size.width * 0.55, size.height * 0.58),
            width: size.width * 0.12,
            height: size.height * 0.07),
        const Radius.circular(6),
      ),
      enginePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Gradient overlay (dark vignette from bottom up)

class _GradientOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            const Color(0xFF010A09).withValues(alpha: 0.55),
            const Color(0xFF010A09).withValues(alpha: 0.88),
            const Color(0xFF010A09),
          ],
          stops: const [0.0, 0.30, 0.52, 0.68, 0.82],
        ),
      ),
    );
  }
}

// ─── Heading with decorative line

class _Heading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome\naboard',
          style: GoogleFonts.cinzel(
            fontSize: 40.0.spV2,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF2A11F),
            height: 1.12,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 1.4.h),
        Row(
          children: [
            Container(
              width: 22,
              height: 1.0,
              color: const Color(0xFFF2A11F).withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Container(
              width: 55,
              height: 1.0,
              color: const Color(0xFFF2A11F).withValues(alpha: 0.35),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Outlined action button (matches reference "Get started" style)

class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({
    required this.label,
    required this.onTap,
    required this.filled,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  static const _gold = Color(0xFFF2A11F);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 6.2.h,
        decoration: BoxDecoration(
          color: filled ? _gold.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _gold.withValues(alpha: 0.65), width: 1.0),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cinzel(
              fontSize: 13.0.spV2,
              fontWeight: FontWeight.w600,
              color: filled ? _gold : Colors.white.withValues(alpha: 0.80),
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
