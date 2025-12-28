import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CustomRevenueSummaryCardTitle extends StatelessWidget {
  const CustomRevenueSummaryCardTitle({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return ListTile(
      title: Text(
        "تحليل الإيرادات",
        style: AppTextStyles(
          context,
        ).semiBold16.copyWith(color: theme.textTheme.bodyLarge!.color),
      ),
      subtitle: Text(
        "نظرة عامة على إيرادات المنصه أخر شهر",
        style: AppTextStyles(context).regular11.copyWith(color: Colors.grey),
      ),
    );
  }
}
