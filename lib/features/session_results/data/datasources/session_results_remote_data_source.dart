import 'package:dio/dio.dart';
import '../models/session_result.dart';

/// Remote data source for session results API
class SessionResultsRemoteDataSource {
  final Dio _dio;

  SessionResultsRemoteDataSource(this._dio);

  /// Fetch session results from OpenF1 API
  Future<List<SessionResult>> getSessionResults({
    required int sessionKey,
    int? driverNumber,
    int? position,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'session_key': sessionKey,
        if (driverNumber != null) 'driver_number': driverNumber,
        if (position != null) 'position<=': position,
      };

      final response = await _dio.get(
        '/session_result',
        queryParameters: queryParameters,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => SessionResult.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to fetch session results: $e');
    }
  }
}
