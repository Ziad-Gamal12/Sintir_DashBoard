import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseFeedBackItemEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomEmptyWidget.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseFeedBacksCubit/course_feed_backs_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseFeedBacksSectionCardWidgets/CustomCourseFeedBacksCardItem.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomCourseFeedBacksListView extends StatelessWidget {
  const CustomCourseFeedBacksListView({
    super.key,
    required this.feedbacks,
    this.shrinkWrap = false,
    required this.courseId,
    this.physics = const BouncingScrollPhysics(),
  });
  final List<CoursefeedbackItemEntity> feedbacks;
  final String courseId;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseFeedBacksCubit, CourseFeedBacksState>(
      buildWhen: (previous, current) {
        return current is CourseFeedBacksGetFeedBackLoading ||
            current is CourseFeedBacksGetFeedBackSuccess ||
            current is CourseFeedBacksGetFeedBackFailure;
      },
      builder: (context, state) {
        if (state is CourseFeedBacksGetFeedBackLoading &&
            state.isPaginate == false) {
          return Center(child: CircularProgressIndicator(color: KMainColor));
        } else if (state is CourseFeedBacksGetFeedBackFailure) {
          return Center(
            child: CustomErrorWidget(errormessage: state.errMessage),
          );
        } else if (state is CourseFeedBacksGetFeedBackSuccess &&
            feedbacks.isEmpty) {
          return Center(
            child: CustomEmptyWidget(text: "لا يوجد تقييمات لهذا الكورس"),
          );
        }
        return ListView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics,
          itemCount:
              (state is CourseFeedBacksGetFeedBackLoading && state.isPaginate)
              ? feedbacks.length + 1
              : feedbacks.length,
          itemBuilder: (context, index) {
            if (index >= feedbacks.length) {
              return const Center(child: CircularProgressIndicator());
            }
            return CustomCourseFeedBacksCardItem(
              feedback: feedbacks[index],
              courseId: courseId,
            );
          },
        );
      },
    );
  }
}
