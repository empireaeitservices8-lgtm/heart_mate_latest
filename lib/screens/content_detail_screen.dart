import 'package:flutter/material.dart';
import 'package:dating_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:dating_app/screens/signup/view_model/signup_viewmodel.dart';
import 'package:dating_app/models/content_item.dart';

class ContentDetailScreen extends StatefulWidget {
  final String type; // 'terms' or 'privacy'

  const ContentDetailScreen({super.key, required this.type});

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<SignUpViewModel>(context, listen: false);
      if (widget.type == 'terms') {
        viewModel.fetchTerms();
      } else {
        viewModel.fetchPrivacy();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == 'terms' ? 'Terms & Conditions' : 'Privacy Policy';

    return Scaffold(
      backgroundColor: AppTheme.backgroundObsidian,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer to balance header
                  ],
                ),
              ),

              Expanded(
                child: Consumer<SignUpViewModel>(
                  builder: (context, viewModel, child) {
                    final isTerms = widget.type == 'terms';
                    final isLoading = isTerms ? viewModel.isTermsLoading : viewModel.isPrivacyLoading;

                    // Fallback dummy data if API fails or returns null
                    final defaultContent = isTerms
                        ? ContentItem(
                            title: 'Terms & Conditions',
                            content: 'Welcome to Heartmate. By using our application, you agree to comply with and be bound by the following terms and conditions of use. Please review these terms carefully.\n\n'
                                '1. Acceptance of Agreement\n'
                                'You agree to the terms and conditions outlined in this Terms of Use Agreement with respect to our application. This Agreement constitutes the entire and only agreement between us and you.\n\n'
                                '2. Use of Services\n'
                                'You must be at least 18 years of age to use this application. You agree to use the application for personal, non-commercial purposes only and to provide accurate and truthful profile information.\n\n'
                                '3. Privacy Policy\n'
                                'Your privacy is important to us. Please refer to our Privacy Policy, which is incorporated into these terms by reference, to understand how we collect and use your personal information.\n\n'
                                '4. User Conduct\n'
                                'You agree not to harass, abuse, stalk, or harm another user of the application. Any violation of user conduct guidelines may result in immediate suspension or termination of your account.\n\n'
                                '5. Limitation of Liability\n'
                                'Heartmate and its affiliates shall not be liable for any direct, indirect, incidental, special, or consequential damages arising out of the use of or inability to use the services.\n\n'
                                '6. Modifications to Terms\n'
                                'We reserve the right to modify these terms at any time without prior notice. Continued use of the application after changes constitute acceptance of the updated terms.',
                          )
                        : ContentItem(
                            title: 'Privacy Policy',
                            content: 'At Heartmate, we are committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.\n\n'
                                '1. Information We Collect\n'
                                'We collect information you provide directly to us when you create an account, complete your profile, or communicate with other users. This includes your name, email address, gender, profile images, and messaging logs.\n\n'
                                '2. How We Use Your Information\n'
                                'We use the collected information to operate, maintain, and improve our services, facilitate user communication, personalize your experience, and protect the security of our platform.\n\n'
                                '3. Sharing of Information\n'
                                'We do not sell or rent your personal information to third parties. We may share information with trusted service providers who assist us, or when required by law to protect our rights and the safety of our users.\n\n'
                                '4. Data Security\n'
                                'We implement industry-standard administrative, technical, and physical security measures designed to protect your personal data from unauthorized access, loss, or alteration.\n\n'
                                '5. Your Data Rights\n'
                                'Depending on your location, you may have the right to access, correct, delete, or limit the use of the personal information you have shared with us. Please contact our support helpline to exercise these rights.\n\n'
                                '6. Changes to This Policy\n'
                                'We may update our Privacy Policy from time to time. Any changes will be posted on this page with an updated revision date.',
                          );

                    final data = (isTerms ? viewModel.termsContent : viewModel.privacyContent) ?? defaultContent;

                    if (isLoading && (isTerms ? viewModel.termsContent : viewModel.privacyContent) == null) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppTheme.accentRose),
                      );
                    }

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24.0),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppTheme.borderTranslucent),
                          boxShadow: AppTheme.softCardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.title,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              data.content,
                              style: TextStyle(
                                color: AppTheme.textPrimary.withOpacity(0.7),
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
