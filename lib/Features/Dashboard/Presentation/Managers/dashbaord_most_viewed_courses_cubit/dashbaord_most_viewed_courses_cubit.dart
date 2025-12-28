// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetCourseResonseEntity.dart';
import 'package:sintir_dashboard/Core/repos/CoursesRepo/CoursesRepo.dart';

part 'dashbaord_most_viewed_courses_state.dart';

class DashbaordMostViewedCoursesCubit
    extends Cubit<DashbaordMostViewedCoursesState> {
  DashbaordMostViewedCoursesCubit({required this.coursesrepo})
    : super(DashbaordMostViewedCoursesInitial());
  final Coursesrepo coursesrepo;

  Future<void> fetchMostViewedCourses({required bool isPaginate}) async {
    emit(DashbaordFetchMostViewedCoursesLoading());

    final mostViewedCourses = await coursesrepo.getPopularCourses(
      isPaginate: isPaginate,
    );
    mostViewedCourses.fold(
      (failure) {
        emit(
          DashbaordFetchMostViewedCoursesFailure(errorMessage: failure.message),
        );
      },
      (resonseEntity) {
        emit(
          DashbaordFetchMostViewedCoursesSuccess(resonseEntity: resonseEntity),
        );
      },
    );
  }
}
