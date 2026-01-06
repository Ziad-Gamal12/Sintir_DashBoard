import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CustomDateHeader extends StatelessWidget {
  final DateTime date;

  const CustomDateHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          DateFormat('d MMM,yyyy').format(date),
          style: AppTextStyles(
            context,
          ).bold13.copyWith(color: theme.textTheme.bodyMedium?.color),
        ),
        Text(
          DateFormat('EEEE').format(date),
          style: AppTextStyles(context).regular11,
        ),
      ],
    );
  }
}
