import 'package:flutter/material.dart';
import 'app_palette.dart';

class AppThemes {
  AppThemes._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppPalette.primaryRose,
      scaffoldBackgroundColor: AppPalette.backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppPalette.primaryRose,
        primary: AppPalette.primaryRose,
        secondary: AppPalette.primaryViolet,
        surface: AppPalette.surfaceCardLight,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppPalette.backgroundLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppPalette.textPrimaryLight),
        titleTextStyle: TextStyle(
          color: AppPalette.textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppPalette.surfaceCardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppPalette.borderLight),
        ),
      ),
      fontFamily: 'Inter',
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppPalette.primaryRose,
      scaffoldBackgroundColor: AppPalette.backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppPalette.primaryRose,
        primary: AppPalette.primaryRose,
        secondary: AppPalette.primaryViolet,
        surface: AppPalette.surfaceCardDark,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppPalette.backgroundDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppPalette.textPrimaryDark),
        titleTextStyle: TextStyle(
          color: AppPalette.textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppPalette.surfaceCardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppPalette.borderDark),
        ),
      ),
      fontFamily: 'Inter',
    );
  }
}
