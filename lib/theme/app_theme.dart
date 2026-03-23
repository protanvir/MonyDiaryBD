import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final ColorScheme colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF0891B2), // Bright Cyan
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF0E7490),
      onPrimaryContainer: Color(0xFFCFFAFE),
      secondary: Color(0xFF22D3EE), // Cyan Accent
      onSecondary: Color(0xFF0F172A),
      secondaryContainer: Color(0xFF67E8F9),
      onSecondaryContainer: Color(0xFF083344),
      tertiary: Color(0xFF22C55E), // Clean Green (CTA/Success)
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFF16A34A),
      onTertiaryContainer: Color(0xFFDCFCE7),
      error: Color(0xFFEF4444),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFEE2E2),
      onErrorContainer: Color(0xFF7F1D1D),
      surface: Color(0xFFECFEFF), // Soft Mint / Cyan Ice
      onSurface: Color(0xFF164E63), // Dark Slate / Teal
      surfaceContainerHighest: Color(0xFFCFFAFE),
      onSurfaceVariant: Color(0xFF164E63),
      outline: Color(0xFF94A3B8),
      outlineVariant: Color(0xFFCBD5E1),
    );

    final TextTheme textTheme = TextTheme(
      displayLarge: GoogleFonts.lexend(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
      displayMedium: GoogleFonts.lexend(fontSize: 45, fontWeight: FontWeight.w400, letterSpacing: 0),
      displaySmall: GoogleFonts.lexend(fontSize: 36, fontWeight: FontWeight.w400, letterSpacing: 0),
      headlineLarge: GoogleFonts.lexend(fontSize: 32, fontWeight: FontWeight.w400, letterSpacing: 0),
      headlineMedium: GoogleFonts.lexend(fontSize: 28, fontWeight: FontWeight.w400, letterSpacing: 0),
      headlineSmall: GoogleFonts.lexend(fontSize: 24, fontWeight: FontWeight.w400, letterSpacing: 0),
      titleLarge: GoogleFonts.sourceSans3(fontSize: 22, fontWeight: FontWeight.w400, letterSpacing: 0),
      titleMedium: GoogleFonts.sourceSans3(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
      titleSmall: GoogleFonts.sourceSans3(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      bodyLarge: GoogleFonts.sourceSans3(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
      bodyMedium: GoogleFonts.sourceSans3(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      bodySmall: GoogleFonts.sourceSans3(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
      labelLarge: GoogleFonts.sourceSans3(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium: GoogleFonts.sourceSans3(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      labelSmall: GoogleFonts.sourceSans3(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF).withOpacity(0.8), // Glassmorphism base
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), 
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.tertiary, // Green CTA
          foregroundColor: colorScheme.onTertiary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          elevation: 4,
          shadowColor: colorScheme.tertiary.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.tertiary,
        foregroundColor: colorScheme.onTertiary,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
