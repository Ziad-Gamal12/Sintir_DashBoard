import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/user_details_cubit/user_details_cubit.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/NoWalletPlaceholder.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserWalletSectionCard/UserWalletSectionCard.dart';

class CustomUserWalletSecion extends StatelessWidget {
  const CustomUserWalletSecion({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserDetailsCubit>().userEntity;
    return BlocSelector<UserDetailsCubit, UserDetailsState, bool>(
      selector: (state) => state is CreatedeEmptyWalletSuccess,
      builder: (context, isLoading) {
        return user.teacherExtraDataEntity?.wallet != null
            ? UserWalletSectionCard(wallet: user.teacherExtraDataEntity!.wallet)
            : NoWalletPlaceholder(
                onAddPressed: () {
                  context.read<UserDetailsCubit>().createWallet();
                },
              );
      },
    );
  }
}
