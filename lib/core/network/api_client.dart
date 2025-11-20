import 'package:dio/dio.dart';
import 'package:f1sync/core/constants/api_constants.dart';
import 'package:f1sync/core/network/api_exception.dart';
import 'package:logger/logger.dart';

/// HTTP client for OpenF1 API using Dio
class OpenF1ApiClient {
  late final Dio _dio;
  final Logger _logger = Logger();

  OpenF1ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConstants.timeout),
        receiveTimeout: Duration(milliseconds: ApiConstants.timeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('REQUEST[${options.method}] => ${options.path}');
          _logger.d('Query Parameters: ${options.queryParameters}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'RESPONSE[${response.statusCode}] <= ${response.requestOptions.path}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e(
            'ERROR[${error.response?.statusCode}] <= ${error.requestOptions.path}',
          );
          handler.next(error);
        },
      ),
    );
  }

  /// Make a GET request and return a list of objects
  ///
  /// [endpoint] - API endpoint (from ApiConstants)
  /// [fromJson] - Factory function to convert JSON to object
  /// [queryParams] - Optional query parameters for filtering
  Future<List<T>> getList<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // If not a list, return empty list
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException.parse('Failed to parse response: ${e.toString()}');
    }
  }

  /// Make a GET request and return a single object
  ///
  /// [endpoint] - API endpoint (from ApiConstants)
  /// [fromJson] - Factory function to convert JSON to object
  /// [queryParams] - Optional query parameters for filtering
  Future<T?> getSingle<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );

      if (response.data is List && (response.data as List).isNotEmpty) {
        return fromJson((response.data as List).first as Map<String, dynamic>);
      } else if (response.data is Map) {
        return fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException.parse('Failed to parse response: ${e.toString()}');
    }
  }

  /// Handle Dio errors and convert to ApiException
  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException.timeout();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        return ApiException.server(statusCode);

      case DioExceptionType.connectionError:
        return const ApiException.network('No internet connection');

      case DioExceptionType.cancel:
        return const ApiException.network('Request cancelled');

      default:
        return ApiException.network(
          error.message ?? 'Unknown network error',
        );
    }
  }

  /// Dispose the client
  void dispose() {
    _dio.close();
  }
}
