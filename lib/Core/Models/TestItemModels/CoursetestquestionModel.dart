import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseTestItemEntities/CourseTestQuestionEntity.dart';
import 'package:sintir_dashboard/Core/Models/TestItemModels/CoursetestquestionsolutionModel.dart';

class Coursetestquestionmodel {
  final String? questionTitle;
  final List<Map<String, dynamic>> solutions;
  final bool isOpened;
  String? imageUrl;
  String? solutionUrl;
  String? selectedSolution;

  Coursetestquestionmodel({
    required this.questionTitle,
    required this.solutions,
    required this.isOpened,
    this.solutionUrl,
    this.imageUrl,
    this.selectedSolution = "",
  });

  factory Coursetestquestionmodel.fromJson(Map<String, dynamic> json) =>
      Coursetestquestionmodel(
        questionTitle: json["questionTitle"] ?? "",
        solutions: (json["solutions"] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
        isOpened: json["isOpened"],
        imageUrl: json["imageUrl"],
        solutionUrl: json["solutionUrl"],
        selectedSolution: json["selectedSolution"],
      );
  factory Coursetestquestionmodel.fromEntity(
    CourseTestQuestionEntity courseTestQuestionModel,
  ) => Coursetestquestionmodel(
    questionTitle: courseTestQuestionModel.questionTitle,
    solutions: courseTestQuestionModel.solutions
        .map(
          (e) => Coursetestquestionsolutionmodel.fromEntity(
            coursetestquestionsolution: e,
          ).toJson(),
        )
        .toList(),
    solutionUrl: courseTestQuestionModel.solutionImageUrl,
    isOpened: courseTestQuestionModel.isOpened,
    imageUrl: courseTestQuestionModel.imageUrl,
    selectedSolution: courseTestQuestionModel.selectedSolution,
  );

  CourseTestQuestionEntity toEntity() => CourseTestQuestionEntity(
    questionTitle: questionTitle,
    solutions: solutions
        .map((e) => Coursetestquestionsolutionmodel.fromJson(e).toEntity())
        .toList(),
    isOpened: isOpened,
    solutionImageUrl: solutionUrl,
    imageUrl: imageUrl,
    selectedSolution: selectedSolution,
  );
  Map<String, dynamic> toJson() => {
    "questionTitle": questionTitle,
    "solutions": solutions,
    "isOpened": isOpened,
    "imageUrl": imageUrl,
    "solutionUrl": solutionUrl,
    "selectedSolution": selectedSolution,
  };
}
