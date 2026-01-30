import 'package:dating_app/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/screens/edit_screen.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Deep dark blue/grey color from the image
    const Color bgColor = Color(0xFF222B32);
    const Color cardColor = Color(0xFF38444D);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  // Profile Image with White Border
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/boy.jpg'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Name and Edit Action
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mohit Sharma',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                        child: Row(
                          children: const [
                            Text(
                              'Edit profile',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Profile Options List
            Expanded(
              child: ListView(
                children: [
                  _buildProfileOption(Icons.call_outlined, 'Call History'),
                  _buildProfileOption(Icons.shield_outlined, 'Privacy Policy'),
                  _buildProfileOption(
                    Icons.receipt_long_outlined,
                    'Refund Policy',
                  ),
                  _buildProfileOption(
                    Icons.security_outlined,
                    'Terms and Condition',
                  ),
                  _buildProfileOption(
                    Icons.report_gmailerrorred_outlined,
                    'Report',
                  ),
                  _buildProfileOptionWithAction(Icons.logout, 'Log Out', () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: Colors.white, size: 28),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 18,
          ),
          onTap: () {
            // Handle navigation here
          },
        ),
        const Divider(color: Colors.white24, thickness: 1),
      ],
    );
  }

  Widget _buildProfileOptionWithAction(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: Colors.white, size: 28),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 18,
          ),
          onTap: onTap,
        ),
        const Divider(color: Colors.white24, thickness: 1),
      ],
    );
  }
}
