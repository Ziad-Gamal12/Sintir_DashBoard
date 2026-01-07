import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CreatorStats extends StatelessWidget {
  final int coursesCount;
  final int subscribersCount;

  const CreatorStats({
    super.key,
    required this.coursesCount,
    required this.subscribersCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            LucideIcons.bookOpen,
            "الكورسات",
            coursesCount.toString(),
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: Colors.grey.withOpacity(0.1),
        ), // Vertical Divider
        Expanded(
          child: _buildStatItem(
            context,
            LucideIcons.users,
            "الطلاب",
            subscribersCount.toString(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    final styles = AppTextStyles(context);

    return Column(
      children: [
        Text(
          value,
          style: styles.semiBold16.copyWith(color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: styles.regular11.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}
