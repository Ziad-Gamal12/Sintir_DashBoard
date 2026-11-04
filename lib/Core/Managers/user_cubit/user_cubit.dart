import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Repos/AuthRepo.dart';

part 'user_state.dart';

@visibleForTesting
bool isDashboardUserAuthorized(UserEntity user) {
  if (user.status != BackendEndpoints.activeStatus) {
    return false;
  }

  final role = user.role.toLowerCase();
  return {
    BackendEndpoints.adminRole.toLowerCase(),
    BackendEndpoints.coursesManagerrRole.toLowerCase(),
    BackendEndpoints.usersManagerrRole.toLowerCase(),
    BackendEndpoints.supportRole.toLowerCase(),
  }.contains(role);
}

class UserCubit extends Cubit<UserState> {
  final AuthRepo authRepo;
  StreamSubscription? _userSubscription;

  UserCubit({required this.authRepo}) : super(UserStateInitial());

  void asyncUser() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    emit(UserStateFetchUserLoading());
    _userSubscription?.cancel();
    _userSubscription = authRepo
        .watchUser(uid: uid)
        .listen(
          _handleUserUpdate,
          onError: (e) =>
              emit(UserStateFetchUserFailure(message: e.toString())),
        );
  }

  void _handleUserUpdate(Either<Failure, UserEntity> result) {
    result.fold(
      (failure) => emit(UserStateFetchUserFailure(message: failure.message)),
      (user) {
        if (user.status == BackendEndpoints.blockedStatus) {
          emit(
            UserStateFetchUserFailure(message: "تم حظر حسابك من قبل المسؤول"),
          );
        } else if (!isDashboardUserAuthorized(user)) {
          emit(
            UserStateFetchUserFailure(
              message: "غير مصرح لك بالدخول يرجى التواصل من إدارة التطبيق ",
            ),
          );
        } else {
          emit(UserStateFetchUserSuccess());
        }
      },
    );
  }

  @override
  Future<void> close() async {
    await _userSubscription?.cancel();
    return super.close();
  }
}
