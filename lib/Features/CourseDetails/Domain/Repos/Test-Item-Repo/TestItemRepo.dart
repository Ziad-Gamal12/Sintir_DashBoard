// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseTestItemEntities/CourseTestEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseTestItemEntities/CourseTestQuestionEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseTestItemEntities/TestResulteEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetExamResultsReponseEntity.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';

abstract class Testitemrepo {
  Future<Either<Failure, void>> uploadTestQuestionsImages({
    required List<CourseTestQuestionEntity> questions,
  });
  Future<Either<Failure, void>> uploadTestQuestionsSolutionsImages({
    required List<CourseTestQuestionEntity> questions,
  });
  Future<Either<Failure, void>> addTestResult({
    required TestResultEntity testResult,
    required String courseId,
    required String userUID,
    required String sectionId,
    required String sectionItemId,
  });
  Future<Either<Failure, void>> updateTest({
    required CourseTestEntity test,
    required String courseId,
    required String sectionId,
  });
  Future<Either<Failure, GetExamResultsReponseEntity>> getTestResults({
    required String courseId,
    required String sectionId,
    required String examId,
    required bool isPaginate,
  });
  Future<Either<Failure, TestResultEntity>> getHighestScore({
    required String courseId,
    required String sectionId,
    required String sectionItemId,
  });
  Future<Either<Failure, TestResultEntity>> getLowestScore({
    required String courseId,
    required String sectionId,
    required String sectionItemId,
  });
  Future<Either<Failure, int>> getAttendedCount({
    required String courseId,
    required String sectionId,
    required String testId,
  });
  Future<Either<Failure, int>> getSuccessedStudentsCount({
    required String courseId,
    required String sectionId,
    required String testId,
  });
  Future<Either<Failure, int>> getFailedStudentsCount({
    required String courseId,
    required String sectionId,
    required String testId,
  });
  Future<Either<Failure, List<TestResultEntity>>> getUserResultsOfExam({
    required String courseId,
    required String sectionId,
    required String examId,
    required String userId,
  });
  Future<Either<Failure, void>> storeMyMistakes({
    required TestResultEntity testResult,
    required String userUID,
  });
  Future<Either<Failure, bool>> checkIfTheResultHidden({
    required String courseId,
    required String sectionId,
    required String testId,
  });
  Future<Either<Failure, bool>> hasReachedMaxAttempts({
    required String courseId,
    required String sectionId,
    required CourseTestEntity test,
    required String userId,
  });
}
