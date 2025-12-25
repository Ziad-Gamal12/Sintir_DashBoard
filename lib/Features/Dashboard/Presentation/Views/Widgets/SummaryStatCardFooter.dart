import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/AnalyticsResultEntity.dart';

class SummaryStatCardFooter extends StatelessWidget {
  const SummaryStatCardFooter({
    super.key,
    required this.summaryCardStatusEntity,
  });
  final AnalyticsResultEntity? summaryCardStatusEntity;

  @override
  Widget build(BuildContext context) {
    final bool isUp = summaryCardStatusEntity?.isIncreasing ?? false;
    final Color statusColor = isUp
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 14,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            "${summaryCardStatusEntity?.percentage} %",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
