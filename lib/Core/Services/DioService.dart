import 'package:dio/dio.dart';
import 'package:sintir_dashboard/constant.dart';

class DioService {
  late Dio _dio;

  DioService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://lsblauupczaxktmrpsmv.supabase.co/functions/v1/',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $supaAnonKey',
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return "Connection timed out. Check your internet.";
    }
    if (error.response != null && error.response?.data is Map) {
      return error.response?.data['error'] ?? "Server error occurred.";
    }
    return "Something went wrong. Please try again.";
  }
}
