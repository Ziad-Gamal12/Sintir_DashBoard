// ignore_for_file: file_names, use_super_parameters

class Failure {
  final String message;
  Failure({required this.message});
}

class ServerFailure extends Failure {
  ServerFailure({required String message}) : super(message: message);
}
