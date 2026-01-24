import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/user_details_cubit/user_details_cubit.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserInfoCard/UserMainInfo.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserAvatar.dart';

class ResponsiveUserInfoLayout extends StatelessWidget {
  const ResponsiveUserInfoLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final userEntity = context.read<UserDetailsCubit>().userEntity;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: isMobile
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              UserAvatar(imageUrl: userEntity.profilePicurl),
              const SizedBox(width: 24, height: 24),
              Flexible(
                flex: isMobile ? 0 : 7,
                child: UserMainInfo(
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
