import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CourseTableWidgets/CustomCourseTable.dart';

class CustomAllCoursesPageViewItem extends StatelessWidget {
  const CustomAllCoursesPageViewItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveCourseTable(
      isLoading: false,
      onLoadMore: (rowIndex) {},
      courses: CourseEntity.fakeCourses,
    );
  }
}
