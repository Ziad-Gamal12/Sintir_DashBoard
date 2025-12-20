import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class InfoRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final TextStyle? textStyle;
  final String? headline;
  const InfoRow({
    super.key,
    this.icon,
    required this.label,
    this.textStyle,
    this.headline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
    final headlineColor = theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Row(
      children: [
        headline == null
            ? Icon(icon, color: textColor, size: 18)
            : Text(
                headline!,
                style: AppTextStyles(
                  context,
                ).semiBold12.copyWith(color: headlineColor),
              ),
        const SizedBox(width: 8),
        Text(
          label,
          style:
              textStyle ??
              AppTextStyles(context).regular10.copyWith(color: textColor),
        ),
      ],
    );
  }
}
