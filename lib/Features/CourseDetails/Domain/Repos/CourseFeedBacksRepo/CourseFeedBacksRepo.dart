import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/CourseFeedBackItemEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetCourseFeedBacksResponseEntity.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';

abstract class CourseFeedBacksRepo {
  Future<Either<Failure, void>> addCourseFedBack({
    required String courseId,
    required CoursefeedbackItemEntity review,
  });
  Future<Either<Failure, void>> deleteCourseFedBack({
    required String courseId,
    required String feedBackId,
  });
  Future<Either<Failure, GetCourseFeedBacksResponseEntity>> getCourseFedBacks({
    required String courseId,
    required bool isPaginate,
  });
}
