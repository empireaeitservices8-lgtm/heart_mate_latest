import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import '../../../../core/config/agora_config.dart';
import '../../../../repositories/app_repository.dart';
import '../../../../models/call.dart';
import '../../../../models/user_listing.dart';
import '../../signup/view_model/signup_viewmodel.dart';
import '../models/call_initiate_response.dart';

class CallViewModel extends ChangeNotifier {
  final AppRepository _appRepository = AppRepository();

  CallStatus _status = CallStatus.idle;
  CallStatus get status => _status;

  CallSession? _currentSession;
  CallSession? get currentSession => _currentSession;

  int _duration = 0;
  int get duration => _duration;

  int _coinsLeft = 0;
  int get coinsLeft => _coinsLeft;

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  bool _isVideoDisabled = false;
  bool get isVideoDisabled => _isVideoDisabled;
  bool get isVideoEnabled => !_isVideoDisabled;
  bool get isCameraOff => _isVideoDisabled;

  bool _isSpeakerPhone = true;
  bool get isSpeakerPhone => _isSpeakerPhone;

  bool _isFrontCamera = true;
  bool get isFrontCamera => _isFrontCamera;

  bool _isMockMode = false;
  bool get isMockMode => _isMockMode;

  List<CallLog> _callLogs = [];
  List<CallLog> get callLogs => _callLogs;

  // Agora properties
  RtcEngine? _engine;
  RtcEngine? get engine => _engine;

  bool _isJoined = false;
  bool get isJoined => _isJoined;

  int? _remoteUid;
  int? get remoteUid => _remoteUid;

  Timer? _callTimer;
  Timer? _simTimer;
  Timer? _statusPollTimer;
  Timer? _ringTimeoutTimer;
  bool _isPollingStatus = false;
  bool _isActionPending = false;
  bool get isActionPending => _isActionPending;
  int _accumulatedDeductedCoins = 0;

  final Set<int> _cancelledCallIds = {};

  bool isCallIdCancelled(int callId) => _cancelledCallIds.contains(callId);

  bool _isLeavingIntentionally = false;
  bool get isLeavingIntentionally => _isLeavingIntentionally;

  String? _remoteOfflineReason;
  String? get remoteOfflineReason => _remoteOfflineReason;

  Timer? _reconnectGraceTimer;

  Future<void> _safeReleaseAgoraEngine() async {
    if (_engine != null) {
      print('[Agora RTC] Releasing RTC engine...');
      try {
        if (_isJoined) {
          await _engine!.leaveChannel();
        }
        try {
          await _engine!.stopPreview();
        } catch (_) {}
        await _engine!.release();
      } catch (e) {
        print('[Agora RTC] Error releasing Agora engine: $e');
      }
      _engine = null;
      _isJoined = false;
      _remoteUid = null;
    }
  }

  void resetToIdle() {
    _status = CallStatus.idle;
    _currentSession = null;
    _remoteOfflineReason = null;
    _reconnectGraceTimer?.cancel();
    _reconnectGraceTimer = null;
    notifyListeners();
  }

  Future<void> _handleRemoteUserLeftCleanup(SignUpViewModel signupVM) async {
    _ringTimeoutTimer?.cancel();
    stopPollingCallStatus();
    _callTimer?.cancel();
    _simTimer?.cancel();
    await FlutterCallkitIncoming.endAllCalls();

    if (_currentSession == null) return;

    final endedSession = _currentSession!;
    final callDuration = _duration;
    final isCaller = endedSession.role == CallRole.caller;
    final rate = getCoinsRate(endedSession.type);
    final finalCoinsSpent = isCaller && callDuration > 0 ? (callDuration * rate) : 0;

    // Send final pending coins to server
    if (isCaller && _accumulatedDeductedCoins > 0) {
      // Server coin deduction endpoint is 404/not found. Running in local sync mode only.
      // _appRepository.deductCoins(_accumulatedDeductedCoins);
    }

    // Update status to completed on backend asynchronously
    if (endedSession.callId != null && endedSession.callId != 0) {
      try {
        final finalStatus = (callDuration > 0)
            ? 'completed'
            : (isCaller ? 'cancelled' : 'missed');
        _appRepository.updateCallStatus(endedSession.callId!, finalStatus).catchError((e) {
          print('Error updating call status asynchronously on remote user left: $e');
        });
      } catch (e) {
        print('Error updating call status on remote user left: $e');
      }
    }

    // Leave Agora
    await _safeReleaseAgoraEngine();

    // Create call history log
    final log = CallLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contactName: endedSession.contact.name,
      contactAvatar: endedSession.contact.id % 2 == 0 ? 'assets/images/boy.jpg' : 'assets/images/girl.jpg',
      contactId: endedSession.contact.id,
      timestamp: DateTime.now(),
      durationSeconds: callDuration,
      type: endedSession.type,
      isIncoming: endedSession.role == CallRole.callee,
      wasConnected: callDuration > 0,
      coinsSpent: finalCoinsSpent,
    );

