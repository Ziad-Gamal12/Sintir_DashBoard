import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Domain/Entities/FilterUsersQueryEntity.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Domain/Entities/GetUsersResponseEntity.dart';

abstract class UsersRepo {
  Future<Either<Failure, GetUsersResponseEntity>> getUsers(
    FilterUsersQueryEntity filters, {
    required bool isPaginate,
  });
}
