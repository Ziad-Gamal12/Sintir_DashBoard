import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/FilterCoursesQueryEntity.dart';
import 'package:sintir_dashboard/Core/repos/CoursesRepo/CoursesRepo.dart';

part 'courses_management_state.dart';

class CoursesManagementCubit extends Cubit<CoursesManagementState> {
  CoursesManagementCubit({required this.coursesrepo})
    : super(CoursesManagementInitial());
  final Coursesrepo coursesrepo;
  FilterCoursesQueryEntity filters = FilterCoursesQueryEntity();
  bool hasMore = true;
  List<CourseEntity> courses = [];
  Future<void> getCourses({required bool isPaginate}) async {
    emit(GetCoursesManagementCoursesLoading());
    final courses = await coursesrepo.getRecentCourses(
      isPaginate: isPaginate,
      filters: filters,
    );
    courses.fold(
      (failure) =>
          emit(GetCoursesManagementCoursesFailure(errmessage: failure.message)),
      (response) {
        hasMore = response.hasMore;
        if (response.isPaginate) {
          this.courses.addAll(response.courses);
        } else {
          this.courses = response.courses;
        }
        emit(GetCoursesManagementCoursesSuccess(coursesList: this.courses));
      },
    );
  }

  Future<void> filterCourses({
    required FilterCoursesQueryEntity filters,
  }) async {
    this.filters = filters;
    getCourses(isPaginate: false);
  }
}
