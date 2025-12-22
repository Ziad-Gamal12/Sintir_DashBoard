// ignore_for_file: camel_case_types, file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Managers/Custom_reset_password_cubit/Custom_reset_password_cubit.dart';
import 'package:sintir_dashboard/Core/widgets/AppDialogs.dart';
import 'package:sintir_dashboard/Core/widgets/customAuthWidgets/CustomResetPasswordViewBodyBlocBuilder.dart';

class CustomResetPasswordViewBody extends StatelessWidget {
  const CustomResetPasswordViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomResetPasswordCubit, CustomResetPasswordState>(
      listener: (context, state) {
        if (state is CustomResetPasswordSuccess) {
          AppDialogs.success(
            context,
            "تم أرسال رابط تغيير كلمه المرور بنجاح",
            onTap: () {
              GoRouter.of(context).pop();
            },
          );
        } else if (state is CustomResetPasswordFailure) {
          AppDialogs.error(context, state.errmessage);
        }
      },
      builder: (context, state) {
        return const CustomResetPasswordViewBodyBlocBuilder();
      },
    );
  }
}
