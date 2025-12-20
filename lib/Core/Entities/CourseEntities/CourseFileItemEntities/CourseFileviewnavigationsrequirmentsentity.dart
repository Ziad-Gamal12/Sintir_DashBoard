import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseFileItemEntities/CourseFileEntity.dart';

class Coursefileviewnavigationsrequirmentsentity {
  final CourseFileEntity file;
  final CourseEntity course;
  final String sectionId;

  Coursefileviewnavigationsrequirmentsentity({
    required this.file,
    required this.course,
    required this.sectionId,
  });
}
