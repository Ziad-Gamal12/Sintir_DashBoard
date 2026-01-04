part of 'course_transactions_cubit.dart';

@immutable
sealed class CourseTransactionsState {}

final class CourseTransactionsInitial extends CourseTransactionsState {}

final class FetchCourseTransactionsLoading extends CourseTransactionsState {
  final bool isPaginate;
  FetchCourseTransactionsLoading({required this.isPaginate});
}

final class FetchCourseTransactionsSuccess extends CourseTransactionsState {
  final FetchTransactionsResponseEntity response;
  FetchCourseTransactionsSuccess({required this.response});
}

final class FetchCourseTransactionsFailure extends CourseTransactionsState {
  final String errMessage;
  FetchCourseTransactionsFailure({required this.errMessage});
}
