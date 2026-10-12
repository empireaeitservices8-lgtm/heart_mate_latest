import 'dart:async';
import 'package:dating_app/screens/coin_screen.dart';
import 'package:dating_app/screens/home_screen.dart';
import 'package:dating_app/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:dating_app/screens/signup/view/signup_screen.dart';
import 'package:dating_app/screens/support_screen.dart';
import 'package:dating_app/screens/profile.screen.dart';
import 'package:dating_app/screens/splash_screen.dart';
import 'package:dating_app/screens/history_screen.dart';
import 'package:dating_app/screens/signup/view/google_auth_continue_screen.dart';
import 'package:dating_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:dating_app/screens/signup/view_model/signup_viewmodel.dart';
import 'package:dating_app/screens/call/view_model/call_viewmodel.dart';
import 'package:dating_app/screens/call/view/outgoing_call_screen.dart';
import 'package:dating_app/screens/call/view/incoming_call_screen.dart';
import 'package:dating_app/screens/call/view/active_call_screen.dart';
import 'package:dating_app/screens/call/view/call_history_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dating_app/firebase_options.dart';
import 'package:dating_app/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dating_app/models/call.dart';
import 'package:dating_app/models/user_listing.dart';
import 'package:dating_app/screens/agent/agent_dashboard_screen.dart';
import 'package:dating_app/screens/agent/agent_wallet_screen.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:dating_app/repositories/app_repository.dart';

const String _fcmBackgroundPortName = 'fcm_background_msg_port';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  print('[debug_fcm] Background message received: ${message.messageId} / ${message.data}');
  
  final data = message.data;
  final typeVal = data['type']?.toString().trim().toLowerCase() ?? '';
  final callId = data['call_id']?.toString() ?? data['callId']?.toString() ?? data['id']?.toString() ?? '0';
  
  final isCallEvent = typeVal == 'call' ||
      typeVal == 'incoming_call' ||
      typeVal == 'video' ||
      typeVal == 'voice' ||
      typeVal == 'audio' ||
      (callId != '0' &&
          typeVal != 'call_cancelled' &&
          typeVal != 'cancelled' &&
          typeVal != 'rejected' &&
          typeVal != 'ended');

  if (isCallEvent && callId != '0') {
    final callerName = data['caller_name'] ?? data['nameCaller'] ?? 'Incoming Caller';
    final callTypeStr = (data['call_type'] ?? data['type'] ?? 'voice').toString().toLowerCase();
    final isVideo = (callTypeStr == 'video' || data['type'] == 1 || data['type'] == '1');
    final channelName = data['channel_name'] ?? data['channel'] ?? data['channelId'] ?? '';
    final token = data['agora_token'] ?? data['token'] ?? '';
    final avatar = data['caller_avatar'] ?? data['avatar'] ?? '';
    final callerId = data['caller_id'] ?? data['callerId'] ?? '0';

    final params = CallKitParams(
      id: callId,
      nameCaller: callerName,
      appName: 'Heartmate',
      avatar: avatar,
      type: isVideo ? 1 : 0, // 0 = voice, 1 = video
      duration: 30000,
      android: const AndroidParams(
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0f172a',
        actionColor: '#e11d48',
        incomingCallNotificationChannelName: 'Incoming Call',
      ),
      ios: const IOSParams(
        iconName: 'AppIcon',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
      ),
      extra: <String, dynamic>{
        'channel_name': channelName,
        'agora_token': token,
        'call_id': callId,
        'caller_name': callerName,
        'caller_id': callerId.toString(),
        'call_type': isVideo ? 'video' : 'voice',
        'caller_avatar': avatar,
      },
    );
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  } else if (typeVal == 'call_cancelled' || typeVal == 'cancelled' || typeVal == 'cancel' || typeVal == 'rejected' || typeVal == 'completed' || typeVal == 'ended' || typeVal == 'hangup') {
    final callIdStr = data['call_id'] ?? data['callId'];
    if (callIdStr != null) {
      await FlutterCallkitIncoming.endCall(callIdStr.toString());
    }
  }

  try {
    final SendPort? sendPort = IsolateNameServer.lookupPortByName(_fcmBackgroundPortName);
    if (sendPort != null) {
      sendPort.send(message.data);
      print('[debug_fcm] Background message sent to main isolate.');
    } else {
      print('[debug_fcm] Main isolate port not found in background handler.');
    }
  } catch (e) {
    print('[debug_fcm] Error routing background message to main isolate: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup ReceivePort to listen to messages from background isolate
  final ReceivePort receivePort = ReceivePort();
  IsolateNameServer.removePortNameMapping(_fcmBackgroundPortName);
  IsolateNameServer.registerPortWithName(receivePort.sendPort, _fcmBackgroundPortName);
  
  receivePort.listen((dynamic messageData) {
    print('[debug_fcm] Port received message in main isolate: $messageData');
    if (messageData is Map) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(messageData);
      final message = RemoteMessage(data: data);
      _handleIncomingCallMessage(message);
    }
  });
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Request permission (highly recommended for iOS and Android 13+)
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('[debug_fcm] User granted permission: ${settings.authorizationStatus}');

    // Listen to token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      print("[debug_fcm] FCM Token Refreshed: $fcmToken");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', fcmToken);
      _syncFcmTokenWithBackend(fcmToken);
    });

    // Get FCM token with retry logic in the background
    _getFcmTokenWithRetry();

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('[debug_fcm] Foreground message received: ${message.data}');
      _handleIncomingCallMessage(message);
    });

    // Handle messages that opened the app from background/terminated states
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('[debug_fcm] Message opened app: ${message.data}');
      _handleIncomingCallMessage(message);
    });

    // Check if app was opened from terminated state via notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('[debug_fcm] Initial message received: ${message.data}');
        Future.delayed(const Duration(seconds: 1), () {
          _handleIncomingCallMessage(message);
        });
      }
    });
  } catch (e) {
    print("[debug_fcm] Error initializing Firebase/FCM: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignUpViewModel()),
        ChangeNotifierProvider(create: (_) => CallViewModel()),
      ],
      child: const HeartMateApp(),
    ),
  );
}

