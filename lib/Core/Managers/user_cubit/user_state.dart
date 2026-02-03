part of 'user_cubit.dart';

@immutable
sealed class UserState {}

final class UserStateInitial extends UserState {}

final class UserStateFetchUserLoading extends UserState {}

final class UserStateFetchUserSuccess extends UserState {}

final class UserStateFetchUserFailure extends UserState {
  final String message;
  UserStateFetchUserFailure({required this.message});
}
