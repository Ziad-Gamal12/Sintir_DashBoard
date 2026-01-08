import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/GenderAnalysisEntity.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/GenderPaiChart.dart';

class GenderChartBuilder extends StatelessWidget {
  const GenderChartBuilder({
    super.key,
    required this.isLoading,
    required this.entity,
    required this.snapshotController,
  });
  final bool isLoading;
  final GenderAnalysisEntity entity;
  final SnapshotController snapshotController;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SizedBox(
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SnapshotWidget(
              controller: snapshotController,
              autoresize: !isLoading,
              child: GenderPieChart(
                femaleCount: entity.femaleCount.toDouble(),
                maleCount: entity.maleCount.toDouble(),
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (entity.maleCount + entity.femaleCount).toString(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "إجمالي",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
