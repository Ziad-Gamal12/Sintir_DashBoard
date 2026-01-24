import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/TeacherWalletEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/user_details_cubit/user_details_cubit.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserWalletSectionCard/UserWalletSectionCard.dart';

class CustomUserWalletSecion extends StatelessWidget {
  const CustomUserWalletSecion({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletEntity? wallet = context
        .watch<UserDetailsCubit>()
        .userEntity
        .teacherExtraDataEntity
        ?.wallet;
    return wallet != null ? UserWalletSectionCard(wallet: wallet) : Container();
  }
}
