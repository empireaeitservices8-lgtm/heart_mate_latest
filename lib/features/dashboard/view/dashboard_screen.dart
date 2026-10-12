import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../helpers/sp_helper.dart';
import '../../../utils/app_palette.dart';
import '../../../utils/extensions.dart';
import '../../../utils/routes.dart';
import '../../../widgets/app_progress_widget.dart';
import '../../../widgets/custom_app_bar.dart';
import '../view_model/dashboard_view_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(),
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    return Scaffold(
      backgroundColor: AppPalette.backgroundLight,
      appBar: buildAppBar(
        title: 'Enterprise Console',
        showBackButton: false,
        isGradientTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppPalette.textSecondaryLight),
            onPressed: () async {
              await SpHelper.clearSession();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppPalette.primaryRose,
        onRefresh: viewModel.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppPalette.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppPalette.primaryRose.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Control Center Active',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Manage enterprise devices, user groups, and security keys.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Metrics Grid
              const Text(
                'System Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),

              if (viewModel.isLoading && viewModel.counts == null)
                const Center(child: AppProgressWidget())
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Total Devices',
                        value: '${viewModel.counts?.totalDevices ?? 148}',
                        icon: Icons.devices_rounded,
                        color: AppPalette.callIndigo,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Active Now',
                        value: '${viewModel.counts?.activeDevices ?? 126}',
                        icon: Icons.wifi_tethering_rounded,
                        color: AppPalette.callGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Total Users',
                        value: '${viewModel.counts?.totalUsers ?? 84}',
                        icon: Icons.people_alt_rounded,
                        color: AppPalette.primaryViolet,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Device Groups',
                        value: '${viewModel.counts?.totalGroups ?? 12}',
                        icon: Icons.folder_shared_rounded,
                        color: AppPalette.primaryRose,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              // License Summary Card
              if (viewModel.license != null) ...[
                const Text(
                  'License Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppPalette.surfaceCardLight,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppPalette.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            viewModel.license!.licenseType,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppPalette.textPrimaryLight,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppPalette.callGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: AppPalette.callGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      LinearProgressIndicator(
                        value: viewModel.license!.utilizationPercentage,
                        backgroundColor: AppPalette.borderLight,
                        color: AppPalette.primaryRose,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${viewModel.license!.usedLicenses} of ${viewModel.license!.totalLicenses} licenses assigned',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppPalette.textSecondaryLight,
                            ),
                          ),
                          Text(
                            'Expires: ${viewModel.license!.expiryDate}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppPalette.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Quick Actions
              const Text(
                'Quick Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              _buildQuickActionTile(
                context,
                title: 'Manage Devices',
                subtitle: 'View, provision, and transfer device access',
                icon: Icons.devices_rounded,
                route: AppRoutes.devices,
              ),
              const SizedBox(height: 10),
              _buildQuickActionTile(
                context,
                title: 'Device Groups',
                subtitle: 'Organize fleet units by departments or sites',
                icon: Icons.folder_copy_rounded,
                route: AppRoutes.deviceGroups,
              ),
              const SizedBox(height: 10),
              _buildQuickActionTile(
                context,
                title: 'User Access Control',
                subtitle: 'Assign roles, permissions, and group access',
                icon: Icons.manage_accounts_rounded,
                route: AppRoutes.users,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surfaceCardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppPalette.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppPalette.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surfaceCardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.borderLight),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppPalette.primaryRose.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppPalette.primaryRose, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppPalette.textPrimaryLight,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppPalette.textSecondaryLight,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: AppPalette.textSecondaryLight,
        ),
        onTap: () => Navigator.of(context).pushNamed(route),
      ),
    );
  }
}
