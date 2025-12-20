class ExamResultSolvedQuestionEntity {
  final String selectedAnswer,
      rightAnswer,
      questionTitle,
      imageUrl,
      solutionImageUrl;
  final bool isCorrect;

  ExamResultSolvedQuestionEntity(
      {required this.selectedAnswer,
      required this.questionTitle,
      required this.solutionImageUrl,
      required this.rightAnswer,
      required this.imageUrl,
      required this.isCorrect});

  static List<ExamResultSolvedQuestionEntity> empty() => List.generate(
      6,
      (index) => ExamResultSolvedQuestionEntity(
          selectedAnswer: 'loading',
          questionTitle: 'loading',
          rightAnswer: 'loading',
          solutionImageUrl:
              "https://cdn-icons-png.flaticon.com/128/6356/6356630.png",
          imageUrl:
              "https://foundr.com/wp-content/uploads/2021/09/Best-online-course-platforms.png",
          isCorrect: false));
}
