// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetCourseSubscribersEntity.dart';
import 'package:sintir_dashboard/Core/errors/Failures.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';

abstract class CourseSubscibtionsRepo {
  Future<bool> checkIfSubscribed({
    required String userID,
    required String courseID,
  });
  Future<Either<Failure, GetCourseSubscribersEntity>> getSubscribers({
    required String courseID,
    required bool isPaginate,
  });
  Future<Either<Failure, GetCourseSubscribersEntity>> searchSubscribers({
    required String courseID,
    required String searchKey,
    required bool isPaginate,
  });
  Future<Either<Failure, void>> addSubscriber({
    required CourseEntity course,
    required UserEntity userEntity,
  });
  Future<Either<Failure, void>> deleteSubscriber({
    required String courseID,
    required String subscriberID,
  });
  Future<Either<Failure, int>> getSubscribersCount({required String courseID});
}
