import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Helper/GetUserData.dart';
import 'package:sintir_dashboard/Core/Permissions/Permissions%20Mapping.dart';
import 'package:sintir_dashboard/Core/widgets/AppDialogs.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Domain/Helpers/EditUserDetailsDialogHelper.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/user_details_cubit/user_details_cubit.dart';

class UserActionsMenu extends StatelessWidget {
  final UserEntity user;
  const UserActionsMenu({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final currentUser = getUserData();

    final bool canEdit = PermissionsManager.can(
      Permission.editUser,
      role: currentUser.role,
      status: currentUser.status,
    );

    final bool canDelete = PermissionsManager.can(
      Permission.deleteUser,
      role: currentUser.role,
      status: currentUser.status,
    );

    if (!canEdit && !canDelete) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey),
      tooltip: "خيارات إدارية",
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        if (canEdit)
          const PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit_outlined, size: 20),
              title: Text("تعديل البيانات"),
              dense: true,
            ),
          ),
        if (canDelete)
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red, size: 20),
              title: Text("حذف المستخدم", style: TextStyle(color: Colors.red)),
              dense: true,
            ),
          ),
      ],
      onSelected: (value) {
        if (value == 'edit' && canEdit) {
          EditUserDetailsDialogHelper.showResponsiveEditUserDialog(
            context,
            user,
          );
        } else if (value == 'delete' && canDelete) {
          AppDialogs.warning(
            context,
            "هل أنت متأكد من رغبتك في حذف هذا المستخدم؟ هذا الإجراء لا يمكن التراجع عنه.",
            onTap: () {
              context.read<UserDetailsCubit>().deleteUser(userID: user.uid);
            },
          );
        }
      },
    );
  }
}
