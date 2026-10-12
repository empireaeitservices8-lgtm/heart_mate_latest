import 'package:flutter/material.dart';
import '../features/auth/view/login_screen.dart';
import '../features/auth/view/otp_verification_screen.dart';
import '../features/auth/view/register_screen.dart';
import '../features/dashboard/view/dashboard_screen.dart';
import '../features/devices/view/add_device_screen.dart';
import '../features/devices/view/device_detail_screen.dart';
import '../features/devices/view/device_list_screen.dart';
import '../features/device_groups/view/device_group_list_screen.dart';
import '../features/splashscreen/view/splashscreen.dart';
import '../features/users/view/add_user_screen.dart';
import '../features/users/view/user_list_screen.dart';
import '../models/device_models.dart';

class AppRoutes {
  AppRoutes._();

  // Root & Splash
  static const String splash = '/';

  // Auth
  static const String login = '/auth/login';
  static const String otpVerification = '/auth/otp';
  static const String register = '/auth/register';

  // Dashboard & Console
  static const String dashboard = '/dashboard';

  // Fleet Devices
  static const String devices = '/devices';
  static const String addDevice = '/devices/add';
  static const String deviceDetail = '/devices/detail';

  // Device Groups
  static const String deviceGroups = '/device-groups';

  // Users
  static const String users = '/users';
  static const String addUser = '/users/add';

  // Legacy HeartMate Routes (Preserved for zero breakage)
  static const String home = '/home';
  static const String signup = '/signup';
  static const String profile = '/profile';
  static const String support = '/support';
  static const String coin = '/coin';
  static const String history = '/history';
  static const String googleAuthContinue = '/google-auth-continue';
  static const String outgoingCall = '/outgoing-call';
  static const String incomingCall = '/incoming-call';
  static const String activeCall = '/active-call';
  static const String callHistory = '/call-history';
  static const String agentDashboard = '/agent-dashboard';
  static const String agentWallet = '/agent-wallet';

  /// Standard route map for MaterialApp.routes
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const FeatureSplashScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        dashboard: (context) => const DashboardScreen(),
        devices: (context) => const DeviceListScreen(),
        addDevice: (context) => const AddDeviceScreen(),
        deviceGroups: (context) => const DeviceGroupListScreen(),
        users: (context) => const UserListScreen(),
        addUser: (context) => const AddUserScreen(),
      };

  /// OnGenerateRoute generator for dynamic arguments
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case otpVerification:
        final phoneOrEmail = settings.arguments as String? ?? '';
        return buildPageRoute(
          page: OtpVerificationScreen(phoneOrEmail: phoneOrEmail),
          settings: settings,
        );

      case deviceDetail:
        final device = settings.arguments as DeviceModel;
        return buildPageRoute(
          page: DeviceDetailScreen(device: device),
          settings: settings,
        );

      default:
        final builder = routes[settings.name];
        if (builder != null) {
          return buildPageRoute(page: builder(AppConfigGlobalKeyContext.currentContext!));
        }
        return null;
    }
  }

  /// Generates a smooth slide/fade page transition route
  static PageRouteBuilder<T> buildPageRoute<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

class AppConfigGlobalKeyContext {
  static BuildContext? get currentContext => null;
}
