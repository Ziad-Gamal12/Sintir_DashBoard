import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/TicketsSummaryCardEntity.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/TicketsSummaryStatCard.dart';

class CustomTicketsSummaryCardGrid extends StatelessWidget {
  const CustomTicketsSummaryCardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = TicketsSummaryCardEntity.getTicketsSummaryCards();
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
        return TicketsSummaryStatCard(summaryCardEntity: items[index]);
      }),
    );
  }
}
