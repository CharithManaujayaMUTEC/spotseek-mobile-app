import 'package:dio/dio.dart';
import 'package:spotseeker_app/core/api/api_exception.dart';
import 'package:spotseeker_app/core/constants/api_constants.dart';
import 'package:spotseeker_app/core/storage/secure_storage.dart';

/// Interceptor to add authentication token to requests
class AuthInterceptor extends Interceptor {
  final SecureStorage _storage = SecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get access token from secure storage
    final accessToken = await _storage.read(ApiConstants.accessTokenKey);

    // Add token to header if available
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    super.onRequest(options, handler);
  }
}

/// Interceptor to handle token refresh on 401 errors
class RefreshTokenInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorage _storage = SecureStorage();

  RefreshTokenInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if error is 401 and not already a refresh token request
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/refresh')) {
      
      try {
        // Get refresh token
        final refreshToken = await _storage.read(ApiConstants.refreshTokenKey);
        
        if (refreshToken != null && refreshToken.isNotEmpty) {
          // Try to refresh the token
          final response = await _dio.post(
            ApiConstants.authRefresh,
            data: {'refreshToken': refreshToken},
            options: Options(
              headers: {'requiresAuth': false}, // Skip auth for this request
            ),
          );

          if (response.statusCode == 200) {
            // Save new tokens
            final newAccessToken = response.data['accessToken'];
            final newRefreshToken = response.data['refreshToken'];
            
            await _storage.write(ApiConstants.accessTokenKey, newAccessToken);
            await _storage.write(ApiConstants.refreshTokenKey, newRefreshToken);

            // Retry the original request with new token
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';
            
            final retryResponse = await _dio.fetch(opts);
            return handler.resolve(retryResponse);
          }
        }
      } catch (e) {
        // If refresh fails, clear tokens and reject
        await _storage.delete(ApiConstants.accessTokenKey);
        await _storage.delete(ApiConstants.refreshTokenKey);
      }
    }

    super.onError(err, handler);
  }
}

/// Interceptor to handle errors and convert to ApiException
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    ApiException exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = ApiException.timeout();
        break;

      case DioExceptionType.badResponse:
        exception = ApiException.fromResponse(
          err.response?.statusCode ?? 500,
          err.response?.data,
        );
        break;

      case DioExceptionType.cancel:
        exception = ApiException.cancelled();
        break;

      case DioExceptionType.connectionError:
        exception = ApiException.network();
        break;

      default:
        exception = ApiException.unknown();
    }

    // Pass the custom exception
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
      ),
    );
  }
}
