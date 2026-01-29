import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/TeacherWalletEntity.dart';

abstract class UserWalletRepo {
  Future<Either<Failure, void>> setTeacherWallet({
    required String userID,
    required WalletEntity walletEntity,
  });
}
