import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/EditCourseViewWidgets/CustomCourseLanguageDropdownButton.dart';

class CourseLanguageSelector extends StatelessWidget {
  final ValueChanged<String?> onChanged;
  final String? hintText;

  const CourseLanguageSelector({
    super.key,
    required this.onChanged,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomLanguageDropdownButton(
      onValueChange: onChanged,
      hintText: hintText,
    );
  }
}
