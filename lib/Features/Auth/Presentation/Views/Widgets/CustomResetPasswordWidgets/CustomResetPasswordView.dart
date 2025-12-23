// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Managers/Custom_reset_password_cubit/Custom_reset_password_cubit.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Core/repos/ResetPaswordRepo/ResetPaswordRepo.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAppBar.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/CustomResetPasswordWidgets/CustomResetPasswordViewBody.dart';

class CustomResetPasswordView extends StatelessWidget {
  const CustomResetPasswordView({super.key});
  static const routeName = '/teacherResetPasswordView';
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CustomResetPasswordCubit(authrepo: getIt<ResetPaswordRepo>()),
      child: Scaffold(
        appBar: CustomAppBar(appBartitle: "نسيت كلمة المرور"),
        body: const CustomResetPasswordViewBody(),
      ),
    );
  }
}
