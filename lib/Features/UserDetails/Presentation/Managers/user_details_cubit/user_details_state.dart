part of 'user_details_cubit.dart';

@immutable
sealed class UserDetailsState {}

final class UserDetailsInitial extends UserDetailsState {}
// get User Details

final class GetUserDetailsLoading extends UserDetailsState {}

final class GetUserDetailsSuccess extends UserDetailsState {}

final class GetUserDetailsFailure extends UserDetailsState {
  final String errmessage;
  GetUserDetailsFailure({required this.errmessage});
}

// get user enrolled courses
final class GetUserEnrolledCoursesLoading extends UserDetailsState {}

final class GetUserEnrolledCoursesSuccess extends UserDetailsState {}

final class GetUserEnrolledCoursesFailure extends UserDetailsState {
  final String errmessage;
  GetUserEnrolledCoursesFailure({required this.errmessage});
}

// get user transactions
final class GetUserTransactionsLoading extends UserDetailsState {}

final class GetUserTransactionsSuccess extends UserDetailsState {}

final class GetUserTransactionsFailure extends UserDetailsState {
  final String errmessage;
  GetUserTransactionsFailure({required this.errmessage});
}

// get user support tickets count
final class GetUserSupportTicketsCountLoading extends UserDetailsState {}

final class GetUserSupportTicketsCountSuccess extends UserDetailsState {}

final class GetUserSupportTicketsCountFailure extends UserDetailsState {
  final String errmessage;
  GetUserSupportTicketsCountFailure({required this.errmessage});
}

// delete user
final class DeleteUserLoading extends UserDetailsState {}

final class DeleteUserSuccess extends UserDetailsState {}

final class DeleteUserFailure extends UserDetailsState {
  final String errmessage;
  DeleteUserFailure({required this.errmessage});
}
