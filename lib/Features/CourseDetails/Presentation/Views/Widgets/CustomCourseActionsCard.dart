import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/HideCourseSwitcher.dart';
import 'package:sintir_dashboard/core/utils/backend_endpoints.dart';

class CustomCourseActionsCard extends StatelessWidget {
  const CustomCourseActionsCard({super.key, required this.course});
  final CourseEntity course;
  @override
  Widget build(BuildContext context) {
    AppTextStyles textStyles = AppTextStyles(context);
    ThemeData theme = Theme.of(context);
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("إجراءات إدارية", style: textStyles.semiBold16),
          const SizedBox(height: 16),
          HideCourseSwitcher(
            isHiddin: course.state == BackendEndpoints.courseArchivedState,
            onChanged: (val) {},
          ),
          const SizedBox(height: 12),
          Custombutton(
            text: "",
            color: Colors.transparent.withOpacity(.2),
            textColor: theme.textTheme.bodySmall?.color ?? Colors.white,
            onPressed: () {},
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
          ),
          const SizedBox(height: 12),

          Custombutton(
            text: "",
            color: Colors.red.withOpacity(.1),
            textColor: Colors.red,
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "حذف الدورة",
                  style: textStyles.regular14.copyWith(
                    color: Colors.red.shade700,
                  ),
                ),
                Icon(Icons.delete, color: Colors.red.shade700),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
