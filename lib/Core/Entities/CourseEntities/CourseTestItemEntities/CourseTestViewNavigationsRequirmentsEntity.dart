import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseTestItemEntities/CourseTestEntity.dart';

class CourseExamViewNavigationsRequirmentsEntity {
  final CourseTestEntity test;
  final CourseEntity course;
  final String sectionId;

  CourseExamViewNavigationsRequirmentsEntity({
    required this.test,
    required this.course,
    required this.sectionId,
  });
}
