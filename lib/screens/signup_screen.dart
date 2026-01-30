import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF1A2A3A);
    const Color lightBlue = Color(0xFFE3F2FD);

    return Scaffold(
      backgroundColor: darkBlue,
      // Using resizeToAvoidBottomInset: false prevents the keyboard from
      // pushing the layout up if you want a strictly "fixed" look.
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Full Screen Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color.fromARGB(255, 239, 240, 240),
                  const Color.fromARGB(255, 21, 43, 65).withOpacity(0.95),
                ],
              ),
            ),
          ),

          // 2. Fixed Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 20,
              ), // Vertical padding for top/bottom space
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Distributes space between top and bottom
                children: [
                  // --- TOP SECTION (Image) ---
                  Column(
                    children: [
                      const SizedBox(height: 10), // Extra space from very top
                      Image.asset(
                        'assets/images/heart.png',
                        height: 280, // Increased height for larger image
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),

                  // --- MIDDLE SECTION (Buttons & Fields) ---
                  Column(
                    children: [
                      _socialButton(
                        Icons.g_mobiledata,
                        "Sign up with Google",
                        Colors.white,
                        Colors.black,
                      ),
                      const SizedBox(height: 12),
                      _socialButton(
                        Icons.phone_android,
                        "Sign up with Number",
                        lightBlue,
                        darkBlue,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "OR CREATE PROFILE",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      _customTextField("Full Name", Icons.person),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _customTextField(
                              "Age",
                              Icons.calendar_today,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: _customTextField("Gender", Icons.wc)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _customTextField("Phone Number", Icons.phone),
                    ],
                  ),

                  // --- BOTTOM SECTION (Action Button) ---
                  Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lightBlue,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: const Text(
                          "FINISH SIGNUP",
                          style: TextStyle(
                            color: darkBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), // Space from bottom edge
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton(
    IconData icon,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: textColor),
      label: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {},
    );
  }

  Widget _customTextField(String hint, IconData icon) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white60, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE3F2FD)),
        ),
      ),
    );
  }
}
