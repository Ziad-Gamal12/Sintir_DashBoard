import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class TransactionsCardItemInfo extends StatelessWidget {
  const TransactionsCardItemInfo({super.key, required this.transaction});

  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyles = AppTextStyles(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${transaction.amount} ${transaction.currency}",
          style: textStyles.bold20.copyWith(
            color: isDark ? Colors.greenAccent : Colors.green.shade700,
          ),
        ),
        Text(
          "${transaction.method}-${transaction.issuer}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textStyles.regular13.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
