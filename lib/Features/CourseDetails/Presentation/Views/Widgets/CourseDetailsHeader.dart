import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDetailsHeaderActionButtons.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDetailsHeaderCourseInfo.dart';

class CourseDetailsHeader extends StatelessWidget {
  const CourseDetailsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(flex: 3, child: CourseDetailsHeaderCourseInfo()),
        Expanded(child: const CourseDetailsHeaderActionButtons()),
      ],
    );
  }
}
