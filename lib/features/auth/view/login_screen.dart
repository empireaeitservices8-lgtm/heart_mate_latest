import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_palette.dart';
import '../../../utils/routes.dart';
import '../../../widgets/app_button_widget.dart';
import '../../../widgets/app_custom_text_field.dart';
import '../../../widgets/custom_checkbox_widget.dart';
import '../view_model/auth_view_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: const _LoginContent(),
    );
  }
}

class _LoginContent extends StatelessWidget {
  const _LoginContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppPalette.backgroundLight,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppPalette.bgLightGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppPalette.primaryRose.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/heart_emblem.png',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) => AppPalette.primaryGradient.createShader(bounds),
                    child: const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    'Sign in to your enterprise console',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppPalette.textSecondaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Username / Email input
                CustomTextField(
                  label: 'Username or Email',
                  hint: 'admin@enterprise.com',
                  controller: viewModel.phoneOrEmailController,
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                ),
                const SizedBox(height: 18),

                // Password input
                CustomTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: viewModel.passwordController,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                ),
                const SizedBox(height: 12),

                // Remember Me & Forgot Password Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomCheckBoxWidget(
                      value: viewModel.rememberMe,
                      onChanged: viewModel.toggleRememberMe,
                      label: 'Remember me',
                    ),
                    TextButton(
                      onPressed: () => viewModel.requestOtp(context),
                      child: const Text(
                        'Sign in with OTP',
                        style: TextStyle(
                          color: AppPalette.primaryRose,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Primary Login Button
                AppButton(
                  label: 'Sign In',
                  isLoading: viewModel.isLoading,
                  onPressed: () => viewModel.login(context),
                ),
                const SizedBox(height: 16),

                // Register Navigation Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: AppPalette.textSecondaryLight,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.register),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: AppPalette.primaryRose,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
