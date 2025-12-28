import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/SummaryCardEntity.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/SummaryStatCard.dart';

class CustomSummaryCardGrid extends StatelessWidget {
  const CustomSummaryCardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = SummaryCardEntity.getSummaryCards();

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 360,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 160,
      ),
      delegate: SliverChildBuilderDelegate(childCount: items.length, (
        context,
        index,
      ) {
        return SummaryStatCard(summaryCardEntity: items[index]);
      }),
    );
  }
}
