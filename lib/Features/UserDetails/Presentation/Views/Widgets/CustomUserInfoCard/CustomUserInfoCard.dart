import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/user_details_cubit/user_details_cubit.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserInfoCard/UserMainInfo.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserInfoCard/UserStatusActionSection.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserAvatar.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomUserInfoCard extends StatelessWidget {
  const CustomUserInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final UserEntity userEntity = context.watch<UserDetailsCubit>().userEntity;
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;
        return CustomCard(
          padding: const EdgeInsets.all(24),
          child: BlocBuilder<UserDetailsCubit, UserDetailsState>(
            buildWhen: (previous, current) {
              return current is GetUserDetailsFailure ||
                  current is GetUserDetailsLoading ||
                  current is GetUserDetailsSuccess;
            },
            builder: (context, state) {
              if (state is GetUserDetailsFailure) {
                return CustomErrorWidget(errormessage: state.errmessage);
              }
              return Skeletonizer(
                enabled: state is GetUserDetailsLoading,
                child: Flex(
                  direction: isMobile ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: isMobile
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    UserAvatar(imageUrl: userEntity.profilePicurl),
                    const SizedBox(width: 24, height: 24),
                    Flexible(
                      flex: isMobile ? 0 : 6,
                      child: UserMainInfo(
                        textAlign: isMobile
                            ? TextAlign.center
                            : TextAlign.start,
                      ),
                    ),
                    if (isMobile)
                      const SizedBox(height: 24)
                    else
                      const Spacer(flex: 1),
                    const UserStatusActionSection(),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
