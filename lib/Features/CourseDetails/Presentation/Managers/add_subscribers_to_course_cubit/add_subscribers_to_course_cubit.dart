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
      result.fold((failure) {
        anyFailure = true;
        lastErrorMessage = failure.message;
      }, (_) => null);
    }
    if (anyFailure) {
      emit(
        AddSubscribersToCourseFailure(
          errmessage: lastErrorMessage ?? "حدث خطأ ما",
        ),
      );
    } else {
      emit(AddSubscribersToCourseSuccess());
    }
  }
}
