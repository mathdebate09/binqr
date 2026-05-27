import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _radius = 20.0;

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0A0A0A),
        brightness: Brightness.light,
      ).copyWith(
        surface: const Color(0xFFF5F5F7),
        onSurface: const Color(0xFF0A0A0A),
        primary: const Color(0xFF0A0A0A),
        onPrimary: Colors.white,
        secondary: const Color(0xFF6E6E73),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 34, fontWeight: FontWeight.w700,
          letterSpacing: -0.5, color: const Color(0xFF0A0A0A),
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28, fontWeight: FontWeight.w600,
          letterSpacing: -0.3, color: const Color(0xFF0A0A0A),
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 17, fontWeight: FontWeight.w400,
          color: const Color(0xFF0A0A0A),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w400,
          color: const Color(0xFF6E6E73),
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 17, fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A0A0A),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 17, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0A0A0A),
          side: const BorderSide(color: Color(0xFFD1D1D6), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 17, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0A0A0A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.white,
        brightness: Brightness.dark,
      ).copyWith(
        surface: const Color(0xFF1C1C1E),
        onSurface: Colors.white,
        primary: Colors.white,
        onPrimary: const Color(0xFF0A0A0A),
        secondary: const Color(0xFF8E8E93),
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 34, fontWeight: FontWeight.w700,
          letterSpacing: -0.5, color: Colors.white,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28, fontWeight: FontWeight.w600,
          letterSpacing: -0.3, color: Colors.white,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 17, fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w400,
          color: const Color(0xFF8E8E93),
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 17, fontWeight: FontWeight.w600,
          color: const Color(0xFF0A0A0A),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0A0A0A),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 17, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF3A3A3C), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 17, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFF1C1C1E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}