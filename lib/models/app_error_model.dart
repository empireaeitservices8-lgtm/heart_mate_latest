enum ErrorType {
  network,
  timeout,
  unauthorized,
  notFound,
  server,
  validation,
  unknown,
}

class AppErrorModel implements Exception {
  final String message;
  final int? statusCode;
  final ErrorType type;
  final Map<String, dynamic>? validationErrors;
  final dynamic originalError;

  AppErrorModel({
    required this.message,
    this.statusCode,
    this.type = ErrorType.unknown,
    this.validationErrors,
    this.originalError,
  });

  factory AppErrorModel.network() {
    return AppErrorModel(
      message: 'No internet connection. Please check your network and try again.',
      type: ErrorType.network,
    );
  }

  factory AppErrorModel.timeout() {
    return AppErrorModel(
      message: 'Connection timed out. The server is taking too long to respond.',
      type: ErrorType.timeout,
    );
  }

  factory AppErrorModel.unauthorized([String? customMessage]) {
    return AppErrorModel(
      message: customMessage ?? 'Your session has expired. Please log in again.',
      statusCode: 401,
      type: ErrorType.unauthorized,
    );
  }

  factory AppErrorModel.server([String? customMessage, int? code]) {
    return AppErrorModel(
      message: customMessage ?? 'A server error occurred. Please try again later.',
      statusCode: code ?? 500,
      type: ErrorType.server,
    );
  }

  factory AppErrorModel.fromResponse(dynamic responseData, int? statusCode) {
    String errorMsg = 'An unexpected error occurred.';
    Map<String, dynamic>? errors;

    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('message')) {
        errorMsg = responseData['message'].toString();
      } else if (responseData.containsKey('error')) {
        errorMsg = responseData['error'].toString();
      } else if (responseData.containsKey('detail')) {
        errorMsg = responseData['detail'].toString();
      }

      if (responseData.containsKey('errors') && responseData['errors'] is Map<String, dynamic>) {
        errors = responseData['errors'] as Map<String, dynamic>;
      }
    } else if (responseData is String && responseData.isNotEmpty) {
      errorMsg = responseData;
    }

    ErrorType determinedType = ErrorType.unknown;
    if (statusCode == 401 || statusCode == 403) {
      determinedType = ErrorType.unauthorized;
    } else if (statusCode == 404) {
      determinedType = ErrorType.notFound;
    } else if (statusCode != null && statusCode >= 500) {
      determinedType = ErrorType.server;
    } else if (statusCode == 400 || statusCode == 422) {
      determinedType = ErrorType.validation;
    }

    return AppErrorModel(
      message: errorMsg,
      statusCode: statusCode,
      type: determinedType,
      validationErrors: errors,
    );
  }

  @override
  String toString() => 'AppErrorModel(status: $statusCode, type: $type, message: $message)';
}
