class AppUrls {
  AppUrls._();

  // Authentication & OTP endpoints
  static const String login = '/auth/login/';
  static const String verifyLogin = '/auth/verify-login/';
  static const String requestOtp = '/auth/request-otp/';
  static const String verifyOtp = '/auth/verify-otp/';
  static const String register = '/register/';
  static const String logout = '/logout/';
  static const String enableBiometric = '/auth/enable-biometric/';
  static const String googleAuth = '/google-auth/';

  // Dashboard endpoints
  static const String deviceUserCount = '/dashboard/device-user-count/';
  static const String licenseSummary = '/dashboard/license-summary/';

  // Devices endpoints
  static const String devices = '/devices/';
  static const String addDevice = '/devices/add/';
  static const String removeDevice = '/devices/remove/';
  static const String deviceTypes = '/devices/types/';
  static const String transferKey = '/devices/transfer-key/';

  // Device Groups endpoints
  static const String deviceGroups = '/device-groups/';
  static const String addDeviceGroup = '/device-groups/add/';
  static const String addDeviceToGroup = '/device-groups/add-device/';
  static const String renameDeviceGroup = '/device-groups/rename/';
  static const String deleteDeviceGroup = '/device-groups/delete/';

  // Users endpoints
  static const String users = '/users/';
  static const String addUser = '/users/add/';
  static const String deleteUserDevice = '/users/delete-device/';
  static const String deleteUserGroup = '/users/delete-group/';
  static const String onlineUsers = '/online-users/';
  static const String updateStatus = '/update-status/';
  static const String profile = '/profile/';

  // Calling & RTC
  static const String initiateCall = '/calls/initiate/';
  static const String callHistory = '/calls/history/';

  // Wallet & Coins
  static const String coins = '/coins/';
  static const String addCoins = '/coins/add/';
  static const String offers = '/offers/';
  static const String coinPackages = '/coins/packages/';
  static const String coinTransactions = '/coins/transactions/';
  static const String createPaymentOrder = '/payment/order/';
  static const String verifyPayment = '/payment/verify/';

  // Info & Support
  static const String menu = '/menu/';
  static const String terms = '/terms-conditions/';
  static const String privacy = '/privacy-policy/';
  static const String helpLine = '/help-line/';

  // Agent
  static const String agentRegister = '/agent/register/';
  static const String agentStatus = '/agent/status/';
  static const String agentDashboard = '/agent/dashboard/';
}
