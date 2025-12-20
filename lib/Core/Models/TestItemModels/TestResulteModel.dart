import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseTestItemEntities/TestResulteEntity.dart';
import 'package:sintir_dashboard/Core/Models/JoinedByModel.dart';
import 'package:sintir_dashboard/Core/Models/TestItemModels/ExamResultSolvedQuestionModel.dart';

class Testresultemodel {
  final String serialNumber;
  final DateTime joinedDate;
  final int totalQuestions;
  final int solvedQuestions;
  final Map<String, dynamic> joinedby;
  final int result;
  final bool isPassed;
  final String courseId;
  final String sectionId;
  final String testId;
  final List<Map<String, dynamic>> questionsSolvedList;

  Testresultemodel({
    required this.serialNumber,
    required this.joinedDate,
    required this.totalQuestions,
    required this.isPassed,
    required this.sectionId,
    required this.testId,
    required this.solvedQuestions,
    required this.joinedby,
    required this.courseId,
    required this.result,
    required this.questionsSolvedList,
  });

  factory Testresultemodel.fromJson(Map<String, dynamic> json) {
    return Testresultemodel(
      serialNumber: json['serialNumber'],
      joinedDate: (json['joinedDate'] as Timestamp).toDate(),
      totalQuestions: json['totalQuestions'],
      sectionId: json['sectionId'],
      testId: json['testId'],
      isPassed: json['isPassed'],
      solvedQuestions: json['solvedQuestions'],
      joinedby: json['joinedby'],
      result: json['result'],
      courseId: json['courseId'] ?? "",
      questionsSolvedList: (json["questionsSolvedList"] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  factory Testresultemodel.fromEntity(
    TestResultEntity entity, {
    bool includeCourseTest = true,
  }) {
    return Testresultemodel(
      serialNumber: entity.serialNumber,
      joinedDate: entity.joinedDate,
      sectionId: entity.sectionId,
      testId: entity.testId,
      isPassed: entity.isPassed,
      courseId: entity.courseId,
      totalQuestions: entity.totalQuestions,
      solvedQuestions: entity.solvedQuestions,
      joinedby: JoinedbyModel.fromEntity(entity.joinedbyentity).toJson(),
      result: entity.result,
      questionsSolvedList: entity.questionsSolvedListEntity
          .map((e) => Examresultsolvedquestionmodel.fromEntity(e).toJson())
          .toList(),
    );
  }

  TestResultEntity toEntity() {
    return TestResultEntity(
      serialNumber: serialNumber,
      joinedDate: joinedDate,
      sectionId: sectionId,
      testId: testId,
      isPassed: isPassed,
      totalQuestions: totalQuestions,
      solvedQuestions: solvedQuestions,
      courseId: courseId,
      joinedbyentity: JoinedbyModel.fromJson(joinedby).toEntity(),
      result: result,
      questionsSolvedListEntity: questionsSolvedList
          .map((e) => Examresultsolvedquestionmodel.fromJson(e).toEntity())
          .toList(),
    );
  }

  Map<String, dynamic> toJson({bool includeCourseTest = true}) => {
    "serialNumber": serialNumber,
    "joinedDate": joinedDate,
    "totalQuestions": totalQuestions,
    "solvedQuestions": solvedQuestions,
    "joinedby": joinedby,
    "isPassed": isPassed,
    "result": result,
    "courseId": courseId,
    "sectionId": sectionId,
    "testId": testId,
    "questionsSolvedList": questionsSolvedList,
  };
}