class AppRouteObserver extends NavigatorObserver {
  static String? currentRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      currentRoute = route.settings.name;
      print('[AppRouteObserver] didPush: $currentRoute');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name != null) {
      currentRoute = newRoute!.settings.name;
      print('[AppRouteObserver] didReplace: $currentRoute');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings.name != null) {
      currentRoute = previousRoute!.settings.name;
      print('[AppRouteObserver] didPop, back to: $currentRoute');
    }
  }
}

class HeartMateApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final AppRouteObserver routeObserver = AppRouteObserver();
  const HeartMateApp({super.key});

  /// Safely executes route navigation, deferring execution to the end of the frame
  /// or retrying if the NavigatorState is not yet mounted.
  static void safeNavigate(String routeName) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _performNavigation(routeName));
  }

  static void _performNavigation(String routeName) {
    final state = navigatorKey.currentState;
    if (state != null) {
      // Guard: Never push duplicate route if we are already on that route
      if (AppRouteObserver.currentRoute == routeName) {
        print('[safeNavigate] Already on route $routeName. Ignoring duplicate push.');
        return;
      }

      // For call screens, replace incoming/outgoing screen to avoid stacking multiple routes
      if (routeName == '/active-call') {
        if (AppRouteObserver.currentRoute == '/active-call') {
          return;
        }
        if (AppRouteObserver.currentRoute == '/incoming-call' ||
            AppRouteObserver.currentRoute == '/outgoing-call') {
          print('[safeNavigate] Replacing ${AppRouteObserver.currentRoute} with /active-call');
          state.pushReplacementNamed(routeName);
          return;
        }
      }

      state.pushNamed(routeName);
    } else {
      // Retry in the next microtask/loop cycle to handle initial frame layout transitions
      Future.delayed(const Duration(milliseconds: 100), () => _performNavigation(routeName));
    }
  }

  @override
  State<HeartMateApp> createState() => _HeartMateAppState();
}

