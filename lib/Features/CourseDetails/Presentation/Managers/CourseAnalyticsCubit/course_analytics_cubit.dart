import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseAnalyticsRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseAnalyticsCubit/CourseAnalyticsState.dart';

class CourseAnalyticsCubit extends Cubit<CourseAnalyticsState> {
  final CourseAnalyticsRepo courseAnalyticsRepo;

  CourseAnalyticsCubit({required this.courseAnalyticsRepo})
    : super(const CourseAnalyticsState());

  Future<void> getCourseRevenue(String courseId) async {
    emit(state.copyWith(isLoadingRevenue: true));
    final result = await courseAnalyticsRepo.getCourseRevenue(courseId);
    result.fold(
      (l) => emit(
        state.copyWith(isLoadingRevenue: false, errorMessage: l.message),
      ),
      (r) => emit(state.copyWith(revenue: r, isLoadingRevenue: false)),
    );
  }

  Future<void> getCourseSubscribers(String courseId) async {
    emit(state.copyWith(isLoadingSubscribers: true));
    final result = await courseAnalyticsRepo.getCourseSubscribers(courseId);
    result.fold(
      (l) => emit(
        state.copyWith(isLoadingSubscribers: false, errorMessage: l.message),
      ),
      (r) => emit(state.copyWith(subscribers: r, isLoadingSubscribers: false)),
    );
  }

  Future<void> getCourseReports(String courseId) async {
    emit(state.copyWith(isLoadingReports: true));
    final result = await courseAnalyticsRepo.getCourseReports(courseId);
    result.fold(
      (l) => emit(
        state.copyWith(isLoadingReports: false, errorMessage: l.message),
      ),
      (r) => emit(state.copyWith(reports: r, isLoadingReports: false)),
    );
  }

  Future<void> getCourseFeedbacks(String courseId) async {
    emit(state.copyWith(isLoadingFeedbacks: true));
    final result = await courseAnalyticsRepo.getCourseFeedbacks(courseId);
    result.fold(
      (l) => emit(
        state.copyWith(isLoadingFeedbacks: false, errorMessage: l.message),
      ),
      (r) => emit(state.copyWith(feedbacks: r, isLoadingFeedbacks: false)),
    );
  }

  Future<void> fetchAllCourseStats(String courseId) async {
    await Future.wait([
      getCourseRevenue(courseId),
      getCourseSubscribers(courseId),
      getCourseReports(courseId),
      getCourseFeedbacks(courseId),
    ]);
  }
}
