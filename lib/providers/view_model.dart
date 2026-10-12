import 'package:flutter/material.dart';
import '_base.dart';
import '../services/web_api_services.dart';

typedef ViewModel = BaseViewModel;

abstract class BaseViewModel extends BaseProvider {
  BuildContext? _context;
  BuildContext? get context => _context;

  void attachContext(BuildContext ctx) {
    _context = ctx;
  }

  void detachContext() {
    _context = null;
  }

  /// Initial entrypoint hook for ViewModel initialization
  void init() {}

  /// Global error reporting hook
  void onShowError(dynamic error) {
    if (error != null) {
      print('[ViewModel Error] $error');
    }
  }

  /// Executes an asynchronous block wrapped with progress and error reporting
  Future<T?> coverWithProgress<T>(
    BaseProvider provider,
    Future<T> Function() task, {
    void Function(dynamic error)? onError,
  }) async {
    provider.setLoading(true);
    provider.clearError();

    try {
      final result = await task();
      return result;
    } catch (e) {
      onShowError(e);
      onError?.call(e);
      return null;
    } finally {
      provider.setLoading(false);
    }
  }

  /// Convenience wrapper to execute asynchronous API calls with automatic loading & error state handling
  Future<T?> handleApiCall<T>(
    Future<ApiResponse<T>> Function() apiCall, {
    bool showLoading = true,
    void Function(T data)? onSuccess,
    void Function(dynamic error)? onError,
  }) async {
    if (showLoading) setLoading(true);
    clearError();

    try {
      final response = await apiCall();
      if (response.isSuccess && response.data != null) {
        onSuccess?.call(response.data as T);
        return response.data;
      } else if (response.error != null) {
        setError(response.error);
        onShowError(response.error);
        onError?.call(response.error);
      }
    } catch (e) {
      onShowError(e);
      onError?.call(e);
    } finally {
      if (showLoading) setLoading(false);
    }
    return null;
  }
}
