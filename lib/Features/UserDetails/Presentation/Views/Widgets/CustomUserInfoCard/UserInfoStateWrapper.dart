import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/user_details_cubit/user_details_cubit.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserInfoCard/ResponsiveUserInfoLayout.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserInfoStateWrapper extends StatelessWidget {
  const UserInfoStateWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserDetailsCubit, UserDetailsState>(
      buildWhen: (prev, curr) =>
          curr is GetUserDetailsFailure ||
          curr is GetUserDetailsLoading ||
          curr is GetUserDetailsSuccess,
      builder: (context, state) {
        if (state is GetUserDetailsFailure) {
          return CustomErrorWidget(errormessage: state.errmessage);
        }

        return Skeletonizer(
          enabled: state is GetUserDetailsLoading,
          child: const ResponsiveUserInfoLayout(),
        );
      },
    );
  }
}
