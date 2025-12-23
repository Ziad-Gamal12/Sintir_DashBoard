import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomBackButton.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomBackButton(),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "إنشاء حساب جديد",
              style: AppTextStyles(
                context,
              ).semiBold24.copyWith(color: theme.textTheme.bodyLarge!.color),
            ),
            const SizedBox(height: 12),
            Text(
              "الرجاء إدخال بياناتك لانشاء حساب جديد",
              style: AppTextStyles(
                context,
              ).regular14.copyWith(color: const Color(0xFFB0B8C4)),
            ),
          ],
        ),
      ],
    );
  }
}
