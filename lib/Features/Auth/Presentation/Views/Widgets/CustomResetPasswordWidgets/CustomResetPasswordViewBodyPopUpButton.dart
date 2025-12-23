import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomResetPasswordViewBodyPopUpButton extends StatelessWidget {
  const CustomResetPasswordViewBodyPopUpButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        GoRouter.of(context).pop();
      },
      child: Text(
        "الرجوع لتسجيل الدخول",
        style: AppTextStyles(context).semiBold16.copyWith(
          color: KMainColor,
          decoration: TextDecoration.underline,
          decorationColor: KMainColor,
        ),
      ),
    );
  }
}
