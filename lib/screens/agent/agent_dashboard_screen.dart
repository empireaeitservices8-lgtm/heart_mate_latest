import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../signup/view_model/signup_viewmodel.dart';
import '../home_screen.dart';
import '../profile.screen.dart';
import 'agent_wallet_screen.dart';
import '../../core/services/permission_service.dart';

class AgentDashboardScreen extends StatefulWidget {
  const AgentDashboardScreen({super.key});

  @override
  State<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends State<AgentDashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionService.requestAppPermissions();
      final viewModel = Provider.of<SignUpViewModel>(context, listen: false);
      viewModel.fetchProfile();
      viewModel.fetchAgentDashboard();
      viewModel.fetchCoins();
      viewModel.fetchWithdrawals();
      viewModel.updateStatus("online", true);
    });

    _screens = [
      HomeScreen(
        onTabSwitch: (index) {
          setState(() {
            _currentIndex = index;
          });
          _refreshTab(index);
        },
      ),
      const AgentWalletScreen(),
      const MyProfileScreen(isEmbedded: true),
    ];
  }

  void _refreshTab(int index) {
    final viewModel = Provider.of<SignUpViewModel>(context, listen: false);
    if (index == 0) {
      viewModel.fetchAgentDashboard();
      viewModel.fetchCoins();
    } else if (index == 1) {
      viewModel.fetchCoins();
      viewModel.fetchWithdrawals();
      viewModel.fetchTransactions();
      viewModel.fetchAgentDashboard();
    } else if (index == 2) {
      viewModel.fetchProfile();
      viewModel.fetchCoins();
    }
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label, {
    required double extraTop,
    required double barHeight,
    required double totalHeight,
  }) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
            });
            _refreshTab(index);
          }
        },
        child: SizedBox(
          height: totalHeight,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                top: isSelected ? 0 : extraTop + 8,
                child: AnimatedScale(
                  scale: isSelected ? 1.12 : 1.0,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    padding: EdgeInsets.all(isSelected ? 11 : 8),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppTheme.primaryGradient : null,
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.accentRose.withOpacity(0.38),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: extraTop + barHeight - 18,
                child: AnimatedOpacity(
                  opacity: isSelected ? 1.0 : 0.7,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isSelected ? AppTheme.accentRose : AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    child: Text(label),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomNavBar() {
    final viewBottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    final paddingBottom = MediaQuery.paddingOf(context).bottom;
    final double systemBottomInset = viewBottomPadding > 0 ? viewBottomPadding : paddingBottom;
    final double bottomPadding = systemBottomInset > 0 ? systemBottomInset : 8.0;

    const double extraTop = 20.0;
    const double barHeight = 62.0;
    final double totalHeight = extraTop + barHeight + bottomPadding;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: extraTop,
            left: 0,
            right: 0,
            bottom: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: _currentIndex.toDouble(),
                end: _currentIndex.toDouble(),
              ),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              builder: (context, animValue, child) {
                return CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, barHeight + bottomPadding),
                  painter: _AgentNotchedNavBarPainter(
                    activeIndex: animValue,
                    totalTabs: 3,
                    color: AppTheme.surfaceCard,
                    borderColor: AppTheme.borderTranslucent,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNavItem(
                  0,
                  Icons.dashboard_rounded,
                  'Dashboard',
                  extraTop: extraTop,
                  barHeight: barHeight,
                  totalHeight: totalHeight,
                ),
                _buildNavItem(
                  1,
                  Icons.account_balance_wallet_rounded,
                  'Wallet',
                  extraTop: extraTop,
                  barHeight: barHeight,
                  totalHeight: totalHeight,
                ),
                _buildNavItem(
                  2,
                  Icons.person_rounded,
                  'Profile',
                  extraTop: extraTop,
                  barHeight: barHeight,
                  totalHeight: totalHeight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundObsidian,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }
}

class _AgentNotchedNavBarPainter extends CustomPainter {
  final double activeIndex;
  final int totalTabs;
  final Color color;
  final Color borderColor;

  _AgentNotchedNavBarPainter({
    required this.activeIndex,
    required this.totalTabs,
    required this.color,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final width = size.width;
    final height = size.height;
    final tabWidth = width / totalTabs;

    final centerX = activeIndex * tabWidth + tabWidth / 2;
    const notchWidth = 85.0;
    const notchHeight = 28.0;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(centerX - notchWidth / 2, 0);
    path.cubicTo(
      centerX - notchWidth / 3,
      0,
      centerX - notchWidth / 4,
      notchHeight,
      centerX,
      notchHeight,
    );
    path.cubicTo(
      centerX + notchWidth / 4,
      notchHeight,
      centerX + notchWidth / 3,
      0,
      centerX + notchWidth / 2,
      0,
    );
    path.lineTo(width, 0);
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    canvas.drawShadow(
      path.shift(const Offset(0, -2)),
      Colors.black.withOpacity(0.04),
      8,
      true,
    );

    canvas.drawPath(path, paint);

    final borderPath = Path()
      ..moveTo(0, 0)
      ..lineTo(centerX - notchWidth / 2, 0)
      ..cubicTo(
        centerX - notchWidth / 3,
        0,
        centerX - notchWidth / 4,
        notchHeight,
        centerX,
        notchHeight,
      )
      ..cubicTo(
        centerX + notchWidth / 4,
        notchHeight,
        centerX + notchWidth / 3,
        0,
        centerX + notchWidth / 2,
        0,
      )
      ..lineTo(width, 0);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _AgentNotchedNavBarPainter oldDelegate) {
    return oldDelegate.activeIndex != activeIndex ||
        oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor;
  }
}
