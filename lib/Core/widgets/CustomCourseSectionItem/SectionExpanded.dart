import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseSectionEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCourseSectionItem/CustomSectionListView.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSectionsCubit/CourseSectionsCubit.dart';
import 'package:sintir_dashboard/constant.dart';

class SectionExpanded extends StatelessWidget {
  const SectionExpanded({
    super.key,
    required this.sectionItem,
    required this.sectionLessons,
    required this.course,
  });

  final CourseSectionEntity sectionItem;
  final List<dynamic> sectionLessons;
  final CourseEntity course;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<CourseSectionsCubit, CourseSectionsState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              state is GetSectionItemsLoading &&
                  state.sectionId == sectionItem.id
              ? const Center(
                  child: CircularProgressIndicator(color: KMainColor),
                )
              : CustomSectionListView(
                  section: sectionItem,
                  items: sectionLessons,
                  course: course,
                ),
        );
      },
    );
  }
}
