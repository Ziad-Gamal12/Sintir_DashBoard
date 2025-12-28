part of 'dashbaord_most_viewed_courses_cubit.dart';

@immutable
sealed class DashbaordMostViewedCoursesState {}

final class DashbaordMostViewedCoursesInitial
    extends DashbaordMostViewedCoursesState {}

final class DashbaordFetchMostViewedCoursesLoading
    extends DashbaordMostViewedCoursesState {}

final class DashbaordFetchMostViewedCoursesSuccess
    extends DashbaordMostViewedCoursesState {
  final GetCoursesResonseEntity resonseEntity;
  DashbaordFetchMostViewedCoursesSuccess({required this.resonseEntity});
}

final class DashbaordFetchMostViewedCoursesFailure
    extends DashbaordMostViewedCoursesState {
  final String errorMessage;
  DashbaordFetchMostViewedCoursesFailure({required this.errorMessage});
}
