part of 'course_details_actions_cubit.dart';

@immutable
sealed class CourseDetailsActionsState {}

final class CourseDetailsActionsInitial extends CourseDetailsActionsState {}

// update course state
final class UpdateCourseStateLoading extends CourseDetailsActionsState {}

final class UpdateCourseStateSuccess extends CourseDetailsActionsState {}

final class UpdateCourseStateFailure extends CourseDetailsActionsState {
  final String errorMessage;
  UpdateCourseStateFailure({required this.errorMessage});
}

// delete course
final class DeleteCourseLoading extends CourseDetailsActionsState {}

final class DeleteCourseSuccess extends CourseDetailsActionsState {}

final class DeleteCourseFailure extends CourseDetailsActionsState {
  final String errorMessage;
  DeleteCourseFailure({required this.errorMessage});
}
