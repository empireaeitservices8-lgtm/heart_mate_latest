import 'dart:io';
import 'package:dio/dio.dart';
import '../helpers/sp_helper.dart';
import '../models/app_error_model.dart';

mixin MixinApiInterceptors {
  InterceptorsWrapper createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SpHelper.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    );
  }

  AppErrorModel mapDioExceptionToAppError(DioException error) {
    if (error.error is SocketException || error.type == DioExceptionType.connectionError) {
      return AppErrorModel.network();
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return AppErrorModel.timeout();
    }

    final response = error.response;
    if (response != null) {
      return AppErrorModel.fromResponse(response.data, response.statusCode);
    }

    return AppErrorModel(
      message: error.message ?? 'An unexpected network error occurred.',
      originalError: error,
    );
  }
}
