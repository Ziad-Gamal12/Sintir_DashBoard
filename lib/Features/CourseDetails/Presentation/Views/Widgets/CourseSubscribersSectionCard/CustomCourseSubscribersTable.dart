import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/SubscriberEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomEmptyWidget.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSubscribersCubit/CourseSubscribersCubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseSubscribersSectionCard/CourseSubscribersTable.dart';

class CustomCourseSubscribersTable extends StatelessWidget {
  const CustomCourseSubscribersTable({
    super.key,
    required this.subscribers,
    required this.courseID,
  });

  final List<SubscriberEntity> subscribers;
  final String courseID;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseSubscribersCubit, CourseSubscribersState>(
      buildWhen: (previous, current) =>
          current is GetCourseSubscribersFailure ||
          current is GetCourseSubscribersSuccess ||
          current is GetCourseSubscribersLoading,
      builder: (context, state) {
        if (state is GetCourseSubscribersFailure) {
          return Center(
            child: CustomErrorWidget(errormessage: state.errMessage),
          );
        } else if (subscribers.isEmpty) {
          return const Center(
            child: CustomEmptyWidget(
              text: "لا يوجد مشتركين لهذا الكورس حالياً",
            ),
          );
        }
        return ResponsiveSubscribersTable(
          subscribers: subscribers,
          onDelete: (subscriber) {
            context.read<CourseSubscribersCubit>().deleteSubscriber(
              subscriberID: subscriber.id,
              courseID: courseID,
            );
          },
          onLoadMore: (val) {
            context.read<CourseSubscribersCubit>().getCoursSubscribers(
              isPaginate: true,
              courseID: courseID,
            );
          },
          isLoading: state is GetCourseSubscribersLoading,
        );
      },
    );
  }
}
