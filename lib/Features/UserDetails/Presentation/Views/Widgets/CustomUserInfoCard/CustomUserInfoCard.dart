import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/user_details_cubit/user_details_cubit.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserInfoCard/UserActionsMenu.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserInfoCard/UserInfoStateWrapper.dart';

class CustomUserInfoCard extends StatelessWidget {
  const CustomUserInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final userEntity = context.watch<UserDetailsCubit>().userEntity;
    return CustomCard(
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          const UserInfoStateWrapper(),
          Positioned(top: 0, left: 0, child: UserActionsMenu(user: userEntity)),
        ],
      ),
    );
  }
}
