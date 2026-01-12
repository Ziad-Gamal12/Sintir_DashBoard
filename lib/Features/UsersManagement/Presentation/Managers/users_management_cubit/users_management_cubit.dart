import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Domain/Entities/FilterUsersQueryEntity.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Domain/Entities/GetUsersResponseEntity.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Domain/Repos/UsersRepo.dart';

part 'users_management_state.dart';

class UsersManagementCubit extends Cubit<UsersManagementState> {
  UsersManagementCubit({required this.usersRepo})
    : super(UsersManagementInitial());
  final UsersRepo usersRepo;
  bool hasMore = true;
  List<UserEntity> users = [];
  FilterUsersQueryEntity filters = FilterUsersQueryEntity();

  Future<void> getUsers({required bool isPaginate}) async {
    emit(GetUsersManagementLoading(isPaginate: isPaginate));
    final result = await usersRepo.getUsers(filters, isPaginate: isPaginate);
    result.fold(
      (failure) => emit(GetUsersManagementFailure(errMessage: failure.message)),
      (response) {
        hasMore = response.hasMore;
        allUsers(response: response);
        emit(GetUsersManagementSuccess(users: users));
      },
    );
  }

  Future<void> filterUsers(FilterUsersQueryEntity filters) async {
    this.filters = filters;
    await getUsers(isPaginate: false);
  }

  void allUsers({required GetUsersResponseEntity response}) {
    if (response.isPaginate) {
      users.addAll(response.users);
    } else {
      users = response.users;
    }
  }
}
