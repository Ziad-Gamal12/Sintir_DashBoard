part of 'users_management_cubit.dart';

@immutable
sealed class UsersManagementState {}

final class UsersManagementInitial extends UsersManagementState {}

final class GetUsersManagementLoading extends UsersManagementState {
  final bool isPaginate;
  GetUsersManagementLoading({required this.isPaginate});
}

final class GetUsersManagementSuccess extends UsersManagementState {
  final List<UserEntity> users;
  GetUsersManagementSuccess({required this.users});
}

final class GetUsersManagementFailure extends UsersManagementState {
  final String errMessage;
  GetUsersManagementFailure({required this.errMessage});
}
