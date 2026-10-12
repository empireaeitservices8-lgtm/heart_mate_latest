import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dating_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:dating_app/screens/signup/view_model/signup_viewmodel.dart';
import 'package:dating_app/models/help_line.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SignUpViewModel>(context, listen: false).fetchHelpLine();
    });
  }

  void _launchWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '').replaceAll('+', '');
    final url = Uri.parse("https://wa.me/$cleanPhone");
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('WhatsApp launch error: $e');
    }
  }

  void _launchEmail(String email) async {
    final url = Uri.parse("mailto:$email");
    try {
      await launchUrl(url);
    } catch (e) {
      print('Email launch error: $e');
    }
  }

  void _launchCall(String phone) async {
    final url = Uri.parse("tel:$phone");
    try {
      await launchUrl(url);
    } catch (e) {
      print('Phone call launch error: $e');
    }
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
                      'Support',
                      style: TextStyle(
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
                    if (viewModel.isHelpLineLoading &&
                        viewModel.helpLine == null) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accentRose,
                        ),
                      );
                    }

                    // Fallback dummy data if API fails or returns null
                    final data =
                        viewModel.helpLine ??
                        HelpLine(
                          phone: "+1 800 555 0199",
                          email: "support@heartmate.app",
                          available: "24/7 Support Available",
                          address:
                              "100 Love Connection Blvd, Suite 500, San Francisco, CA 94103",
                        );

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'Online Support',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Available: ${data.available}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.accentRose,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),

                          // Main Illustration with soft glow backdrop
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.callGreen.withOpacity(0.08),
                                    blurRadius: 60,
                                    spreadRadius: 20,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.asset(
                                  'assets/images/support.jpg',
                                  height: 300,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Support details Card
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.borderTranslucent,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Email Tile
                                InkWell(
                                  onTap: () => _launchEmail(data.email),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.email_outlined,
                                          color: AppTheme.accentRose,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            data.email,
                                            style: const TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          color: AppTheme.textSecondary,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  color: AppTheme.borderTranslucent.withOpacity(
                                    0.5,
                                  ),
                                  height: 1,
                                ),
                                // Phone Call Tile
                                InkWell(
                                  onTap: () => _launchCall(data.phone),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.phone_outlined,
                                          color: Colors.blueAccent,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            data.phone,
                                            style: const TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          color: AppTheme.textSecondary,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  color: AppTheme.borderTranslucent.withOpacity(
                                    0.5,
                                  ),
                                  height: 1,
                                ),
                                // Address / Location Tile
                                InkWell(
                                  onTap: () async {
                                    final url = Uri.parse(
                                      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(data.address)}",
                                    );
                                    try {
                                      await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } catch (e) {
                                      print('Google Maps launch error: $e');
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          color: Colors.amberAccent,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            data.address,
                                            style: const TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          color: AppTheme.textSecondary,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // WhatsApp Contact Button
                          GestureDetector(
                            onTap: () => _launchWhatsApp(data.phone),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 30),
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF25D366),
                                    Color(0xFF075E54),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF25D366,
                                    ).withOpacity(0.25),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.whatsapp,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Direct helpline phone: ${data.phone}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Chat on WhatsApp',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
