import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CustomCourseHorizontalItemPrice extends StatelessWidget {
  const CustomCourseHorizontalItemPrice({super.key, required this.price});

  final double price;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "$price",
          style: AppTextStyles(
            context,
          ).semiBold20.copyWith(color: Colors.red.shade500),
        ),
        const SizedBox(width: 4),
        Text("جنيه", style: AppTextStyles(context).regular16),
      ],
    );
  }
}
