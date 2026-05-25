import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color tokens ────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Gold
  static const Color gold        = Color(0xFFC9962A);
  static const Color goldLight   = Color(0xFFDDB84A);
  static const Color goldDim     = Color(0xFF7A5A16);

  // Backgrounds
  static const Color bg0         = Color(0xFF0F0F0F); // deepest
  static const Color bg1         = Color(0xFF1A1A1A); // card surface
  static const Color bg2         = Color(0xFF242424); // elevated surface

  // Text
  static const Color textPrimary   = Color(0xFFF0EDE8);
  static const Color textSecondary = Color(0xFF9A9590);
  static const Color textDisabled  = Color(0xFF5A5651);

  // Semantic
  static const Color error   = Color(0xFFCF4C4C);
  static const Color success = Color(0xFF4BAD06);

  // Misc
  static const Color divider    = Color(0xFF2E2E2E);
  static const Color inputFill  = Color(0xFF1E1E1E);
  static const Color borderIdle = Color(0xFF3A3A3A);
}

// ─── Typography tokens ────────────────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();

  static TextStyle heading1 = GoogleFonts.raleway(
    fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static TextStyle heading2 = GoogleFonts.raleway(
    fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static TextStyle heading3 = GoogleFonts.raleway(
    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );

  static TextStyle body = GoogleFonts.nunito(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
  );
  static TextStyle bodySmall = GoogleFonts.nunito(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
  );

  static TextStyle label = GoogleFonts.nunito(
    fontSize: 12, fontWeight: FontWeight.w600,
    color: AppColors.textSecondary, letterSpacing: 0.8,
  );
  static TextStyle button = GoogleFonts.raleway(
    fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5,
  );

  static TextStyle caption = GoogleFonts.nunito(
    fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
  );
}

// ─── Spacing tokens ───────────────────────────────────────────────────────────

class AppSpacing {
  AppSpacing._();

  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 24;
  static const double xxl = 32;
}

// ─── Radius tokens ────────────────────────────────────────────────────────────

class AppRadius {
  AppRadius._();

  static const double sm  = 6;
  static const double md  = 10;
  static const double lg  = 14;
  static const double pill = 100;
}

// ─── ThemeData ────────────────────────────────────────────────────────────────

class AppThemeData {
  AppThemeData._();

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg0,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.gold,
        secondary: AppColors.goldLight,
        surface: AppColors.bg1,
        error: AppColors.error,
        onPrimary: AppColors.bg0,
        onSecondary: AppColors.bg0,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),
      dividerColor: AppColors.divider,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg0,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.heading3,
      ),
      cardTheme: CardThemeData(
        color: AppColors.bg1,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.divider),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderIdle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderIdle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: AppTextStyles.label,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textDisabled),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.bg0,
          disabledBackgroundColor: AppColors.goldDim,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTextStyles.button,
          minimumSize: const Size.fromHeight(48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.gold),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bg2,
        selectedColor: AppColors.gold,
        disabledColor: AppColors.bg1,
        labelStyle: AppTextStyles.bodySmall,
        secondaryLabelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.bg0),
        side: const BorderSide(color: AppColors.borderIdle),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs,
        ),
      ),
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.bodySmall,
        titleLarge: AppTextStyles.heading2,
      ),
    );
  }
}
