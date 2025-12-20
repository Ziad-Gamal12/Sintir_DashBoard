import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/Custom%20Course%20Widgets/CourseItemDetailsContentCreatorCard.dart';

class CourseItemDetails extends StatelessWidget {
  const CourseItemDetails({super.key, required this.courseItem});

  final CourseEntity courseItem;

  @override
  Widget build(BuildContext context) {
    final styles = AppTextStyles(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          courseItem.title,
          maxLines: 1,
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
          style: styles.semiBold12.copyWith(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          courseItem.description,
          maxLines: 2,
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
          style: styles.regular10.copyWith(
            color: isDark ? Colors.white70 : Colors.grey,
          ),
        ),
        const Spacer(),
        if (courseItem.contentcreaterentity != null)
          InkWell(
            onTap: () {},
            child: CourseItemDetailsContentCreatorCard(
              contentcreaterentity: courseItem.contentcreaterentity!,
            ),
          )
        else
          const SizedBox(),
      ],
    );
  }
}
