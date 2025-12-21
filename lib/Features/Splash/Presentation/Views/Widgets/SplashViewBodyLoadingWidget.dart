import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/constant.dart';

class SplashViewBodyLoadingWidget extends StatelessWidget {
  const SplashViewBodyLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .center,
      mainAxisAlignment: .center,
      children: [
        const CircularProgressIndicator(color: KMainColor, strokeWidth: 1),
        SizedBox(height: 8),
        Text("حاري التحميل ...", style: AppTextStyles(context).regular14),
      ],
    );
  }
}
