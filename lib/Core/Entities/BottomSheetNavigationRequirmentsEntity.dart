// ignore_for_file: file_names

import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';

class DisplayCourseBottomsheetNavigationRequirmentsEntity {
  final CourseEntity course;
  bool isSubscribed;
  DisplayCourseBottomsheetNavigationRequirmentsEntity({
    required this.course,
    required this.isSubscribed,
  });
}
