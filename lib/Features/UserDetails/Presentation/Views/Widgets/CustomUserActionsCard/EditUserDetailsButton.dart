import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class EditUserDetailsButton extends StatelessWidget {
  const EditUserDetailsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyles = AppTextStyles(context);
    return IconButton(
      onPressed: () {},
      icon: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.edit,
            color: theme.textTheme.bodySmall?.color ?? Colors.white,
          ),
          Text(
            "تعديل البيانات",
            style: textStyles.regular14.copyWith(
              color: theme.textTheme.bodySmall?.color ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
