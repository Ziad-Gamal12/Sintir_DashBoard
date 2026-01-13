import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/SubscriberEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomEmptyWidget.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSubscribtionsCubit/CourseSubscribtionsCubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseSubscribersSectionCard/SubscriberPremiumCard.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomCourseSubscribersListView extends StatelessWidget {
  const CustomCourseSubscribersListView({
    super.key,
    required this.subscribers,
    this.shrinkWrap = false,
    this.physics = const BouncingScrollPhysics(),
  });

  final List<SubscriberEntity> subscribers;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseSubscribtionsCubit, CourseSubscribtionsState>(
      buildWhen: (previous, current) =>
          current is GetCourseSubscribersFailure ||
          current is GetCourseSubscribersSuccess ||
          current is GetCourseSubscribersLoading,
      builder: (context, state) {
        if (state is GetCourseSubscribersLoading && !state.isPaginate) {
          return const Center(
            child: CircularProgressIndicator(color: KMainColor),
          );
        } else if (state is GetCourseSubscribersFailure) {
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

        return ListView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics,
          itemCount: (state is GetCourseSubscribersLoading && state.isPaginate)
              ? subscribers.length + 1
              : subscribers.length,
          itemBuilder: (context, index) {
            if (index == subscribers.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: CircularProgressIndicator(color: KMainColor),
                ),
              );
            }
            return SubscriberPremiumCard(
              subscriber: subscribers[index],
              onDelete: () {},
              onNavigate: () {},
            );
          },
        );
      },
    );
  }
}
