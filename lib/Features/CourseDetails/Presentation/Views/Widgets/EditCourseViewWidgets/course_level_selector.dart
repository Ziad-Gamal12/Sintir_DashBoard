import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/EditCourseViewWidgets/CustomEducationLevelDropdownButton.dart';

class CourseLevelSelector extends StatelessWidget {
  final ValueChanged<String?> onChanged;
  final String? hintText;

  const CourseLevelSelector({
    super.key,
    required this.onChanged,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomEducationLevelDropdownButton(
      onValueChange: onChanged,
      hintText: hintText,
    );
  }
}
