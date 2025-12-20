import 'package:flutter/material.dart';

class CourseTestQuestionSolutionEntity {
  String answer;
  bool isCorrect;
  TextEditingController solutionController;
  String id = DateTime.now().millisecondsSinceEpoch.toString();

  CourseTestQuestionSolutionEntity(
      {required this.answer, required this.isCorrect})
      : solutionController = TextEditingController(text: answer);

  void dispose() {
    solutionController.dispose();
  }
}
