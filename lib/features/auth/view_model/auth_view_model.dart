import 'package:flutter/material.dart';
import '../../../models/auth_models.dart';
import '../../../providers/view_model.dart';
import '../../../services/auth_api_service.dart';
import '../../../utils/routes.dart';

class AuthViewModel extends ViewModel {
  final AuthApiService _authService = AuthApiService();

  final TextEditingController phoneOrEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool _rememberMe = false;
  bool get rememberMe => _rememberMe;

  bool _isBiometricEnabled = false;
  bool get isBiometricEnabled => _isBiometricEnabled;

  AuthResponse? _authResponse;
  AuthResponse? get authResponse => _authResponse;

  void toggleRememberMe(bool val) {
    _rememberMe = val;
    notifyListeners();
  }

  void toggleBiometric(bool val) {
    _isBiometricEnabled = val;
    notifyListeners();
  }

  Future<bool> login(BuildContext context) async {
    final username = phoneOrEmailController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setError(null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your credentials')),
      );
      return false;
    }

    final result = await coverWithProgress(this, () async {
      final res = await _authService.login(
        LoginRequest(username: username, password: password),
      );
      if (res.isSuccess && res.data != null) {
        _authResponse = res.data;
        return true;
      }
      return false;
    });

    if (result == true && context.mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
      return true;
    }
    return false;
  }

  Future<bool> requestOtp(BuildContext context) async {
    final target = phoneOrEmailController.text.trim();
    if (target.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email or phone number')),
      );
      return false;
    }

    final success = await coverWithProgress(this, () async {
      final res = await _authService.requestOtp(RequestOtpRequest(phoneOrEmail: target));
      return res.isSuccess;
    });

    if (success == true && context.mounted) {
      Navigator.of(context).pushNamed(
        AppRoutes.otpVerification,
        arguments: target,
      );
      return true;
    }
    return false;
  }

  Future<bool> verifyOtp(BuildContext context, String phoneOrEmail) async {
    final otp = otpController.text.trim();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 4-6 digit OTP code')),
      );
      return false;
    }

    final result = await coverWithProgress(this, () async {
      final res = await _authService.verifyOtp(
        VerifyOtpRequest(phoneOrEmail: phoneOrEmail, otp: otp),
      );
      if (res.isSuccess && res.data != null) {
        _authResponse = res.data;
        return true;
      }
      return false;
    });

    if (result == true && context.mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    phoneOrEmailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    nameController.dispose();
    super.dispose();
  }
}
