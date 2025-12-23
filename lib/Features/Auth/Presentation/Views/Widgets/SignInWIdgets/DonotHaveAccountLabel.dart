import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/SignUpView.dart';
import 'package:sintir_dashboard/constant.dart';

class DonotHaveAccountLabel extends StatelessWidget {
  const DonotHaveAccountLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "ليس لديك حساب؟",
          style: AppTextStyles(context).regular13.copyWith(color: Colors.grey),
        ),
        TextButton(
          onPressed: () {
            GoRouter.of(context).push(SignUpView.routeName);
          },
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(
            " سجل الأن ",
            style: AppTextStyles(
              context,
            ).semiBold13.copyWith(color: KSecondaryColor),
          ),
        ),
      ],
    );
  }
}
