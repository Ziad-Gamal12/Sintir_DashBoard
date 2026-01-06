import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Core/Entities/CourseFeedBackItemEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetCourseFeedBacksResponseEntity.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseFeedBacksRepo/CourseFeedBacksRepo.dart';

part 'course_feed_backs_state.dart';

class CourseFeedBacksCubit extends Cubit<CourseFeedBacksState> {
  CourseFeedBacksCubit({required this.courseFeedBacksRepo})
    : super(CourseFeedBacksInitial());
  final CourseFeedBacksRepo courseFeedBacksRepo;
  List<CoursefeedbackItemEntity> feedBacks = [];
  bool hasMore = true;
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
        emit(CourseFeedBacksDeleteFeedBackSuccess());
      },
    );
  }
}
