import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';
import '../view_model/signup_viewmodel.dart';
import '../../../core/services/permission_service.dart';
import '../../../helpers/sp_helper.dart';

class GoogleAuthContinueScreen extends StatefulWidget {
  const GoogleAuthContinueScreen({super.key});

  @override
  State<GoogleAuthContinueScreen> createState() =>
      _GoogleAuthContinueScreenState();
}

class _GoogleAuthContinueScreenState extends State<GoogleAuthContinueScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Future<void> _handleGoogleSignIn(
    BuildContext context,
    SignUpViewModel viewModel,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Sign in was cancelled by user
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In cancelled. Please try again.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
        return;
      }

      final String googleId = googleUser.id;
      final String email = googleUser.email;
      final String displayName = googleUser.displayName ?? "User";

      final success = await viewModel.googleAuth(
        googleId: googleId,
        email: email,
        name: displayName,
      );

      if (success) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Authenticated successfully! Welcome to HeartMate.'),
            backgroundColor: Colors.green,
          ),
        );
        viewModel.fetchProfile();
        viewModel.fetchCoins();
        final isAgent = await SpHelper.getIsAgent() || viewModel.isAgentMode;
        if (isAgent) {
          navigator.pushReplacementNamed('/agent-dashboard');
        } else {
          await PermissionService.requestAppPermissions();
          navigator.pushReplacementNamed('/home');
        }
      } else {
        if (viewModel.errorMessage != null) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage!),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      print('Google Sign-In failed error: $e');

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SignUpViewModel>(context);

    return PopScope(
      canPop: false, // Prevent returning to the signup flow
      child: Scaffold(
        backgroundColor: AppTheme.backgroundObsidian,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 28.0,
                vertical: 24.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Success Glowing Icon
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                      boxShadow: AppTheme.glowShadow(AppTheme.accentRose),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppTheme.backgroundObsidian,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppTheme.accentRose,
                        size: 64,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Success Titles
                  const Text(
                    'Success!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your account has been created successfully!',
                    style: TextStyle(
                      color: AppTheme.textPrimary.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please verify your identity with Google to unlock access to HeartMate.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // Continue with Google Button
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: viewModel.isLoading
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: viewModel.isLoading
                          ? null
                          : () => _handleGoogleSignIn(context, viewModel),
                      icon: viewModel.isLoading
                          ? const SizedBox.shrink()
                          : const FaIcon(
                              FontAwesomeIcons.google,
                              color: Colors.black87,
                              size: 18,
                            ),
                      label: viewModel.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black54,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Continue with Google',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        disabledBackgroundColor: Colors.white.withOpacity(0.7),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
