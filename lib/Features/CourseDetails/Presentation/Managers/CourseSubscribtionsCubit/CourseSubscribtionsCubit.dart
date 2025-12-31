// ignore_for_file: file_names, depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetCourseSubscribersEntity.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseSubscibtionsRepo/CourseSubscibtionsRepo.dart';

part 'CourseSubscribtionsState.dart';

class CourseSubscribtionsCubit extends Cubit<CourseSubscribtionsState> {
  CourseSubscribtionsCubit({
    required this.subscribtionRepo,
    required this.course,
  }) : super(SubscribeToCoursesInitial());
  final CourseSubscibtionsRepo subscribtionRepo;
  final CourseEntity course;

  void checkIfSubscribed({required String uid}) async {
    emit(CheckIfSubscribedLoading());
    var result = await subscribtionRepo.checkIfSubscribed(
      userID: uid,
      courseID: course.id,
    );
    result.fold(
      (failure) {
        emit(CheckIfSubscribedFailure(errMessage: failure.message));
      },
      (isSubscribed) {
        emit(CheckIfSubscribedSuccess(isSubscribed: isSubscribed));
      },
    );
  }

  Future<void> getCoursSubscribers({required bool isPaginate}) async {
    emit(GetCourseSubscribersLoading(isPaginate: isPaginate));
    var result = await subscribtionRepo.getSubscribers(
      courseID: course.id,
      isPaginate: isPaginate,
    );
    result.fold(
      (failure) {
        emit(GetCourseSubscribersFailure(errMessage: failure.message));
      },
      (response) {
        emit(GetCourseSubscribersSuccess(response: response));
      },
    );
  }

  Future<void> searchSubscribers({
    required String keyword,
    required bool isPaginate,
  }) async {
    emit(SearchSubscribersLoading(isPaginate: isPaginate));
    var result = await subscribtionRepo.searchSubscribers(
      searchKey: keyword,
      isPaginate: isPaginate,
      courseID: course.id,
    );
    result.fold(
      (failure) {
        emit(SearchSubscribersFailure(errMessage: failure.message));
      },
      (response) {
        emit(SearchSubscribersSuccess(response: response));
      },
    );
  }
}
