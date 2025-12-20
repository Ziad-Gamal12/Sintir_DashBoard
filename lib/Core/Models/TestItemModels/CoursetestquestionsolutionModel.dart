import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseTestItemEntities/CourseTestQuestionSolutionEntity.dart';

class Coursetestquestionsolutionmodel {
  final String answer;
  final bool isCorrect;

  Coursetestquestionsolutionmodel({
    required this.answer,
    required this.isCorrect,
  });

  factory Coursetestquestionsolutionmodel.fromJson(Map<String, dynamic> json) {
    return Coursetestquestionsolutionmodel(
      answer: json['answer'],
      isCorrect: json['isCorrect'],
    );
  }
  factory Coursetestquestionsolutionmodel.fromEntity({
    required CourseTestQuestionSolutionEntity coursetestquestionsolution,
  }) {
    return Coursetestquestionsolutionmodel(
      answer: coursetestquestionsolution.answer,
      isCorrect: coursetestquestionsolution.isCorrect,
    );
  }

  CourseTestQuestionSolutionEntity toEntity() {
    return CourseTestQuestionSolutionEntity(
      answer: answer,
      isCorrect: isCorrect,
    );
  }

  Map<String, dynamic> toJson() => {'answer': answer, 'isCorrect': isCorrect};
}
