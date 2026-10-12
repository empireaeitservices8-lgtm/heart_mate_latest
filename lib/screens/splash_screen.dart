import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'signup/view_model/signup_viewmodel.dart';
import 'call/view_model/call_viewmodel.dart';
import '../models/call.dart';
import '../core/services/storage_service.dart';
import '../core/services/permission_service.dart';

import '../helpers/sp_helper.dart';

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
    Timer(const Duration(seconds: 3), () async {
      final storageService = StorageService();
      final loggedIn = await storageService.isLoggedIn() || await SpHelper.getIsLoggedIn();
      final token = await SpHelper.getToken() ?? await storageService.getToken();
      final isAuth = loggedIn || (token != null && token.isNotEmpty);
      if (!mounted) return;

      if (isAuth) {
        // Pre-fetch profile and coins to ensure state is hydrated on home screen
        final viewModel = Provider.of<SignUpViewModel>(context, listen: false);
        await viewModel.fetchProfile();
        viewModel.fetchCoins();

        // Request permissions before entering Home screen
        await PermissionService.requestAppPermissions();
        if (!mounted) return;

        // Do not navigate to /home if an incoming or active call is in progress
        final callVM = Provider.of<CallViewModel>(context, listen: false);
        if (callVM.status != CallStatus.idle) {
          print('[SplashScreen] Call is already in progress (${callVM.status}). Preserving call screen.');
          return;
        }

        // Check whether the logged-in user is an agent (true or false)
        final bool isAgent = viewModel.profile != null
            ? viewModel.profile!.isAgent
            : (await SpHelper.getIsAgent());

        print('[SplashScreen] isAgent: $isAgent (profile isAgent: ${viewModel.profile?.isAgent}, isAgentMode: ${viewModel.isAgentMode})');

        if (isAgent) {
          Navigator.pushReplacementNamed(context, '/agent-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/signup');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo image
              Image.asset(
                'assets/images/heart.png',
                width: 280,
                height: 280,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),

              // Premium Progress Indicator
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Color(0xFFEC4899),
                  strokeWidth: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
