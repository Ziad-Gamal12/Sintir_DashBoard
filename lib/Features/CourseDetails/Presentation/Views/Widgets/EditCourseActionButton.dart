import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Helper/ShowBottomSheet.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/EditCourseViewWidgets/EditCourseView.dart';

class EditCourseActionButton extends StatelessWidget {
  const EditCourseActionButton({
    super.key,
    required this.theme,
    required this.textStyles,
    required this.currentCourse,
  });

  final ThemeData theme;
  final AppTextStyles textStyles;
  final CourseEntity currentCourse;

  @override
  Widget build(BuildContext context) {
    return Custombutton(
      text: "",
      color: Colors.transparent.withOpacity(.2),
      textColor: theme.textTheme.bodySmall?.color ?? Colors.white,
      onPressed: () {
        showCustomModalBottomSheet(
          child: EditCourseView(currentCourse: currentCourse),
          context: context,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "تعديل البيانات",
            style: textStyles.regular14.copyWith(
              color: theme.textTheme.bodySmall?.color ?? Colors.white,
            ),
          ),
          Icon(
            Icons.edit,
            color: theme.textTheme.bodySmall?.color ?? Colors.white,
          ),
        ],
      ),
    );
  }
}