class _HeartMateAppState extends State<HeartMateApp> with WidgetsBindingObserver {
  StreamSubscription? _callKitSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCallKitListener();
    _checkActiveCallOnStartup();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkActiveCallOnStartup();
    }
  }

  /// Checks for any active call managed by the CallKit engine.
  /// 
  /// Introduces a brief delay before execution to allow asynchronous platform channel
  /// CallKit events (like accept actions) to be dispatched first. This guards against
  /// race conditions where a resume check resets state before the event handler runs.
  Future<void> _checkActiveCallOnStartup() async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      final activeCalls = await FlutterCallkitIncoming.activeCalls();
      if (activeCalls == null || activeCalls.isEmpty) return;

      final callData = activeCalls.first;
      print('[debug_callkit] Active call found on startup: $callData');
      
      final extraRaw = callData.extra;
      final Map<String, dynamic> extra = extraRaw != null
          ? Map<String, dynamic>.from(extraRaw)
          : <String, dynamic>{};

      final channelName = extra['channel_name']?.toString() ?? '';
      final token = extra['agora_token']?.toString() ?? '';
      final callIdStr = extra['call_id']?.toString() ?? callData.id?.toString() ?? '';
      final callId = int.tryParse(callIdStr) ?? 0;
      final callerName = extra['caller_name']?.toString() ?? callData.nameCaller?.toString() ?? 'Incoming Caller';
      final callerId = int.tryParse(extra['caller_id']?.toString() ?? '') ?? 0;
      final callTypeStr = (extra['call_type'] ?? (callData.type == 1 ? 'video' : 'voice'))?.toString().toLowerCase();
      final callType = (callTypeStr == 'video' || callData.type == 1)
          ? CallType.video
          : CallType.voice;
      final avatar = extra['caller_avatar']?.toString() ?? callData.avatar?.toString() ?? '';

      final caller = UserListing(
        id: callerId,
        name: callerName,
        status: 'online',
        isVerified: true,
      );

      final signupVM = Provider.of<SignUpViewModel>(context, listen: false);
      final callVM = Provider.of<CallViewModel>(context, listen: false);

      // If call is already active or in progress, make sure active-call screen is visible
      if (callVM.status == CallStatus.connected || callVM.status == CallStatus.accepting) {
        print('[debug_callkit] Call is already ${callVM.status}. Ensuring navigation to /active-call.');
        HeartMateApp.safeNavigate('/active-call');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final persistedCallId = prefs.getInt('active_call_id');
      final persistedStatus = prefs.getString('active_call_status');

      if (persistedCallId == callId && persistedStatus == 'accepted') {
        print('[debug_callkit] Active call $callId was previously accepted. Syncing state and navigating to active call.');
        if (callVM.status == CallStatus.idle) {
          callVM.handleAcceptedFromCallKit(
            callId: callId,
            channelName: channelName,
            token: token,
            signupVM: signupVM,
            callerName: callerName,
            callerId: callerId,
            callType: callType,
            avatar: avatar,
          );
        }
        HeartMateApp.safeNavigate('/active-call');
      } else {
        if (callVM.status == CallStatus.idle) {
          callVM.handleIncomingCall(
            callId: callId,
            channelId: channelName,
            caller: caller,
            type: callType,
            signupVM: signupVM,
          );
          HeartMateApp.safeNavigate('/incoming-call');
        }
      }
    } catch (e) {
      print('[debug_callkit] Error checking active calls on startup: $e');
    }
  }

  void _initCallKitListener() {
    try {
      _callKitSubscription = FlutterCallkitIncoming.onEvent.listen(
        (CallEvent? event) {
          if (event == null) return;
          print('[debug_callkit] Event received in main app: ${event.eventName}');

          switch (event) {
            case CallEventActionCallAccept(:final callKitParams):
              _handleCallAccept(callKitParams.toJson());
              break;
              
            case CallEventActionCallDecline(:final callKitParams):
              _handleCallDecline(callKitParams.toJson());
              break;

            case CallEventActionCallEnded(:final callKitParams):
              _handleCallEnded(callKitParams.toJson());
              break;

            case CallEventActionCallTimeout(:final id):
              _handleCallEnded({'id': id});
              break;
              
            default:
              break;
          }
        },
        onError: (e) {
          print('[debug_callkit] CallKit events stream error: $e');
        },
      );
    } catch (e) {
      print('[debug_callkit] Error configuring CallKit listener: $e');
    }
  }

  void _handleCallAccept(dynamic body) {
    final Map<String, dynamic> data = body is Map
        ? Map<String, dynamic>.from(body)
        : <String, dynamic>{};

    final extraRaw = data['extra'];
    final Map<String, dynamic> extra = extraRaw is Map
        ? Map<String, dynamic>.from(extraRaw)
        : <String, dynamic>{};

    final channelName = extra['channel_name']?.toString() ?? data['channel_name']?.toString() ?? '';
    final token = extra['agora_token']?.toString() ?? data['agora_token']?.toString() ?? data['token']?.toString() ?? '';
    final callIdStr = extra['call_id']?.toString() ?? data['call_id']?.toString() ?? data['id']?.toString() ?? '';
    final callId = int.tryParse(callIdStr) ?? 0;
    final callerName = extra['caller_name']?.toString() ?? data['caller_name']?.toString() ?? data['nameCaller']?.toString() ?? 'Incoming Caller';
    final callerId = int.tryParse(extra['caller_id']?.toString() ?? data['caller_id']?.toString() ?? '') ?? 0;
    final callTypeStr = (extra['call_type'] ?? data['call_type'] ?? data['type'] ?? extra['type'])?.toString().toLowerCase();
    final callType = (callTypeStr == 'video' || data['type'] == 1 || data['type'] == '1' || extra['type'] == 1 || extra['type'] == '1')
        ? CallType.video
        : CallType.voice;
    final avatar = extra['caller_avatar']?.toString() ?? data['caller_avatar']?.toString() ?? data['avatar']?.toString() ?? '';

    final signupVM = Provider.of<SignUpViewModel>(context, listen: false);
    final callVM = Provider.of<CallViewModel>(context, listen: false);

    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('active_call_id', callId);
      prefs.setString('active_call_status', 'accepted');
    });

    callVM.handleAcceptedFromCallKit(
      callId: callId,
      channelName: channelName,
      token: token,
      signupVM: signupVM,
      callerName: callerName,
      callerId: callerId,
      callType: callType,
      avatar: avatar,
    );

    HeartMateApp.safeNavigate('/active-call');
  }

  void _handleCallDecline(dynamic body) {
    final Map<String, dynamic> data = body is Map
        ? Map<String, dynamic>.from(body)
        : <String, dynamic>{};
    final extraRaw = data['extra'];
    final Map<String, dynamic> extra = extraRaw is Map
        ? Map<String, dynamic>.from(extraRaw)
        : <String, dynamic>{};

    final callIdStr = extra['call_id']?.toString() ?? data['id']?.toString() ?? '';
    final callId = int.tryParse(callIdStr) ?? 0;

    final callVM = Provider.of<CallViewModel>(context, listen: false);
    callVM.declineCallKitCall(callId);
  }

  void _handleCallEnded(dynamic body) {
    final Map<String, dynamic> data = body is Map
        ? Map<String, dynamic>.from(body)
        : <String, dynamic>{};
    final extraRaw = data['extra'];
    final Map<String, dynamic> extra = extraRaw is Map
        ? Map<String, dynamic>.from(extraRaw)
        : <String, dynamic>{};

    final callIdStr = extra['call_id']?.toString() ?? data['call_id']?.toString() ?? data['id']?.toString() ?? '';
    final callId = int.tryParse(callIdStr) ?? 0;

    final context = HeartMateApp.navigatorKey.currentContext;
    if (context == null) return;

    final callVM = Provider.of<CallViewModel>(context, listen: false);

    // Guard: Only cancel if the call is still ringing or incoming!
    // When the call has already been answered/connected in-app, CallKit notification
    // dismissals or background end events must NOT terminate the active call.
    if (callVM.status == CallStatus.incoming || callVM.status == CallStatus.ringing) {
      print('[debug_callkit] CallKit ended event received for ringing/incoming call $callId. Cancelling.');
      callVM.handleCallCancelled(callId: callId);
    } else {
      print('[debug_callkit] Ignoring CallKit end event for call $callId because in-app status is ${callVM.status}');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _callKitSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: HeartMateApp.navigatorKey,
      navigatorObservers: [HeartMateApp.routeObserver],
      debugShowCheckedModeBanner: false,
      title: 'Heart Mate',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const MainNavigationScreen(),
        '/support': (context) => const SupportScreen(),
        '/profile': (context) => const MyProfileScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/coin': (context) => const CoinBalanceScreen(),
        '/history': (context) => const HistoryScreen(),
        '/google-auth-continue': (context) => const GoogleAuthContinueScreen(),
        '/outgoing-call': (context) => const OutgoingCallScreen(),
        '/incoming-call': (context) => const IncomingCallScreen(),
        '/active-call': (context) => const ActiveCallScreen(),
        '/call-history': (context) => const CallHistoryScreen(),
        '/agent-dashboard': (context) => const AgentDashboardScreen(),
        '/agent-wallet': (context) => const AgentWalletScreen(),
      },
    );
  }
}