    _callLogs.insert(0, log);
    saveCallLogs();
    
    notifyListeners();
  }

  Future<void> clearCallKitNotification() async {
    if (_currentSession != null && _currentSession!.callId != null) {
      final callIdStr = _currentSession!.callId!.toString();
      print('[debug_callkit] Marking CallKit as connected for call $callIdStr');
      try {
        await FlutterCallkitIncoming.setCallConnected(callIdStr);
      } catch (e) {
        print('[debug_callkit] Error setting call connected: $e');
      }
    }
  }

  Future<void> handleCallCancelled({required int callId}) async {
    if (_isLeavingIntentionally) return;
    _isLeavingIntentionally = true;

    print('[Agora Call] Call $callId cancelled by remote caller or backend.');
    _cancelledCallIds.add(callId);
    await FlutterCallkitIncoming.endCall(callId.toString());
    if (_currentSession != null && _currentSession!.callId == callId) {
      _ringTimeoutTimer?.cancel();
      stopPollingCallStatus();
      _simTimer?.cancel();
      _callTimer?.cancel();

      await _safeReleaseAgoraEngine();

      _status = CallStatus.cancelled;
      _isLeavingIntentionally = false;
      notifyListeners();
    } else {
      _isLeavingIntentionally = false;
    }
  }

  CallViewModel() {
    loadCallLogs();
  }

  // Rate definitions
  int getCoinsRate(CallType type) => type == CallType.voice ? 3 : 20;

  Future<bool> validateIncomingCall(int callId) async {
    try {
      final data = await _appRepository.getCallStatus(callId);
      final String status = (data['status'] ?? data['message']) as String? ?? '';
      return status == 'initiated';
    } catch (e) {
      print('Error validating incoming call: $e');
    }
    return false;
  }

  Future<String?> checkCallStatus(int callId) async {
    try {
      final data = await _appRepository.getCallStatus(callId);
      return (data['status'] ?? data['message']) as String?;
    } catch (e) {
      print('Error checking call status: $e');
    }
    return null;
  }

  void startPollingCallStatus(int callId, SignUpViewModel signupVM) {
    if (_isPollingStatus) return;
    _isPollingStatus = true;
 
    _statusPollTimer?.cancel();
    _statusPollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_currentSession == null || _status == CallStatus.idle) {
        stopPollingCallStatus();
        return;
      }
 
      final currentCallId = _currentSession!.callId;
      if (currentCallId == null || currentCallId != callId) {
        stopPollingCallStatus();
        return;
      }
 
      final backendStatus = await checkCallStatus(callId);
      if (backendStatus == null) return;
 
      print('[debug_call] Polled status for $callId: $backendStatus');
 
      if (backendStatus == 'accepted') {
        if (_currentSession!.role == CallRole.caller && _status != CallStatus.connected) {
          _connectCall(signupVM);
        }
      } else if (backendStatus == 'rejected' ||
                 backendStatus == 'cancelled' ||
                 backendStatus == 'missed' ||
                 backendStatus == 'completed') {
        stopPollingCallStatus();
        if (backendStatus == 'cancelled') {
          handleCallCancelled(callId: callId);
        } else if (_status == CallStatus.connected) {
          hangUp(signupVM);
        } else {
          if (_currentSession!.role == CallRole.caller) {
            hangUp(signupVM);
          } else {
            declineCall();
          }
        }
      }
    });
  }

  void stopPollingCallStatus() {
    _statusPollTimer?.cancel();
    _statusPollTimer = null;
    _isPollingStatus = false;
  }

  // Format call duration to MM:SS
  String get formattedDuration {
    final minutes = (_duration ~/ 60).toString().padLeft(2, '0');
    final seconds = (_duration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Request call permissions
  Future<bool> _requestPermissions(CallType type) async {
    final micStatus = await Permission.microphone.request();
    if (type == CallType.video) {
      final camStatus = await Permission.camera.request();
      return micStatus.isGranted && camStatus.isGranted;
    }
    return micStatus.isGranted;
  }

  // Initialize Agora RTC Engine
  Future<void> _initAgora(CallType type, SignUpViewModel signupVM) async {
    if (AgoraConfig.appId == 'YOUR_AGORA_APP_ID' || AgoraConfig.appId.isEmpty) {
      throw Exception('Agora App ID not configured.');
    }

    // Safely release pre-existing engine to prevent duplicate initialization
    await _safeReleaseAgoraEngine();

    print('[Agora RTC] Initializing RTC engine for $type (App ID configured)...');

    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(
        appId: AgoraConfig.appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Always enable audio for both audio and video calls
      await _engine!.enableAudio();

      if (type == CallType.video) {
        await _engine!.enableVideo();
        await _engine!.startPreview();
      } else {
        await _engine!.disableVideo();
      }

      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      print('[Agora RTC] Registering event handlers...');
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print('[Agora] Local user joined channel: ${connection.channelId}');
            _isJoined = true;
            notifyListeners();
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            print('[Agora] Remote user joined: $remoteUid in channel: ${connection.channelId}');
            _remoteUid = remoteUid;
            _reconnectGraceTimer?.cancel();
            _reconnectGraceTimer = null;
            if (_status == CallStatus.remoteLeft) {
              _status = CallStatus.connected;
              _remoteOfflineReason = null;
            } else {
              _isMockMode = false; // Real user connected!
              _connectCall(signupVM);
            }
            notifyListeners();
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            print('[Agora] Remote user offline: $remoteUid, reason: $reason');
            if (_isLeavingIntentionally) return;
            
            _remoteUid = null;
            
            if (reason == UserOfflineReasonType.userOfflineQuit) {
              _remoteOfflineReason = 'quit';
              _status = CallStatus.remoteLeft;
              notifyListeners();
              _handleRemoteUserLeftCleanup(signupVM);
            } else if (reason == UserOfflineReasonType.userOfflineDropped) {
              _remoteOfflineReason = 'dropped';
              _status = CallStatus.remoteLeft;
              notifyListeners();
              
              // Start a 5-second reconnect grace period
              _reconnectGraceTimer?.cancel();
              _reconnectGraceTimer = Timer(const Duration(seconds: 5), () {
                if (_status == CallStatus.remoteLeft && _remoteUid == null) {
                  print('[Agora] Reconnect grace period expired. Cleaning up.');
                  _handleRemoteUserLeftCleanup(signupVM);
                }
              });
            }
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            print('[Agora] Local user left channel: ${connection.channelId}');
            _isJoined = false;
            _remoteUid = null;
            notifyListeners();
          },
          onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
            print('[Agora] Connection state changed: $state, reason: $reason');
          },
          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
            print('[Agora] Token privilege will expire soon for channel: ${connection.channelId}');
          },
          onError: (ErrorCodeType err, String msg) {
            print('[Agora Error] Code: $err, message: $msg');
          },
        ),
      );
      print('[Agora RTC] Engine initialization complete.');
    } catch (e) {
      print('[Agora RTC] Engine initialization failed: $e');
      await _safeReleaseAgoraEngine();
      rethrow;
    }
  }

  // Start outbound call
  Future<bool> startCall(UserListing contact, CallType type, SignUpViewModel signupVM) async {
    _status = CallStatus.outgoing;
    _isMockMode = false;
    _isJoined = false;
    _remoteUid = null;
    _duration = 0;
    _accumulatedDeductedCoins = 0;
    _isMuted = false;
    _isVideoDisabled = false;
    _isSpeakerPhone = true;
    _isFrontCamera = true;
    _coinsLeft = signupVM.coins;

    // Immediately establish call session with contact info so OutgoingCallScreen
    // renders the contact name, pulsing avatar, and ringing audio immediately.
    _currentSession = CallSession(
      callId: null,
      channelId: '',
      contact: contact,
      type: type,
      role: CallRole.caller,
      startTime: DateTime.now(),
    );
    notifyListeners();

    final hasPermission = await _requestPermissions(type);
    if (!hasPermission) {
      print('Calling permissions rejected.');
      _status = CallStatus.idle;
      _currentSession = null;
      notifyListeners();
      return false;
    }

    final contactIdInt = contact.id;
    String channelId = 'call_${contact.id}_${DateTime.now().millisecondsSinceEpoch}';
    String agoraToken = AgoraConfig.token;
    int agoraUid = 0;

    int? callId;
    try {
      final String callTypeStr = (type == CallType.video) ? 'video' : 'audio';
      final apiResponse = await _appRepository.initiateCall(contactIdInt, callTypeStr);
      channelId = apiResponse.channelName;
      agoraToken = apiResponse.token;
      agoraUid = apiResponse.uid;
      callId = apiResponse.callId;
    } catch (e) {
      print("API call initiation failed: $e. Cancelling outbound call.");
      _status = CallStatus.idle;
      _currentSession = null;
      notifyListeners();
      return false;
    }

    _currentSession = CallSession(
      callId: callId,
      channelId: channelId,
      contact: contact,
      type: type,
      role: CallRole.caller,
      startTime: DateTime.now(),
    );

    notifyListeners();

    // Init Agora
    try {
      await _initAgora(type, signupVM);
    } catch (e) {
      print("Agora initialization failed: $e. Cancelling outbound call.");
      _status = CallStatus.idle;
      _currentSession = null;
      notifyListeners();
      return false;
    }

    if (_engine != null) {
      try {
        await _engine!.joinChannel(
          token: agoraToken,
          channelId: channelId,
          uid: agoraUid,
          options: const ChannelMediaOptions(
            autoSubscribeAudio: true,
            autoSubscribeVideo: true,
            publishCameraTrack: true,
            publishMicrophoneTrack: true,
            clientRoleType: ClientRoleType.clientRoleBroadcaster,
          ),
        );
      } catch (e) {
        print('Agora join channel failed: $e. Cancelling outbound call.');
        _status = CallStatus.idle;
        _currentSession = null;
        notifyListeners();
        return false;
      }
    }

    if (callId != null) {
      startPollingCallStatus(callId, signupVM);
      _ringTimeoutTimer?.cancel();
      _ringTimeoutTimer = Timer(const Duration(seconds: 30), () {
        if (_status == CallStatus.outgoing) {
          print('[debug_call] Ring timeout occurred. Caller hanging up.');
          hangUp(signupVM);
        }
      });
    }

    return true;
  }

  // Receive simulated inbound call
  void receiveSimulatedCall(UserListing contact, CallType type) {
    if (_status != CallStatus.idle) return;

    _status = CallStatus.incoming;
    _isMockMode = true;
    _isJoined = false;
    _remoteUid = null;
    _duration = 0;
    _accumulatedDeductedCoins = 0;
    _isMuted = false;
    _isVideoDisabled = false;
    _isSpeakerPhone = true;
    _isFrontCamera = true;

    final channelId = 'call_incoming_${DateTime.now().millisecondsSinceEpoch}';
    _currentSession = CallSession(
      callId: 0, // Mock ID
      channelId: channelId,
      contact: contact,
      type: type,
      role: CallRole.callee,
      startTime: DateTime.now(),
    );

    notifyListeners();
  }

  // Receive real inbound call from notification
  void handleIncomingCall({
    required int callId,
    required String channelId,
    required UserListing caller,
    required CallType type,
    required SignUpViewModel signupVM,
  }) {
    if (_status != CallStatus.idle) {
      print('[Agora Call] Incoming call $callId ignored: current status is $_status');
      return;
    }

    print('[Agora Call] Incoming call received -> ID: $callId, Caller ID: ${caller.id} (${caller.name}), Channel: $channelId, Type: $type');

    _status = CallStatus.incoming;
    _isMockMode = false;
    _isJoined = false;
    _remoteUid = null;
    _duration = 0;
    _accumulatedDeductedCoins = 0;
    _isMuted = false;
    _isVideoDisabled = false;
    _isSpeakerPhone = true;
    _isFrontCamera = true;

    _currentSession = CallSession(
      callId: callId,
      channelId: channelId,
      contact: caller,
      type: type,
      role: CallRole.callee,
      startTime: DateTime.now(),
    );

    startPollingCallStatus(callId, signupVM);
    _ringTimeoutTimer?.cancel();
    _ringTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (_status == CallStatus.incoming) {
        print('[debug_call] Ring timeout occurred. Callee declining.');
        declineCall();
      }
    });

    notifyListeners();
  }

  // Accept incoming call
  Future<bool> acceptCall(SignUpViewModel signupVM) async {
    if (_status != CallStatus.incoming || _currentSession == null || _isActionPending) {
      print('[Agora Call] Ignored invalid/duplicate accept tap: status=$_status, pending=$_isActionPending');
      return false;
    }
    
    _isActionPending = true;
    _status = CallStatus.accepting;
    notifyListeners();

    print('[Agora Call] Accept button pressed for call: ${_currentSession!.callId}, caller: ${_currentSession!.contact.id} (${_currentSession!.contact.name})');

    final hasPermission = await _requestPermissions(_currentSession!.type);
    if (!hasPermission) {
      print('[Agora Call] Permissions not granted by user.');
      _isActionPending = false;
      await _declineCallInternal();
      return false;
    }

    try {
      final callId = _currentSession!.callId;
      if (callId == null || callId == 0) {
        throw Exception('Call ID is null or invalid ($callId).');
      }

      // Check current status on backend to prevent race condition
      final currentBackendStatus = await checkCallStatus(callId);
      if (currentBackendStatus == 'cancelled' || currentBackendStatus == 'completed' || currentBackendStatus == 'rejected') {
        print('[Agora Call] Call $callId was already $currentBackendStatus on backend. Aborting accept.');
        _status = CallStatus.cancelled;
        _currentSession = null;
        _isActionPending = false;
        notifyListeners();
        return false;
      }

      final response = await _appRepository.updateCallStatus(callId, 'accepted');
      
      final String channelName = (response.channelName != null && response.channelName!.isNotEmpty)
          ? response.channelName!
          : _currentSession!.channelId;

      final String agoraToken = (response.token != null && response.token!.isNotEmpty)
          ? response.token!
          : AgoraConfig.token;

      final int agoraUid = response.uid ?? 0;

      print('[Agora Call] Backend accepted -> Channel: $channelName, UID: $agoraUid, Token Exists: ${agoraToken.isNotEmpty}');

      _currentSession = CallSession(
        callId: callId,
        channelId: channelName,
        contact: _currentSession!.contact,
        type: _currentSession!.type,
        role: _currentSession!.role,
        startTime: _currentSession!.startTime,
      );

      _coinsLeft = signupVM.coins;
      
      await _initAgora(_currentSession!.type, signupVM);
      
      if (_engine == null) {
        throw Exception('Agora engine failed to initialize.');
      }

      print('[Agora Call] Joining channel "$channelName" ...');
      await _engine!.joinChannel(
        token: agoraToken,
        channelId: channelName,
        uid: agoraUid,
        options: const ChannelMediaOptions(
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );

      // Wait up to 8 seconds for Agora join channel acknowledgment
      final joinStart = DateTime.now();
      while (!_isJoined && DateTime.now().difference(joinStart).inMilliseconds < 8000) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (_status == CallStatus.cancelled || _status == CallStatus.rejected) {
          print('[Agora Call] Call state cancelled during join wait.');
          return false;
        }
      }

      if (!_isJoined) {
        throw Exception('Timed out waiting for Agora joinChannel confirmation.');
      }

      print('[Agora Call] Channel "$channelName" joined successfully. Connecting call state.');
      _connectCall(signupVM);
      return true;
    } catch (e) {
      print('[Agora Call] Error accepting call: $e');
      // Do not silently reject on transient join failure; allow retry
      _status = CallStatus.incoming;
      notifyListeners();
      return false;
    } finally {
      _isActionPending = false;
      notifyListeners();
    }
  }

  // Connect active call state
  void _connectCall(SignUpViewModel signupVM) {
    if (_status == CallStatus.connected) return;
    _status = CallStatus.connected;
    
    _ringTimeoutTimer?.cancel();
    
    notifyListeners();

    // Start timer for duration and coin consumption
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _duration++;
      
      // Billings only apply to the Caller
      if (_currentSession?.role == CallRole.caller) {
        final rate = getCoinsRate(_currentSession!.type);
        
        // Decrement locally for UI
        signupVM.deductCoinsLocally(rate);
        _coinsLeft = signupVM.coins;
        _accumulatedDeductedCoins += rate;

        // Sync with server every 10 seconds
        if (_duration % 10 == 0) {
          // Server coin deduction endpoint is 404/not found. Running in local sync mode only.
          // _appRepository.deductCoins(_accumulatedDeductedCoins);
          _accumulatedDeductedCoins = 0;
        }

        // Hang up on 0 coins
        if (_coinsLeft <= 0) {
          _callTimer?.cancel();
          hangUp(signupVM, lowBalance: true);
          return;
        }
      }
      notifyListeners();
    });
  }

  // Decline incoming call internal helper (bypasses button lock checks)
  Future<void> _declineCallInternal() async {
    _ringTimeoutTimer?.cancel();
    stopPollingCallStatus();
    _simTimer?.cancel();
    final session = _currentSession;
    if (session != null && session.callId != null) {
      await FlutterCallkitIncoming.endCall(session.callId!.toString());
    }

    await _safeReleaseAgoraEngine();

    _status = CallStatus.rejected;
    notifyListeners();

    if (session != null && session.callId != null && session.callId != 0) {
      try {
        await _appRepository.updateCallStatus(session.callId!, 'rejected');
      } catch (e) {
        print('[Agora Call] Error updating call status to rejected: $e');
      }
    }
  }

  // Decline incoming call (public method with duplicate protection)
  Future<void> declineCall() async {
    if (_isActionPending) return;
    _isActionPending = true;
    notifyListeners();
    print('[Agora Call] Decline call initiated by user.');
    try {
      await _declineCallInternal();
    } finally {
      _isActionPending = false;
      notifyListeners();
    }
  }

  // End active call
  Future<void> hangUp(SignUpViewModel signupVM, {bool lowBalance = false}) async {
    if (_isLeavingIntentionally) return;
    _isLeavingIntentionally = true;

    _ringTimeoutTimer?.cancel();
    stopPollingCallStatus();
    _callTimer?.cancel();
    _simTimer?.cancel();
    await FlutterCallkitIncoming.endAllCalls();

    if (_currentSession == null) {
      _isLeavingIntentionally = false;
      return;
    }

    final endedSession = _currentSession!;
    final callDuration = _duration;
    final isCaller = endedSession.role == CallRole.caller;
    final rate = getCoinsRate(endedSession.type);
    final finalCoinsSpent = isCaller && callDuration > 0 ? (callDuration * rate) : 0;

    // Send final pending coins to server
    if (isCaller && _accumulatedDeductedCoins > 0) {
      // Server coin deduction endpoint is 404/not found. Running in local sync mode only.
      // _appRepository.deductCoins(_accumulatedDeductedCoins);
    }

    // Update status to completed on backend immediately/asynchronously
    if (endedSession.callId != null && endedSession.callId != 0) {
      try {
        final finalStatus = (callDuration > 0)
            ? 'completed'
            : (isCaller ? 'cancelled' : 'missed');
        _appRepository.updateCallStatus(endedSession.callId!, finalStatus).catchError((e) {
          print('Error updating call status asynchronously on hangUp: $e');
        });
      } catch (e) {
        print('Error updating call status on hangUp: $e');
      }
    }

    // Leave Agora
    await _safeReleaseAgoraEngine();

    // Create call history log
    final log = CallLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contactName: endedSession.contact.name,
      contactAvatar: endedSession.contact.id % 2 == 0 ? 'assets/images/boy.jpg' : 'assets/images/girl.jpg',
      contactId: endedSession.contact.id,
      timestamp: DateTime.now(),
      durationSeconds: callDuration,
      type: endedSession.type,
      isIncoming: endedSession.role == CallRole.callee,
      wasConnected: callDuration > 0,
      coinsSpent: finalCoinsSpent,
    );

    _callLogs.insert(0, log);
    saveCallLogs();

    if (callDuration > 0) {
      _status = CallStatus.ended;
    } else {
      _status = isCaller ? CallStatus.cancelled : CallStatus.missed;
    }
    
    _isLeavingIntentionally = false;
    notifyListeners();

    // Trigger toast or navigation indicator on low balance
    if (lowBalance) {
      print('Hangup triggered: low coin balance.');
    }
  }

  // Agora audio/video control toggles
  Future<void> toggleMute() async {
    final targetMuted = !_isMuted;
    if (_engine != null && !_isMockMode) {
      await _engine!.muteLocalAudioStream(targetMuted);
    }
    _isMuted = targetMuted;
    notifyListeners();
  }

  Future<void> toggleVideo() async {
    final targetVideoDisabled = !_isVideoDisabled;
    if (_engine != null && !_isMockMode) {
      await _engine!.muteLocalVideoStream(targetVideoDisabled);
      await _engine!.enableLocalVideo(!targetVideoDisabled);
    }
    _isVideoDisabled = targetVideoDisabled;
    notifyListeners();
  }

  Future<void> toggleSpeaker() async {
    if (_engine != null && !_isMockMode) {
      await _engine!.setEnableSpeakerphone(!_isSpeakerPhone);
    }
    _isSpeakerPhone = !_isSpeakerPhone;
    notifyListeners();
  }

  Future<void> switchCamera() async {
    if (_engine != null && !_isMockMode) {
      await _engine!.switchCamera();
    }
    _isFrontCamera = !_isFrontCamera;
    notifyListeners();
  }

  List<CallLog> _serverCallLogs = [];
  List<CallLog> get serverCallLogs => _serverCallLogs;
  bool _isHistoryLoading = false;
  bool get isHistoryLoading => _isHistoryLoading;
  String? _historyError;
  String? get historyError => _historyError;

  Future<void> fetchServerCallHistory() async {
    _isHistoryLoading = true;
    _historyError = null;
    notifyListeners();
    try {
      final List<dynamic> serverData = await _appRepository.getCallHistory();
      
      // Parse server response to CallLog
      _serverCallLogs = serverData.map((item) {
        if (item is Map) {
          final int idVal = item['id'] as int? ?? 0;
          final String callerName = item['caller_name'] as String? ?? 'Match';
          final String receiverName = item['receiver_name'] as String? ?? 'Match';
          final String callTypeStr = item['call_type'] as String? ?? 'voice';
          final String status = item['status'] as String? ?? 'ended';
          final int duration = item['duration'] as int? ?? 0;
          final String createdAtStr = item['created_at'] as String? ?? DateTime.now().toIso8601String();
          final bool isIncoming = item['role'] == 'receiver' || item['role'] == 'callee';

          return CallLog(
            id: idVal.toString(),
            contactName: isIncoming ? callerName : receiverName,
            contactAvatar: 'assets/images/girl.jpg', // Default fallback
            contactId: isIncoming ? (item['caller_id'] as int? ?? 0) : (item['receiver_id'] as int? ?? 0),
            timestamp: DateTime.tryParse(createdAtStr) ?? DateTime.now(),
            durationSeconds: duration,
            type: callTypeStr == 'video' ? CallType.video : CallType.voice,
            isIncoming: isIncoming,
            wasConnected: status == 'accepted' || duration > 0,
            coinsSpent: isIncoming ? 0 : (callTypeStr == 'video' ? 20 : 3) * (duration ~/ 60 + 1),
          );
        }
        return CallLog(
          id: '0',
          contactName: 'Unknown',
          contactAvatar: 'assets/images/girl.jpg',
          contactId: 0,
          timestamp: DateTime.now(),
          durationSeconds: 0,
          type: CallType.voice,
          isIncoming: false,
          wasConnected: false,
          coinsSpent: 0,
        );
      }).toList();
    } catch (e) {
      _historyError = e.toString().replaceAll('Exception: ', '');
      print('Error fetching call history from server: $e');
    } finally {
      _isHistoryLoading = false;
      notifyListeners();
    }
  }

  // Load call logs from local SharedPreferences
  Future<void> loadCallLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsString = prefs.getString('call_history');
      if (logsString != null) {
        final List<dynamic> logsJson = json.decode(logsString);
        _callLogs = logsJson.map((jsonItem) => CallLog.fromJson(jsonItem)).toList();
      } else {
        _callLogs = [];
      }
      notifyListeners();
    } catch (e) {
      print('Error loading call logs: $e');
    }
  }

  // Save call logs to SharedPreferences
  Future<void> saveCallLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = _callLogs.map((log) => log.toJson()).toList();
      await prefs.setString('call_history', json.encode(logsJson));
    } catch (e) {
      print('Error saving call logs: $e');
    }
  }

  // Clear call logs
  Future<void> clearCallLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('call_history');
      _callLogs.clear();
      notifyListeners();
    } catch (e) {
      print('Error clearing call logs: $e');
    }
  }

  Future<void> handleAcceptedFromCallKit({
    required int callId,
    required String channelName,
    required String token,
    required SignUpViewModel signupVM,
    String? callerName,
    int? callerId,
    CallType? callType,
    String? avatar,
  }) async {
    _status = CallStatus.accepting;
    _duration = 0;
    _remoteUid = null;
    _isJoined = false;

    final resolvedCallType = callType ?? CallType.voice;

    final callerContact = UserListing(
      id: callerId ?? 0,
      name: (callerName != null && callerName.isNotEmpty) ? callerName : 'Incoming Caller',
      status: 'online',
      isVerified: true,
    );

    _currentSession = CallSession(
      callId: callId,
      channelId: channelName,
      contact: callerContact,
      type: resolvedCallType,
      role: CallRole.callee,
      startTime: DateTime.now(),
    );
    notifyListeners();

    try {
      startPollingCallStatus(callId, signupVM);

      final hasPermission = await _requestPermissions(resolvedCallType);
      if (!hasPermission) {
        print('[Agora Call] Permissions not granted in handleAcceptedFromCallKit.');
        await _declineCallInternal();
        return;
      }

      final response = await _appRepository.updateCallStatus(callId, 'accepted');
      final String resolvedChannel = (response.channelName != null && response.channelName!.isNotEmpty)
          ? response.channelName!
          : (channelName.isNotEmpty ? channelName : _currentSession!.channelId);
      final String resolvedToken = (response.token != null && response.token!.isNotEmpty)
          ? response.token!
          : (token.isNotEmpty ? token : AgoraConfig.token);
      final int agoraUid = response.uid ?? 0;

      // Update _currentSession with the resolvedChannel so the UI has the real channelId!
      _currentSession = CallSession(
        callId: callId,
        channelId: resolvedChannel,
        contact: callerContact,
        type: resolvedCallType,
        role: CallRole.callee,
        startTime: _currentSession?.startTime ?? DateTime.now(),
      );
      notifyListeners();

      await _initAgora(resolvedCallType, signupVM);
      
      if (_engine != null) {
        await _engine!.joinChannel(
          token: resolvedToken,
          channelId: resolvedChannel,
          uid: agoraUid,
          options: const ChannelMediaOptions(
            autoSubscribeAudio: true,
            autoSubscribeVideo: true,
            publishCameraTrack: true,
            publishMicrophoneTrack: true,
            clientRoleType: ClientRoleType.clientRoleBroadcaster,
          ),
        );
      }
      _connectCall(signupVM);
    } catch (e) {
      print('Error completing callkit acceptance: $e');
      stopPollingCallStatus();
      _status = CallStatus.idle;
      notifyListeners();
    }
  }

  /// Re-enables video and preview when returning from the background
  Future<void> resumeVideoOnForeground() async {
    if (_engine != null && _currentSession?.type == CallType.video && !_isVideoDisabled) {
      print('[Agora RTC] Resuming video and preview on foreground...');
      try {
        await _engine!.enableVideo();
        await _engine!.startPreview();
      } catch (e) {
        print('[Agora RTC] Error resuming video on foreground: $e');
      }
      notifyListeners();
    }
  }

  Future<void> declineCallKitCall(int callId) async {
    if (_isLeavingIntentionally) return;
    _isLeavingIntentionally = true;
    try {
      await _appRepository.updateCallStatus(callId, 'rejected');
    } catch (e) {
      print('Error declining CallKit call on backend: $e');
    }
    _isLeavingIntentionally = false;
    resetToIdle();
  }

  Future<void> _updateCallStateStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_status == CallStatus.idle || 
          _status == CallStatus.ended || 
          _status == CallStatus.cancelled || 
          _status == CallStatus.rejected || 
          _status == CallStatus.missed) {
        await prefs.remove('active_call_id');
        await prefs.remove('active_call_status');
      } else {
        if (_currentSession != null && _currentSession!.callId != null) {
          await prefs.setInt('active_call_id', _currentSession!.callId!);
          await prefs.setString(
            'active_call_status', 
            (_status == CallStatus.connected || _status == CallStatus.accepting) ? 'accepted' : 'incoming'
          );
        }
      }
    } catch (e) {
      print('Error persisting call state: $e');
    }
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    _updateCallStateStorage();
  }

  @override
  void dispose() {
    _ringTimeoutTimer?.cancel();
    stopPollingCallStatus();
    _callTimer?.cancel();
    _simTimer?.cancel();
    unawaited(_safeReleaseAgoraEngine());
    super.dispose();
  }
}
