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
      // Change to mainAxisSize.min so it doesn't try to take up infinite space
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          courseItem.title,
          maxLines: 1,
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
          style: styles.semiBold14.copyWith(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        // Use Flexible to allow the description to shrink if the card is small
        Flexible(
          child: Text(
            courseItem.description,
            maxLines: 2,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: styles.regular11.copyWith(
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(height: 1, thickness: 0.5),
        ),

        if (courseItem.contentcreaterentity != null)
          CourseItemDetailsContentCreatorCard(
            contentcreaterentity: courseItem.contentcreaterentity!,
          ),
      ],
    );
  }
}
