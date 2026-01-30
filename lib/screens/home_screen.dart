import 'package:flutter/material.dart';
// import 'package:dating_app/screens/coin_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a single Scaffold with no AppBar for the full-screen effect
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 83, 108, 173),
              Color.fromARGB(255, 21, 43, 65),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Custom Header (Replacing the AppBar)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Color.fromARGB(248, 240, 242, 245),
                              Color.fromARGB(204, 231, 231, 238),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                          'Heart Mate',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 1.2,
                            shadows: [
                            Shadow(
                              color: const Color.fromARGB(
                              204,
                              28,
                              29,
                              54,
                              ).withValues(alpha: 0.5),
                              offset: Offset(2, 2),
                              blurRadius: 3,
                            ),
                            ],
                          ),
                          ),
                        ),
                        Row(
                          children: [
                            // Coin Balance UI
                            // GestureDetector(
                            //   onTap: () {
                            //     Navigator.pushNamed(context, '/coin');
                            //   },
                            //   child: Container(
                            //     padding: const EdgeInsets.symmetric(
                            //       horizontal: 12,
                            //       vertical: 6,
                            //     ),
                            //     decoration: BoxDecoration(
                            //       color: const Color.fromARGB(
                            //         255,
                            //         230,
                            //         117,
                            //         60,
                            //       ).withValues(alpha: 0.15),
                            //       borderRadius: BorderRadius.circular(20),
                            //       border: Border.all(
                            //         color: Colors.amber.withValues(alpha: 0.3),
                            //       ),
                            //     ),
                            //     child: Row(
                            //       // children: [
                            //       //   const Icon(
                            //       //     Icons.monetization_on,
                            //       //     color: Colors.amber,
                            //       //     size: 18,
                            //       //   ),
                            //       //   const SizedBox(width: 5),
                            //       //   const Text(
                            //       //     "150",
                            //       //     style: TextStyle(
                            //       //       fontWeight: FontWeight.bold,
                            //       //       color: Colors.white,
                            //       //     ),
                            //       //   ),
                            //       //   const SizedBox(width: 5),
                            //       //   const Icon(
                            //       //     Icons.add_circle,
                            //       //     color: Colors.white,
                            //       //     size: 16,
                            //       //   ),
                            //       // ],
                            //     ),
                            //   ),
                            // ),

                            const SizedBox(width: 12),

                            GestureDetector(
                              onTap: () {
                              Navigator.pushNamed(context, '/profile');
                              },
                              child: const CircleAvatar(
                              radius: 18,
                              backgroundImage: AssetImage(
                                'assets/images/boy.jpg',
                              ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/signup',
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "Logout",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Scrollable List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        100,
                      ), // Extra bottom padding for buttons
                      itemCount: 8,
                      itemBuilder: (context, index) => const UserListTile(),
                    ),
                  ),
                ],
              ),

              // Floating Bottom Action Bar
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Add Coin Button
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF38BDF8).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/coin');
                        },
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        label: const Text(
                          "Add Coin",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),

                    // Support Button
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.greenAccent.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/support');
                        },
                        child: CircleAvatar(
                          backgroundColor: const Color(0xFF22C55E),
                          radius: 28,
                          child: const Icon(
                            Icons.support_agent,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserListTile extends StatelessWidget {
  const UserListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 39, 66, 109), // Card background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Profile & Online Status
          Column(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF38BDF8),
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 34,
                      backgroundImage: AssetImage('assets/images/girl.jpg'),
                    ),
                  ),
                  Container(
                    transform: Matrix4.translationValues(0, 5, 0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF1E293B),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      "ONLINE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                  Text(
                    " 4.9",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 16),
          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Malayalam • Tamil",
                  style: TextStyle(
                    color: Colors.orangeAccent.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Ananya",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                _buildRateInfo(Icons.mic_none_rounded, "3 Coins/sec"),
                const SizedBox(height: 4),
                _buildRateInfo(Icons.videocam_outlined, "20 Coins/sec"),
              ],
            ),
          ),
          // Call Actions
          Column(
            children: [
              _buildCallButton(Icons.videocam_rounded),
              const SizedBox(height: 10),
              _buildCallButton(Icons.call_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRateInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white60),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildCallButton(IconData icon) {
    return Container(
      height: 45,
      width: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}
