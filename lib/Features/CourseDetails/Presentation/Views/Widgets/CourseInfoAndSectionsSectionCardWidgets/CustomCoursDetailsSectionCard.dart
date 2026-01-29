import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSectionsCubit/CourseSectionsCubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseInfoAndSectionsSectionCardWidgets/CourseDetailsDescription.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseInfoAndSectionsSectionCardWidgets/CustomCoursePoster.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseInfoAndSectionsSectionCardWidgets/CustomCourseSectionsBuilder.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseInfoAndSectionsSectionCardWidgets/CustomCourseSectionsCardHeader.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomCoursDetailsSectionCard extends StatefulWidget {
  const CustomCoursDetailsSectionCard({super.key, required this.course});

  final CourseEntity course;

  @override
  State<CustomCoursDetailsSectionCard> createState() =>
      _CustomCoursDetailsSectionCardState();
}

class _CustomCoursDetailsSectionCardState
    extends State<CustomCoursDetailsSectionCard> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CourseSectionsCubit>();
    final theme = Theme.of(context);
    return CustomCard(
      child: Column(
        children: [
          CustomCoursePoster(),
          SizedBox(height: 32),
          CourseDetailsDescription(),
          Divider(height: 32),
          CustomCourseSectionsCardHeader(
            title: "المحاضرات",
            action: IconButton(
              icon: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: isExpanded ? KMainColor : theme.hintColor,
              ),
              onPressed: () => setState(() => isExpanded = !isExpanded),
            ),
            showMore: cubit.hasMore
                ? () {
                    if (cubit.hasMore &&
                        context.read<CourseSectionsCubit>().state
                            is! GetCourseSectionsLoading) {
                      context.read<CourseSectionsCubit>().getCourseSections(
                        courseId: widget.course.id,
                        isPaginate: true,
                      );
                    }
                  }
                : null,
          ),
          SizedBox(height: 32),
          isExpanded
              ? _buildExpandedList(cubit: cubit)
              : _buildFixedScrollableList(cubit: cubit),
        ],
      ),
    );
  }

  Widget _buildFixedScrollableList({required CourseSectionsCubit cubit}) {
    return SizedBox(
      height: 400,
      child: CustomCourseSectionsBuilder(
        course: widget.course,
        shrinkWrap: false,
        physics: const BouncingScrollPhysics(),
        sections: cubit.courseSections,
      ),
    );
  }

  Widget _buildExpandedList({required CourseSectionsCubit cubit}) {
    return CustomCourseSectionsBuilder(
      course: widget.course,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      sections: cubit.courseSections,
    );
  }
}
