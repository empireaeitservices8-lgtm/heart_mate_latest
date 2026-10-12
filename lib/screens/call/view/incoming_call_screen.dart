import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/call.dart';
import '../../signup/view_model/signup_viewmodel.dart';
import '../view_model/call_viewmodel.dart';
import 'package:audioplayers/audioplayers.dart';

class IncomingCallScreen extends StatefulWidget {
  const IncomingCallScreen({super.key});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  late CallViewModel _callVM;
  CallSession? _cachedSession;
  AudioPlayer? _audioPlayer;
  bool _isHandlingAccept = false;
  bool _hasNavigated = false;

  Future<void> _playRingtone() async {
    try {
      _audioPlayer = AudioPlayer();
      await _audioPlayer!.setSource(
        UrlSource(
          'https://assets.mixkit.co/active_storage/sfx/1358/1358-84.wav',
        ),
      );
      await _audioPlayer!.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer!.resume();
    } catch (e) {
      print('[IncomingCallScreen] Error playing incoming ringtone: $e');
    }
  }

  Future<void> _stopRingtone() async {
    if (_audioPlayer != null) {
      try {
        await _audioPlayer!.stop();
        await _audioPlayer!.dispose();
      } catch (e) {
        print('[IncomingCallScreen] Error stopping ringtone: $e');
      } finally {
        _audioPlayer = null;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _callVM = Provider.of<CallViewModel>(context, listen: false);
    _playRingtone();
  }

  @override
  void dispose() {
    _stopRingtone();
    if (_callVM.status == CallStatus.cancelled ||
        _callVM.status == CallStatus.rejected ||
        _callVM.status == CallStatus.missed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _callVM.resetToIdle();
      });
    }
    super.dispose();
  }

  Future<void> _onAcceptPressed(SignUpViewModel signupVM) async {
    if (_isHandlingAccept || _callVM.isActionPending) return;

    setState(() {
      _isHandlingAccept = true;
    });

    // 1. Immediately stop the ringtone upon user interaction
    await _stopRingtone();

    // 2. Initiate Agora join flow
    final success = await _callVM.acceptCall(signupVM);

    if (!success && mounted) {
      setState(() {
        _isHandlingAccept = false;
        _hasNavigated = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to connect the call. Please try again.'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _onDeclinePressed() async {
    if (_isHandlingAccept || _callVM.isActionPending) return;

    await _stopRingtone();
    await _callVM.declineCall();
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
      if (callVM.status == CallStatus.connected || callVM.status == CallStatus.accepting) {
        _hasNavigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _stopRingtone();
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/active-call');
          }
        });
      } else if (callVM.status == CallStatus.idle ||
          callVM.status == CallStatus.cancelled ||
          callVM.status == CallStatus.rejected ||
          callVM.status == CallStatus.missed) {
        _hasNavigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _stopRingtone();
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

    final isVideo = displaySession.type == CallType.video;
    final String avatarAsset = displaySession.contact.id % 2 == 0
        ? 'assets/images/boy.jpg'
        : 'assets/images/girl.jpg';

    final isConnecting = _isHandlingAccept ||
        callVM.status == CallStatus.accepting ||
        callVM.isActionPending;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundObsidian,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // Top Call Type Badge & Caller Information
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.borderTranslucent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                            color: AppTheme.accentRose,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isVideo ? 'INCOMING VIDEO CALL' : 'INCOMING AUDIO CALL',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      displaySession.contact.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'is calling you...',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                // Centered Caller Profile Avatar
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.accentRose.withOpacity(0.4),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentRose.withOpacity(0.18),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 75,
                      backgroundColor: AppTheme.surfaceCard,
                      backgroundImage: AssetImage(avatarAsset),
                    ),
                  ),
                ),

                // Bottom Call Action Controls (Reject and Accept)
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Reject Button
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: isConnecting ? null : _onDeclinePressed,
                            child: AnimatedOpacity(
                              opacity: isConnecting ? 0.4 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: const BoxDecoration(
                                  color: AppTheme.accentRose,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
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
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Decline',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      // Accept Button
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: isConnecting ? null : () => _onAcceptPressed(signupVM),
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppTheme.callGreen,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.callGreen.withOpacity(0.4),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: isConnecting
                                  ? const Center(
                                      child: SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.call_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Accept',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
