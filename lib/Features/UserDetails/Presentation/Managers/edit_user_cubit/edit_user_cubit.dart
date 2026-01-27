import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Domain/Repos/UserDetailRepo.dart';

part 'edit_user_state.dart';

class EditUserCubit extends Cubit<EditUserState> {
  EditUserCubit({required this.userDetailsRepo}) : super(EditUserInitial());
  final UserDetailsRepo userDetailsRepo;

  Future<void> editUser({required UserEntity userEntity}) async {
    emit(EditUserLoading());
    final result = await userDetailsRepo.updateUser(userEntity: userEntity);
    result.fold(
      (failure) {
        emit(EditUserFailure(errmessage: failure.message));
      },
      (r) {
        emit(EditUserSuccess());
      },
    );
  }
}
