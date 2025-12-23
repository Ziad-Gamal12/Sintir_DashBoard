import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Repos/AuthRepo.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit({required this.authRepo}) : super(SignUpInitial());
  final AuthRepo authRepo;

  Future<void> signUp({
    required UserEntity user,
    required String password,
  }) async {
    emit(SignUpLoading());
    final result = await authRepo.signUpWithEmailAndPassword(
      userEntity: user,
      password: password,
    );
    result.fold(
      (failure) => emit(SignUpFailure(errMessage: failure.message)),
      (r) => emit(SignUpSuccess()),
    );
  }
}
