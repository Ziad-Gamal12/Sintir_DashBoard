import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/ContentCreaterEntity.dart';
import 'package:sintir_dashboard/Core/Managers/content_creator_courses_cubit/content_creator_courses_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseInstructorSectionCardWidgets/CreatorAvatar.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseInstructorSectionCardWidgets/CreatorNameTitle.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseInstructorSectionCardWidgets/CreatorStats.dart';

class ContentCreatorDetails extends StatelessWidget {
  final ContentCreatorEntity contentcreaterentity;

  const ContentCreatorDetails({super.key, required this.contentcreaterentity});

  @override
  Widget build(BuildContext context) {
    final creator = contentcreaterentity;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Fetching stats from Cubit
    final subscribersCount = context
        .watch<ContentCreatorCoursesCubit>()
        .getContentCreatorSubscribersCount();
    final coursesCount = context
        .watch<ContentCreatorCoursesCubit>()
        .getContentCreatorCoursesCount();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CreatorAvatar(imageUrl: creator.profileImageUrl),
          const SizedBox(height: 20),
          CreatorNameTitle(name: creator.name, title: creator.title),
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 24),
          CreatorStats(
            coursesCount: coursesCount,
            subscribersCount: subscribersCount,
          ),
        ],
      ),
    );
  }
}
