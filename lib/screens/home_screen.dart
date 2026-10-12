import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dating_app/theme/app_theme.dart';
import 'package:dating_app/models/user_listing.dart';
import 'package:dating_app/models/call.dart';
import 'package:dating_app/models/agent_dashboard_model.dart';
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
      viewModel.updateStatus("online", true);
      if (viewModel.isAgentMode) {
        viewModel.fetchAgentDashboard();
        viewModel.fetchCoins();
        viewModel.fetchWithdrawals();
      } else {
        viewModel.fetchAgents();
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
                              'No agents available at the moment',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          );
                        }

                        final users = viewModel.users;

                        return RefreshIndicator(
                          color: AppTheme.accentRose,
                          onRefresh: () async {
                            await viewModel.fetchAgents();
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
    final model = viewModel.agentDashboardModel;
    final agent = model?.agent;
    final tasks = model?.tasks;

    final stats = viewModel.agentDashboardData;
    final rawAgent = (stats?['agent'] is Map)
        ? (stats!['agent'] as Map<String, dynamic>)
        : stats;

    final String todayTalkDuration = agent?.todayDurationFormatted ??
        rawAgent?['today_duration_formatted']?.toString() ??
        rawAgent?['talk_duration']?.toString() ??
        '0h 0m';
    final String totalTalkDuration = agent?.totalDurationFormatted ??
        rawAgent?['total_duration_formatted']?.toString() ??
        '0h 0m';

    final int callsCompletedCount = agent?.callsCompleted ??
        (rawAgent?['calls_completed'] as num?)?.toInt() ??
        0;

    final double ratingVal = agent?.agentRating ??
        (rawAgent?['agent_rating'] as num?)?.toDouble() ??
        (rawAgent?['rating'] as num?)?.toDouble() ??
        4.9;

    final num totalEarningsVal = agent?.totalEarnings ??
        (rawAgent?['total_earnings'] as num?) ??
        (rawAgent?['coins_earned'] as num?) ??
        viewModel.coins;

    final num todayEarningsVal = agent?.todayEarnings ??
        (rawAgent?['today_earnings'] as num?) ??
        0;

    final num successRateVal = agent?.successRate ??
        (rawAgent?['success_rate'] as num?) ??
        100;

    final int walletBalanceVal = agent?.walletBalance ??
        (rawAgent?['wallet_balance'] as num?)?.toInt() ??
        viewModel.coins;

    final int coinsEarnedVal = agent?.coinsEarned ??
        (rawAgent?['coins_earned'] as num?)?.toInt() ??
        viewModel.coins;

    final isOnline = viewModel.profile?.isOnline ?? true;

    return RefreshIndicator(
      color: AppTheme.accentRose,
      onRefresh: () async {
        await viewModel.fetchCoins();
        await viewModel.fetchWithdrawals();
        await viewModel.fetchAgentDashboard();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // 1. Agent Availability & Call Readiness Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isOnline ? AppTheme.callGreen.withOpacity(0.4) : AppTheme.borderTranslucent,
              ),
              boxShadow: [
                if (isOnline)
                  BoxShadow(
                    color: AppTheme.callGreen.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  )
                else
                  ...AppTheme.softCardShadow,
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOnline ? AppTheme.callGreen : AppTheme.textSecondary,
                            boxShadow: isOnline
                                ? [
                                    BoxShadow(
                                      color: AppTheme.callGreen.withOpacity(0.6),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOnline ? 'Online & Ready' : 'Currently Offline',
                              style: TextStyle(
                                color: isOnline ? AppTheme.callGreen : AppTheme.textSecondary,
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isOnline ? 'Accepting audio & video calls' : 'Turn on to receive calls',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: isOnline,
                      activeColor: AppTheme.callGreen,
                      onChanged: (val) {
                        viewModel.toggleOnlineStatus();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundObsidian.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppTheme.textSecondary, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Keep HeartMate open in the background to never miss incoming user calls.',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Earnings Banner with Direct Withdraw CTA
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentRose.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL COIN BALANCE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₹$walletBalanceVal.00',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '($coinsEarnedVal Coins Earned)',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (widget.onTabSwitch != null) {
                      widget.onTabSwitch!(1); // Switch to Wallet tab
                    } else {
                      Navigator.pushNamed(context, '/agent-wallet');
                    }
                  },
                  icon: const Icon(Icons.arrow_upward_rounded, size: 15),
                  label: const Text(
                    'Withdraw',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Performance Metrics Header
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
                value: todayTalkDuration,
                subtitle: 'Total: $totalTalkDuration',
              ),
              _buildStatCard(
                icon: Icons.phone_callback_rounded,
                iconColor: AppTheme.callGreen,
                title: 'Calls Completed',
                value: '$callsCompletedCount Calls',
                subtitle: '$successRateVal% Success Rate',
              ),
              _buildStatCard(
                icon: Icons.monetization_on_rounded,
                iconColor: AppTheme.accentGold,
                title: 'Total Earnings',
                value: '₹$totalEarningsVal',
                subtitle: 'Today: ₹$todayEarningsVal',
              ),
              _buildStatCard(
                icon: Icons.star_rate_rounded,
                iconColor: Colors.orangeAccent,
                title: 'Agent Rating',
                value: '$ratingVal ★',
                subtitle: 'Excellent Feedback',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4. Agent Tasks & Milestone Goals
          if (tasks != null) ...[
            const Text(
              "CALL TARGETS & GOALS",
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.borderTranslucent),
                boxShadow: AppTheme.softCardShadow,
              ),
              child: Column(
                children: [
                  _buildTaskProgressItem(
                    label: 'Daily Target',
                    completed: tasks.daily.completed,
                    target: tasks.daily.target,
                    percentage: tasks.daily.progressPercentage,
                    color: AppTheme.accentViolet,
                  ),
                  const SizedBox(height: 14),
                  _buildTaskProgressItem(
                    label: 'Weekly Target',
                    completed: tasks.weekly.completed,
                    target: tasks.weekly.target,
                    percentage: tasks.weekly.progressPercentage,
                    color: AppTheme.accentRose,
                  ),
                  const SizedBox(height: 14),
                  _buildTaskProgressItem(
                    label: 'Monthly Milestone',
                    completed: tasks.monthly.completed,
                    target: tasks.monthly.target,
                    percentage: tasks.monthly.progressPercentage,
                    color: AppTheme.callGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 4. Quick Agent Shortcuts
          const Text(
            "AGENT ACTIONS & SHORTCUTS",
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: AppTheme.accentRose,
                  title: 'Wallet & Payouts',
                  subtitle: 'Request money',
                  onTap: () {
                    if (widget.onTabSwitch != null) {
                      widget.onTabSwitch!(1);
                    } else {
                      Navigator.pushNamed(context, '/agent-wallet');
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  icon: Icons.phone_in_talk_rounded,
                  iconColor: Colors.lightBlueAccent,
                  title: 'Call History',
                  subtitle: 'View past calls',
                  onTap: () {
                    Navigator.pushNamed(context, '/call-history');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildTaskProgressItem({
    required String label,
    required int completed,
    required int target,
    required num percentage,
    required Color color,
  }) {
    final double progress = (target > 0 ? (completed / target) : 0.0).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$completed / $target calls (${percentage.toStringAsFixed(0)}%)',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppTheme.borderTranslucent,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderTranslucent),
          boxShadow: AppTheme.softCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
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
    final isOnCall = user.isOnCall ||
        user.status.toLowerCase() == 'on call' ||
        user.status.toLowerCase() == 'on_call';
    final isOnline = !isOnCall &&
        (user.isOnline || user.status.toLowerCase() == 'online');

    final Color statusColor = isOnCall
        ? AppTheme.accentGold
        : (isOnline ? AppTheme.callGreen : Colors.grey);
    final String statusText = isOnCall ? 'ON CALL' : (isOnline ? 'ONLINE' : 'OFFLINE');

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
                  // Online / On-Call Pill Badge
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
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
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
    final isOnCall = user.isOnCall ||
        user.status.toLowerCase() == 'on call' ||
        user.status.toLowerCase() == 'on_call';

    if (isOnCall) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} is currently on another call. Please try again soon.'),
          backgroundColor: Colors.amber.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

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
