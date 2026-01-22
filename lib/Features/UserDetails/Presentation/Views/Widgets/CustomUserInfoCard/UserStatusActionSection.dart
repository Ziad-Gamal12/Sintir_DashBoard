import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/UserRoleBadgeEntity.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Domain/Helpers/UsersStatusHelper.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/user_details_cubit/user_details_cubit.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserInfoCard/UserDetailsStatusBadge.dart';

class UserStatusActionSection extends StatelessWidget {
  const UserStatusActionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final UserEntity userEntity = context.watch<UserDetailsCubit>().userEntity;
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isNarrow = constraints.maxWidth < 600;
        return Wrap(
          direction: isNarrow ? Axis.horizontal : Axis.vertical,
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            UserDetailsStatusBadge(
              text: UsersStatusHelper.getUserStatusArabic(userEntity.status),
              color: UsersStatusHelper.getUserStatusColor(userEntity.status),
            ),
            UserDetailsStatusBadge(
              text: UserRoleBadgeEntity.getUserRoleBadgeEntity(userEntity.role).title,
              color: UserRoleBadgeEntity.getUserRoleBadgeEntity(userEntity.role).color,
            ),
          ],
        );
      },
    );
  }


}