Future<void> _syncFcmTokenWithBackend(String fcmToken) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final lastUploaded = prefs.getString('last_uploaded_fcm_token');
    final authToken = prefs.getString('auth_token') ?? prefs.getString('token');
    if (authToken != null && authToken.isNotEmpty && fcmToken.isNotEmpty && fcmToken != lastUploaded) {
      final appRepo = AppRepository();
      await appRepo.updateProfile({'fcm_token': fcmToken});
      await prefs.setString('last_uploaded_fcm_token', fcmToken);
      print('[debug_fcm] Successfully synced FCM token with backend: $fcmToken');
    }
  } catch (e) {
    print('[debug_fcm] Error syncing FCM token with backend: $e');
  }
}

Future<void> _getFcmTokenWithRetry() async {
  int retries = 5;
  for (int i = 0; i < retries; i++) {
    try {
      await Future.delayed(Duration(seconds: 2 * (i + 1)));
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        print("[debug_fcm] FCM Token: $token");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
        await _syncFcmTokenWithBackend(token);
        return;
      }
    } catch (e) {
      print("[debug_fcm] Attempt ${i + 1} to get FCM Token failed: $e");
      if (i == retries - 1) {
        print("[debug_fcm] Failed to get FCM Token after $retries attempts.");
      }
    }
  }
}

