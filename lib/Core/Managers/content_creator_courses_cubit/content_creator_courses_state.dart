part of 'content_creator_courses_cubit.dart';

@immutable
sealed class ContentCreatorCoursesState {}

final class ContentCreatorCoursesInitial extends ContentCreatorCoursesState {}

final class GetContentCreatorCoursesLoading
    extends ContentCreatorCoursesState {}

final class GetContentCreatorCoursesSuccess extends ContentCreatorCoursesState {
  final List<CourseEntity> coursesList;
  GetContentCreatorCoursesSuccess({required this.coursesList});
}

final class GetContentCreatorCoursesFailure extends ContentCreatorCoursesState {
  final String errmessage;
  GetContentCreatorCoursesFailure({required this.errmessage});
}
// search content creator courses

final class SearchContentCreatorCoursesLoading
    extends ContentCreatorCoursesState {}

final class SearchContentCreatorCoursesSuccess
    extends ContentCreatorCoursesState {
  final List<CourseEntity> coursesList;
  SearchContentCreatorCoursesSuccess({required this.coursesList});
}

final class SearchContentCreatorCoursesFailure
    extends ContentCreatorCoursesState {
  final String errmessage;
  SearchContentCreatorCoursesFailure({required this.errmessage});
}
