import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/call.dart';
import '../../signup/view_model/signup_viewmodel.dart';
import '../view_model/call_viewmodel.dart';
import 'package:audioplayers/audioplayers.dart';

class OutgoingCallScreen extends StatefulWidget {
  const OutgoingCallScreen({super.key});

  @override
  State<OutgoingCallScreen> createState() => _OutgoingCallScreenState();
}

class _OutgoingCallScreenState extends State<OutgoingCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  AudioPlayer? _audioPlayer;
  late CallViewModel _callVM;
  CallSession? _cachedSession;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _callVM = Provider.of<CallViewModel>(context, listen: false);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));
    _playRingtone();
  }

  Future<void> _playRingtone() async {
    try {
      _audioPlayer = AudioPlayer();
      // Set source first to initialize the player streams and prevent 'Bad state: No element'
      await _audioPlayer!.setSource(
        UrlSource(
          'https://assets.mixkit.co/active_storage/sfx/1359/1359-84.wav',
        ),
      );
      await _audioPlayer!.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer!.resume();
    } catch (e) {
      print('Error playing outgoing ringtone: $e');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    try {
      _audioPlayer?.stop();
      _audioPlayer?.dispose();
    } catch (e) {
      print('Error disposing audio player: $e');
    }
    if (_callVM.status == CallStatus.cancelled ||
        _callVM.status == CallStatus.rejected ||
        _callVM.status == CallStatus.ended) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _callVM.resetToIdle();
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callVM = Provider.of<CallViewModel>(context);
    final signupVM = Provider.of<SignUpViewModel>(context, listen: false);
    final session = callVM.currentSession;
    if (session != null) {
      _cachedSession = session;
    }
    final displaySession = session ?? _cachedSession;

    // Handle routing state transitions with single-execution guard
    if (!_hasNavigated) {
      if (callVM.status == CallStatus.connected) {
        _hasNavigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/active-call');
          }
        });
      } else if (callVM.status == CallStatus.idle ||
          callVM.status == CallStatus.cancelled ||
          callVM.status == CallStatus.rejected ||
          callVM.status == CallStatus.ended) {
        _hasNavigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          }
        });
      }
    }

    if (displaySession == null) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundObsidian,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.accentRose),
        ),
      );
    }

    final String avatarAsset = displaySession.contact.id % 2 == 0
        ? 'assets/images/boy.jpg'
        : 'assets/images/girl.jpg';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background blurred avatar image
          Image.asset(avatarAsset, fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),

          // Call UI
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Call Type & Header
                Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: Column(
                    children: [
                      Icon(
                        displaySession.type == CallType.video
                            ? Icons.videocam_rounded
                            : Icons.phone_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        displaySession.type == CallType.video
                            ? 'VIDEO CALLING'
                            : 'VOICE CALLING',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Pulsing Center Avatar
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Container(
                              height: 140 * _pulseAnimation.value,
                              width: 140 * _pulseAnimation.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    (displaySession.type == CallType.video
                                            ? AppTheme.callIndigo
                                            : AppTheme.callGreen)
                                        .withOpacity(
                                          (2 - _pulseAnimation.value) * 0.15,
                                        ),
                              ),
                            );
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.primaryGradient,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppTheme.backgroundObsidian,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundImage: AssetImage(avatarAsset),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      displaySession.contact.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.ring_volume_rounded,
                          color: AppTheme.textSecondary,
                          size: 14,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Ringing...',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Call Controls (End Call button)
                Padding(
                  padding: const EdgeInsets.only(bottom: 60.0),
                  child: Column(
                    children: [
                      // Rate display
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.monetization_on_rounded,
                              color: AppTheme.accentGold,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${callVM.getCoinsRate(displaySession.type)} Coins/sec',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Cancel Button
                      GestureDetector(
                        onTap: () => callVM.hangUp(signupVM),
                        child: Container(
                          height: 72,
                          width: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.accentRose,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentRose.withOpacity(0.35),
                                blurRadius: 15,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.call_end_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
