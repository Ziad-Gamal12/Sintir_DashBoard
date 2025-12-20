import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseTestItemEntities/ExamResultSolvedQuestionEntity.dart';
import 'package:sintir_dashboard/Core/Entities/JoinedByEntity.dart';

class TestResultEntity {
  final String serialNumber;
  final DateTime joinedDate;
  final int totalQuestions;
  final int solvedQuestions;
  bool isPassed;
  final JoinedByEntity joinedbyentity;
  final int result;
  final List<ExamResultSolvedQuestionEntity> questionsSolvedListEntity;
  final String courseId;
  final String sectionId;
  final String testId;
  TestResultEntity({
    required this.serialNumber,
    required this.joinedDate,
    required this.totalQuestions,
    required this.isPassed,
    required this.solvedQuestions,
    required this.sectionId,
    required this.testId,
    required this.joinedbyentity,
    required this.courseId,
    required this.result,
    required this.questionsSolvedListEntity,
  });
  static TestResultEntity empty() {
    return TestResultEntity(
      serialNumber: "123456789",
      joinedDate: DateTime.now(),
      sectionId: "00000",
      testId: "00000",
      totalQuestions: 0,
      courseId: "00000",
      solvedQuestions: 0,
      joinedbyentity: JoinedByEntity.empty(),
      result: 0,
      isPassed: false,
      questionsSolvedListEntity: [],
    );
  }
}
