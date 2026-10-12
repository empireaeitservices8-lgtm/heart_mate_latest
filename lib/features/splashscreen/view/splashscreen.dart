import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_palette.dart';
import '../../../widgets/app_progress_widget.dart';
import '../view_model/splash_view_model.dart';

class FeatureSplashScreen extends StatelessWidget {
  const FeatureSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SplashViewModel(),
      child: const _SplashScreenBody(),
    );
  }
}

class _SplashScreenBody extends StatefulWidget {
  const _SplashScreenBody();

  @override
  State<_SplashScreenBody> createState() => _SplashScreenBodyState();
}

class _SplashScreenBodyState extends State<_SplashScreenBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<SplashViewModel>(context, listen: false);
      viewModel.checkAuthStatus().then((_) {
        if (mounted && viewModel.isInitialized) {
          Navigator.of(context).pushReplacementNamed(viewModel.targetRoute);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.backgroundLight,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppPalette.bgLightGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glowing Emblem Logo
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppPalette.primaryRose.withOpacity(0.2),
                      blurRadius: 36,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/heart_emblem.png',
                  width: 130,
                  height: 130,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 18),

              // Gradient Brand Title
              ShaderMask(
                shaderCallback: (bounds) => AppPalette.primaryGradient.createShader(bounds),
                child: const Text(
                  'HeartMate',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              const Text(
                'Enterprise Device & Fleet Management',
                style: TextStyle(
                  color: AppPalette.textSecondaryLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 44),

              // Progress Indicator
              const AppProgressWidget(size: 26, strokeWidth: 2.5),
            ],
          ),
        ),
      ),
    );
  }
}
