part of 'user_wallet_cubit.dart';

@immutable
sealed class UserWalletState {}

final class UserWalletInitial extends UserWalletState {}

final class SetUserWalletLoading extends UserWalletState {}

final class SetUserWalletSuccess extends UserWalletState {}

final class SetUserWalletFailure extends UserWalletState {
  final String errMessage;
  SetUserWalletFailure({required this.errMessage});
}
