import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CreatorNameTitle extends StatelessWidget {
  final String name;
  final String title;

  const CreatorNameTitle({super.key, required this.name, required this.title});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primaryTextColor = theme.textTheme.titleLarge!.color!;
    final Color secondaryTextColor = theme.textTheme.bodyMedium!.color!;
    final Color verificationColor = theme.colorScheme.secondary;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.user2, size: 22, color: primaryTextColor),
            const SizedBox(width: 6),
            Text(
              name,
              style: AppTextStyles(
                context,
              ).semiBold20.copyWith(color: primaryTextColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.badgeCheck, size: 20, color: verificationColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppTextStyles(
                context,
              ).regular14.copyWith(color: secondaryTextColor),
            ),
          ],
        ),
      ],
    );
  }
}
