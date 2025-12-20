import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseTestItemEntities/ExamResultSolvedQuestionEntity.dart';

class Examresultsolvedquestionmodel {
  final String selectedAnswer,
      rightAnswer,
      questionTitle,
      imageUrl,
      solutionImageUrl;
  final bool isCorrect;

  Examresultsolvedquestionmodel({
    required this.selectedAnswer,
    required this.rightAnswer,
    required this.questionTitle,
    required this.solutionImageUrl,
    required this.imageUrl,
    required this.isCorrect,
  });

  factory Examresultsolvedquestionmodel.fromJson(Map<String, dynamic> json) =>
      Examresultsolvedquestionmodel(
        selectedAnswer: json["selectedAnswer"],
        imageUrl: json["imageUrl"],
        rightAnswer: json["rightAnswer"],
        questionTitle: json["questionTitle"],
        solutionImageUrl: json["solutionImageUrl"] ?? "",
        isCorrect: json["isCorrect"],
      );

  factory Examresultsolvedquestionmodel.fromEntity(
    ExamResultSolvedQuestionEntity entity,
  ) => Examresultsolvedquestionmodel(
    selectedAnswer: entity.selectedAnswer,
    imageUrl: entity.imageUrl,
    questionTitle: entity.questionTitle,
    rightAnswer: entity.rightAnswer,
    solutionImageUrl: entity.solutionImageUrl,
    isCorrect: entity.isCorrect,
  );
  ExamResultSolvedQuestionEntity toEntity() => ExamResultSolvedQuestionEntity(
    selectedAnswer: selectedAnswer,
    questionTitle: questionTitle,
    imageUrl: imageUrl,
    solutionImageUrl: solutionImageUrl,
    rightAnswer: rightAnswer,
    isCorrect: isCorrect,
  );

  Map<String, dynamic> toJson() => {
    "selectedAnswer": selectedAnswer,
    "rightAnswer": rightAnswer,
    "isCorrect": isCorrect,
    "questionTitle": questionTitle,
    "solutionImageUrl": solutionImageUrl,
    "imageUrl": imageUrl,
  };
}
