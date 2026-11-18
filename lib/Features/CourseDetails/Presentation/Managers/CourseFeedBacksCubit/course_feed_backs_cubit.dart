import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Core/Entities/CourseFeedBackItemEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetCourseFeedBacksResponseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/ReviewReportEntity.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseFeedBacksRepo/CourseFeedBacksRepo.dart';

part 'course_feed_backs_state.dart';

class CourseFeedBacksCubit extends Cubit<CourseFeedBacksState> {
  CourseFeedBacksCubit({required this.courseFeedBacksRepo})
    : super(CourseFeedBacksInitial());
  final CourseFeedBacksRepo courseFeedBacksRepo;
  List<CoursefeedbackItemEntity> feedBacks = [];
  Map<String, List<ReviewReportEntity>> openReports = {};
  bool hasMore = true;

  List<ReviewReportEntity> reportsFor(String reviewUid) =>
      openReports[reviewUid] ?? const [];

  Future<void> loadOpenReports({required String courseId}) async {
    final result = await courseFeedBacksRepo.getOpenReviewReports(
      courseId: courseId,
    );
    result.fold((_) {}, (reports) {
      openReports = reports;
      if (!isClosed) emit(CourseFeedBacksReportsChanged());
    });
  }

  Future<void> dismissReports({
    required String courseId,
    required String reviewUid,
  }) async {
    final reports = reportsFor(reviewUid);
    if (reports.isEmpty) return;
    emit(CourseFeedBacksDeleteFeedBackLoading(feedBackId: reviewUid));
    final result = await courseFeedBacksRepo.closeReviewReports(
      reports: reports,
      status: 'dismissed',
    );
    result.fold(
      (failure) => emit(
        CourseFeedBacksDeleteFeedBackFailure(errMessage: failure.message),
      ),
      (_) {
        openReports = Map.of(openReports)..remove(reviewUid);
        emit(CourseFeedBacksReportsChanged());
      },
    );
  }
  Future<void> getCourseFeedBacks({
    required String courseId,
    required bool isPaginate,
  }) async {
    emit(CourseFeedBacksGetFeedBackLoading(isPaginate: isPaginate));
    final result = await courseFeedBacksRepo.getCourseFedBacks(
      courseId: courseId,
      isPaginate: isPaginate,
    );
    result.fold(
      (failure) {
        emit(CourseFeedBacksGetFeedBackFailure(errMessage: failure.message));
      },
      (success) {
        handleFetchedFeedBacksSuccessState(success);
        emit(CourseFeedBacksGetFeedBackSuccess(response: success));
        if (!isPaginate) loadOpenReports(courseId: courseId);
      },
    );
  }

  void handleFetchedFeedBacksSuccessState(
    GetCourseFeedBacksResponseEntity response,
  ) {
    if (response.isPaginate) {
      feedBacks.addAll(response.feedBacks);
    } else {
      feedBacks = response.feedBacks;
    }
    hasMore = response.hasMore;
  }

  Future<void> addCourseFeedBack({
    required String courseId,
    required CoursefeedbackItemEntity feedback,
  }) async {
    emit(CourseFeedBacksAddFeedBackLoading());
    final result = await courseFeedBacksRepo.addCourseFedBack(
      courseId: courseId,
      review: feedback,
    );
    result.fold(
      (failure) {
        emit(CourseFeedBacksAddFeedBackFailure(errMessage: failure.message));
      },
      (success) {
        emit(CourseFeedBacksAddFeedBackSuccess());
      },
    );
  }

  // delete feedback
  Future<void> deleteCourseFeedBack({
    required String courseId,
    required String feedBackId,
  }) async {
    emit(CourseFeedBacksDeleteFeedBackLoading(feedBackId: feedBackId));
    final result = await courseFeedBacksRepo.deleteCourseFedBack(
      courseId: courseId,
      feedBackId: feedBackId,
    );
    result.fold(
      (failure) {
        emit(CourseFeedBacksDeleteFeedBackFailure(errMessage: failure.message));
      },
      (success) {
        feedBacks = feedBacks.where((item) => item.uid != feedBackId).toList();
        openReports = Map.of(openReports)..remove(feedBackId);
        emit(CourseFeedBacksDeleteFeedBackSuccess());
      },
    );
  }
}
