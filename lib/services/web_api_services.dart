import 'package:dio/dio.dart';
import '../helpers/url_helpers.dart';
import '../models/app_error_model.dart';
import '_mixins_api.dart';

class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool isSuccess;
  final int? statusCode;
  final AppErrorModel? error;

  ApiResponse({
    this.data,
    this.message,
    required this.isSuccess,
    this.statusCode,
    this.error,
  });

  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse(
      data: data,
      message: message,
      isSuccess: true,
      statusCode: statusCode ?? 200,
    );
  }

  factory ApiResponse.failure(AppErrorModel error, {int? statusCode}) {
    return ApiResponse(
      isSuccess: false,
      message: error.message,
      statusCode: statusCode ?? error.statusCode,
      error: error,
    );
  }
}

class WebApiServices with MixinApiInterceptors {
  static final WebApiServices _instance = WebApiServices._internal();
  factory WebApiServices() => _instance;

  late final Dio _dio;
  Dio get dioClient => _dio;

  WebApiServices._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: UrlHelpers.getBaseUrl(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: UrlHelpers.getDefaultHeaders(),
      ),
    );

    _dio.interceptors.add(createAuthInterceptor());
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[API] $obj'),
      ),
    );
  }

  /// Centralized API execution method that handles requests safely
  Future<ApiResponse<T>> executeAPI<T>({
    required String path,
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic rawData)? parser,
  }) async {
    try {
      final requestOptions = options ?? Options();
      requestOptions.method = method;

      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
      );

      final dynamic raw = response.data;
      final parsedData = parser != null ? parser(raw) : raw as T;

      return ApiResponse.success(
        parsedData,
        statusCode: response.statusCode,
      );
    } on DioException catch (dioErr) {
      final appError = mapDioExceptionToAppError(dioErr);
      return ApiResponse.failure(appError);
    } catch (e) {
      return ApiResponse.failure(
        AppErrorModel(
          message: e.toString(),
          originalError: e,
        ),
      );
    }
  }

  // Shorthand helpers
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) {
    return executeAPI<T>(
      path: path,
      method: 'GET',
      queryParameters: queryParameters,
      parser: parser,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) {
    return executeAPI<T>(
      path: path,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      parser: parser,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? parser,
  }) {
    return executeAPI<T>(
      path: path,
      method: 'PUT',
      data: data,
      parser: parser,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? parser,
  }) {
    return executeAPI<T>(
      path: path,
      method: 'DELETE',
      data: data,
      parser: parser,
    );
  }
}
