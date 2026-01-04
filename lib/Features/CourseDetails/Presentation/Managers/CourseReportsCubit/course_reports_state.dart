part of 'course_reports_cubit.dart';

@immutable
sealed class CourseReportsState {}

final class CourseReportsInitial extends CourseReportsState {}

final class CourseReportsAddReportLoading extends CourseReportsState {}

final class CourseReportsAddReportSuccess extends CourseReportsState {}

final class CourseReportsAddReportFailure extends CourseReportsState {
  final String errMessage;
  CourseReportsAddReportFailure({required this.errMessage});
}

final class CourseReportsGetReportLoading extends CourseReportsState {
  final bool isPaginate;
  CourseReportsGetReportLoading({required this.isPaginate});
}

final class CourseReportsGetReportSuccess extends CourseReportsState {
  final GetCourseReportsResponseEntity response;
  CourseReportsGetReportSuccess({required this.response});
}

final class CourseReportsGetReportFailure extends CourseReportsState {
  final String errMessage;
  CourseReportsGetReportFailure({required this.errMessage});
}
