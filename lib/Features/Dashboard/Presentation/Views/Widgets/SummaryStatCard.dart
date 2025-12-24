import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/InfoHighlightIconCard.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/SummaryCardEntity.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/SummaryCardStatusEntity.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/SummaryStatCardFooter.dart';

class SummaryStatCard extends StatelessWidget {
  const SummaryStatCard({super.key, required this.summaryCardEntity});
  final SummaryCardEntity summaryCardEntity;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    bool isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InfoHighlightIconCard(
                icon: summaryCardEntity.icon,
                color: summaryCardEntity.color,
              ),
              SummaryStatCardFooter(
                summaryCardStatusEntity: SummaryCardStatusEntity(
                  isIncreasing: true, // Example logic
                  percentage: 12.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            summaryCardEntity.title,
            style: AppTextStyles(context).regular13.copyWith(
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "100",
            style: AppTextStyles(context).bold19.copyWith(
              fontSize: 22, // Make the number more prominent
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
