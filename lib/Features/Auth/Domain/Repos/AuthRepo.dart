// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';

abstract class AuthRepo {
  Future<Either<Failure, void>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, void>> signUpWithEmailAndPassword({
    required UserEntity userEntity,
    required String password,
  });

  Future<Either<Failure, void>> updateUser(
    String? newPassword, {
    required UserEntity userEntity,
    required String currentPassword,
  });
  Future<Either<Failure, void>> resetPassword({required String email});
  Future<Either<Failure, void>> fetchUserAndStoreLocally({required String uid});
  Future<String> getDeviceId();
}
