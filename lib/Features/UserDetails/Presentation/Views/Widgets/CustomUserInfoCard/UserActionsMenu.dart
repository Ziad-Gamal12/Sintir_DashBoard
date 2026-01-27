import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/widgets/AppDialogs.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Domain/Helpers/EditUserDetailsDialogHelper.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/user_details_cubit/user_details_cubit.dart';

class UserActionsMenu extends StatelessWidget {
  final UserEntity user;
  const UserActionsMenu({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey),
      tooltip: "خيارات إدارية",
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined, size: 20),
            title: Text("تعديل البيانات"),
            dense: true,
          ),
        ),
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
        if (value == 'edit') {
          EditUserDetailsDialogHelper.showResponsiveEditUserDialog(
            context,
            user,
          );
        } else if (value == 'delete') {
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
