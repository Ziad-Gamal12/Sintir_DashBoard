import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CustomCourseTransactionsCardItem extends StatelessWidget {
  final TransactionEntity transaction;
  const CustomCourseTransactionsCardItem({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyles = AppTextStyles(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Adapts to light/dark mode automatically
        color: isDark ? theme.cardColor.withOpacity(0.8) : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withOpacity(isDark ? 0.1 : 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Side: Amount and Method
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${transaction.amount} ${transaction.currency}",
                  style: textStyles.bold16.copyWith(
                    color: isDark ? Colors.greenAccent : Colors.green.shade700,
                  ),
                ),
                Text(
                  transaction.method,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyles.regular13.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Center Side: ID and Date
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.transactionId ?? "---",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyles.regular14.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  transaction.createdAt != null
                      ? DateFormat(
                          'yyyy/MM/dd HH:mm',
                        ).format(transaction.createdAt!)
                      : "---",
                  style: textStyles.regular13.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Right Side: Status Badge
          _buildStatusBadge(theme, transaction.status ?? "pending"),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, String status) {
    Color baseColor;
    String label;

    switch (status.toLowerCase()) {
      case 'success':
        baseColor = Colors.green;
        label = "ناجحة";
        break;
      case 'failed':
        baseColor = Colors.red;
        label = "فاشلة";
        break;
      default:
        baseColor = Colors.orange;
        label = "معلقة";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: baseColor.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: baseColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}
