import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/CustomResetPasswordView.dart';
import 'package:sintir_dashboard/constant.dart';

class ForgetPasswordLabel extends StatelessWidget {
  const ForgetPasswordLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        GoRouter.of(context).push(CustomResetPasswordView.routeName);
      },
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
      child: Text(
        "نسيت كلمة المرور؟",
        style: AppTextStyles(context).regular13.copyWith(color: KMainColor),
      ),
    );
  }
}
