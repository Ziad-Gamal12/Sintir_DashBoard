// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/widgets/Custom%20Course%20Widgets/CourseItemDetails.dart';
import 'package:sintir_dashboard/Core/widgets/Custom%20Course%20Widgets/CourseItemImage.dart';
class CustomCourseItem extends StatefulWidget {
  final VoidCallback ontap;
  final CourseEntity courseItem;

  const CustomCourseItem({super.key, required this.ontap, required this.courseItem});

  @override
  State<CustomCourseItem> createState() => _CustomCourseItemState();
}

class _CustomCourseItemState extends State<CustomCourseItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          // Premium web uses thin borders instead of heavy shadows
          border: Border.all(
            color: isHovered 
                ? Theme.of(context).primaryColor 
                : (isDark ? Colors.white10 : Colors.grey.shade200),
            width: 1.5,
          ),
          boxShadow: [
            if (isHovered)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
          ],
        ),
        child: InkWell(
          onTap: widget.ontap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section with AspectRatio to prevent stretching
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    CourseItemImage(imageUrl: widget.courseItem.posterUrl ?? ""),
                    // Premium Badge (Level)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.courseItem.level,
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CourseItemDetails(courseItem: widget.courseItem),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}