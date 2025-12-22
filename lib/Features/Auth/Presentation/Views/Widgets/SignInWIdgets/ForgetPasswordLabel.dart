import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/constant.dart';

class ForgetPasswordLabel extends StatelessWidget {
  const ForgetPasswordLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
      child: Text(
        "نسيت كلمة المرور؟",
        style: AppTextStyles(context).regular13.copyWith(color: KMainColor),
      ),
    );
  }
}
