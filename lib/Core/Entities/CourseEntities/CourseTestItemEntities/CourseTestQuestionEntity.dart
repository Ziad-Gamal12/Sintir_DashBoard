// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseTestItemEntities/CourseTestQuestionSolutionEntity.dart';

class CourseTestQuestionEntity {
  String? questionTitle;
  List<CourseTestQuestionSolutionEntity> solutions;
  TextEditingController questionController;
  bool isOpened;
  String? imageUrl;
  String? solutionImageUrl;
  String? selectedSolution;
  File? imageFile;
  File? solutionFile;

  CourseTestQuestionEntity({
    required this.questionTitle,
    required this.solutions,
    required this.isOpened,
    this.imageUrl,
    this.imageFile,
    this.solutionImageUrl,
    this.solutionFile,
    this.selectedSolution = "",
  }) : questionController = TextEditingController(text: questionTitle);

  void addSolution(CourseTestQuestionSolutionEntity? solution) {
    if (solution != null) {
      solutions.add(solution);
    }

    solutions.add(
      CourseTestQuestionSolutionEntity(answer: "", isCorrect: false),
    );
  }

  void removeSolution(CourseTestQuestionSolutionEntity solution) {
    solutions.remove(solution);
  }

  void dispose() {
    questionController.dispose();
  }

  void disposeSolutions() {
    for (CourseTestQuestionSolutionEntity solution in solutions) {
      solution.solutionController.dispose();
    }
  }
}
