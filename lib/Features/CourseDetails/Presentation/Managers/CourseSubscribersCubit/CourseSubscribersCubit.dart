// ignore_for_file: file_names, depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/SubscriberEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetCourseSubscribersEntity.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseSubscibtionsRepo/CourseSubscibtionsRepo.dart';

part 'CourseSubscribersState.dart';

class CourseSubscribersCubit extends Cubit<CourseSubscribersState> {
  CourseSubscribersCubit({required this.subscribtionRepo})
    : super(SubscribeToCoursesInitial());
  final CourseSubscibtionsRepo subscribtionRepo;
  bool hasMore = true;
  List<SubscriberEntity> subscribers = [];

  Future<void> getCoursSubscribers({
    required bool isPaginate,
    required String courseID,
  }) async {
    emit(GetCourseSubscribersLoading(isPaginate: isPaginate));
    var result = await subscribtionRepo.getSubscribers(
      courseID: courseID,
      isPaginate: isPaginate,
    );
    result.fold(
      (failure) {
        emit(GetCourseSubscribersFailure(errMessage: failure.message));
      },
      (response) {
        hasMore = response.hasMore;
        if (response.isPaginate) {
          subscribers.addAll(response.subscribers);
        } else {
          subscribers = response.subscribers;
        }
        emit(GetCourseSubscribersSuccess(subscribers: subscribers));
      },
    );
  }

  Future<void> searchSubscribers({
    required String keyword,
    required bool isPaginate,
    required String courseID,
  }) async {
    emit(SearchSubscribersLoading(isPaginate: isPaginate));
    var result = await subscribtionRepo.searchSubscribers(
      searchKey: keyword,
      isPaginate: isPaginate,
      courseID: courseID,
    );
    result.fold(
      (failure) {
        emit(SearchSubscribersFailure(errMessage: failure.message));
      },
      (response) {
        if (response.isPaginate) {
          subscribers.addAll(response.subscribers);
        } else {
          subscribers = response.subscribers;
        }
        emit(SearchSubscribersSuccess(response: response));
      },
    );
  }

  Future<void> deleteSubscriber({
    required String courseID,
    required String subscriberID,
  }) async {
    emit(DeleteSubscriberLoading(subscriberId: subscriberID));
    final result = await subscribtionRepo.deleteSubscriber(
      courseID: courseID,
      subscriberID: subscriberID,
    );
    result.fold(
      (failure) {
        emit(DeleteSubscriberFailure(errMessage: failure.message));
      },
      (response) {
        subscribers.removeWhere((element) => element.id == subscriberID);
        emit(DeleteSubscriberSuccess(subscriberId: subscriberID));
      },
    );
  }
}
