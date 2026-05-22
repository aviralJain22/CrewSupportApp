// Re-implements Sizer v2's font scaling based on device width.
// Old v2 formula: 1.sp = (width / 3) / 100
// Note: we cap width on tablets (e.g., iPad) to avoid oversized text.
//
// Usage: TextStyle(fontSize: 10.spV2)
//
// ⚠️ Make sure your app is wrapped in Sizer so Device.* is initialized:
// Sizer(builder: (_, __, ___) => MyApp())

import 'package:sizer/sizer.dart';

extension SizerV2Compat on num {
  /// Returns the same visual size you'd get from Sizer v2's `sp`, but caps width on tablets.
  double get spV2 {
    // Sizer v2 scaled text purely by device width.
    // On tablets (e.g., iPad), this makes text look oversized.
    // We keep the same visual scale as large iPhones by capping the effective width.

    final double w = Device.width;

    // Treat wider layouts as tablets and cap to a "large phone" logical width.
    // 430 is roughly the max iPhone logical width in portrait; this keeps iPad text consistent.
    final double effectiveWidth = (w >= 600.0) ? 530.0 : w;

    return toDouble() * (effectiveWidth / 3.0) / 100.0;
  }
}