import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dating_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../view_model/signup_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/permission_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Toggle state between Login and Signup modes
  bool _isLoginMode = true; 

  String _selectedGender = 'Male'; // Default signup gender selection

  // Form Controllers
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SignUpViewModel>(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundObsidian,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.bgGradient,
            ),
          ),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    
                    // Logo Image
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentRose.withOpacity(0.18),
                              blurRadius: 36,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/heart_emblem.png',
                          height: 110,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Stylized HeartMate Logo Text
                    Center(
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                            child: const Text(
                              'HeartMate',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Find Your Perfect Match',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Social login actions (These are always displayed at the top)
                    _buildSocialButton(
                      icon: FontAwesomeIcons.google,
                      label: "Login with Google",
                      bgColor: Colors.white,
                      textColor: Colors.black87,
                      borderColor: AppTheme.borderTranslucent,
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        try {
                          final GoogleSignIn googleSignIn = GoogleSignIn(
                            scopes: ['email', 'profile'],
                          );
                          final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
                          if (googleUser == null) {
                            return;
                          }

                          final success = await viewModel.googleAuth(
                            googleId: googleUser.id,
                            email: googleUser.email,
                            name: googleUser.displayName ?? "User",
                          );

                          if (success) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Logged in successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            viewModel.fetchProfile();
                            viewModel.fetchCoins();
                            if (viewModel.isAgentMode) {
                              navigator.pushReplacementNamed('/agent-dashboard');
                            } else {
                              await PermissionService.requestAppPermissions();
                              navigator.pushReplacementNamed('/home');
                            }
                          } else {
                            if (viewModel.errorMessage != null) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(viewModel.errorMessage!),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          print('Google login error detail: $e');
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Google login failed: $e'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                    ),
                    /*
                    const SizedBox(height: 12),
                    _buildSocialButton(
                      icon: FontAwesomeIcons.phone,
                      label: "Login with Number",
                      bgColor: AppTheme.surfaceCard,
                      textColor: AppTheme.textPrimary,
                      borderColor: AppTheme.borderTranslucent,
                      onTap: () {},
                    ),
                    */
                    
                    // Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppTheme.textPrimary.withOpacity(0.1),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "OR USE EMAIL",
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppTheme.textPrimary.withOpacity(0.1),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Premium Custom Mode Switcher (Login vs Sign Up)
                    Container(
                      height: 52,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.textPrimary.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderTranslucent, width: 1),
                      ),
                      child: Row(
                        children: [
                          // Login Selection Option
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isLoginMode = true;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  gradient: _isLoginMode
                                      ? AppTheme.primaryGradient
                                      : null,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _isLoginMode
                                        ? Colors.white
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Sign Up Selection Option
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isLoginMode = false;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  gradient: !_isLoginMode
                                      ? AppTheme.primaryGradient
                                      : null,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: !_isLoginMode
                                        ? Colors.white
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Form Fields (Dynamic depending on selection)
                    if (_isLoginMode) ..._buildLoginForm() else ..._buildSignupForm(),

                    const SizedBox(height: 30),

                    // Primary Action Button (Login or Sign Up)
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.glowShadow(AppTheme.accentRose),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                final navigator = Navigator.of(context);
                                final messenger = ScaffoldMessenger.of(context);

                                if (_isLoginMode) {
                                  // Login Logic
                                  final username = _usernameController.text.trim();
                                  final password = _passwordController.text.trim();

                                  if (username.isEmpty || password.isEmpty) {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Please fill all fields'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return;
                                  }

                                  final success = await viewModel.login(
                                    username: username,
                                    password: password,
                                  );

                                  if (success) {
                                    if (mounted) {
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text('Logged in successfully!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      viewModel.fetchProfile();
                                      viewModel.fetchCoins();
                                      if (viewModel.isAgentMode) {
                                        navigator.pushReplacementNamed('/agent-dashboard');
                                      } else {
                                        await PermissionService.requestAppPermissions();
                                        navigator.pushReplacementNamed('/home');
                                      }
                                    }
                                  } else {
                                    if (mounted && viewModel.errorMessage != null) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(viewModel.errorMessage!),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  // Signup Logic
                                  final username = _usernameController.text.trim();
                                  final name = _nameController.text.trim();
                                  final email = _emailController.text.trim();
                                  final password = _passwordController.text.trim();
                                  final ageText = _ageController.text.trim();
                                  final phone = _phoneController.text.trim();
                                  final bio = _bioController.text.trim();

                                  if (username.isEmpty ||
                                      name.isEmpty ||
                                      email.isEmpty ||
                                      password.isEmpty ||
                                      ageText.isEmpty ||
                                      phone.isEmpty ||
                                      bio.isEmpty) {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Please fill all fields'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return;
                                  }

                                  final age = int.tryParse(ageText);
                                  if (age == null) {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter a valid age'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return;
                                  }

                                  final success = await viewModel.register(
                                    username: username,
                                    email: email,
                                    password: password,
                                    phoneNumber: phone,
                                    name: name,
                                    age: age,
                                    gender: _selectedGender,
                                    bio: bio,
                                  );

                                  if (success) {
                                    if (mounted) {
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text('Registered successfully!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      viewModel.fetchProfile();
                                      viewModel.fetchCoins();
                                      await PermissionService.requestAppPermissions();
                                      navigator.pushReplacementNamed('/home');
                                    }
                                  } else {
                                    if (mounted && viewModel.errorMessage != null) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(viewModel.errorMessage!),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                        child: viewModel.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                _isLoginMode ? "LOG IN" : "FINISH SIGNUP",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                      ),
                    ),
                    // const SizedBox(height: 16),
                    // // Demo Agent Login Shortcut
                    // Container(
                    //   decoration: BoxDecoration(
                    //     color: AppTheme.surfaceCard,
                    //     borderRadius: BorderRadius.circular(16),
                    //     border: Border.all(color: AppTheme.borderTranslucent),
                    //     boxShadow: AppTheme.softCardShadow,
                    //   ),
                    //   child: TextButton.icon(
                    //     style: TextButton.styleFrom(
                    //       minimumSize: const Size(double.infinity, 52),
                    //       foregroundColor: AppTheme.accentRose,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(16),
                    //       ),
                    //     ),
                    //     icon: const Icon(Icons.support_agent_rounded, size: 20),
                    //     label: const Text(
                    //       "LOGIN AS DEMO AGENT",
                    //       style: TextStyle(
                    //         fontSize: 14,
                    //         fontWeight: FontWeight.bold,
                    //         letterSpacing: 0.5,
                    //       ),
                    //     ),
                    //     onPressed: () async {
                    //       final messenger = ScaffoldMessenger.of(context);
                    //       final navigator = Navigator.of(context);
                          
                    //       // Mock login logic for agent
                    //       final prefs = await SharedPreferences.getInstance();
                    //       await prefs.setString('agent_status', 'approved');
                    //       await prefs.setBool('is_agent_mode', true);
                    //       await prefs.setString('auth_token', 'demo_agent_mock_token_1234');
                          
                    //       await viewModel.fetchProfile(); // reload profile & status
                    //       await viewModel.toggleAgentMode(true); // activates mode & loads details
                          
                    //       messenger.showSnackBar(
                    //         const SnackBar(
                    //           content: Text('Logged in as Demo Agent!'),
                    //           backgroundColor: AppTheme.callGreen,
                    //         ),
                    //       );
                    //       navigator.pushReplacementNamed('/agent-dashboard');
                    //     },
                    //   ),
                    // ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLoginForm() {
    return [
      _buildCustomTextField(
        hint: "Username",
        icon: Icons.alternate_email_rounded,
        controller: _usernameController,
      ),
      const SizedBox(height: 14),
      _buildCustomTextField(
        hint: "Password",
        icon: Icons.lock_outline_rounded,
        obscureText: true,
        controller: _passwordController,
      ),
    ];
  }

  List<Widget> _buildSignupForm() {
    return [
      _buildCustomTextField(
        hint: "Username",
        icon: Icons.alternate_email_rounded,
        controller: _usernameController,
      ),
      const SizedBox(height: 14),

      _buildCustomTextField(
        hint: "Full Name",
        icon: Icons.person_outline_rounded,
        controller: _nameController,
      ),
      const SizedBox(height: 14),

      _buildCustomTextField(
        hint: "Email Address",
        icon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        controller: _emailController,
      ),
      const SizedBox(height: 14),

      _buildCustomTextField(
        hint: "Password",
        icon: Icons.lock_outline_rounded,
        obscureText: true,
        controller: _passwordController,
      ),
      const SizedBox(height: 14),
      
      Row(
        children: [
          Expanded(
            child: _buildCustomTextField(
              hint: "Age",
              icon: Icons.calendar_today_rounded,
              keyboardType: TextInputType.number,
              controller: _ageController,
            ),
          ),
          const SizedBox(width: 14),
          // Premium Inline Gender Selector
          Expanded(
            child: Container(
              height: 56,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.textPrimary.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderTranslucent, width: 1),
              ),
              child: Row(
                children: [
                  // Male Selection Option
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGender = 'Male';
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          gradient: _selectedGender == 'Male'
                              ? AppTheme.callIndigoGradient
                              : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.male_rounded,
                              size: 16,
                              color: _selectedGender == 'Male'
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Male",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _selectedGender == 'Male'
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Female Selection Option
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGender = 'Female';
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          gradient: _selectedGender == 'Female'
                              ? AppTheme.primaryGradient
                              : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.female_rounded,
                              size: 16,
                              color: _selectedGender == 'Female'
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Female",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _selectedGender == 'Female'
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      
      _buildCustomTextField(
        hint: "Phone Number",
        icon: Icons.phone_android_rounded,
        keyboardType: TextInputType.phone,
        controller: _phoneController,
      ),
      const SizedBox(height: 14),

      _buildCustomTextField(
        hint: "Bio (e.g. Love to travel!)",
        icon: Icons.chat_bubble_outline_rounded,
        controller: _bioController,
      ),
    ];
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: textColor, size: 18),
      label: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: 0.2,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        minimumSize: const Size(double.infinity, 52),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: borderColor != null
              ? BorderSide(color: borderColor, width: 1)
              : BorderSide.none,
        ),
      ),
      onPressed: onTap,
    );
  }

  Widget _buildCustomTextField({
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextEditingController? controller,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Icon(icon, color: AppTheme.textSecondary, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
        ),
        filled: true,
        fillColor: AppTheme.textPrimary.withOpacity(0.03),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.borderTranslucent, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.accentRose, width: 1.5),
        ),
      ),
    );
  }
}
