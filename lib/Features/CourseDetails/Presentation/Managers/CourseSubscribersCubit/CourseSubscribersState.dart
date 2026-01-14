// ignore_for_file: file_names

part of 'CourseSubscribersCubit.dart';

@immutable
sealed class CourseSubscribersState {}

final class SubscribeToCoursesInitial extends CourseSubscribersState {}

final class GetCourseSubscribersLoading extends CourseSubscribersState {
  final bool isPaginate;
  GetCourseSubscribersLoading({required this.isPaginate});
}

final class GetCourseSubscribersSuccess extends CourseSubscribersState {
  final List<SubscriberEntity> subscribers;

  GetCourseSubscribersSuccess({required this.subscribers});
}

final class GetCourseSubscribersFailure extends CourseSubscribersState {
  final String errMessage;
  GetCourseSubscribersFailure({required this.errMessage});
}

// search Subscribers

final class SearchSubscribersLoading extends CourseSubscribersState {
  final bool isPaginate;

  SearchSubscribersLoading({required this.isPaginate});
}

final class SearchSubscribersSuccess extends CourseSubscribersState {
  final GetCourseSubscribersEntity response;
  SearchSubscribersSuccess({required this.response});
}

final class SearchSubscribersFailure extends CourseSubscribersState {
  final String errMessage;
  SearchSubscribersFailure({required this.errMessage});
}
