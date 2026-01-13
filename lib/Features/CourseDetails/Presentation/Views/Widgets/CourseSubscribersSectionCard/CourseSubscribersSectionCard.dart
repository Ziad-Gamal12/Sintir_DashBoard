import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomSearchTextField.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSubscribtionsCubit/CourseSubscribtionsCubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseInfoAndSectionsSectionCardWidgets/CustomCourseSectionsCardHeader.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseSubscribersSectionCard/CustomCourseSubscribersListView.dart';
import 'package:sintir_dashboard/constant.dart';

class CourseSubscribersSectionCard extends StatefulWidget {
  const CourseSubscribersSectionCard({super.key, required this.courseId});
  final String courseId;

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
    final cubit = context.watch<CourseSubscribtionsCubit>();
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
                      if (context.read<CourseSubscribtionsCubit>().state
                          is! GetCourseSubscribersLoading) {
                        context
                            .read<CourseSubscribtionsCubit>()
                            .getCoursSubscribers(
                              isPaginate: true,
                              courseID: widget.courseId,
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
              courseID: widget.courseId,
            ),
            const SizedBox(height: 8),

            isExpanded ? _buildFullView(cubit) : _buildFixedView(cubit),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedView(CourseSubscribtionsCubit cubit) {
    return SizedBox(
      height: 450,
      child: CustomCourseSubscribersListView(
        subscribers: cubit.subscribers,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: false,
      ),
    );
  }

  Widget _buildFullView(CourseSubscribtionsCubit cubit) {
    return CustomCourseSubscribersListView(
      subscribers: cubit.subscribers,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
    );
  }
}

class CourseSubscribersSearchAndAddSection extends StatelessWidget {
  const CourseSubscribersSearchAndAddSection({
    super.key,
    required this.searchController,
    required this.courseID,
  });

  final TextEditingController searchController;
  final String courseID;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomSearchTextField(
            controller: searchController,
            onChanged: (val) {
              context.read<CourseSubscribtionsCubit>().searchSubscribers(
                courseID: courseID,
                keyword: val,
                isPaginate: false,
              );
            },
          ),
        ),
        Spacer(),
        Expanded(
          child: Custombutton(
            text: "إضافة",
            color: KMainColor,
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
