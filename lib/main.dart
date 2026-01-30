import 'package:dating_app/screens/coin_screen.dart';
import 'package:dating_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/screens/signup_screen.dart';
import 'package:dating_app/screens/support_screen.dart';
import 'package:dating_app/screens/profile.screen.dart';
import 'package:dating_app/screens/splash_screen.dart';

void main() {
  runApp(const HeartMateApp());
}

class HeartMateApp extends StatelessWidget {
  const HeartMateApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      home: const SplashScreen(),
      routes: {

        '/home': (context) => const HomeScreen(),
        '/support': (context) => const SupportScreen(),
        '/profile': (context) => const MyProfileScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/coin': (context) => const CoinBalanceScreen(),

      },
    );
  }
}