part of 'courses_management_cubit.dart';

@immutable
sealed class CoursesManagementState {}

final class CoursesManagementInitial extends CoursesManagementState {}

final class GetCoursesManagementCoursesSuccess extends CoursesManagementState {
  final List<CourseEntity> coursesList;
  GetCoursesManagementCoursesSuccess({required this.coursesList});
}

final class GetCoursesManagementCoursesFailure extends CoursesManagementState {
  final String errmessage;
  GetCoursesManagementCoursesFailure({required this.errmessage});
}

final class GetCoursesManagementCoursesLoading extends CoursesManagementState {}
