import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseVideoItemEntities/CourseVedioItemEntity.dart';

class CourseVideoViewNavigationsRequirmentsEntity {
  final CourseVideoItemEntity video;
  final CourseEntity courseEntity;
  final String sectionId;

  CourseVideoViewNavigationsRequirmentsEntity({
    required this.video,
    required this.courseEntity,
    required this.sectionId,
  });
}
