// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/widgets/Custom%20Course%20Widgets/CourseItemDetails.dart';
import 'package:sintir_dashboard/Core/widgets/Custom%20Course%20Widgets/CourseItemImage.dart';

class CustomCourseItem extends StatefulWidget {
  final VoidCallback ontap;
  final CourseEntity courseItem;

  const CustomCourseItem({
    super.key,
    required this.ontap,
    required this.courseItem,
  });

  @override
  State<CustomCourseItem> createState() => _CustomCourseItemState();
}

class _CustomCourseItemState extends State<CustomCourseItem> {
  @override
  Widget build(BuildContext context) {
    final course = widget.courseItem;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.ontap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black12 : Colors.black12,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CourseItemImage(imageUrl: course.posterUrl ?? ""),
                ),
                const SizedBox(height: 8),
                Expanded(child: CourseItemDetails(courseItem: course)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
