import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCheckBox.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Presentation/Managers/users_management_cubit/users_management_cubit.dart';
import 'package:sintir_dashboard/constant.dart';

class UserListSection extends StatelessWidget {
  final ScrollController scrollController;
  final List<UserEntity> selectedUsers;
  final Function(UserEntity, bool) onUserToggled;

  const UserListSection({
    super.key,
    required this.scrollController,
    required this.selectedUsers,
    required this.onUserToggled,
  });

  @override
  Widget build(BuildContext context) {
    final textstyles = AppTextStyles(context);
    return BlocBuilder<UsersManagementCubit, UsersManagementState>(
      builder: (context, state) {
        final cubit = context.read<UsersManagementCubit>();

        if (state is GetUsersManagementLoading && !state.isPaginate) {
          return const Center(
            child: CircularProgressIndicator(color: KMainColor),
          );
        }

        if (state is GetUsersManagementFailure && cubit.users.isEmpty) {
          return Center(
            child: CustomErrorWidget(errormessage: state.errMessage),
          );
        }

        return Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          child: ListView.separated(
            controller: scrollController,
            itemCount: cubit.users.length + (cubit.hasMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index >= cubit.users.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: KMainColor),
                  ),
                );
              }
              final user = cubit.users[index];
              final isSelected = selectedUsers.any((u) => u.uid == user.uid);
              return ListTile(
                key: ValueKey(user.uid),
                leading: _UserAvatar(imageUrl: user.profilePicurl),
                title: Text(
                  "${user.firstName} ${user.lastName}",
                  style: textstyles.semiBold14,
                ),
                subtitle: Text(
                  user.email,
                  style: textstyles.regular11,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Customcheckbox(
                  isChecked: isSelected,
                  onChanged: (val) => onUserToggled(user, val),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String imageUrl;
  const _UserAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: CustomCachedNetworkImage(imageUrl: imageUrl),
        ),
      ),
    );
  }
}
