import 'dart:async';
import '../../../helpers/sp_helper.dart';
import '../../../providers/view_model.dart';
import '../../../utils/routes.dart';

class SplashViewModel extends ViewModel {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  String _targetRoute = AppRoutes.login;
  String get targetRoute => _targetRoute;

  Future<void> checkAuthStatus() async {
    setLoading(true);
    try {
      // Branding display delay
      await Future.delayed(const Duration(seconds: 2));

      // Check token presence via SpHelper.getString(SpHelper.keyToken)
      final token = await SpHelper.getString(SpHelper.keyToken);

      if (token != null && token.isNotEmpty) {
        _targetRoute = AppRoutes.dashboard;
      } else {
        _targetRoute = AppRoutes.login;
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      onShowError(e);
      _targetRoute = AppRoutes.login;
      _isInitialized = true;
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }
}
