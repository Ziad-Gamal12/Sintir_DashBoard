class CourseReportEntity {
  final DateTime date;
  String type;
  String description;

  CourseReportEntity(
      {required this.date, required this.type, required this.description});
  static CourseReportEntity empty() => CourseReportEntity(
        date: DateTime.now(),
        type: "",
        description: "",
      );
}
