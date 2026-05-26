import 'package:crew_support/utils/AppColor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF0D47A1);   // Replace with repo's primary
  static const Color secondary = Color(0xFF42A5F5); // Replace with repo's accent
  static const Color background = Color(0xFFF7F9FC);
  static const Color appBarBackground = Colors.white;
  static const Color appBarText = primary;
  static const Color bodyText = Colors.black87;

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColor.bgColor1,

      colorScheme: base.colorScheme.copyWith(
        primary: AppColor.primaryColor,
        secondary: AppColor.secondaryColor1,
        surface: AppColor.blackColor2,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColor.textColor1,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColor.secondaryColor1,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.raleway(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColor.secondaryColor1,
        ),
      ),

      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          color: AppColor.textColor1,
        ),
        titleLarge: GoogleFonts.raleway(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColor.secondaryColor1,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.btnColor2,
          foregroundColor: AppColor.textColor1,
          disabledBackgroundColor: AppColor.btnColor2.withOpacity(0.5),
          disabledForegroundColor: AppColor.textColor1.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColor.primaryColor1,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColor.blackColor2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
      ),

      dividerColor: AppColor.greyColor,
      cardColor: AppColor.blackColor2,
    );
  }

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      // Universal background color
      scaffoldBackgroundColor: AppColor.bgColor2,

      // Universal color scheme
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: secondary,
        background: background,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: bodyText,
        onSurface: bodyText,
      ),

      // AppBar styling
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColor.secondaryColor1,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.raleway(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColor.secondaryColor1,
        ),
      ),

      // // Card styling
      // cardTheme: CardTheme(
      //   color: Colors.white,
      //   elevation: 2,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(12),
      //   ),
      // ),

      // Text defaults
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          color: bodyText,
        ),
        titleLarge: GoogleFonts.raleway(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: appBarText,
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.btnColor2,
          foregroundColor: AppColor.textColor1,
          disabledBackgroundColor: AppColor.btnColor2.withOpacity(0.5),
          disabledForegroundColor: AppColor.textColor1.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondary,
        ),
      ),
      

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: TextStyle(color: Colors.grey[700]),
      ),
    );
  }
}