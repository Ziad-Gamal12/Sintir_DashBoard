import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/imageAssets.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:svg_flutter/svg_flutter.dart';

class SignInHeader extends StatelessWidget {
  const SignInHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SvgPicture.asset(
          Assets.assetsIconsSVGIconsAppLogo,
          height: 40,
          width: 40,
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "مرحباً بعودتك !",
              style: AppTextStyles(context).semiBold24.copyWith(),
            ),
            const SizedBox(height: 12),
            Text(
              "الرجاء إدخال بياناتك لتسجيل الدخول",
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
