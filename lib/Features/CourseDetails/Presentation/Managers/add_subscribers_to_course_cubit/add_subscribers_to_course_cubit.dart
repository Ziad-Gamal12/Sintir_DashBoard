import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseSubscibtionsRepo/CourseSubscibtionsRepo.dart';

part 'add_subscribers_to_course_state.dart';

class AddSubscribersToCourseCubit extends Cubit<AddSubscribersToCourseState> {
  AddSubscribersToCourseCubit({required this.courseSubscibtionsRepo})
    : super(AddSubscribersToCourseInitial());
  final CourseSubscibtionsRepo courseSubscibtionsRepo;
  void addSubscribers({
    required List<UserEntity> usersEntity,
    required CourseEntity course,
  }) async {
    emit(AddSubscribersToCourseLoading());
    bool anyFailure = false;
    String? lastErrorMessage;
    for (UserEntity user in usersEntity) {
      final result = await courseSubscibtionsRepo.addSubscriber(
        course: course,
        userEntity: user,
      );
      if (isClosed) return;
      result.fold((failure) {
        anyFailure = true;
        lastErrorMessage = failure.message;
      }, (_) => null);
    }

    if (isClosed) return;

    if (anyFailure) {
      emit(
        AddSubscribersToCourseFailure(
          errmessage: lastErrorMessage ?? "حدث خطأ ما",
        ),
      );
    } else {
      emit(AddSubscribersToCourseSuccess());
    }
  }
}
