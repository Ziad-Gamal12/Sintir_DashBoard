import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class ContentCreatorCoursesHeader extends StatelessWidget {
  const ContentCreatorCoursesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text("الكورسات", style: AppTextStyles(context).semiBold20),
        const SizedBox(height: 12),
      ],
    );
  }
}
