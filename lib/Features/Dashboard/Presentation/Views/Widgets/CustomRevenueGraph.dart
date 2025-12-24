import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CustomRevenueGraph extends StatefulWidget {
  final List<TransactionEntity> transactions;

  const CustomRevenueGraph({super.key, required this.transactions});

  @override
  State<CustomRevenueGraph> createState() => _CustomRevenueGraphState();
}

class _CustomRevenueGraphState extends State<CustomRevenueGraph> {
  bool showAverage = false;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color secondaryTextColor = theme.textTheme.bodyMedium!.color!
        .withOpacity(0.6);
    final Color mainColor = theme.colorScheme.primary;

    if (widget.transactions.isEmpty) {
      return const Center(child: Text("لا يوجد بيانات"));
    }

    // Process data for the last 6 transactions
    List<TransactionEntity> recentResults = widget.transactions.reversed
        .toList();
    List<TransactionEntity> displayedResults = recentResults.length > 6
        ? recentResults.sublist(0, 6).reversed.toList()
        : recentResults.reversed.toList();

    final List<double> values = displayedResults
        .map((e) => (e.amount ?? 0).toDouble())
        .toList();
    final double totalRevenue = values.fold(0, (p, c) => p + c);
    final double avgValue = values.isNotEmpty
        ? totalRevenue / values.length
        : 0.0;
    final double maxVal = values.isNotEmpty
        ? values.reduce((a, b) => a > b ? a : b)
        : 0;

    // Y-Axis padding
    double chartMaxY = (maxVal + (maxVal * 0.2)).clamp(10, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- NEW HEADER SECTION ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "إجمالي الشهر: ",
                      style: AppTextStyles(
                        context,
                      ).regular13.copyWith(color: secondaryTextColor),
                    ),
                    Text(
                      "${totalRevenue.toStringAsFixed(0)} \$",
                      style: AppTextStyles(
                        context,
                      ).semiBold14.copyWith(color: mainColor),
                    ),
                  ],
                ),
              ],
            ),
            // Toggle Switch for Average
            _buildToggleButton(mainColor, context),
          ],
        ),
        const SizedBox(height: 24),

        // --- THE CHART ---
        AspectRatio(
          aspectRatio: 1.7,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 20, 25, 10),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false, // Cleaner look
                  horizontalInterval: (chartMaxY / 4),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.dividerColor.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "عملية ${value.toInt() + 1}",
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (chartMaxY / 4),
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) => Text(
                        "${value.toInt()}\$",
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (values.length - 1).toDouble(),
                minY: 0,
                maxY: chartMaxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: showAverage
                        ? [
                            FlSpot(0, avgValue),
                            FlSpot((values.length - 1).toDouble(), avgValue),
                          ]
                        : values
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value))
                              .toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    barWidth: 4,
                    color: showAverage ? Colors.orangeAccent : mainColor,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: !showAverage),
                    belowBarData: BarAreaData(
                      show: !showAverage,
                      gradient: LinearGradient(
                        colors: [
                          mainColor.withOpacity(0.2),
                          mainColor.withOpacity(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) =>
                        isDark ? const Color(0xFF2E2E35) : Colors.white,
                    tooltipBorderRadius: BorderRadius.circular(8),
                    getTooltipItems: (spots) => spots.map((s) {
                      return LineTooltipItem(
                        "${s.y.toStringAsFixed(2)} \$",
                        TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(Color mainColor, BuildContext context) {
    return InkWell(
      onTap: () => setState(() => showAverage = !showAverage),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: mainColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              showAverage ? Icons.show_chart : Icons.auto_graph,
              size: 18,
              color: mainColor,
            ),
            const SizedBox(width: 8),
            Text(
              showAverage ? "العرض التفصيلي" : "عرض المتوسط",
              style: TextStyle(
                color: mainColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
