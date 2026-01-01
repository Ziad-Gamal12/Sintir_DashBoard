import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseSectionEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCourseSectionItem/SectionExpanded.dart';
import 'package:sintir_dashboard/constant.dart';

class SectionItemContent extends StatelessWidget {
  final bool isExpanded;
  final bool isLoading;
  final CourseSectionEntity sectionItem;
  final List<dynamic> sectionLessons;
  final CourseEntity course;

  const SectionItemContent({
    super.key,
    required this.isExpanded,
    required this.isLoading,
    required this.sectionItem,
    required this.sectionLessons,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: const SizedBox(width: double.infinity),
      secondChild: Column(
        children: [
          Divider(height: 1, color: KMainColor.withOpacity(0.1)),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: KMainColor,
                ),
              ),
            )
          else
            SectionExpanded(
              sectionItem: sectionItem,
              sectionLessons: sectionLessons,
              course: course,
            ),
        ],
      ),
      crossFadeState: isExpanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );
  }
}