void _handleIncomingCallMessage(RemoteMessage message) {
  final data = message.data;
  print('[debug_fcm] Handling incoming message data: $data');
  if (data.isEmpty) return;

  final typeVal = data['type']?.toString().trim().toLowerCase() ?? '';

  final callIdStr = data['call_id'] ?? data['callId'] ?? data['id'];
  final int callId = int.tryParse(callIdStr?.toString() ?? '') ?? 0;

  if (callId == 0) return;

  final context = HeartMateApp.navigatorKey.currentContext;
  if (context == null) {
    print('[debug_fcm] Navigator context is null. Retrying in 300ms...');
    Future.delayed(const Duration(milliseconds: 300), () {
      _handleIncomingCallMessage(message);
    });
    return;
  }

  final callVM = Provider.of<CallViewModel>(context, listen: false);

  if (typeVal == 'call_cancelled' ||
      typeVal == 'cancelled' ||
      typeVal == 'cancel' ||
      typeVal == 'rejected' ||
      typeVal == 'completed' ||
      typeVal == 'ended' ||
      typeVal == 'hangup' ||
      typeVal == 'decline' ||
      typeVal == 'declined') {
    print('[debug_fcm] Processing cancellation/end event ($typeVal) for call $callId');
    callVM.handleCallCancelled(callId: callId);
    return;
  }

  final callerIdStr = data['caller_id'] ?? data['callerId'];
  final int callerId = int.tryParse(callerIdStr?.toString() ?? '') ?? 0;

  final signupVM = Provider.of<SignUpViewModel>(context, listen: false);
  final myId = signupVM.profile?.id;

  // Ignore if we are the caller
  if (myId != null && myId != 0 && myId == callerId) {
    print('[debug_fcm] Incoming call $callId ignored because we are the caller.');
    return;
  }

  // Ignore if we are already active in another call state (e.g. outgoing, connected)
  if (callVM.status != CallStatus.idle) {
    print('[debug_fcm] Incoming call $callId ignored because we are already in call status: ${callVM.status}');
    return;
  }

  final callerName = data['caller_name'] ?? data['nameCaller'] ?? 'Incoming Caller';
  final callTypeStr = (data['call_type'] ?? data['type'] ?? 'voice').toString().toLowerCase();
  final channelName = data['channel_name']?.toString() ?? '';

  final CallType callType = (callTypeStr == 'video' || data['type'] == 1 || data['type'] == '1')
      ? CallType.video
      : CallType.voice;

  final caller = UserListing(
    id: callerId,
    name: callerName,
    status: 'online',
    isVerified: true,
  );

  // Verify if already cancelled locally
  if (callVM.isCallIdCancelled(callId)) {
    print('[debug_fcm] Incoming call $callId ignored because it was already cancelled locally.');
    return;
  }

  // Show incoming call immediately without waiting on network validation
  callVM.handleIncomingCall(
    callId: callId,
    channelId: channelName,
    caller: caller,
    type: callType,
    signupVM: signupVM,
  );

  // Bring the app to the foreground on Android
  const MethodChannel('com.heartmate.app/call')
      .invokeMethod('bringToForeground')
      .catchError((e) {
        print('[debug_fcm] Failed to bring app to foreground: $e');
      });

  HeartMateApp.safeNavigate('/incoming-call');

  // Verify status on backend asynchronously to handle late cancellations
  callVM.checkCallStatus(callId).then((backendStatus) {
    if (backendStatus == 'cancelled' || backendStatus == 'completed' || backendStatus == 'rejected') {
      print('[debug_fcm] Incoming call $callId aborted because backend status is $backendStatus.');
      callVM.handleCallCancelled(callId: callId);
    }
  }).catchError((e) {
    print('[debug_fcm] Error validating call status: $e');
  });
}
