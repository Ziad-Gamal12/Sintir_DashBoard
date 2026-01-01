import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/repos/ContentCreatorRepos/ContentCreatorProfileRepo.dart';

part 'content_creator_courses_state.dart';

class ContentCreatorCoursesCubit extends Cubit<ContentCreatorCoursesState> {
  ContentCreatorCoursesCubit({required this.contentCreatorProfileRepo})
    : super(ContentCreatorCoursesInitial());
  final ContentCreatorProfileRepo contentCreatorProfileRepo;
  List<CourseEntity> contentCreatorCourses = [];
  Future<void> getContentCreatorCourses({required String userId}) async {
    emit(GetContentCreatorCoursesLoading());
    final response = await contentCreatorProfileRepo.getContentCreatorCourses(
      userId: userId,
    );
    response.fold(
      (failure) =>
          emit(GetContentCreatorCoursesFailure(errmessage: failure.message)),
      (courses) {
        contentCreatorCourses = courses;
        emit(GetContentCreatorCoursesSuccess(coursesList: courses));
      },
    );
  }

  Future<void> searchContentCreatorCourses({
    required String userId,
    required String keyword,
  }) async {
    emit(SearchContentCreatorCoursesLoading());
    final response = await contentCreatorProfileRepo
        .searchContentCreatorCourses(userId: userId, keyword: keyword);
    response.fold(
      (failure) =>
          emit(SearchContentCreatorCoursesFailure(errmessage: failure.message)),
      (courses) =>
          emit(SearchContentCreatorCoursesSuccess(coursesList: courses)),
    );
  }

  int getContentCreatorSubscribersCount() {
    int count = 0;
    for (var course in contentCreatorCourses) {
      count += course.studentsCount;
    }
    return count;
  }

  int getContentCreatorCoursesCount() {
    return contentCreatorCourses.length;
  }
}
