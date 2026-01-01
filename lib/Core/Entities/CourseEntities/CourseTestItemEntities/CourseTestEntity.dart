import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseTestItemEntities/CourseTestQuestionEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseTestItemEntities/CourseTestQuestionSolutionEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseTestItemEntities/CourseTestViewNavigationsRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseTestItemEntities/TestResulteEntity.dart';
import 'package:sintir_dashboard/Core/Entities/JoinedByEntity.dart';
import 'package:sintir_dashboard/Core/Utils/imageAssets.dart';

class CourseTestEntity {
  int durationTime;
  String title;
  final List<CourseTestQuestionEntity> questions;
  String? type;
  String id;
  bool? isOpened;
  bool showResult;
  int? numberOfAttempts;
  String preffixImage = Assets.assetsIconsSVGIconsExamIcon;

  CourseTestEntity({
    required this.durationTime,
    required this.title,
    required this.questions,
    this.isOpened,
    required this.numberOfAttempts,
    required this.showResult,
    required this.id,
    this.type = "Test",
  });
  static CourseTestEntity empty() => CourseTestEntity(
    durationTime: 0,
    showResult: false,
    numberOfAttempts: 0,
    title: '',
    questions: [],
    id: '',
  );
  CourseTestEntity copyWith({
    int? durationTime,
    String? title,
    List<JoinedByEntity>? joinedBy,
    List<CourseTestQuestionEntity>? questions,
    String? type,
    String? preffixImage,
    bool? isOpened,
    bool? showResult,
    List<TestResultEntity>? results,
  }) {
    return CourseTestEntity(
      id: id,
      showResult: showResult ?? this.showResult,
      type: type ?? this.type,
      numberOfAttempts: numberOfAttempts,
      durationTime: durationTime ?? this.durationTime,
      title: title ?? this.title,
      questions: questions ?? this.questions,
    );
  }

  void ontap({
    required BuildContext context,
    required CourseExamViewNavigationsRequirmentsEntity item,
    required CourseEntity course,
  }) {}

  void addQuestion(CourseTestQuestionEntity? question) {
    question ??= CourseTestQuestionEntity(
      isOpened: false,
      questionTitle: "",
      solutions: [
        CourseTestQuestionSolutionEntity(answer: "0", isCorrect: false),
      ],
    );
    questions.add(question);
  }

  void removeQuestion(CourseTestQuestionEntity question) {
    question.questionController.dispose();
    questions.remove(question);
  }

  void dispose() {
    for (CourseTestQuestionEntity question in questions) {
      question.dispose();
      question.disposeSolutions();
    }
  }
}
