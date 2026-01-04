import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/ContentCreaterEntity.dart';
import 'package:sintir_dashboard/Core/Managers/content_creator_courses_cubit/content_creator_courses_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CreatorAvatar.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CreatorNameTitle.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CreatorStats.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CustomNavigateToInstructorProfileButton.dart';

class ContentCreatorDetails extends StatefulWidget {
  final Contentcreaterentity contentcreaterentity;

  const ContentCreatorDetails({super.key, required this.contentcreaterentity});

  @override
  State<ContentCreatorDetails> createState() => _ContentCreatorDetailsState();
}

class _ContentCreatorDetailsState extends State<ContentCreatorDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creator = widget.contentcreaterentity;
    final ThemeData theme = Theme.of(context);
    final Color cardBackgroundColor = theme.cardColor;
    final Color shadowColor = theme.shadowColor;

    final subscribersCount = context
        .watch<ContentCreatorCoursesCubit>()
        .getContentCreatorSubscribersCount();

    final coursesCount = context
        .watch<ContentCreatorCoursesCubit>()
        .getContentCreatorCoursesCount();

    return ScaleTransition(
      scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            CreatorAvatar(imageUrl: creator.profileImageUrl),
            const SizedBox(height: 16),
            CreatorNameTitle(name: creator.name, title: creator.title),
            const SizedBox(height: 20),
            CreatorStats(
              coursesCount: coursesCount,
              subscribersCount: subscribersCount,
            ),
            const SizedBox(height: 20),
            CustomNavigateToInstructorProfileButton(theme: theme),
          ],
        ),
      ),
    );
  }
}
