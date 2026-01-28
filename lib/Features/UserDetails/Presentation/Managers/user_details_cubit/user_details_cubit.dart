import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/TeacherExtraDataEntity.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/TeacherWalletEntity.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Domain/Repos/UserDetailRepo.dart';

part 'user_details_state.dart';

class UserDetailsCubit extends Cubit<UserDetailsState> {
  UserDetailsCubit({required this.userDetailRepo})
    : super(UserDetailsInitial());
  final UserDetailsRepo userDetailRepo;
  UserEntity userEntity = UserEntity.empty();
  List<CourseEntity> userCourses = [];
  List<TransactionEntity> userTransactions = [];
  int userSupportTicketsCount = 0;
  int userSubscriptionsCount = 0;
  double userTransactionsAmount = 0.0;

  Future<void> getUserDetails({required String userID}) async {
    emit(GetUserDetailsLoading());
    log(userID);
    final result = await userDetailRepo.getUser(userID: userID);
    result.fold(
      (failure) {
        emit(GetUserDetailsFailure(errmessage: failure.message));
      },
      (userDetails) {
        userEntity = userDetails;
        emit(GetUserDetailsSuccess());
      },
    );
  }

  // get user courses
  Future<void> getUserCourses({required String userID}) async {
    emit(GetUserEnrolledCoursesLoading());
    final result = await userDetailRepo.getUserCourses(uid: userID);
    result.fold(
      (failure) {
        emit(GetUserEnrolledCoursesFailure(errmessage: failure.message));
      },
      (courses) {
        userCourses = courses;
        userSubscriptionsCount = userCourses.length;
        emit(GetUserEnrolledCoursesSuccess());
      },
    );
  }

  // get user transactions
  Future<void> getUserTransactions({required String userID}) async {
    emit(GetUserTransactionsLoading());
    final result = await userDetailRepo.getUserTransactions(uid: userID);
    result.fold(
      (failure) {
        emit(GetUserTransactionsFailure(errmessage: failure.message));
      },
      (transactions) {
        userTransactions = transactions;
        for (TransactionEntity transaction in userTransactions) {
          userTransactionsAmount += transaction.amount ?? 0.0;
        }
        emit(GetUserTransactionsSuccess());
      },
    );
  }

  // get user support tickets
  Future<void> getUserSupportTicketsCount({required String userID}) async {
    emit(GetUserSupportTicketsCountLoading());
    final result = await userDetailRepo.getUserSupportTicketsCount(uid: userID);
    result.fold(
      (failure) {
        emit(GetUserSupportTicketsCountFailure(errmessage: failure.message));
      },
      (supportTickets) {
        userSupportTicketsCount = supportTickets;
        emit(GetUserSupportTicketsCountSuccess());
      },
    );
  }

  // delete user
  Future<void> deleteUser({required String userID}) async {
    emit(DeleteUserLoading());
    final result = await userDetailRepo.deleteUser(uid: userID);
    result.fold(
      (failure) {
        emit(DeleteUserFailure(errmessage: failure.message));
      },
      (r) {
        emit(DeleteUserSuccess());
      },
    );
  }

  void reset() {
    userEntity = UserEntity.empty();
    userCourses = [];
    userTransactions = [];
    userSupportTicketsCount = 0;
    userSubscriptionsCount = 0;
    userTransactionsAmount = 0.0;
  }

  void callAll({required String userID}) {
    getUserDetails(userID: userID);
    getUserCourses(userID: userID);
    getUserTransactions(userID: userID);
    getUserSupportTicketsCount(userID: userID);
  }

  void createWallet() {
    userEntity.teacherExtraDataEntity =
        userEntity.teacherExtraDataEntity ??
        TeacherExtraDataEntity(
          wallet: WalletEntity.empty().copyWith(teacherId: userEntity.uid),
          subject: "",
          workExperience: "",
        );
    emit(CreatedeEmptyWalletSuccess());
  }
}
