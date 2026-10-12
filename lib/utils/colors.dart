import 'package:flutter/material.dart';
import 'app_palette.dart';

class AppColors {
  AppColors._();

  static const Color primary = AppPalette.primaryRose;
  static const Color secondary = AppPalette.primaryViolet;
  static const Color background = AppPalette.backgroundLight;
  static const Color surface = AppPalette.surfaceCardLight;
  static const Color border = AppPalette.borderLight;

  static const Color textDark = AppPalette.textPrimaryLight;
  static const Color textMuted = AppPalette.textSecondaryLight;
  static const Color textLight = Colors.white;

  static const Color success = AppPalette.callGreen;
  static const Color error = AppPalette.callRed;
}
