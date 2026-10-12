import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../models/register_request.dart';
import '../models/login_request.dart';
import '../repo/signup_repository.dart';
import '../../../repositories/app_repository.dart';
import '../../../models/user_profile.dart';
import '../../../models/offer_item.dart';
import '../../../models/user_listing.dart';
import '../../../models/agent_models.dart';
import '../../../models/agent_dashboard_model.dart';
import '../../../models/help_line.dart';
import '../../../models/content_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../helpers/sp_helper.dart';

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

  List<Map<String, dynamic>> _withdrawals = [];
  List<Map<String, dynamic>> get withdrawals => _withdrawals;

  bool _isWithdrawalsLoading = false;
  bool get isWithdrawalsLoading => _isWithdrawalsLoading;

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

  List<AgentModel> _agents = [];
  List<AgentModel> get agents => _agents;
  bool _isAgentsLoading = false;
  bool get isAgentsLoading => _isAgentsLoading;

  HelpLine? _helpLine;
  HelpLine? get helpLine => _helpLine;
  bool _isHelpLineLoading = false;
  bool get isHelpLineLoading => _isHelpLineLoading;

  Map<String, dynamic>? _agentDashboardData;
  Map<String, dynamic>? get agentDashboardData => _agentDashboardData;
  AgentDashboardModel? _agentDashboardModel;
  AgentDashboardModel? get agentDashboardModel => _agentDashboardModel;
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

  Future<void> fetchProfile([String? username]) async {
    _isProfileLoading = true;
    _setError(null);
    notifyListeners();
    try {
      String uname = username ?? '';
      if (uname.isEmpty) {
        uname = await SpHelper.getUsername() ?? '';
      }
      if (uname.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        uname = prefs.getString('username') ?? '';
      }

      _profile = await _appRepository.getProfile(uname.isNotEmpty ? uname : null);
      await fetchAgentStatus();
      
      // Load current isAgentMode from preferences
      final prefs = await SharedPreferences.getInstance();
      if (_profile != null && _profile!.username.isNotEmpty) {
        await prefs.setString('username', _profile!.username);
        await SpHelper.setUsername(_profile!.username);
      }
      if (_profile != null) {
        final bool isAgent = _profile!.isAgent;
        await prefs.setBool('is_agent_mode', isAgent);
        await SpHelper.setIsAgent(isAgent);
        _isAgentMode = isAgent;
      } else {
        _isAgentMode = await SpHelper.getIsAgent();
      }
      
      if (_isAgentMode) {
        await fetchTransactions();
        await fetchWithdrawals();
        await fetchAgentDashboard();
      }

      // Sync FCM Token with backend for this user
      final fcmToken = prefs.getString('fcm_token');
      final userTokenKey = 'last_uploaded_fcm_token_${_profile?.id}';
      if (fcmToken != null && fcmToken.isNotEmpty) {
        print('[debug_fcm] Syncing FCM token with backend for user ${_profile?.id}: $fcmToken');
        try {
          final Map<String, dynamic> updateData = {'fcm_token': fcmToken};
          if (_profile != null) {
            if (_profile!.username.isNotEmpty) updateData['username'] = _profile!.username;
            if (_profile!.email.isNotEmpty) updateData['email'] = _profile!.email;
          }
          await _appRepository.updateProfile(updateData);
          await prefs.setString(userTokenKey, fcmToken);
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

  Future<void> fetchAgents() async {
    _isAgentsLoading = true;
    _isUsersLoading = true;
    _setError(null);
    notifyListeners();
    try {
      _agents = await _appRepository.getAgents();
      _users = _agents.map((agent) => agent.toUserListing()).toList();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isAgentsLoading = false;
      _isUsersLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUsers() async {
    await fetchAgents();
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
    await SpHelper.clearSession();
    await clearAgentSession();
    _profile = null;
    _coins = 0;
    _isAgentMode = false;
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
      await _storageService.saveUsername(username);
      await SpHelper.setToken(response.token);
      await SpHelper.setIsLoggedIn(true);
      await SpHelper.setUsername(username);
      await SpHelper.setIsAgent(false);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
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
      await _storageService.saveUsername(username);
      
      final bool isAgent = response.isAgent;
      await SpHelper.setToken(response.token);
      await SpHelper.setIsLoggedIn(true);
      await SpHelper.setUsername(username);
      await SpHelper.setIsAgent(isAgent);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setBool('is_agent_mode', isAgent);
      _isAgentMode = isAgent;

      if (isAgent) {
        await fetchAgentDashboard(username);
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

        final bool isAgent = response.isAgent;
        await SpHelper.setToken(response.token);
        await SpHelper.setIsLoggedIn(true);
        await SpHelper.setIsAgent(isAgent);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_agent_mode', isAgent);
        _isAgentMode = isAgent;

        if (response.user != null && response.user!.username.isNotEmpty) {
          await prefs.setString('username', response.user!.username);
          await SpHelper.setUsername(response.user!.username);
        }

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

  Future<void> fetchAgentDashboard([String? username]) async {
    _isAgentDashboardLoading = true;
    notifyListeners();
    try {
      final uname = username ?? _profile?.username;
      _agentDashboardData = await _appRepository.getAgentDashboard(uname);
      if (_agentDashboardData != null && _agentDashboardData!.isNotEmpty) {
        _agentDashboardModel = AgentDashboardModel.fromJson(_agentDashboardData!);
        final agent = _agentDashboardModel!.agent;
        if (agent.walletBalance > 0) {
          _coins = agent.walletBalance;
        } else if (agent.coinsEarned > 0) {
          _coins = agent.coinsEarned;
        }
      }
    } catch (e) {
      print('Error fetching agent dashboard: $e');
    } finally {
      _isAgentDashboardLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWithdrawals() async {
    _isWithdrawalsLoading = true;
    notifyListeners();
    try {
      _withdrawals = await _appRepository.getWithdrawalsHistory();
    } catch (e) {
      print('Error fetching agent withdrawals: $e');
    } finally {
      _isWithdrawalsLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> submitWithdrawal({
    required int coinsAmount,
    required double cashAmount,
    required String method,
    required Map<String, dynamic> payoutDetails,
  }) async {
    if (_coins < coinsAmount) {
      _setError('Insufficient coins balance for withdrawal.');
      return {'success': false, 'message': 'Insufficient coins balance.'};
    }

    _isWithdrawalsLoading = true;
    _setError(null);
    notifyListeners();

    try {
      // 1. Deduct coins on backend and locally
      await _appRepository.deductCoins(coinsAmount);

      // 2. Register withdrawal request
      final result = await _appRepository.requestWithdrawal(
        coinsAmount: coinsAmount,
        cashAmount: cashAmount,
        method: method,
        payoutDetails: payoutDetails,
      );

      // 3. Record in local wallet transactions
      final tx = {
        'id': 'tx_wd_${DateTime.now().millisecondsSinceEpoch}',
        'title': 'Withdrawal: $method',
        'subtitle': 'Ref: ${result['reference_id'] ?? 'Pending'}',
        'amount': '-$coinsAmount Coins',
        'type': 'debit',
        'date': 'Today',
        'status': 'pending',
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _appRepository.saveLocalTransaction(tx);

      // 4. Reload states
      await fetchCoins();
      await fetchWithdrawals();
      await fetchTransactions();

      return {
        'success': true,
        'reference_id': result['reference_id'] ?? result['id'],
        'withdrawal': result,
      };
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return {'success': false, 'message': e.toString()};
    } finally {
      _isWithdrawalsLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearAgentSession() async {
    await _appRepository.clearLocalAgentState();
    _agentStatus = 'none';
    _isAgentMode = false;
    _agentTransactions = [];
    _withdrawals = [];
    _transactionsError = null;
    _agentDashboardData = null;
    notifyListeners();
  }
}
