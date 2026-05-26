import 'dart:math';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// AppSpacing — Responsive Spacing System
// ---------------------------------------------------------------------------
// Usage:
//   AppSpacing.sm(context)           → adaptive scalar value
//   AppSpacing.insetMd(context)      → EdgeInsets.all(md)
//   AppSpacing.insetH(context, AppSpacing.screenH(context))  → horizontal
//   AppSpacing.h(context, AppSpacing.sm(context))  → SizedBox height
//   AppSpacing.w(context, AppSpacing.sm(context))  → SizedBox width
//
// Device tiers:
//   compact  < 360  dp wide  (very small phones)
//   small    < 400  dp wide  (standard small phones, e.g. iPhone SE)
//   medium   < 600  dp wide  (standard phones, e.g. iPhone 14 / Pixel 7)
//   large    < 900  dp wide  (large phones / small tablets)
//   tablet   ≥ 900  dp wide  (tablets / iPads)
// ---------------------------------------------------------------------------

class AppSpacing {
  AppSpacing._();

  // ── Device tier ──────────────────────────────────────────────────────────

  static _Tier _tier(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 360) return _Tier.compact;
    if (w < 400) return _Tier.small;
    if (w < 600) return _Tier.medium;
    if (w < 900) return _Tier.large;
    return _Tier.tablet;
  }

  static bool isTablet(BuildContext context) =>
      _tier(context) == _Tier.tablet || _tier(context) == _Tier.large;

  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width > size.height;
  }

  // ── Scale factor (0.85 → 1.20) ───────────────────────────────────────────
  // Derived from actual screen width so spacing stretches/shrinks smoothly.

  static double _scale(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    // clamp between 320 and 900, normalise to [0.85, 1.20]
    final clamped = w.clamp(320.0, 900.0);
    return 0.85 + (clamped - 320) / (900 - 320) * (1.20 - 0.85);
  }

  // ── Base token values (device-tier aware) ────────────────────────────────

  static double _base(BuildContext context, {
    required double compact,
    required double small,
    required double medium,
    required double large,
    required double tablet,
  }) {
    final raw = switch (_tier(context)) {
      _Tier.compact => compact,
      _Tier.small   => small,
      _Tier.medium  => medium,
      _Tier.large   => large,
      _Tier.tablet  => tablet,
    };
    // smooth scaling on top of the tier values
    return (raw * _scale(context)).roundToDouble();
  }

  // ── Spacing tokens ───────────────────────────────────────────────────────

  /// 2–4 dp  — tiny separators, icon gaps
  static double xxs(BuildContext context) => _base(context,
      compact: 2, small: 2, medium: 3, large: 3, tablet: 4);

  /// 4–6 dp  — tight internal gaps
  static double xs(BuildContext context) => _base(context,
      compact: 4, small: 4, medium: 5, large: 5, tablet: 6);

  /// 6–10 dp — label-to-field, icon-to-text
  static double sm(BuildContext context) => _base(context,
      compact: 6, small: 6, medium: 8, large: 8, tablet: 10);

  /// 10–16 dp — component internal padding, card inner gaps
  static double md(BuildContext context) => _base(context,
      compact: 10, small: 12, medium: 14, large: 14, tablet: 16);

  /// 14–24 dp — section spacing, card margins
  static double lg(BuildContext context) => _base(context,
      compact: 14, small: 16, medium: 18, large: 20, tablet: 24);

  /// 20–32 dp — screen-level section breaks
  static double xl(BuildContext context) => _base(context,
      compact: 20, small: 22, medium: 24, large: 28, tablet: 32);

  /// 28–48 dp — large hero/top spacing
  static double xxl(BuildContext context) => _base(context,
      compact: 28, small: 32, medium: 36, large: 40, tablet: 48);

  /// 40–72 dp — page hero spacers (logo area etc.)
  static double xxxl(BuildContext context) => _base(context,
      compact: 40, small: 44, medium: 48, large: 56, tablet: 72);

  // ── Screen-edge padding ──────────────────────────────────────────────────

  /// Horizontal screen padding (sides of the screen)
  static double screenH(BuildContext context) => _base(context,
      compact: 16, small: 20, medium: 22, large: 24, tablet: 32);

  /// Vertical screen padding (top/bottom safe zone content margin)
  static double screenV(BuildContext context) => _base(context,
      compact: 12, small: 16, medium: 20, large: 20, tablet: 24);

  // ── Component dimension tokens ────────────────────────────────────────────

  /// Standard touch-target button height  (≥ 44 dp always)
  static double buttonH(BuildContext context) {
    final v = _base(context,
        compact: 44, small: 48, medium: 52, large: 52, tablet: 56);
    return max(44, v);
  }

  /// Standard form-field height
  static double fieldH(BuildContext context) {
    final v = _base(context,
        compact: 46, small: 50, medium: 54, large: 54, tablet: 58);
    return max(44, v);
  }

  /// App-bar / header height
  static double headerH(BuildContext context) => _base(context,
      compact: 54, small: 58, medium: 62, large: 64, tablet: 70);

  /// Bottom navigation bar height
  static double bottomNavH(BuildContext context) => _base(context,
      compact: 54, small: 58, medium: 62, large: 62, tablet: 70);

  /// Avatar / icon-button standard size
  static double avatarSm(BuildContext context) => _base(context,
      compact: 32, small: 34, medium: 36, large: 38, tablet: 44);

  static double avatarMd(BuildContext context) => _base(context,
      compact: 44, small: 48, medium: 52, large: 54, tablet: 60);

  static double avatarLg(BuildContext context) => _base(context,
      compact: 60, small: 66, medium: 72, large: 76, tablet: 88);

  /// Icon size (standard)
  static double iconSm(BuildContext context) => _base(context,
      compact: 14, small: 15, medium: 16, large: 17, tablet: 20);

  static double iconMd(BuildContext context) => _base(context,
      compact: 18, small: 20, medium: 22, large: 22, tablet: 26);

  static double iconLg(BuildContext context) => _base(context,
      compact: 22, small: 24, medium: 28, large: 28, tablet: 32);

  /// Card horizontal margin (space between card edge and screen edge)
  static double cardMarginH(BuildContext context) => _base(context,
      compact: 10, small: 12, medium: 14, large: 16, tablet: 20);

  /// Card bottom margin (spacing between stacked cards)
  static double cardMarginV(BuildContext context) => _base(context,
      compact: 8, small: 10, medium: 12, large: 12, tablet: 14);

  /// Card inner padding
  static double cardPadding(BuildContext context) => _base(context,
      compact: 10, small: 12, medium: 14, large: 14, tablet: 16);

  // ── EdgeInsets helpers ───────────────────────────────────────────────────

  static EdgeInsets insetAll(BuildContext context, double v) =>
      EdgeInsets.all(v);

  static EdgeInsets insetH(BuildContext context, double h) =>
      EdgeInsets.symmetric(horizontal: h);

  static EdgeInsets insetV(BuildContext context, double v) =>
      EdgeInsets.symmetric(vertical: v);

  static EdgeInsets insetHV(BuildContext context, double h, double v) =>
      EdgeInsets.symmetric(horizontal: h, vertical: v);

  static EdgeInsets insetLTRB(
          BuildContext context, double l, double t, double r, double b) =>
      EdgeInsets.fromLTRB(l, t, r, b);

  /// Standard screen-edge horizontal inset
  static EdgeInsets screenInset(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: screenH(context));

  /// Card inset (inner padding of a card)
  static EdgeInsets cardInset(BuildContext context) =>
      EdgeInsets.all(cardPadding(context));

  // ── SizedBox helpers ─────────────────────────────────────────────────────

  static SizedBox h(BuildContext context, double v) => SizedBox(height: v);
  static SizedBox w(BuildContext context, double v) => SizedBox(width: v);

  static SizedBox gapXXS(BuildContext context) => h(context, xxs(context));
  static SizedBox gapXS(BuildContext context)  => h(context, xs(context));
  static SizedBox gapSM(BuildContext context)  => h(context, sm(context));
  static SizedBox gapMD(BuildContext context)  => h(context, md(context));
  static SizedBox gapLG(BuildContext context)  => h(context, lg(context));
  static SizedBox gapXL(BuildContext context)  => h(context, xl(context));
  static SizedBox gapXXL(BuildContext context) => h(context, xxl(context));

  static SizedBox wGapXXS(BuildContext context) => w(context, xxs(context));
  static SizedBox wGapXS(BuildContext context)  => w(context, xs(context));
  static SizedBox wGapSM(BuildContext context)  => w(context, sm(context));
  static SizedBox wGapMD(BuildContext context)  => w(context, md(context));
  static SizedBox wGapLG(BuildContext context)  => w(context, lg(context));
  static SizedBox wGapXL(BuildContext context)  => w(context, xl(context));
}

enum _Tier { compact, small, medium, large, tablet }
