import 'package:flutter/foundation.dart';
import '../models/app_error_model.dart';

mixin MixinProgressProvider on ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
}

mixin MixinApiProvider on ChangeNotifier {
  AppErrorModel? _error;
  AppErrorModel? get error => _error;
  bool get hasError => _error != null;

  void setError(AppErrorModel? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
