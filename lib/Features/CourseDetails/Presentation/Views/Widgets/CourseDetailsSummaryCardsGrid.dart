import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Entities/CourseDetailsSummaryCardEntity.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDetailsSummaryStatCard.dart';

class CourseDetailsSummaryCardsGrid extends StatelessWidget {
  const CourseDetailsSummaryCardsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = CourseDetailsSummaryCardEntity.getCourseDetailsSummaryCards();
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
        return CourseDetailsSummaryStatCard(summaryCardEntity: items[index]);
      }),
    );
  }
}
