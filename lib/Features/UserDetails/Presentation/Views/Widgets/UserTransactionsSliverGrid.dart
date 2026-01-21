import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';

import 'VerticalUserTransactionItem.dart';

class UserTransactionsSliverGrid extends StatelessWidget {
  final List<TransactionEntity> transactions;

  const UserTransactionsSliverGrid({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    int crossAxisCount = width < 600 ? 2 : (width < 900 ? 3 : 4);
    return SliverGrid.builder(
      itemCount: transactions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        return VerticalUserTransactionItem(transaction: transactions[index]);
      },
    );
  }
}
