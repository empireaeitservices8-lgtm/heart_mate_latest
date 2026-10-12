import 'package:flutter/material.dart';
import '../../../models/user_models.dart';
import '../../../services/user_api_service.dart';
import '../../../utils/app_palette.dart';
import '../../../widgets/app_button_widget.dart';
import '../../../widgets/app_custom_text_field.dart';
import '../../../widgets/custom_app_bar.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _service = UserApiService();

  String _selectedRole = 'Operator';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide name and email')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await _service.addUser(
      AddUserRequest(
        name: name,
        email: email,
        phone: phone,
        role: _selectedRole,
      ),
    );
    setState(() => _isLoading = false);

    if (res.isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User registered successfully!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.backgroundLight,
      appBar: buildAppBar(title: 'Add User'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Member Profile & Role',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Invite or assign operator permissions to this enterprise pool',
                style: TextStyle(fontSize: 13, color: AppPalette.textSecondaryLight),
              ),
              const SizedBox(height: 24),

              CustomTextField(
                label: 'Full Name',
                hint: 'e.g. Alex Rivera',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Email Address',
                hint: 'alex.r@enterprise.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Phone Number (Optional)',
                hint: '+1 (555) 000-0000',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              ),
              const SizedBox(height: 16),

              const Text(
                'System Role',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppPalette.backgroundLightAlt,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppPalette.borderLight),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'Administrator', child: Text('Administrator')),
                      DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                      DropdownMenuItem(value: 'Engineer', child: Text('Engineer')),
                      DropdownMenuItem(value: 'Operator', child: Text('Operator')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRole = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 36),

              AppButton(
                label: 'Add & Send Invitation',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
