import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_palette.dart';
import '../../../widgets/app_button_widget.dart';
import '../../../widgets/app_custom_text_field.dart';
import '../../../widgets/custom_app_bar.dart';
import '../view_model/auth_view_model.dart';

class OtpVerificationScreen extends StatelessWidget {
  final String phoneOrEmail;

  const OtpVerificationScreen({super.key, required this.phoneOrEmail});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: _OtpContent(phoneOrEmail: phoneOrEmail),
    );
  }
}

class _OtpContent extends StatelessWidget {
  final String phoneOrEmail;

  const _OtpContent({required this.phoneOrEmail});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: buildAppBar(title: 'Verify OTP'),
      backgroundColor: AppPalette.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppPalette.primaryRose.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  size: 48,
                  color: AppPalette.primaryRose,
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Enter Verification Code',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'We sent a 6-digit code to\n$phoneOrEmail',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppPalette.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              CustomTextField(
                label: 'OTP Code',
                hint: '1 2 3 4 5 6',
                controller: viewModel.otpController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.pin_rounded, size: 20),
              ),
              const SizedBox(height: 28),

              AppButton(
                label: 'Verify & Continue',
                isLoading: viewModel.isLoading,
                onPressed: () => viewModel.verifyOtp(context, phoneOrEmail),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive code? ",
                    style: TextStyle(
                      color: AppPalette.textSecondaryLight,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: () => viewModel.requestOtp(context),
                    child: const Text(
                      'Resend Code',
                      style: TextStyle(
                        color: AppPalette.primaryRose,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
