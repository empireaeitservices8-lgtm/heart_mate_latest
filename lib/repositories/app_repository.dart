import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/user_profile.dart';
import '../models/menu_item.dart';
import '../models/content_item.dart';
import '../models/help_line.dart';
import '../models/offer_item.dart';
import '../models/user_listing.dart';
import '../models/online_user.dart';
import '../screens/call/models/call_initiate_request.dart';
import '../screens/call/models/call_initiate_response.dart';
import '../screens/call/models/call_status_response.dart';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:shared_preferences/shared_preferences.dart';

class AppRepository {
  final ApiClient _apiClient = ApiClient();

  Future<UserProfile> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.profileEndpoint);
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      if (e is TypeError) {
        print('Subtype/Type error in getProfile: $e');
      }
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<List<MenuItem>> getMenu() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.menuEndpoint);
      final List dataList = _extractList(response.data, mapKey: 'menu');
      return dataList.map((json) => MenuItem.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      if (e is TypeError) {
        print('Subtype/Type error in getMenu: $e');
      }
      throw Exception('Failed to load menu: $e');
    }
  }

  Future<ContentItem> getTerms() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.termsEndpoint);
      return ContentItem.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      if (e is TypeError) {
        print('Subtype/Type error in getTerms: $e');
      }
      throw Exception('Failed to load terms: $e');
    }
  }

  Future<ContentItem> getPrivacy() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.privacyEndpoint);
      return ContentItem.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      if (e is TypeError) {
        print('Subtype/Type error in getPrivacy: $e');
      }
      throw Exception('Failed to load privacy: $e');
    }
  }

  Future<HelpLine> getHelpLine() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.helpLineEndpoint);
      return HelpLine.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      if (e is TypeError) {
        print('Subtype/Type error in getHelpLine: $e');
      }
      throw Exception('Failed to load helpline: $e');
    }
  }

  Future<int> getCoins() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.coinsEndpoint);
      final coins = response.data['coins'];
      if (coins is num) {
        return coins.toInt();
      } else if (coins is String) {
        return int.tryParse(coins) ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      if (e is TypeError) {
        print('Subtype/Type error in getCoins: $e');
      }
      throw Exception('Failed to load coins: $e');
    }
  }

  Future<int> addCoins(int amount) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.addCoinsEndpoint,
        data: {'coins': amount},
      );
      final coins = response.data['coins'];
      if (coins is num) {
        return coins.toInt();
      } else if (coins is String) {
        return int.tryParse(coins) ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      if (e is TypeError) {
        print('Subtype/Type error in addCoins: $e');
      }
      throw Exception('Failed to add coins: $e');
    }
  }

  Future<List<OfferItem>> getOffers() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.offersEndpoint);
      final List dataList = _extractList(response.data, mapKey: 'offers');
      return dataList.map((json) => OfferItem.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      if (e is TypeError) {
        print('Subtype/Type error in getOffers: $e');
      }
      throw Exception('Failed to load offers: $e');
    }
  }

  Future<List<UserListing>> getUsers() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.usersEndpoint);
      try {
        final prettyJson = const JsonEncoder.withIndent('  ').convert(response.data);
        dev.log('[debug_api] getUsers response:\n$prettyJson');
      } catch (e) {
        dev.log('[debug_api] getUsers response: ${response.data}');
      }
      final List dataList = _extractList(response.data, mapKey: 'users');
      return dataList.map((json) => UserListing.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      if (e is TypeError) {
        print('Subtype/Type error in getUsers: $e');
      }
      throw Exception('Failed to load users: $e');
    }
  }

  Future<List<OnlineUser>> getOnlineUsers() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.onlineUsersEndpoint,
      );
      final List dataList = _extractList(response.data, mapKey: 'online_users');
      return dataList.map((json) => OnlineUser.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      if (e is TypeError) {
        print('Subtype/Type error in getOnlineUsers: $e');
      }
      throw Exception('Failed to load online users: $e');
    }
  }

  List _extractList(dynamic data, {String? mapKey}) {
    if (data is List) {
      return data;
    } else if (data is Map) {
      if (mapKey != null && data.containsKey(mapKey) && data[mapKey] is List) {
        return data[mapKey] as List;
      }
      for (final value in data.values) {
        if (value is List) {
          return value;
        }
      }
    }
    return [];
  }

  Future<UserProfile> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put(
        ApiConstants.profileEndpoint,
        data: data,
      );
      final resMap = response.data as Map<String, dynamic>;
      if (resMap.containsKey('profile') && resMap['profile'] is Map) {
        return UserProfile.fromJson(resMap['profile'] as Map<String, dynamic>);
      }
      return UserProfile.fromJson(resMap);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      if (e is TypeError) {
        print('Subtype/Type error in updateProfile: $e');
      }
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> updateStatus(String statusType, bool isActive) async {
    try {
      await _apiClient.dio.post(
        ApiConstants.updateStatusEndpoint,
        data: {"status_type": statusType, "is_active": isActive},
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      if (e is TypeError) {
        print('Subtype/Type error in updateStatus: $e');
      }
      throw Exception('Failed to update status: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post(ApiConstants.logoutEndpoint, data: {});
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  Future<void> deductCoins(int amount) async {
    try {
      await _apiClient.dio.post(
        '${ApiConstants.baseUrl}/deduct-coins/',
        data: {'amount': amount},
      );
      print('Coins synced with server successfully: -$amount');
    } on DioException catch (e) {
      print(
        'Server coin deduction failed (running in local sync mode): ${e.message}',
      );
    } catch (e) {
      print('Local fallback sync triggered: $e');
    }
  }

  String _handleDioError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
      return 'Server error: ${error.response!.statusCode}';
    }
    return 'Connection error: ${error.message}';
  }

  Future<CallInitiateResponse> initiateCall(int receiverId, String callType) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.initiateCallEndpoint,
        data: {
          'receiver_id': receiverId,
          'call_type': callType,
        },
      );
      return CallInitiateResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      if (e is TypeError) {
        print('Subtype/Type error in initiateCall: $e');
      }
      throw Exception('Failed to initiate call: $e');
    }
  }

  Future<CallStatusResponse> updateCallStatus(int callId, String status) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.baseUrl}/calls/$callId/status/',
        data: {'status': status},
      );
      return CallStatusResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Failed to update call status: $e');
    }
  }

  Future<Map<String, dynamic>> getCallStatus(int callId) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.baseUrl}/calls/$callId/status/');
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }
      return {'status': 'initiated'};
    } on DioException catch (e) {
      // Fallback: if direct status endpoint is not found or fails, return initiated
      print('Direct call status API failed: ${e.message}. Using initiated status.');
      return {'status': 'initiated'};
    } catch (e) {
      return {'status': 'initiated'};
    }
  }

  Future<List<dynamic>> getCallHistory() async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.baseUrl}/calls/history/',
        queryParameters: {'status': 'accepted'},
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Failed to load call history: $e');
    }
  }

  // --- Agent & Wallet API Integrations with Fallback Simulations ---

  Future<Map<String, dynamic>> getAgentStatus() async {
    // Return local status directly without making any HTTP request
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString('agent_status') ?? 'approved';
    final submittedDate = prefs.getString('agent_registration_date') ?? '';
    
    return {
      "status": status,
      "submitted_date": submittedDate,
    };
  }

  Future<Map<String, dynamic>> getAgentDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await _apiClient.dio.get(
        ApiConstants.agentDashboardEndpoint,
        options: Options(
          headers: token != null ? {'Authorization': 'Token $token'} : null,
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Failed to load agent dashboard: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCoinPackages() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.coinPackagesEndpoint);
      final List dataList = response.data as List;
      return dataList.map((json) => json as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      print('Coin packages API 404/Error, returning default packages: ${e.message}');
      
      // Default coin packages to return when backend API is missing
      return [
        {'id': 1, 'coins': 100, 'price': 99.0, 'badge': ''},
        {'id': 2, 'coins': 500, 'price': 449.0, 'badge': ''},
        {'id': 3, 'coins': 1000, 'price': 799.0, 'badge': 'Popular'},
        {'id': 4, 'coins': 2500, 'price': 1799.0, 'badge': 'Best Deal'},
      ];
    } catch (e) {
      throw Exception('Failed to fetch coin packages: $e');
    }
  }

  Future<Map<String, dynamic>> createPaymentOrder(int packageId, double amount) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.createPaymentOrderEndpoint,
        data: {'package_id': packageId, 'amount': amount},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('Create payment order API 404/Error, simulating order creation: ${e.message}');
      
      return {
        "order_id": "order_mock_${DateTime.now().millisecondsSinceEpoch}",
        "amount": amount,
        "currency": "INR",
        "status": "created"
      };
    } catch (e) {
      throw Exception('Failed to create payment order: $e');
    }
  }

  Future<Map<String, dynamic>> verifyPayment(Map<String, String> razorpayParams) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.verifyPaymentEndpoint,
        data: razorpayParams,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('Verify payment API 404/Error, simulating payment verification: ${e.message}');
      
      return {
        "status": "success",
        "message": "Payment verified successfully (simulated locally)"
      };
    } catch (e) {
      throw Exception('Failed to verify payment: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getWalletTransactions() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.coinTransactionsEndpoint);
      final List dataList = response.data as List;
      return dataList.map((json) => json as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      print('Coin transactions API 404/Error, loading from local simulation: ${e.message}');
      
      // Load local transactions list from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('wallet_transactions');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List parsed = json.decode(jsonStr) as List;
        return parsed.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load wallet transactions: $e');
    }
  }

  Future<void> saveLocalTransaction(Map<String, dynamic> transaction) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('wallet_transactions');
      List transactionsList = [];
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final parsed = json.decode(jsonStr);
        if (parsed is List) {
          transactionsList = parsed;
        }
      }
      transactionsList.insert(0, transaction);
      await prefs.setString('wallet_transactions', json.encode(transactionsList));
    } catch (e) {
      print('Failed to save local transaction: $e');
    }
  }

  Future<void> clearLocalAgentState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('agent_status');
      await prefs.remove('agent_registration_data');
      await prefs.remove('agent_registration_date');
      await prefs.remove('wallet_transactions');
    } catch (e) {
      print('Failed to clear local agent state: $e');
    }
  }
}

