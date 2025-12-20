// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomLoginViewBodyDonotHaveAccountText extends StatelessWidget {
  const CustomLoginViewBodyDonotHaveAccountText({
    super.key,
    required this.onTap,
  });

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "ليس لديك حساب؟ ",
              style: AppTextStyles(
                context,
              ).semiBold16.copyWith(color: const Color(0xff949D9E)),
            ),
            TextSpan(
              text: "إنشاء حساب",
              style: AppTextStyles(
                context,
              ).semiBold16.copyWith(color: KMainColor),
            ),
          ],
        ),
      ),
    );
  }
}
