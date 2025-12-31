part of 'course_feed_backs_cubit.dart';

@immutable
sealed class CourseFeedBacksState {}

final class CourseFeedBacksInitial extends CourseFeedBacksState {}

final class CourseFeedBacksGetFeedBackLoading extends CourseFeedBacksState {}

final class CourseFeedBacksGetFeedBackSuccess extends CourseFeedBacksState {
  final GetCourseFeedBacksResponseEntity response;
  CourseFeedBacksGetFeedBackSuccess({required this.response});
}

final class CourseFeedBacksGetFeedBackFailure extends CourseFeedBacksState {
  final String errMessage;
  CourseFeedBacksGetFeedBackFailure({required this.errMessage});
}

final class CourseFeedBacksAddFeedBackLoading extends CourseFeedBacksState {}

final class CourseFeedBacksAddFeedBackSuccess extends CourseFeedBacksState {}

final class CourseFeedBacksAddFeedBackFailure extends CourseFeedBacksState {
  final String errMessage;
  CourseFeedBacksAddFeedBackFailure({required this.errMessage});
}
