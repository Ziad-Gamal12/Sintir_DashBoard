import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Repos/AuthRepo.dart';

part 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit({required this.authRepo}) : super(SignInInitial());
  final AuthRepo authRepo;

  Future<void> signIn({required String email, required String password}) async {
    emit(SignInLoading());
    final result = await authRepo.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    result.fold(
      (failure) => emit(SignInFailure(errMessage: failure.message)),
      (r) => emit(SignInSuccess()),
    );
  }
}
