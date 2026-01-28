import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/TeacherWalletEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Domain/Repos/UserWalletRepo.dart';

part 'user_wallet_state.dart';

class UserWalletCubit extends Cubit<UserWalletState> {
  UserWalletCubit({
    required this.walletRepo,
    required WalletEntity initialWallet,
  }) : _initialData = {
         'walletId': initialWallet.walletId,
         'balance': initialWallet.balance,
         'currency': initialWallet.currency,
         'totalEarned': initialWallet.totalEarned,
         'payoutPending': initialWallet.payoutPending,
         'lastTransactionId': initialWallet.lastTransactionId,
         'createdAt': initialWallet.createdAt,
       },
       super(UserWalletInitial());

  final UserWalletRepo walletRepo;
  final Map<String, dynamic> _initialData;

  Future<void> setWallet({
    required String userID,
    required WalletEntity updatedWallet,
  }) async {
    bool isSame =
        _initialData['walletId'] == updatedWallet.walletId &&
        _initialData['balance'] == updatedWallet.balance &&
        _initialData['currency'] == updatedWallet.currency &&
        _initialData['totalEarned'] == updatedWallet.totalEarned &&
        _initialData['payoutPending'] == updatedWallet.payoutPending &&
        _initialData['lastTransactionId'] == updatedWallet.lastTransactionId &&
        _initialData['createdAt'] == updatedWallet.createdAt;

    if (isSame) {
      emit(SetUserWalletSuccess());
      return;
    }

    emit(SetUserWalletLoading());
    final result = await walletRepo.setTeacherWallet(
      userID: userID,
      walletEntity: updatedWallet,
    );

    result.fold(
      (failure) => emit(SetUserWalletFailure(errMessage: failure.message)),
      (r) {
        _updateSnapshot(updatedWallet);
        emit(SetUserWalletSuccess());
      },
    );
  }

  void _updateSnapshot(WalletEntity updated) {
    _initialData['walletId'] = updated.walletId;
    _initialData['balance'] = updated.balance;
    _initialData['currency'] = updated.currency;
    _initialData['totalEarned'] = updated.totalEarned;
    _initialData['payoutPending'] = updated.payoutPending;
    _initialData['lastTransactionId'] = updated.lastTransactionId;
    _initialData['createdAt'] = updated.createdAt;
  }
}
