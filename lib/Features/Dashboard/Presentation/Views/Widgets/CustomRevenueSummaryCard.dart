import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomRevenueGraph.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomRevenueSummaryCardTitle.dart';

class CustomRevenueSummaryCard extends StatelessWidget {
  const CustomRevenueSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    bool isDark = theme.brightness == Brightness.dark;
    double width = MediaQuery.sizeOf(context).width;

    double dynamicAspectRatio = width < 600 ? 1 : (width < 1100 ? 1 : 1.2);

    return AspectRatio(
      aspectRatio: dynamicAspectRatio,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomRevenueSummaryCardTitle(),
            const SizedBox(height: 16),
            Expanded(
              child: CustomRevenueGraph(
                transactions: TransactionEntity.getTestTransactions(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
