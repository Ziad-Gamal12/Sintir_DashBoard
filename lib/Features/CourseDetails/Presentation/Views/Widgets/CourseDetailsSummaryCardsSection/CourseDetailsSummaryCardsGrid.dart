import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Entities/CourseDetailsSummaryCardEntity.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseAnalyticsCubit/course_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDetailsSummaryCardsSection/CourseDetailsSummaryStatCard.dart';

class CourseDetailsSummaryCardsGrid extends StatefulWidget {
  const CourseDetailsSummaryCardsGrid({super.key, required this.courseId});
  final String courseId;
  @override
  State<CourseDetailsSummaryCardsGrid> createState() =>
      _CourseDetailsSummaryCardsGridState();
}

class _CourseDetailsSummaryCardsGridState
    extends State<CourseDetailsSummaryCardsGrid> {
  @override
  void initState() {
    super.initState();
    context.read<CourseAnalyticsCubit>().fetchAllCourseStats(widget.courseId);
  }

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
