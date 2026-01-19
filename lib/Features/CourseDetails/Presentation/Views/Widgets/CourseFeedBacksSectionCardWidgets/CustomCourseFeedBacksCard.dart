import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Helper/ShowSnackBar.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseFeedBacksCubit/course_feed_backs_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseFeedBacksSectionCardWidgets/CustomCourseFeedBacksListView.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseInfoAndSectionsSectionCardWidgets/CustomCourseSectionsCardHeader.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomCourseFeedBacksCard extends StatefulWidget {
  const CustomCourseFeedBacksCard({super.key, required this.courseId});
  final String courseId;

  @override
  State<CustomCourseFeedBacksCard> createState() =>
      _CustomCourseFeedBacksCardState();
}

class _CustomCourseFeedBacksCardState extends State<CustomCourseFeedBacksCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CourseFeedBacksCubit>();
    final theme = Theme.of(context);
    return BlocListener<CourseFeedBacksCubit, CourseFeedBacksState>(
      listener: (context, state) {
        if (state is CourseFeedBacksDeleteFeedBackFailure) {
          CustomSnackBar.show(
            context,
            message: state.errMessage,
            type: SnackType.error,
          );
        } else if (state is CourseFeedBacksDeleteFeedBackSuccess) {
          CustomSnackBar.show(
            context,
            message: "تم حذف التقييم بنجاح",
            type: SnackType.success,
          );
          context.read<CourseFeedBacksCubit>().getCourseFeedBacks(
            courseId: widget.courseId,
            isPaginate: false,
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomCourseSectionsCardHeader(
              title: "التقييمات",
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
                          context.read<CourseFeedBacksCubit>().state
                              is! CourseFeedBacksGetFeedBackLoading) {
                        context.read<CourseFeedBacksCubit>().getCourseFeedBacks(
                          isPaginate: true,
                          courseId: widget.courseId,
                        );
                      }
                    }
                  : null,
            ),
            const SizedBox(height: 24),

            isExpanded
                ? _buildExpandedList(cubit)
                : _buildFixedScrollableList(cubit),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedScrollableList(CourseFeedBacksCubit cubit) {
    return SizedBox(
      height: 400,
      child: CustomCourseFeedBacksListView(
        feedbacks: cubit.feedBacks,
        courseId: widget.courseId,
      ),
    );
  }

  Widget _buildExpandedList(CourseFeedBacksCubit cubit) {
    return CustomCourseFeedBacksListView(
      feedbacks: cubit.feedBacks,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      courseId: widget.courseId,
    );
  }
}
