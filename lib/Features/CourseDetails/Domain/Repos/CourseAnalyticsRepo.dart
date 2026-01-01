import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart'; // Ensure you have your Failure class here
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/AnalyticsResultEntity.dart';

abstract class CourseAnalyticsRepo {
  Future<Either<Failure, AnalyticsResultEntity>> getCourseRevenue(
    String courseId,
  );
  Future<Either<Failure, AnalyticsResultEntity>> getCourseSubscribers(
    String courseId,
  );
  Future<Either<Failure, AnalyticsResultEntity>> getCourseReports(
    String courseId,
  );
  Future<Either<Failure, AnalyticsResultEntity>> getCourseFeedbacks(
    String courseId,
  );
}
