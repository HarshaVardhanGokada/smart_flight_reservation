import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Color Palette
  static const Color primaryNavy = Color(0xFF0B1F3A);
  static const Color primaryBlue = Color(0xFF1A73E8);
  static const Color lightBlue = Color(0xFFE8F1FD);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentGold = Color(0xFFD97706);
  static const Color successGreen = Color(0xFF10B981);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color scaffoldBackground = Color(0xFFF8FAFC);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color borderColor = Color(0xFFE2E8F0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryNavy,
        primary: primaryNavy,
        secondary: primaryBlue,
        tertiary: accentAmber,
        surface: cardBackground,
        error: dangerRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: primaryNavy,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: primaryNavy,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: primaryNavy),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dangerRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dangerRed, width: 1.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryNavy,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          side: const BorderSide(color: borderColor, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 24,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: primaryNavy,
        secondarySelectedColor: primaryNavy,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: borderColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
