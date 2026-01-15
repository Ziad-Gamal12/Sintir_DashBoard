import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';

class SelectedUsersWrap extends StatelessWidget {
  final List<UserEntity> selectedUsers;
  final Function(UserEntity) onDelete;

  const SelectedUsersWrap({
    super.key,
    required this.selectedUsers,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedUsers.isEmpty) return const SizedBox.shrink();
    ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 8,
        children: selectedUsers
            .map(
              (user) => Chip(
                side: BorderSide(color: theme.primaryColor.withOpacity(0.5)),
                backgroundColor: theme.cardColor,
                deleteIconColor: theme.primaryColor,
                label: Text(user.firstName),
                onDeleted: () => onDelete(user),
              ),
            )
            .toList(),
      ),
    );
  }
}
