import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Helper/AppPadding.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignInWIdgets/SignInSection.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignInWIdgets/SignInWelcomePlaceHolder.dart';

class SignInViewBody extends StatelessWidget {
  const SignInViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppPadding.horizontal(context),
              vertical: AppPadding.vertical(context),
            ),
            child: SignInSection(),
          ),
        ),
        SignInWelcomePlaceHolder(),
      ],
    );
  }
}
