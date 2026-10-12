import 'package:flutter/material.dart';
import 'app_palette.dart';

class BrandColors {
  BrandColors._();

  static const Color primary = AppPalette.primaryRose;
  static const Color secondary = AppPalette.primaryViolet;

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color online = Color(0xFF10B981);
  static const Color offline = Color(0xFF94A3B8);

  static List<BoxShadow> glowShadow(Color color, {double opacity = 0.25, double blur = 14}) => [
    BoxShadow(
      color: color.withOpacity(opacity),
      blurRadius: blur,
      offset: const Offset(0, 4),
    ),
  ];
}
