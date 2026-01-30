import 'dart:async';
import 'package:flutter/material.dart';
import 'signup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the next screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      // Replace 'NextScreen()' with your actual home or profile widget
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 239, 240, 240),
              const Color.fromARGB(255, 21, 43, 65).withOpacity(0.95),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Your logo image (heart.png)
              Image.asset(
                'assets/images/heart.png', 
                width: 320, // Adjust size as needed
                height: 320,
              ),
              const SizedBox(height: 20),
              // Optional: Add a loading indicator
              const CircularProgressIndicator(
                color: Color(0xFF152B41),
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}