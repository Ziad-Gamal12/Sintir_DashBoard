// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCheckBox.dart';
import 'package:sintir_dashboard/Core/widgets/CustomSizedBox.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomTermsAndConditions extends StatelessWidget {
  const CustomTermsAndConditions({
    super.key,
    required this.textOnPressed,
    required this.onChanged,
  });

  final VoidCallback textOnPressed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Customcheckbox(onChanged: onChanged),
        const Customsizedbox(width: 16, height: 0),
        Expanded(
          child: GestureDetector(
            onTap: textOnPressed,
            child: SizedBox(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "من خلال إنشاء حساب، فإنك توافق على ",
                      style: AppTextStyles(
                        context,
                      ).semiBold13.copyWith(color: const Color(0xff949D9E)),
                    ),
                    TextSpan(
                      text: "الشروط والأحكام الخاصة بنا",
                      style: AppTextStyles(
                        context,
                      ).semiBold13.copyWith(color: KSecondaryColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
