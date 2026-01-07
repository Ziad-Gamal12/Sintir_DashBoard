import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/ContentCreaterEntity.dart';
import 'package:sintir_dashboard/Core/Managers/content_creator_courses_cubit/content_creator_courses_cubit.dart';
import 'package:sintir_dashboard/Features/ContentCreatorProfile/Presentation/Views/Widgets/ContentCreatorCoursesGrid.dart';
import 'package:sintir_dashboard/Features/ContentCreatorProfile/Presentation/Views/Widgets/ContentCreatorCoursesHeader.dart';
import 'package:sintir_dashboard/Features/ContentCreatorProfile/Presentation/Views/Widgets/ContentCreatorDetails.dart';

class ContentCreatorProfileBody extends StatefulWidget {
  const ContentCreatorProfileBody({
    super.key,
    required this.contentcreaterentity,
  });
  final ContentCreatorEntity contentcreaterentity;

  @override
  State<ContentCreatorProfileBody> createState() =>
      _ContentCreatorProfileBodyState();
}

class _ContentCreatorProfileBodyState extends State<ContentCreatorProfileBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<ContentCreatorCoursesCubit>().getContentCreatorCourses(
        userId: widget.contentcreaterentity.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ContentCreatorDetails(
              contentcreaterentity: widget.contentcreaterentity,
            ),
          ),
          const SliverToBoxAdapter(child: ContentCreatorCoursesHeader()),
          const ContentCreatorCoursesGrid(),
        ],
      ),
    );
  }
}
