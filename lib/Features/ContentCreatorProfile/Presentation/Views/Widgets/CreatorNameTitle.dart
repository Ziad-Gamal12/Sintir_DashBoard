import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CreatorNameTitle extends StatelessWidget {
  final String name;
  final String title;

  const CreatorNameTitle({super.key, required this.name, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styles = AppTextStyles(context);

    return Column(
      children: [
        Text(
          name,
          style: styles.semiBold20.copyWith(
            letterSpacing: -0.5,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.badgeCheck,
              size: 16,
              color: Color(0xff5F9BFF),
            ),
            const SizedBox(width: 6),
            Text(
              title.isEmpty ? "محاضر معتمد" : title,
              style: styles.regular14.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
