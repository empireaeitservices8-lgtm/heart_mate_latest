import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';
import '../models/login_response.dart';
import '../../../core/network/api_client.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupRepository {
  final Dio _dio = Dio();

  SignupRepository() {
    _dio.interceptors.add(LoggingInterceptor());
  }

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final fcmToken = await _getFcmToken();
      final Map<String, dynamic> requestData = request.toJson();
      requestData['fcm_token'] = fcmToken;

      final response = await _dio.post(
        ApiConstants.registerEndpoint,
        data: requestData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print('Register Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RegisterResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to register. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      final errorMsg = _parseDioError(e);
      throw Exception(errorMsg);
    } catch (e) {
      if (e is TypeError) {
        print('Subtype/Type error in register: $e');
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final fcmToken = await _getFcmToken();
      final Map<String, dynamic> requestData = request.toJson();
      requestData['fcm_token'] = fcmToken;

      final response = await _dio.post(
        ApiConstants.loginEndpoint,
        data: requestData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print('Login Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to login. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMsg = _parseDioError(e);
      throw Exception(errorMsg);
    } catch (e) {
      if (e is TypeError) {
        print('Subtype/Type error in login: $e');
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<LoginResponse> googleAuth({
    required String googleId,
    required String email,
    required String name,
  }) async {
    try {
      final fcmToken = await _getFcmToken();
      final response = await _dio.post(
        ApiConstants.googleAuthEndpoint,
        data: {
          "google_id": googleId,
          "email": email,
          "name": name,
          "fcm_token": fcmToken,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print('Google Auth Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to authenticate with Google. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      final errorMsg = _parseDioError(e);
      throw Exception(errorMsg);
    } catch (e) {
      if (e is TypeError) {
        print('Subtype/Type error in googleAuth: $e');
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<String> _getFcmToken() async {
    try {
      print("[debug_fcm] Reading FCM token from direct SharedPreferences...");
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('fcm_token');
      if (savedToken != null && savedToken.isNotEmpty) {
        print(
          "[debug_fcm] Found cached FCM token in SharedPreferences: $savedToken",
        );
        return savedToken;
      }

      print(
        "[debug_fcm] No cached token found in SharedPreferences. Requesting from Firebase...",
      );
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        print(
          "[debug_fcm] Successfully retrieved FCM token from Firebase: $fcmToken",
        );
        await prefs.setString('fcm_token', fcmToken);
        return fcmToken;
      }
      print("[debug_fcm] Firebase returned null or empty token.");
    } catch (e) {
      print("[debug_fcm] Exception caught during FCM token retrieval: $e");
    }
    return '';
  }

  String _parseDioError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      print('Auth Error Response: $data');
      if (data is Map) {
        if (data.containsKey('message')) {
          return data['message'];
        }
        return data.values
            .map((v) {
              if (v is List) return v.join(', ');
              return v.toString();
            })
            .join('. ');
      }
      return 'Server error: ${error.response!.statusCode}';
    }
    return 'Connection error: ${error.message}';
  }
}
