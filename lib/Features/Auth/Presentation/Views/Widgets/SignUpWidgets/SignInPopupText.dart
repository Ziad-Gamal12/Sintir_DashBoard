import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class SignInPopupText extends StatelessWidget {
  const SignInPopupText({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).pop();
      },
      child: Align(
        alignment: Alignment.center,
        child: Text(
          "لديك حساب؟",
          style: AppTextStyles(
            context,
          ).regular14.copyWith(color: theme.textTheme.bodyLarge!.color),
        ),
      ),
    );
  }
}
