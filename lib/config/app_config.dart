import 'package:flutter/material.dart';

enum Environment {
  dg,   // Development / Debug
  uat,  // User Acceptance Testing / Staging
  live, // Production
}

class AppConfig {
  AppConfig._();

  static const String appName = 'HeartMate';
  static const String appVersion = '1.0.0';

  // Screen design viewport references
  static const double designWidth = 375.0;
  static const double designHeight = 812.0;

  // Active build environment
  static Environment currentEnvironment = Environment.live;

  // Global Navigator key for overlay/navigation without direct context
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Global ScaffoldMessenger key for snackbars
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  // Layout Dimensions & Spacing Tokens
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusExtraLarge = 32.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double buttonHeight = 52.0;
  static const double inputHeight = 54.0;
}
