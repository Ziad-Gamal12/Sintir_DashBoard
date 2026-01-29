import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class AppCopyrightLabel extends StatelessWidget {
  const AppCopyrightLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "جميع الحقوق محفوظة لموقع سينتير ${DateTime.now().year}",
      textAlign: TextAlign.center,
      style: AppTextStyles(
        context,
      ).regular10.copyWith(color: Colors.grey, letterSpacing: 0.5),
    );
  }
}
