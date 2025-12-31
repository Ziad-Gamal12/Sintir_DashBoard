import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/CourseReportsItemEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetCourseReportsResponseEntity.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';

abstract class CourseReportsRepo {
  Future<Either<Failure, GetCourseReportsResponseEntity>> getCourseReports({
    required String courseId,
    required bool isPaginate,
  });
  Future<Either<Failure, void>> addCourseReport({
    required String courseId,
    required CourseReportEntity reportEntity,
  });
}
