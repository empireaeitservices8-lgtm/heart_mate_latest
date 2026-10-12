import 'package:dio/dio.dart';
import '../services/storage_service.dart';

class ApiClient {
  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();

  ApiClient() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Automatically inject the token if it is stored in SharedPreferences
        final token = await _storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Token $token';
        }
        options.headers['Content-Type'] = 'application/json';
        return handler.next(options);
      },
    ));

    // Custom logging interceptor to log URL, headers, body, and response
    _dio.interceptors.add(LoggingInterceptor());
  }

  Dio get dio => _dio;
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('--> HTTP REQUEST');
    print('URL: ${options.uri}');
    print('Method: ${options.method}');
    print('Headers: ${options.headers}');
    if (options.data != null) {
      print('Body: ${options.data}');
    }
    print('--> END REQUEST');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('<-- HTTP RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('URL: ${response.requestOptions.uri}');
    print('Response Body: ${response.data}');
    print('<-- END RESPONSE');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('<-- HTTP ERROR');
    print('URL: ${err.requestOptions.uri}');
    print('Status Code: ${err.response?.statusCode}');
    print('Error Message: ${err.message}');
    if (err.response?.data != null) {
      print('Error Body: ${err.response?.data}');
    }
    print('<-- END ERROR');
    super.onError(err, handler);
  }
}
