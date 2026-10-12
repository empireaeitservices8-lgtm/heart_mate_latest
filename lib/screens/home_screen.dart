import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dating_app/theme/app_theme.dart';
import 'package:dating_app/models/user_listing.dart';
import 'package:dating_app/models/call.dart';
import 'package:dating_app/screens/signup/view_model/signup_viewmodel.dart';
import 'package:dating_app/screens/call/view_model/call_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onTabSwitch;
  const HomeScreen({super.key, this.onTabSwitch});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<SignUpViewModel>(context, listen: false);
      viewModel.fetchUsers();
      viewModel.updateStatus("online", true);
      if (viewModel.isAgentMode) {
        viewModel.fetchAgentDashboard();
      }
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
          child: Stack(
            children: [
              Column(
                children: [
                  // Premium Custom Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo text with rose-to-violet gradient
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppTheme.primaryGradient.createShader(bounds),
                          child: const Text(
                            'Heart Mate',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                      ],
                    ),
                  ),
                  if (viewModel.isAgentMode)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.glowShadow(AppTheme.accentRose),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.support_agent_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Agent Dashboard Active',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // User Scrollable List
                  Expanded(
                    child: Consumer<SignUpViewModel>(
                      builder: (context, viewModel, child) {
                        if (viewModel.isAgentMode) {
                          return _buildAgentDashboardView(context, viewModel);
                        }
                        if (viewModel.isUsersLoading &&
                            viewModel.users.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.accentRose,
                            ),
                          );
                        } else if (viewModel.errorMessage != null &&
                            viewModel.users.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                'Error loading users: ${viewModel.errorMessage}',
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        } else if (viewModel.users.isEmpty) {
                          return const Center(
                            child: Text(
                              'No users found',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          );
                        }

                        final users = viewModel.users;

                        return RefreshIndicator(
                          color: AppTheme.accentRose,
                          onRefresh: () async {
                            await viewModel.fetchUsers();
                          },
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.fromLTRB(
                              20,
                              8,
                              20,
                              100, // Extra bottom padding to avoid overlap with bottom navigation actions
                            ),
                            itemCount: users.length,
                            itemBuilder: (context, index) =>
                                UserListTile(user: users[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Floating Bottom Action Bar
              if (!viewModel.isAgentMode)
                Positioned(
                  bottom: 24,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.glowShadow(AppTheme.callGreen),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/support');
                      },
                      child: Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          gradient: AppTheme.callGreenGradient,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgentDashboardView(
    BuildContext context,
    SignUpViewModel viewModel,
  ) {
    final stats = viewModel.agentDashboardData;
    final String talkDuration =
        stats?['talk_duration']?.toString() ?? '12h 45m';
    final String callsCompleted =
        stats?['calls_completed']?.toString() ?? '48 Calls';
    final String rating = stats?['rating']?.toString() ?? '4.9 ★';
    final String totalEarnings =
        stats?['total_earnings']?.toString() ??
        stats?['coins']?.toString() ??
        '${viewModel.coins}';

    final List<dynamic>? apiClients =
        stats?['waiting_clients'] as List<dynamic>? ??
        stats?['clients'] as List<dynamic>?;
    final List<Map<String, dynamic>> waitingClients =
        (apiClients != null && apiClients.isNotEmpty)
        ? apiClients.map((client) {
            final map = Map<String, dynamic>.from(client as Map);
            // Ensure avatar fallback if none provided
            if (map['avatar'] == null || map['avatar'].toString().isEmpty) {
              map['avatar'] = map['gender'] == 'male'
                  ? 'assets/images/boy.jpg'
                  : 'assets/images/girl.jpg';
            }
            // Ensure status/waiting text
            if (map['status'] == null) {
              map['status'] = 'Waiting since ${map['waiting_time'] ?? '1m'}';
            }
            return map;
          }).toList()
        : [
            {
              'id': 101,
              'name': 'Sophia',
              'age': 22,
              'gender': 'female',
              'status': 'Waiting since 1m',
              'avatar': 'assets/images/girl.jpg',
            },
            {
              'id': 102,
              'name': 'Chloe',
              'age': 20,
              'gender': 'female',
              'status': 'Waiting since 4m',
              'avatar': 'assets/images/girl.jpg',
            },
            {
              'id': 103,
              'name': 'Daniel',
              'age': 25,
              'gender': 'male',
              'status': 'Waiting since 7m',
              'avatar': 'assets/images/boy.jpg',
            },
            {
              'id': 104,
              'name': 'Emma',
              'age': 21,
              'gender': 'female',
              'status': 'Waiting since 11m',
              'avatar': 'assets/images/girl.jpg',
            },
          ];

    return RefreshIndicator(
      color: AppTheme.accentRose,
      onRefresh: () async {
        await viewModel.fetchCoins();
        await viewModel.fetchUsers();
        await viewModel.fetchAgentDashboard();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // Premium Stat Cards Grid (Hours online, completed calls, rating, earnings)
          const Text(
            "AGENT PERFORMANCE DASHBOARD",
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _buildStatCard(
                icon: Icons.access_time_rounded,
                iconColor: AppTheme.accentViolet,
                title: 'Talk Duration',
                value: talkDuration,
                subtitle: 'Online Today',
              ),
              _buildStatCard(
                icon: Icons.phone_callback_rounded,
                iconColor: AppTheme.callGreen,
                title: 'Calls Completed',
                value: callsCompleted.endsWith('Calls')
                    ? callsCompleted
                    : '$callsCompleted Calls',
                subtitle: '100% Success Rate',
              ),
              _buildStatCard(
                icon: Icons.monetization_on_rounded,
                iconColor: AppTheme.accentGold,
                title: 'Total Earnings',
                value: totalEarnings,
                subtitle: 'Earned Today',
              ),
              _buildStatCard(
                icon: Icons.star_rate_rounded,
                iconColor: Colors.orangeAccent,
                title: 'Agent Rating',
                value: rating.endsWith('★') ? rating : '$rating ★',
                subtitle: 'Excellent Feedback',
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Waiting Call Requests Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "INCOMING CALL QUEUE",
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE CALLS',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Waiting queue list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: waitingClients.length,
            itemBuilder: (context, index) {
              final client = waitingClients[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderTranslucent),
                  boxShadow: AppTheme.softCardShadow,
                ),
                child: Row(
                  children: [
                    // Client Photo
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundImage:
                            (client['avatar'].toString().startsWith('http') ||
                                client['avatar'].toString().startsWith('https'))
                            ? NetworkImage(client['avatar']) as ImageProvider
                            : AssetImage(client['avatar']) as ImageProvider,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Info details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${client['name']}, ${client['age']}',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                color: AppTheme.textSecondary,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                client['status'],
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Connect Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.callGreenGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.glowShadow(AppTheme.callGreen),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Show connecting loader dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: Card(
                                color: AppTheme.surfaceCard,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 32.0,
                                    vertical: 24.0,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        color: AppTheme.accentRose,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Connecting client call...',
                                        style: TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );

                          // Simulate API connection delay of 1.5 seconds
                          await Future.delayed(
                            const Duration(milliseconds: 1500),
                          );

                          if (context.mounted) {
                            Navigator.pop(context); // dismiss loader
                            Navigator.pushNamed(context, '/active-call');
                          }
                        },
                        icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                        label: const Text(
                          'Connect',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderTranslucent),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.8),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserListTile extends StatelessWidget {
  final UserListing user;

  const UserListTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isOnline = user.status.toLowerCase() == 'online';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderTranslucent),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Row(
        children: [
          // Profile & Online Status
          Column(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  // Circular Avatar Outer Border
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundObsidian,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: AppTheme.backgroundNavy,
                        backgroundImage: user.id % 2 == 0
                            ? AssetImage('assets/images/boy.jpg')
                            : AssetImage('assets/images/girl.jpg'),
                      ),
                    ),
                  ),
                  // Online Pill Badge
                  Positioned(
                    bottom: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF090D16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF1E293B),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? AppTheme.callGreen
                                  : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Rating Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.textPrimary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.textPrimary.withOpacity(0.08),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.star_rounded,
                      color: AppTheme.accentGold,
                      size: 14,
                    ),
                    SizedBox(width: 2),
                    Text(
                      "4.9",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Language Tags Chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRose.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.accentRose.withOpacity(0.12),
                    ),
                  ),
                  child: Text(
                    "English • Hindi",
                    style: TextStyle(
                      color: AppTheme.accentRose.withOpacity(0.85),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (user.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified_rounded,
                        color: AppTheme.accentRose,
                        size: 18,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                _buildRateInfo(
                  Icons.mic_none_rounded,
                  Colors.tealAccent,
                  "3 Coins/sec",
                ),
                const SizedBox(height: 6),
                _buildRateInfo(
                  Icons.videocam_outlined,
                  Colors.purpleAccent,
                  "20 Coins/sec",
                ),
              ],
            ),
          ),

          // Call Actions
          Column(
            children: [
              GestureDetector(
                onTap: () => _initiateCall(context, CallType.video),
                child: _buildCallButton(
                  icon: Icons.videocam_rounded,
                  gradient: AppTheme.callIndigoGradient,
                  glowColor: AppTheme.callIndigo,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _initiateCall(context, CallType.voice),
                child: _buildCallButton(
                  icon: Icons.call_rounded,
                  gradient: AppTheme.callGreenGradient,
                  glowColor: AppTheme.callGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _initiateCall(BuildContext context, CallType type) async {
    final signupVM = Provider.of<SignUpViewModel>(context, listen: false);
    final callVM = Provider.of<CallViewModel>(context, listen: false);

    final rate = callVM.getCoinsRate(type);
    final minCoins = rate * 15;

    if (signupVM.coins < minCoins) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
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
              const Icon(
                Icons.monetization_on_rounded,
                color: AppTheme.accentGold,
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                'Insufficient Coins',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You need at least $minCoins coins (15 seconds call) to connect with ${user.name}. Your current balance is ${signupVM.coins} coins.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(
                          color: AppTheme.borderTranslucent,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/coin');
                        },
                        child: const Text(
                          'Add Coins',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
      return;
    }

    // Navigate directly to the outgoing ringing screen without an intermediate loader dialog
    Navigator.pushNamed(context, '/outgoing-call');

    final dialed = await callVM.startCall(user, type, signupVM);
    if (!dialed && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not connect call. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildRateInfo(IconData icon, Color iconColor, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor.withOpacity(0.8)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required LinearGradient gradient,
    required Color glowColor,
  }) {
    return Container(
      height: 44,
      width: 48,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
