import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class TransactionsCardItemCreatedAt extends StatelessWidget {
  const TransactionsCardItemCreatedAt({super.key, required this.transaction});

  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyles = AppTextStyles(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          transaction.createdAt != null
              ? DateFormat('yyyy/MM/dd').format(transaction.createdAt!)
              : "---",
          style: textStyles.regular13.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
        ),
        Text(
          transaction.createdAt != null
              ? DateFormat('hh:mm a').format(transaction.createdAt!)
              : "---",
          style: textStyles.regular13.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}
