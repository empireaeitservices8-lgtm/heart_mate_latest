import 'package:flutter/material.dart';

class AppPalette {
  AppPalette._();

  // Core Brand Colors
  static const Color primaryRose = Color(0xFFEC4899);
  static const Color primaryViolet = Color(0xFF8B5CF6);
  static const Color accentGold = Color(0xFFF59E0B);

  // Background Tones
  static const Color backgroundLight = Color(0xFFFAFBFC);
  static const Color backgroundLightAlt = Color(0xFFF1F5F9);
  static const Color backgroundDark = Color(0xFF0B0F19);
  static const Color backgroundDarkAlt = Color(0xFF111827);

  // Surface Card Tones
  static const Color surfaceCardLight = Colors.white;
  static const Color surfaceCardDark = Color(0xFF1E293B);

  // Border Tones
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  // Call Status Accents
  static const Color callGreen = Color(0xFF10B981);
  static const Color callIndigo = Color(0xFF6366F1);
  static const Color callRed = Color(0xFFEF4444);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Brand Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryRose, primaryViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgLightGradient = LinearGradient(
    colors: [backgroundLight, backgroundLightAlt],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient bgDarkGradient = LinearGradient(
    colors: [backgroundDark, backgroundDarkAlt],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient callGreenGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
