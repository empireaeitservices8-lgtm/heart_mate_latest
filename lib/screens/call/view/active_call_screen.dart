import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/call.dart';
import '../../signup/view_model/signup_viewmodel.dart';
import '../view_model/call_viewmodel.dart';

class ActiveCallScreen extends StatefulWidget {
  const ActiveCallScreen({super.key});

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _waveController;
  late CallViewModel _callVM;
  CallSession? _cachedSession;
  double _localVideoTop = 170.0;
  double _localVideoRight = 20.0;
  bool _isNavigatingAway = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _callVM = Provider.of<CallViewModel>(context, listen: false);
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    // Clear CallKit/Push notification now that the call screen has mounted/connected
    _callVM.clearCallKitNotification();

    // Ensure camera track and preview are running
    _callVM.resumeVideoOnForeground();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('[ActiveCallScreen] App resumed from background. Re-enabling camera/video preview.');
      _callVM.resumeVideoOnForeground();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _waveController.dispose();
    if (!_callVM.isCallActive) {
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
    final currentSession = callVM.currentSession;
    if (currentSession != null) {
      _cachedSession = currentSession;
    }
    final session = currentSession ?? _cachedSession;

    // Auto-navigate out on hang up or remote left
    if (!_isNavigatingAway &&
        (callVM.status == CallStatus.idle ||
            callVM.status == CallStatus.ended ||
            callVM.status == CallStatus.cancelled)) {
      _isNavigatingAway = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      });
    } else if (callVM.status == CallStatus.remoteLeft && !_isNavigatingAway) {
      _isNavigatingAway = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            callVM.resetToIdle();
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          }
        });
      });
    }

    if (session == null) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundObsidian,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.accentRose),
        ),
      );
    }

    final isVideo = session.type == CallType.video;
    final isCaller = session.role == CallRole.caller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Core Call View (Video / Audio UI)
          if (isVideo) ...[
            _buildVideoFeed(callVM),
          ] else ...[
            _buildVoiceCallUI(session),
          ],

          // 2. Mock mode banner alert
          if (callVM.isMockMode)
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: SafeArea(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentRose.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentRose.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stop, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Demo Call',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 3. Top Call Info Overlay (Timer & Real-Time Coins Billing)
          Positioned(
            top: callVM.isMockMode ? 100 : 50,
            left: 20,
            right: 20,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Call Duration Timer
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          callVM.formattedDuration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Coin Deductions Info (Only visible for the Caller billing)
                  if (isCaller)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.accentGold.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.monetization_on_rounded,
                            color: AppTheme.accentGold,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${callVM.coinsLeft} Coins',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '-${callVM.getCoinsRate(session.type)}/s',
                            style: const TextStyle(
                              color: AppTheme.accentRose,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.callGreen.withOpacity(0.2),
                        ),
                      ),
                      child: const Text(
                        'Incoming • Free',
                        style: TextStyle(
                          color: AppTheme.callGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 4. Bottom Controls Overlay
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  //  backdropFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute Button
                    _buildControlCircle(
                      icon: callVM.isMuted
                          ? Icons.mic_off_rounded
                          : Icons.mic_rounded,
                      isActive: !callVM.isMuted,
                      onTap: () => callVM.toggleMute(),
                    ),

                    // Video Camera Toggle (Video Only)
                    if (isVideo)
                      _buildControlCircle(
                        icon: callVM.isVideoDisabled
                            ? Icons.videocam_off_rounded
                            : Icons.videocam_rounded,
                        isActive: !callVM.isVideoDisabled,
                        onTap: () => callVM.toggleVideo(),
                      ),

                    // Speaker Button
                    _buildControlCircle(
                      icon: callVM.isSpeakerPhone
                          ? Icons.volume_up_rounded
                          : Icons.volume_down_rounded,
                      isActive: callVM.isSpeakerPhone,
                      onTap: () => callVM.toggleSpeaker(),
                    ),

                    // Camera Switch (Video Only)
                    if (isVideo)
                      _buildControlCircle(
                        icon: Icons.flip_camera_ios_rounded,
                        isActive: true,
                        onTap: () => callVM.switchCamera(),
                      ),

                    // End Call button
                    GestureDetector(
                      onTap: () => callVM.hangUp(signupVM),
                      child: Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accentRose,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentRose.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.call_end_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 5. Remote Left / Disconnected Message Overlay
          if (callVM.status == CallStatus.remoteLeft)
            Positioned.fill(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (callVM.remoteOfflineReason == 'dropped' && callVM.isJoined)
                                  ? AppTheme.accentGold.withOpacity(0.1)
                                  : AppTheme.accentRose.withOpacity(0.1),
                              border: Border.all(
                                color: (callVM.remoteOfflineReason == 'dropped' && callVM.isJoined)
                                    ? AppTheme.accentGold.withOpacity(0.3)
                                    : AppTheme.accentRose.withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              (callVM.remoteOfflineReason == 'dropped' && callVM.isJoined)
                                  ? Icons.signal_wifi_connected_no_internet_4_rounded
                                  : Icons.phone_disabled_rounded,
                              color: (callVM.remoteOfflineReason == 'dropped' && callVM.isJoined)
                                  ? AppTheme.accentGold
                                  : AppTheme.accentRose,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            callVM.remoteOfflineReason == 'quit'
                                ? 'Call ended'
                                : (callVM.isJoined ? 'Connection lost' : 'Call disconnected'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            callVM.remoteOfflineReason == 'quit'
                                ? 'The other party hung up.'
                                : (callVM.isJoined
                                    ? 'Attempting to reconnect...'
                                    : 'Connection could not be restored.'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Build Voice Call Centerpiece
  Widget _buildVoiceCallUI(CallSession session) {
    final avatarAsset = session.contact.id % 2 == 0
        ? 'assets/images/boy.jpg'
        : 'assets/images/girl.jpg';

    return Stack(
      fit: StackFit.expand,
      children: [
        // Blurry backdrop representation
        Image.asset(avatarAsset, fit: BoxFit.cover),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(color: Colors.black.withOpacity(0.7)),
        ),
        // Sound waves and avatar
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Animate multiple sound wave rings
                  for (double val in [0.25, 0.5, 0.75, 1.0])
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        final animVal = (_waveController.value + val) % 1.0;
                        return Container(
                          height: 120 + (120 * animVal),
                          width: 120 + (120 * animVal),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.callGreen.withOpacity(
                                (1.0 - animVal) * 0.25,
                              ),
                              width: 1.5,
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
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage(avatarAsset),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                session.contact.name,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Active Voice Connection',
                style: TextStyle(
                  color: AppTheme.callGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build Video Call UI (either Agora or Mock mockup)
  Widget _buildVideoFeed(CallViewModel callVM) {
    final session = callVM.currentSession!;
    final contactAvatar = session.contact.id % 2 == 0
        ? 'assets/images/boy.jpg'
        : 'assets/images/girl.jpg';

    if (callVM.isMockMode) {
      // Return a simulated dual video feed
      return Stack(
        fit: StackFit.expand,
        children: [
          // Remote simulated stream (large picture)
          Image.asset(
            contactAvatar,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(color: Colors.black.withOpacity(0.15)),

          // Local simulated stream (small floating PIP window)
          if (!callVM.isVideoDisabled)
            Positioned(
              top: 170,
              right: 20,
              child: Container(
                width: 110,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white30, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/images/boy.jpg', // Local user simulation
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    // Real Agora Video Stream Engine Rendering
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Fullscreen Remote Video view
        (callVM.remoteUid != null && callVM.engine != null)
            ? AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: callVM.engine!,
                  canvas: VideoCanvas(
                    uid: callVM.remoteUid,
                    renderMode: RenderModeType.renderModeHidden,
                  ),
                  connection: RtcConnection(
                    channelId: session.channelId.isNotEmpty
                        ? session.channelId
                        : (callVM.currentSession?.channelId ?? ''),
                  ),
                  useAndroidSurfaceView: false,
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    contactAvatar,
                    fit: BoxFit.cover,
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.primaryGradient,
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: AssetImage(contactAvatar),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const CircularProgressIndicator(color: AppTheme.accentRose),
                        const SizedBox(height: 16),
                        Text(
                          'Waiting for ${session.contact.name} to join...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

        // Floating Local PIP View
        if (callVM.isJoined && callVM.engine != null)
          Positioned(
            top: _localVideoTop,
            right: _localVideoRight,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  // Keep local preview inside screen bounds (with padding)
                  _localVideoTop = (_localVideoTop + details.delta.dy).clamp(
                    80.0,
                    screenHeight - 260.0,
                  );
                  _localVideoRight = (_localVideoRight - details.delta.dx).clamp(
                    10.0,
                    screenWidth - 130.0,
                  );
                });
              },
              child: Container(
                width: 110,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white30, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: !callVM.isVideoDisabled
                      ? AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: callVM.engine!,
                            canvas: const VideoCanvas(
                              uid: 0,
                              renderMode: RenderModeType.renderModeHidden,
                            ),
                            useAndroidSurfaceView: false,
                          ),
                        )
                      : Container(
                          color: Colors.black87,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.videocam_off_rounded,
                                color: Colors.white70,
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Camera Off',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Interactive Bottom Button builder
  Widget _buildControlCircle({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? Colors.white.withOpacity(0.2)
              : Colors.red.withOpacity(0.25),
          border: Border.all(
            color: isActive
                ? Colors.white24
                : Colors.redAccent.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.redAccent,
          size: 24,
        ),
      ),
    );
  }
}
