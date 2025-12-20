// ignore_for_file: file_names

import 'package:dio/dio.dart';

class CustomException implements Exception {
  final String message;
  CustomException({required this.message});
  @override
  String toString() {
    return message;
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class DioStatusHandler {
  static ApiException handle(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      throw ApiException("أنتهى الاتصال بالسيرفر");
    } else if (error.type == DioExceptionType.sendTimeout) {
      throw ApiException("انتهى الاتصال بسيرفر");
    } else if (error.type == DioExceptionType.receiveTimeout) {
      throw ApiException("انتهى الاتصال بسيرفر");
    } else if (error.type == DioExceptionType.badCertificate) {
      throw ApiException("خطا في الاتصال");
    } else if (error.type == DioExceptionType.cancel) {
      throw ApiException("خطا في الاتصال");
    } else if (error.type == DioExceptionType.unknown) {
      throw ApiException("خطأ غير معروف");
    } else if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode ?? 0;
      switch (statusCode) {
        case 400:
          throw ApiException("طلب غير صحيح");
        case 401:
          throw ApiException("غير مصرح لك");
        case 403:
          throw ApiException("غير مصرح لك");
        case 404:
          throw ApiException("غير موجود");
        case 422:
          throw ApiException("خطاء في البيانات");
        case 500:
          throw ApiException("خطاء في السيرفر");
        case 503:
          throw ApiException("خطاء في السيرفر");
        default:
          throw ApiException("خطاء غير معروف");
      }
    } else {
      throw ApiException("خطاء غير معروف");
    }
  }
}
