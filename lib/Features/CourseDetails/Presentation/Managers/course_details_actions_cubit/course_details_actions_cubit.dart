import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Core/repos/CoursesRepo/CoursesRepo.dart';

part 'course_details_actions_state.dart';

class CourseDetailsActionsCubit extends Cubit<CourseDetailsActionsState> {
  CourseDetailsActionsCubit({required this.coursesrepo})
    : super(CourseDetailsActionsInitial());
  final Coursesrepo coursesrepo;

  Future<void> updateCourseState({
    required String courseId,
    required String newState,
    required String teacherId,
  }) async {
    emit(UpdateCourseStateLoading());
    final result = await coursesrepo.updateCourseState(
      courseId: courseId,
      newState: newState,
      teacherId: teacherId,
    );
    result.fold(
      (failure) =>
          emit(UpdateCourseStateFailure(errorMessage: failure.message)),
      (_) => emit(UpdateCourseStateSuccess()),
    );
  }

  Future<void> deleteCourse({
    required String courseId,
    required String teacherId,
  }) async {
    emit(DeleteCourseLoading());
    final result = await coursesrepo.deleteCourse(
      courseId: courseId,
      teacherId: teacherId,
    );
    result.fold(
      (failure) => emit(DeleteCourseFailure(errorMessage: failure.message)),
      (_) => emit(DeleteCourseSuccess()),
    );
  }
}
