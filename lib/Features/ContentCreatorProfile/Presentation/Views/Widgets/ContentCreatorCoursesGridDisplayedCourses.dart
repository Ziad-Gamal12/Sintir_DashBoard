import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/widgets/Custom%20Course%20Widgets/CustomCourseItem.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/ResponsiveCourseDeatilsView.dart';

class ContentCreatorCoursesGridDisplayedCourses extends StatelessWidget {
  const ContentCreatorCoursesGridDisplayedCourses({
    super.key,
    required this.coursesList,
  });
  final List<CourseEntity> coursesList;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 1. Logic for a side-sheet (typically ~35% width)
          // On a standard desktop (1920px), 35% is ~670px.
          // On smaller screens, it could be ~400px.

          int crossAxisCount;
          double aspectRatio;

          if (constraints.maxWidth > 1200) {
            crossAxisCount = 4;
            aspectRatio = 0.85; // Portrait
          } else if (constraints.maxWidth > 800) {
            crossAxisCount = 3;
            aspectRatio = 0.8;
          } else if (constraints.maxWidth > 500) {
            // This is the likely state for your Side Sheet on most desktops
            crossAxisCount = 2;
            aspectRatio = 0.75; // Taller to prevent text overflow
          } else {
            // Very narrow side sheet or mobile
            crossAxisCount = 1;
            aspectRatio = 1.3; // Wide layout for single column
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              // Using the calculated ratio to ensure vertical room
              childAspectRatio: aspectRatio,
            ),
            itemCount: coursesList.length,
            itemBuilder: (context, index) {
              return CustomCourseItem(
                courseItem: coursesList[index],
                ontap: () => GoRouter.of(context).push(
                  ResponsiveCourseDeatilsView.routeName,
                  extra: coursesList[index],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
