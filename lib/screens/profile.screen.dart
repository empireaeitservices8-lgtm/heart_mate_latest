import 'package:dating_app/screens/signup/view/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/screens/edit_screen.dart';
import 'package:dating_app/theme/app_theme.dart';
import 'package:dating_app/screens/content_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:dating_app/screens/signup/view_model/signup_viewmodel.dart';

class MyProfileScreen extends StatefulWidget {
  final bool isEmbedded;
  const MyProfileScreen({super.key, this.isEmbedded = false});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<SignUpViewModel>(context, listen: false);
      viewModel.fetchProfile();
      viewModel.fetchCoins();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SignUpViewModel>(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundObsidian,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    viewModel.isAgentMode || widget.isEmbedded
                        ? const SizedBox(width: 48)
                        : IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: AppTheme.textPrimary,
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                    Text(
                      viewModel.isAgentMode ? 'Agent Profile' : 'My Profile',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 48), // Balancing spacing
                  ],
                ),
              ),

              Expanded(
                child: Consumer<SignUpViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isProfileLoading &&
                        viewModel.profile == null) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accentRose,
                        ),
                      );
                    } else if (viewModel.errorMessage != null &&
                        viewModel.profile == null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'Error: ${viewModel.errorMessage}',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final user = viewModel.profile;
                    if (user == null) {
                      return const Center(
                        child: Text(
                          'No profile data found',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      );
                    }

                    final profile = user.profile;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // Header Profile Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppTheme.borderTranslucent,
                              ),
                              boxShadow: AppTheme.softCardShadow,
                            ),
                            child: Row(
                              children: [
                                // Profile Image with Gradient Ring
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppTheme.primaryGradient,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.backgroundObsidian,
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircleAvatar(
                                      radius: 44,
                                      backgroundImage:
                                          profile.gender.toLowerCase() ==
                                              'female'
                                          ? const AssetImage(
                                              'assets/images/girl.jpg',
                                            )
                                          : const AssetImage(
                                              'assets/images/boy.jpg',
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Name and Edit Action
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.name,
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '@${user.username}',
                                        style: const TextStyle(
                                          color: AppTheme.accentRose,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (!viewModel.isAgentMode) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.monetization_on_rounded,
                                              color: AppTheme.accentGold,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${viewModel.coins} Coins',
                                              style: const TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const EditProfileScreen(),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.textPrimary
                                                .withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: AppTheme.textPrimary
                                                  .withOpacity(0.1),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(
                                                Icons.edit_outlined,
                                                color: AppTheme.accentRose,
                                                size: 14,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Edit Profile',
                                                style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(
                                                Icons.chevron_right,
                                                color: AppTheme.textSecondary,
                                                size: 14,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //const SizedBox(height: 20),

                          // Dynamic Profile Details Card
                          // Container(
                          //   width: double.infinity,
                          //   padding: const EdgeInsets.all(20),
                          //   decoration: BoxDecoration(
                          //     color: AppTheme.surfaceCard,
                          //     borderRadius: BorderRadius.circular(24),
                          //     border: Border.all(
                          //       color: AppTheme.borderTranslucent,
                          //     ),
                          //     boxShadow: AppTheme.softCardShadow,
                          //   ),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       const Text(
                          //         "ABOUT ME",
                          //         style: TextStyle(
                          //           color: AppTheme.textSecondary,
                          //           fontSize: 11,
                          //           fontWeight: FontWeight.bold,
                          //           letterSpacing: 1.2,
                          //         ),
                          //       ),
                          //       const SizedBox(height: 14),
                          //       _buildDetailItem(
                          //         Icons.email_outlined,
                          //         "Email",
                          //         user.email,
                          //       ),
                          //       const Divider(
                          //         color: AppTheme.borderTranslucent,
                          //         height: 24,
                          //       ),
                          //       _buildDetailItem(
                          //         Icons.cake_outlined,
                          //         "Age",
                          //         "${profile.age} years",
                          //       ),
                          //       const Divider(
                          //         color: AppTheme.borderTranslucent,
                          //         height: 24,
                          //       ),
                          //       _buildDetailItem(
                          //         Icons.transgender_outlined,
                          //         "Gender",
                          //         profile.gender,
                          //       ),
                          //       const Divider(
                          //         color: AppTheme.borderTranslucent,
                          //         height: 24,
                          //       ),
                          //       _buildDetailItem(
                          //         Icons.phone_android_outlined,
                          //         "Phone",
                          //         profile.phoneNumber,
                          //       ),
                          //       const Divider(
                          //         color: AppTheme.borderTranslucent,
                          //         height: 24,
                          //       ),
                          //       _buildDetailItem(
                          //         Icons.chat_bubble_outline_outlined,
                          //         "Bio",
                          //         profile.bio,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          const SizedBox(height: 24),

                          // Profile Options Title
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 4.0, bottom: 12.0),
                              child: Text(
                                "ACCOUNT SETTINGS",
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),

                          // Options Group Container
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppTheme.borderTranslucent,
                              ),
                              boxShadow: AppTheme.softCardShadow,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Column(
                                children: [
                                  if (viewModel.isAgentMode) ...[
                                    _buildSwitchOptionTile(
                                      icon: Icons.sync_alt_rounded,
                                      iconColor: AppTheme.accentRose,
                                      title: 'Agent Mode Active',
                                      value: viewModel.isAgentMode,
                                      onChanged: (val) {
                                        viewModel.toggleAgentMode(false);
                                        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                                      },
                                      isLast: true,
                                    ),
                                  ] else ...[
                                    _buildSwitchOptionTile(
                                      icon: Icons.online_prediction_rounded,
                                      iconColor: Colors.greenAccent,
                                      title: 'Online Status',
                                      value: user.isOnline,
                                      onChanged: (val) {
                                        viewModel.toggleOnlineStatus();
                                      },
                                      isLast: false,
                                    ),
                                    // if (viewModel.agentStatus == 'approved')
                                    //   _buildSwitchOptionTile(
                                    //     icon: Icons.sync_alt_rounded,
                                    //     iconColor: AppTheme.accentRose,
                                    //     title: 'Switch to Agent Mode',
                                    //     value: viewModel.isAgentMode,
                                    //     onChanged: (val) {
                                    //       viewModel.toggleAgentMode(true);
                                    //       Navigator.pushNamedAndRemoveUntil(context, '/agent-dashboard', (route) => false);
                                    //     },
                                    //     isLast: false,
                                    //   ),
                                    _buildOptionTile(
                                      icon: Icons.phone_callback_rounded,
                                      iconColor: Colors.blueAccent,
                                      title: 'Call History',
                                      isLast: false,
                                      onTap: () {
                                        Navigator.pushNamed(context, '/call-history');
                                      },
                                    ),
                                    _buildOptionTile(
                                      icon: Icons.local_offer_rounded,
                                      iconColor: Colors.orangeAccent,
                                      title: 'Coins & Offers',
                                      isLast: false,
                                      onTap: () async {
                                        await Navigator.pushNamed(
                                          context,
                                          '/coin',
                                        );
                                        viewModel.fetchCoins();
                                      },
                                    ),
                                    _buildOptionTile(
                                      icon: Icons.verified_user_rounded,
                                      iconColor: Colors.tealAccent,
                                      title: 'Privacy Policy',
                                      isLast: false,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ContentDetailScreen(
                                                  type: 'privacy',
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildOptionTile(
                                      icon: Icons.description_rounded,
                                      iconColor: Colors.amberAccent,
                                      title: 'Terms and Conditions',
                                      isLast: false,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ContentDetailScreen(
                                                  type: 'terms',
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                  _buildOptionTile(
                                    icon: Icons.logout_rounded,
                                    iconColor: Colors.redAccent,
                                    title: 'Log Out',
                                    isLast: true,
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: Colors.transparent,
                                        barrierColor: Colors.black.withOpacity(0.6),
                                        builder: (context) => Container(
                                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                                          decoration: const BoxDecoration(
                                            color: AppTheme.surfaceCard,
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                                            border: Border(top: BorderSide(color: AppTheme.borderTranslucent)),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.textSecondary.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              const Text(
                                                'Log Out',
                                                style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              const Text(
                                                'Are you sure you want to log out from Heart Mate?',
                                                style: TextStyle(
                                                  color: AppTheme.textSecondary,
                                                  fontSize: 14,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 32),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      style: TextButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(16),
                                                          side: const BorderSide(color: AppTheme.borderTranslucent),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                          color: AppTheme.textSecondary,
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient: AppTheme.primaryGradient,
                                                        borderRadius: BorderRadius.circular(16),
                                                        boxShadow: AppTheme.glowShadow(AppTheme.accentRose),
                                                      ),
                                                      child: ElevatedButton(
                                                        onPressed: () async {
                                                          Navigator.pop(context);
                                                          final navigator = Navigator.of(context);
                                                          await viewModel.clearAgentSession();
                                                          await viewModel.logout();
                                                          navigator.pushReplacement(
                                                            MaterialPageRoute(
                                                              builder: (context) => const SignUpScreen(),
                                                            ),
                                                          );
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.transparent,
                                                          foregroundColor: Colors.white,
                                                          elevation: 0,
                                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(16),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'Log Out',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.only(left: 60.0),
                child: Divider(
                  color: AppTheme.borderTranslucent.withOpacity(0.5),
                  height: 1,
                  thickness: 0.8,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isLast,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 10.0,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: AppTheme.accentRose,
              ),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 60.0),
            child: Divider(
              color: AppTheme.borderTranslucent.withOpacity(0.5),
              height: 1,
              thickness: 0.8,
            ),
          ),
      ],
    );
  }
}
