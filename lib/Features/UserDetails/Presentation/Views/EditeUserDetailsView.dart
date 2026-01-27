import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Domain/Repos/UserDetailRepo.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/edit_user_cubit/edit_user_cubit.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/EditUserDetails/EditeUserDetailsViewBody.dart';

class EditeUserDetailsView extends StatelessWidget {
  const EditeUserDetailsView({super.key, required this.user});
  final UserEntity user;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          EditUserCubit(userDetailsRepo: getIt<UserDetailsRepo>()),
      child: Scaffold(body: EditUserDetailsViewBody(userEntity: user)),
    );
  }
}
