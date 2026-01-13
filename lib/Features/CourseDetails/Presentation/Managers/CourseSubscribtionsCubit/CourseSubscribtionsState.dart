// ignore_for_file: file_names

part of 'CourseSubscribtionsCubit.dart';

@immutable
sealed class CourseSubscribtionsState {}

final class SubscribeToCoursesInitial extends CourseSubscribtionsState {}

final class CheckIfSubscribedSuccess extends CourseSubscribtionsState {
  final bool isSubscribed;

  CheckIfSubscribedSuccess({required this.isSubscribed});
}

final class CheckIfSubscribedLoading extends CourseSubscribtionsState {}

final class CheckIfSubscribedFailure extends CourseSubscribtionsState {
  final String errMessage;

  CheckIfSubscribedFailure({required this.errMessage});
}

final class GetCourseSubscribersLoading extends CourseSubscribtionsState {
  final bool isPaginate;
  GetCourseSubscribersLoading({required this.isPaginate});
}

final class GetCourseSubscribersSuccess extends CourseSubscribtionsState {
 final List<SubscriberEntity> subscribers;

  GetCourseSubscribersSuccess({required this.subscribers});
}

final class GetCourseSubscribersFailure extends CourseSubscribtionsState {
  final String errMessage;
  GetCourseSubscribersFailure({required this.errMessage});
}

// search Subscribers

final class SearchSubscribersLoading extends CourseSubscribtionsState {
  final bool isPaginate;

  SearchSubscribersLoading({required this.isPaginate});
}

final class SearchSubscribersSuccess extends CourseSubscribtionsState {
  final GetCourseSubscribersEntity response;
  SearchSubscribersSuccess({required this.response});
}

final class SearchSubscribersFailure extends CourseSubscribtionsState {
  final String errMessage;
  SearchSubscribersFailure({required this.errMessage});
}
