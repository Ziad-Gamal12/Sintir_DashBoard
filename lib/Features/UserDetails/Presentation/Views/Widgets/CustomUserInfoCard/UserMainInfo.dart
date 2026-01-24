import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/user_details_cubit/user_details_cubit.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserInfoCard/UserDetailsInfoTile.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserInfoCard/UserStatusActionSection.dart';

class UserMainInfo extends StatelessWidget {
  final TextAlign textAlign;
  const UserMainInfo({super.key, this.textAlign = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    final UserEntity userEntity = context.watch<UserDetailsCubit>().userEntity;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              "${userEntity.firstName} ${userEntity.lastName}",
              style: AppTextStyles(context).bold24,
            ),
            IntrinsicWidth(child: const UserStatusActionSection()),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            UserDetailsInfoTile(icon: Icons.email, label: userEntity.email),
            UserDetailsInfoTile(
              icon: Icons.badge,
              label: "ID: ${userEntity.uid}",
            ),
            UserDetailsInfoTile(
              icon: Icons.phone,
              label: userEntity.phoneNumber,
            ),
            UserDetailsInfoTile(
              icon: Icons.calendar_month,
              label:
                  "تاريخ التسجيل: ${DateFormat('yyyy/MM/dd').format(userEntity.joinedDate)}",
            ),
          ],
        ),
      ],
    );
  }
}
