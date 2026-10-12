import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../models/register_request.dart';
import '../models/login_request.dart';
import '../repo/signup_repository.dart';
import '../../../repositories/app_repository.dart';
import '../../../models/user_profile.dart';
import '../../../models/offer_item.dart';
import '../../../models/user_listing.dart';
import '../../../models/help_line.dart';
import '../../../models/content_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SignUpViewModel extends ChangeNotifier {
  final SignupRepository _repository = SignupRepository();
  final StorageService _storageService = StorageService();
  final AppRepository _appRepository = AppRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  int _coins = 0;
  int get coins => _coins;

  bool _isProfileLoading = false;
  bool get isProfileLoading => _isProfileLoading;

  bool _isCoinsLoading = false;
  bool get isCoinsLoading => _isCoinsLoading;

  String _agentStatus = 'none';
  String get agentStatus => _agentStatus;

  bool _isAgentMode = false;
  bool get isAgentMode => _isAgentMode;

  List<Map<String, dynamic>> _agentTransactions = [];
  List<Map<String, dynamic>> get agentTransactions => _agentTransactions;

  bool _isAgentTransactionsLoading = false;
  bool get isAgentTransactionsLoading => _isAgentTransactionsLoading;

  String? _transactionsError;
  String? get transactionsError => _transactionsError;

  bool _isAgentStatusLoading = false;
  bool get isAgentStatusLoading => _isAgentStatusLoading;

  List<OfferItem> _offers = [];
  List<OfferItem> get offers => _offers;
  bool _isOffersLoading = false;
  bool get isOffersLoading => _isOffersLoading;

  List<UserListing> _users = [];
  List<UserListing> get users => _users;
  bool _isUsersLoading = false;
  bool get isUsersLoading => _isUsersLoading;

  HelpLine? _helpLine;
  HelpLine? get helpLine => _helpLine;
  bool _isHelpLineLoading = false;
  bool get isHelpLineLoading => _isHelpLineLoading;

  Map<String, dynamic>? _agentDashboardData;
  Map<String, dynamic>? get agentDashboardData => _agentDashboardData;
  bool _isAgentDashboardLoading = false;
  bool get isAgentDashboardLoading => _isAgentDashboardLoading;

  ContentItem? _privacyContent;
  ContentItem? get privacyContent => _privacyContent;
  bool _isPrivacyLoading = false;
  bool get isPrivacyLoading => _isPrivacyLoading;

  ContentItem? _termsContent;
  ContentItem? get termsContent => _termsContent;
  bool _isTermsLoading = false;
  bool get isTermsLoading => _isTermsLoading;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    _isProfileLoading = true;
    _setError(null);
    notifyListeners();
    try {
      _profile = await _appRepository.getProfile();
      await fetchAgentStatus();
      
      // Load current isAgentMode from preferences
      final prefs = await SharedPreferences.getInstance();
      if (_profile?.isAgent ?? false) {
        await prefs.setBool('is_agent_mode', true);
        _isAgentMode = true;
      } else {
        _isAgentMode = prefs.getBool('is_agent_mode') ?? false;
      }
      
      if (_isAgentMode) {
        await fetchTransactions();
        await fetchAgentDashboard();
      }

      // Sync FCM Token with backend if changed/new
      final fcmToken = prefs.getString('fcm_token');
      final lastUploadedToken = prefs.getString('last_uploaded_fcm_token');
      if (fcmToken != null && fcmToken.isNotEmpty && fcmToken != lastUploadedToken) {
        print('[debug_fcm] Syncing refreshed FCM token with backend: $fcmToken');
        try {
          await _appRepository.updateProfile({'fcm_token': fcmToken});
          await prefs.setString('last_uploaded_fcm_token', fcmToken);
          print('[debug_fcm] Successfully synced FCM token with backend.');
        } catch (e) {
          print('[debug_fcm] Failed to sync FCM token with backend: $e');
        }
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCoins() async {
    _isCoinsLoading = true;
    _setError(null);
    notifyListeners();
    try {
      _coins = await _appRepository.getCoins();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isCoinsLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOffers() async {
    _isOffersLoading = true;
    _setError(null);
    notifyListeners();
    try {
      _offers = await _appRepository.getOffers();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isOffersLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUsers() async {
    _isUsersLoading = true;
    _setError(null);
    notifyListeners();
    try {
      _users = await _appRepository.getUsers();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isUsersLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHelpLine() async {
    _isHelpLineLoading = true;
    _setError(null);
    notifyListeners();
    try {
      _helpLine = await _appRepository.getHelpLine();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isHelpLineLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPrivacy() async {
    _isPrivacyLoading = true;
    _setError(null);
    notifyListeners();
    try {
      _privacyContent = await _appRepository.getPrivacy();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isPrivacyLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTerms() async {
    _isTermsLoading = true;
    _setError(null);
    notifyListeners();
    try {
      _termsContent = await _appRepository.getTerms();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isTermsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    _setError(null);
    try {
      final updatedProfile = await _appRepository.updateProfile(data);
      _profile = updatedProfile;
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<void> updateStatus(String statusType, bool isActive) async {
    try {
      await _appRepository.updateStatus(statusType, isActive);
    } catch (e) {
      print('API updateStatus error: $e');
    }
  }

  Future<void> toggleOnlineStatus() async {
    if (_profile == null) return;
    final nextStatus = !_profile!.isOnline;
    
    // Optimistic UI update
    _profile = UserProfile(
      id: _profile!.id,
      username: _profile!.username,
      email: _profile!.email,
      isOnline: nextStatus,
      rawProfile: _profile!.rawProfile,
    );
    notifyListeners();

    try {
      await _appRepository.updateStatus("online", nextStatus);
    } catch (e) {
      print('Toggle online status API error: $e');
      // Revert if error
      if (_profile != null) {
        _profile = UserProfile(
          id: _profile!.id,
          username: _profile!.username,
          email: _profile!.email,
          isOnline: !nextStatus,
          rawProfile: _profile!.rawProfile,
        );
        notifyListeners();
      }
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _appRepository.updateStatus("online", false);
    } catch (e) {
      print('API updateStatus offline on logout error: $e');
    }
    try {
      await _appRepository.logout();
    } catch (e) {
      print('API Logout error: $e');
    }
    await _storageService.clearToken();
    _profile = null;
    _coins = 0;
    _setLoading(false);
    notifyListeners();
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String phoneNumber,
    required String name,
    required int age,
    required String gender,
    required String bio,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final profile = RegisterProfile(
        name: name,
        age: age,
        gender: gender,
        phoneNumber: phoneNumber,
        bio: bio,
      );

      final request = RegisterRequest(
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        profile: profile,
      );

      final response = await _repository.register(request);
      
      // Save token to preferences
      await _storageService.saveToken(response.token);
      await _storageService.setLoggedIn(true);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_agent_mode', false);
      _isAgentMode = false;
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.login(
        LoginRequest(username: username, password: password)
      );

      // Save token to preferences
      await _storageService.saveToken(response.token);
      await _storageService.setLoggedIn(true);
      
      final prefs = await SharedPreferences.getInstance();
      final bool isAgent = response.isAgent;
      await prefs.setBool('is_agent_mode', isAgent);
      _isAgentMode = isAgent;

      if (isAgent) {
        await fetchAgentDashboard();
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> googleAuth({
    required String googleId,
    required String email,
    required String name,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.googleAuth(
        googleId: googleId,
        email: email,
        name: name,
      );

      if (response.success) {
        // Save token to preferences
        await _storageService.saveToken(response.token);
        await _storageService.setLoggedIn(true);

        final prefs = await SharedPreferences.getInstance();
        final bool isAgent = response.isAgent;
        await prefs.setBool('is_agent_mode', isAgent);
        _isAgentMode = isAgent;

        if (isAgent) {
          await fetchAgentDashboard();
        }

        if (response.user != null) {
          _profile = UserProfile(
            id: response.user!.id,
            username: response.user!.username,
            email: email,
            isOnline: true,
            isAgent: isAgent,
          );
        }

        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError("Google authentication failed.");
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  void deductCoinsLocally(int amount) {
    _coins = (_coins - amount);
    if (_coins < 0) _coins = 0;
    notifyListeners();
  }

  Future<bool> addCoins(int amount) async {
    _isCoinsLoading = true;
    _setError(null);
    notifyListeners();
    try {
      await _appRepository.addCoins(amount);
      await fetchCoins();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _isCoinsLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- Agent & Secure Payments Actions ---

  Future<void> fetchAgentStatus() async {
    _isAgentStatusLoading = true;
    notifyListeners();
    try {
      final res = await _appRepository.getAgentStatus();
      _agentStatus = res['status'] ?? 'none';
    } catch (e) {
      print('Error fetching agent status: $e');
    } finally {
      _isAgentStatusLoading = false;
      notifyListeners();
    }
  }



  Future<void> toggleAgentMode(bool active) async {
    _isAgentMode = active;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_agent_mode', active);
    
    if (active) {
      await fetchCoins();
      await fetchTransactions();
      await fetchAgentDashboard();
    }
    notifyListeners();
  }

  Future<void> fetchTransactions() async {
    _isAgentTransactionsLoading = true;
    _transactionsError = null;
    notifyListeners();
    try {
      _agentTransactions = await _appRepository.getWalletTransactions();
    } catch (e) {
      print('Error loading transactions: $e');
      _transactionsError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isAgentTransactionsLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> initiateSecureCheckoutOrder(int packageId, double amount) async {
    try {
      return await _appRepository.createPaymentOrder(packageId, amount);
    } catch (e) {
      _setError('Failed to initiate order.');
      rethrow;
    }
  }

  Future<bool> verifyAndCreditCoins({
    required String orderId,
    required String paymentId,
    required String signature,
    required int coinsAmount,
    required double price,
  }) async {
    _isCoinsLoading = true;
    _setError(null);
    notifyListeners();
    try {
      // 1. Verify Payment signature on backend (proposed)
      final verifyParams = {
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      };
      await _appRepository.verifyPayment(verifyParams);
      
      // 2. Backend Credits Coins (using working endpoint)
      await _appRepository.addCoins(coinsAmount);
      
      // 3. Log credit transaction details locally
      final transaction = {
        'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
        'title': 'Coin Purchase',
        'subtitle': 'Credit Bundle',
        'amount': '+$coinsAmount Coins',
        'type': 'purchase',
        'date': 'Today',
        'status': 'success',
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _appRepository.saveLocalTransaction(transaction);
      
      // 4. Synchronize local states
      await fetchCoins();
      await fetchTransactions();
      
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _isCoinsLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deductCoinsForAgentAction(int amount, String actionTitle) async {
    if (_coins < amount) {
      _setError('Insufficient coins.');
      return false;
    }
    _isCoinsLoading = true;
    notifyListeners();
    try {
      await _appRepository.deductCoins(amount);
      final transaction = {
        'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
        'title': actionTitle,
        'subtitle': 'Debit Action',
        'amount': '-$amount Coins',
        'type': 'debit',
        'date': 'Today',
        'status': 'success',
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _appRepository.saveLocalTransaction(transaction);
      await fetchCoins();
      await fetchTransactions();
      return true;
    } catch (e) {
      _setError('Failed to deduct coins: $e');
      _isCoinsLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchAgentDashboard() async {
    _isAgentDashboardLoading = true;
    notifyListeners();
    try {
      _agentDashboardData = await _appRepository.getAgentDashboard();
    } catch (e) {
      print('Error fetching agent dashboard: $e');
    } finally {
      _isAgentDashboardLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearAgentSession() async {
    await _appRepository.clearLocalAgentState();
    _agentStatus = 'none';
    _isAgentMode = false;
    _agentTransactions = [];
    _transactionsError = null;
    _agentDashboardData = null;
    notifyListeners();
  }
}
