import 'package:sintir_dashboard/Core/Entities/CourseReportsItemEntity.dart';

class GetCourseReportsResponseEntity {
  final List<CourseReportEntity> reports;
  final bool hasMore;
  final bool isPaginate;

  GetCourseReportsResponseEntity({
    required this.reports,
    required this.hasMore,
    required this.isPaginate,
  });
}
