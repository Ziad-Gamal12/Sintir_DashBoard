import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Helper/GetUserData.dart';
import 'package:sintir_dashboard/Core/Permissions/Permissions%20Mapping.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Core/widgets/AccessDeniedWidget.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Domain/Repos/UsersRepo.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Presentation/Managers/users_management_cubit/users_management_cubit.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Presentation/Views/Widgets/UsersManagementViewBodyHandler.dart';

class UsersManagementViewBody extends StatelessWidget {
  const UsersManagementViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final user = getUserData();

    final bool canViewUsers = PermissionsManager.can(
      Permission.viewUsers,
      role: user.role,
      status: user.status,
    );

    if (!canViewUsers) {
      return const AccessDeniedWidgetAr(featureNameAr: "إدارة المستخدمين");
    }

    return BlocProvider(
      create: (context) => UsersManagementCubit(usersRepo: getIt<UsersRepo>()),
      child: const UsersManagementViewBodyHandler(),
    );
  }
}
