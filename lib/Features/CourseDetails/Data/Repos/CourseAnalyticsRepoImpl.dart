import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';
import 'package:sintir_dashboard/Core/Services/CourseAnalyticsService.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseAnalyticsRepo.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/AnalyticsResultEntity.dart';

class CourseAnalyticsRepoImpl implements CourseAnalyticsRepo {
  final CourseAnalyticsService courseAnalyticsService;

  CourseAnalyticsRepoImpl({required this.courseAnalyticsService});

  @override
  Future<Either<Failure, AnalyticsResultEntity>> getCourseRevenue(
    String courseId,
  ) async {
    try {
      final result = await courseAnalyticsService.getCourseRevenue(courseId);
      return right(result);
    } catch (e) {
      return left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnalyticsResultEntity>> getCourseSubscribers(
    String courseId,
  ) async {
    try {
      final result = await courseAnalyticsService.getCourseSubscribers(
        courseId,
      );
      return right(result);
    } catch (e) {
      return left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnalyticsResultEntity>> getCourseReports(
    String courseId,
  ) async {
    try {
      final result = await courseAnalyticsService.getCourseReports(courseId);
      return right(result);
    } catch (e) {
      return left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnalyticsResultEntity>> getCourseFeedbacks(
    String courseId,
  ) async {
    try {
      final result = await courseAnalyticsService.getCourseFeedbacks(courseId);
      return right(result);
    } catch (e) {
      return left(ServerFailure(message: e.toString()));
    }
  }
}
