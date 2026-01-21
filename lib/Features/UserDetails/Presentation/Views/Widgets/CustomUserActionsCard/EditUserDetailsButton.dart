import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';

class EditUserDetailsButton extends StatelessWidget {
  const EditUserDetailsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyles = AppTextStyles(context);
    return Custombutton(
      text: "",
      color: Colors.transparent.withOpacity(.2),
      textColor: theme.textTheme.bodySmall?.color ?? Colors.white,
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "تعديل البيانات",
            style: textStyles.regular14.copyWith(
              color: theme.textTheme.bodySmall?.color ?? Colors.white,
            ),
          ),
          Icon(
            Icons.edit,
            color: theme.textTheme.bodySmall?.color ?? Colors.white,
          ),
        ],
      ),
    );
  }
}
