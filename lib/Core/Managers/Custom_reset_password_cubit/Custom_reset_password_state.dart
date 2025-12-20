// ignore_for_file: file_names

part of 'Custom_reset_password_cubit.dart';

@immutable
sealed class CustomResetPasswordState {}

final class CustomResetPasswordInitial extends CustomResetPasswordState {}

final class CustomResetPasswordLoading extends CustomResetPasswordState {}

final class CustomResetPasswordSuccess extends CustomResetPasswordState {}

final class CustomResetPasswordFailure extends CustomResetPasswordState {
  final String errmessage;
  CustomResetPasswordFailure({required this.errmessage});
}
