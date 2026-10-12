import '../config/app_config.dart';

class UrlHelpers {
  UrlHelpers._();

  static String getBaseUrl([Environment? env]) {
    final activeEnv = env ?? AppConfig.currentEnvironment;
    switch (activeEnv) {
      case Environment.dg:
        return 'https://heartmateapi.pythonanywhere.com/api'; // Debug host
      case Environment.uat:
        return 'https://heartmateapi.pythonanywhere.com/api'; // Staging host
      case Environment.live:
        return 'https://heartmateapi.pythonanywhere.com/api'; // Production host
    }
  }

  static Map<String, String> getDefaultHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
