import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Core/Entities/CourseReportsItemEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetCourseReportsResponseEntity.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseReportsRepo/CourseReportsRepo.dart';

part 'course_reports_state.dart';

class CourseReportsCubit extends Cubit<CourseReportsState> {
  CourseReportsCubit({required this.coursereportsrepo})
    : super(CourseReportsInitial());
  final CourseReportsRepo coursereportsrepo;
  List<CourseReportEntity> courseReports = [];
  bool hasMore = true;
  Future<void> getCourseReports({
    required String courseId,
    required bool isPaginate,
  }) async {
    emit(CourseReportsGetReportLoading(isPaginate: isPaginate));
    final result = await coursereportsrepo.getCourseReports(
      courseId: courseId,
      isPaginate: isPaginate,
    );
    result.fold(
      (failure) {
        emit(CourseReportsGetReportFailure(errMessage: failure.message));
      },
      (courseReports) {
        handleFetchedReportsSuccessState(courseReports);
        emit(CourseReportsGetReportSuccess(response: courseReports));
      },
    );
  }

  void handleFetchedReportsSuccessState(
    GetCourseReportsResponseEntity response,
  ) {
    if (response.isPaginate) {
      courseReports.addAll(response.reports);
    } else {
      courseReports = response.reports;
    }
    hasMore = response.hasMore;
  }

  Future<void> addCourseReport({
    required String courseId,
    required CourseReportEntity reportEntity,
  }) async {
    emit(CourseReportsAddReportLoading());
    final result = await coursereportsrepo.addCourseReport(
      courseId: courseId,
      reportEntity: reportEntity,
    );
    result.fold(
      (failure) {
        emit(CourseReportsAddReportFailure(errMessage: failure.message));
      },
      (success) {
        emit(CourseReportsAddReportSuccess());
      },
    );
  }
}
