import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';

abstract class UserDetailsRepo {
  Future<Either<Failure, UserEntity>> getUser({required String userID});
  Future<Either<Failure, void>> updateUser({required UserEntity userEntity});
  Future<Either<Failure, void>> deleteUser({required String uid});
  Future<Either<Failure, List<CourseEntity>>> getUserCourses({
    required String uid,
  });
  Future<Either<Failure, List<TransactionEntity>>> getUserTransactions({
    required String uid,
  });
  Future<Either<Failure, int>> getUserSupportTicketsCount({
    required String uid,
  });
}
