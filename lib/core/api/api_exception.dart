/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }

  /// Factory constructors for common errors
  factory ApiException.fromResponse(int statusCode, dynamic data) {
    String message;

    switch (statusCode) {
      case 400:
        message = _extractMessage(data, 'Bad Request');
        break;
      case 401:
        message = 'Unauthorized - Please login again';
        break;
      case 403:
        message = 'Forbidden - You don\'t have permission';
        break;
      case 404:
        message = _extractMessage(data, 'Resource not found');
        break;
      case 413:
        message = 'File is too large - Please upload a smaller file (max 5MB recommended)';
        break;
      case 422:
        message = _extractMessage(data, 'Validation failed');
        break;
      case 500:
        message = 'Server error - Please try again later';
        break;
      case 503:
        message = 'Service unavailable - Please try again later';
        break;
      default:
        message = _extractMessage(data, 'An error occurred');
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: data,
    );
  }

  factory ApiException.network() {
    return ApiException(
      message: 'No internet connection - Please check your network',
    );
  }

  factory ApiException.timeout() {
    return ApiException(
      message: 'Request timeout - Please try again',
    );
  }

  factory ApiException.cancelled() {
    return ApiException(
      message: 'Request was cancelled',
    );
  }

  factory ApiException.unknown() {
    return ApiException(
      message: 'An unexpected error occurred',
    );
  }

  static String _extractMessage(dynamic data, String defaultMessage) {
    if (data == null) return defaultMessage;

    if (data is Map) {
      // Try common message fields
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
      if (data['errors'] != null) {
        // Handle validation errors
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
          return firstError.toString();
        }
        return data['errors'].toString();
      }
    }

    if (data is String) return data;

    return defaultMessage;
  }
}
