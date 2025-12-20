import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseSectionEntity.dart';

class GetCourseSectionsResonseEntity {
  final List<CourseSectionEntity> sections;
  final bool hasMore;
  final bool isPaginate;
  GetCourseSectionsResonseEntity({
    required this.sections,
    required this.hasMore,
    required this.isPaginate,
  });
}
