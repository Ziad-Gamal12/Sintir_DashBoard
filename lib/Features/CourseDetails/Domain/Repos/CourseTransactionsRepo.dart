import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/FetchTransactionsResponseEntity.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';

abstract class CourseTransactionsRepo {
  Future<Either<Failure, FetchTransactionsResponseEntity>>
  fetchCourseTransactions({required String courseId, required bool isPaginate});
}
