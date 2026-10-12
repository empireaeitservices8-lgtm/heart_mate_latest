import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_palette.dart';
import '../../../utils/routes.dart';
import '../../../widgets/app_button_widget.dart';
import '../../../widgets/app_custom_text_field.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_checkbox_widget.dart';
import '../view_model/auth_view_model.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: const _RegisterContent(),
    );
  }
}

class _RegisterContent extends StatefulWidget {
  const _RegisterContent();

  @override
  State<_RegisterContent> createState() => _RegisterContentState();
}

class _RegisterContentState extends State<_RegisterContent> {
  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: buildAppBar(title: 'Create Account'),
      backgroundColor: AppPalette.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enterprise Registration',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign up to manage devices, user licenses, and security',
                style: TextStyle(
                  fontSize: 14,
                  color: AppPalette.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 28),

              CustomTextField(
                label: 'Full Name',
                hint: 'Jane Doe',
                controller: viewModel.nameController,
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Email Address or Phone',
                hint: 'user@enterprise.com',
                controller: viewModel.phoneOrEmailController,
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Password',
                hint: 'At least 8 characters',
                controller: viewModel.passwordController,
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
              ),
              const SizedBox(height: 16),

              CustomCheckBoxWidget(
                value: _agreeToTerms,
                onChanged: (val) => setState(() => _agreeToTerms = val),
                label: 'I accept the Enterprise Terms & Conditions',
              ),
              const SizedBox(height: 28),

              AppButton(
                label: 'Create Account',
                isLoading: viewModel.isLoading,
                onPressed: !_agreeToTerms
                    ? null
                    : () async {
                        final success = await viewModel.login(context);
                        if (success && context.mounted) {
                          Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
