import 'package:flutter/material.dart';
import 'package:dating_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:dating_app/screens/signup/view_model/signup_viewmodel.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String _selectedGender = 'Male';
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<SignUpViewModel>(context, listen: false);
    final user = viewModel.profile;
    final profile = user?.profile;

    _nameController = TextEditingController(text: profile?.name ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _ageController = TextEditingController(
      text: profile != null ? profile.age.toString() : '',
    );
    _phoneController = TextEditingController(text: profile?.phoneNumber ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');

    final gender = profile?.gender ?? 'male';
    _selectedGender = gender.toLowerCase() == 'female' ? 'Female' : 'Male';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundObsidian,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppTheme.textPrimary,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                      onPressed: () {
                        // Delete logic
                      },
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      // Profile Image with Premium Edit Badge
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            // Glowing Gradient Outer Ring
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppTheme.primaryGradient,
                                boxShadow: AppTheme.glowShadow(
                                  AppTheme.accentRose,
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppTheme.backgroundObsidian,
                                  shape: BoxShape.circle,
                                ),
                                child: const CircleAvatar(
                                  radius: 65,
                                  backgroundImage: AssetImage(
                                    'assets/images/boy.jpg',
                                  ),
                                ),
                              ),
                            ),
                            // Edit Icon Badge
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                height: 38,
                                width: 38,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.backgroundObsidian,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Username Field
                      _buildEditField(
                        label: 'USERNAME',
                        controller: _usernameController,
                        icon: Icons.alternate_email_rounded,
                      ),
                      const SizedBox(height: 24),

                      // Nick Name Field
                      _buildEditField(
                        label: 'NICK NAME',
                        controller: _nameController,
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 24),

                      // Email Field
                      _buildEditField(
                        label: 'EMAIL ADDRESS',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 24),

                      // Age Field
                      _buildEditField(
                        label: 'AGE',
                        controller: _ageController,
                        icon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),

                      // Phone Number Field
                      _buildEditField(
                        label: 'PHONE NUMBER',
                        controller: _phoneController,
                        icon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),

                      // About Me (Bio) Field
                      _buildEditField(
                        label: 'ABOUT ME',
                        controller: _bioController,
                        icon: Icons.chat_bubble_outline_outlined,
                      ),
                      const SizedBox(height: 24),

                      // Gender Selector Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                            child: Text(
                              'GENDER',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textSecondary,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Container(
                            height: 58,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.borderTranslucent,
                              ),
                              boxShadow: AppTheme.softCardShadow,
                            ),
                            child: Row(
                              children: [
                                // Male Button
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedGender = 'Male';
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      curve: Curves.easeInOut,
                                      decoration: BoxDecoration(
                                        gradient: _selectedGender == 'Male'
                                            ? AppTheme.callIndigoGradient
                                            : null,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.male_rounded,
                                            size: 18,
                                            color: _selectedGender == 'Male'
                                                ? Colors.white
                                                : AppTheme.textSecondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Male",
                                            style: TextStyle(
                                              fontSize: 14,
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
                                // Female Button
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedGender = 'Female';
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      curve: Curves.easeInOut,
                                      decoration: BoxDecoration(
                                        gradient: _selectedGender == 'Female'
                                            ? AppTheme.primaryGradient
                                            : null,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.female_rounded,
                                            size: 18,
                                            color: _selectedGender == 'Female'
                                                ? Colors.white
                                                : AppTheme.textSecondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Female",
                                            style: TextStyle(
                                              fontSize: 14,
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
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Save Changes Button
                      Consumer<SignUpViewModel>(
                        builder: (context, viewModel, child) {
                          return Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppTheme.glowShadow(
                                AppTheme.accentRose,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () async {
                                      final scaffoldMessenger =
                                          ScaffoldMessenger.of(context);
                                      final navigator = Navigator.of(context);
                                      final ageVal =
                                          int.tryParse(
                                            _ageController.text.trim(),
                                          ) ??
                                          0;
                                      final updatedData = {
                                        "username": _usernameController.text.trim(),
                                        "email": _emailController.text.trim(),
                                        "profile": {
                                          "name": _nameController.text.trim(),
                                          "age": ageVal,
                                          "gender": _selectedGender
                                              .toLowerCase(),
                                          "phone_number": _phoneController.text
                                              .trim(),
                                          "bio": _bioController.text.trim(),
                                        },
                                      };
                                      final success = await viewModel
                                          .updateProfile(updatedData);
                                      if (success) {
                                        if (mounted) {
                                          scaffoldMessenger.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Profile updated successfully!',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          navigator.pop();
                                        }
                                      } else {
                                        if (mounted) {
                                          scaffoldMessenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                viewModel.errorMessage ??
                                                    'Failed to update profile',
                                              ),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: viewModel.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderTranslucent),
            boxShadow: AppTheme.softCardShadow,
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(icon, color: AppTheme.textSecondary, size: 20),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 40),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppTheme.accentRose,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
