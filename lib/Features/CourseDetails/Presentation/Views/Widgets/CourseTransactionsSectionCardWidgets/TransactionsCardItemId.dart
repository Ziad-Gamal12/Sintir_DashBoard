import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Core/Helper/ShowSnackBar.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class TransactionsCardItemId extends StatelessWidget {
  const TransactionsCardItemId({super.key, required this.transaction});

  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyles = AppTextStyles(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            Clipboard.setData(
              ClipboardData(text: transaction.transactionId ?? ""),
            );
            CustomSnackBar.show(
              context,
              message: "تم نسخ الكود",
              type: SnackType.success,
            );
          },
          child: Icon(
            Icons.copy_rounded,
            size: 16,
            color: theme.colorScheme.primary.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            transaction.transactionId ?? "---",
            maxLines: 1,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: textStyles.medium12.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
