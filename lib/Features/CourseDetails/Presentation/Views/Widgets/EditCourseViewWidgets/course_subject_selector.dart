import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/EditCourseViewWidgets/CustomSubjectDropdownButton.dart';

class CourseSubjectSelector extends StatelessWidget {
  final ValueChanged<String?> onChanged;
  final String? hintText;

  const CourseSubjectSelector({
    super.key,
    required this.onChanged,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSubjectDropdownButton(
      onValueChange: onChanged,
      hintText: hintText,
    );
  }
}
