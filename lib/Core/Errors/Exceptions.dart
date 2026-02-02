// ignore_for_file: file_names

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
