import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseTransactionsSectionCardWidgets/TransactionItemStatusBadge.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseTransactionsSectionCardWidgets/TransactionsCardItemCreatedAt.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseTransactionsSectionCardWidgets/TransactionsCardItemId.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseTransactionsSectionCardWidgets/TransactionsCardItemInfo.dart';

class VerticalUserTransactionItem extends StatelessWidget {
  final TransactionEntity transaction;

  const VerticalUserTransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor.withOpacity(0.8) : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withOpacity(isDark ? 0.1 : 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TransactionItemStatusBadge(status: transaction.status),
              SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TransactionsCardItemId(transaction: transaction),
                ),
              ),
            ],
          ),
          const Spacer(),
          Align(
            alignment: Alignment.center,
            child: TransactionsCardItemInfo(transaction: transaction),
          ),
          const Spacer(),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          TransactionsCardItemCreatedAt(transaction: transaction),
        ],
      ),
    );
  }
}
