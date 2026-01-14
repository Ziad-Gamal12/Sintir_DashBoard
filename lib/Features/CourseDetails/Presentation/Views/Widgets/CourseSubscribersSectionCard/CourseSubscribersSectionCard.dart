import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSubscribersCubit/CourseSubscribersCubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseInfoAndSectionsSectionCardWidgets/CustomCourseSectionsCardHeader.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseSubscribersSectionCard/CourseSubscribersSearchAndAddSection.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseSubscribersSectionCard/CustomCourseSubscribersListView.dart';
import 'package:sintir_dashboard/constant.dart';

class CourseSubscribersSectionCard extends StatefulWidget {
  const CourseSubscribersSectionCard({super.key, required this.course});
  final CourseEntity course;

  @override
  State<CourseSubscribersSectionCard> createState() =>
      _CourseSubscribersSectionCardState();
}

class _CourseSubscribersSectionCardState
    extends State<CourseSubscribersSectionCard> {
  bool isExpanded = false;
  TextEditingController searchController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CourseSubscribersCubit>();
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomCourseSectionsCardHeader(
              title: "المشتركين",
              showMore: cubit.hasMore
                  ? () {
                      if (context.read<CourseSubscribersCubit>().state
                          is! GetCourseSubscribersLoading) {
                        context
                            .read<CourseSubscribersCubit>()
                            .getCoursSubscribers(
                              isPaginate: true,
                              courseID: widget.course.id,
                            );
                      }
                    }
                  : null,
              action: IconButton(
                onPressed: () => setState(() => isExpanded = !isExpanded),
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: isExpanded ? KMainColor : theme.hintColor,
                ),
                tooltip: isExpanded ? "تصغير" : "توسيع",
              ),
            ),
            const SizedBox(height: 16),
            CourseSubscribersSearchAndAddSection(
              searchController: searchController,
              course: widget.course,
            ),
            const SizedBox(height: 8),

            isExpanded ? _buildFullView(cubit) : _buildFixedView(cubit),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedView(CourseSubscribersCubit cubit) {
    return SizedBox(
      height: 450,
      child: CustomCourseSubscribersListView(
        subscribers: cubit.subscribers,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: false,
      ),
    );
  }

  Widget _buildFullView(CourseSubscribersCubit cubit) {
    return CustomCourseSubscribersListView(
      subscribers: cubit.subscribers,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
    );
  }
}
