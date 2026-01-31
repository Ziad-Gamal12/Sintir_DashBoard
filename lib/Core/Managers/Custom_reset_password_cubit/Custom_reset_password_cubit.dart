// ignore_for_file: file_names, depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Core/Errors/Exceptions.dart';
import 'package:sintir_dashboard/Core/repos/ResetPaswordRepo/ResetPaswordRepo.dart';

part 'Custom_reset_password_state.dart';

class CustomResetPasswordCubit extends Cubit<CustomResetPasswordState> {
  CustomResetPasswordCubit({required this.authrepo})
    : super(CustomResetPasswordInitial());
  final ResetPaswordRepo authrepo;
  Future<void> sendResetPasswordEmail({required String email}) async {
    emit(CustomResetPasswordLoading());
    try {
      await authrepo.resetPassword(email: email);
      emit(CustomResetPasswordSuccess());
    } on CustomException catch (e) {
      emit(CustomResetPasswordFailure(errmessage: e.message));
    } catch (e) {
      emit(CustomResetPasswordFailure(errmessage: e.toString()));
    }
  }
}
