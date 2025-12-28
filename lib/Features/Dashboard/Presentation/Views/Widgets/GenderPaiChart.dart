import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GenderPieChart extends StatefulWidget {
  const GenderPieChart({
    super.key,
    required this.maleCount,
    required this.femaleCount,
  });

  final double maleCount;
  final double femaleCount;

  @override
  State<GenderPieChart> createState() => _GenderPieChartState();
}

class _GenderPieChartState extends State<GenderPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 8,
        centerSpaceRadius: 70,
        startDegreeOffset: -90,
        sections: showingSections(),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    final total = widget.maleCount + widget.femaleCount;
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 35.0 : 25.0;
      final isMale = i == 0;
      final double value = isMale ? widget.maleCount : widget.femaleCount;
      final String percentage = total == 0
          ? "0%"
          : "${(value / total * 100).toStringAsFixed(1)}%";

      return PieChartSectionData(
        gradient: isMale
            ? const LinearGradient(
                colors: [Color(0xff2196F3), Color(0xff64B5F6)],
              )
            : const LinearGradient(
                colors: [Color(0xffE91E63), Color(0xffF06292)],
              ),
        value: value,
        title: isTouched ? percentage : '',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: _Badge(
          isMale ? Icons.male : Icons.female,
          size: isTouched ? 48 : 40,
          color: isMale ? const Color(0xff2196F3) : const Color(0xffE91E63),
        ),
        badgePositionPercentageOffset: 1.3,
      );
    });
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.icon, {required this.size, required this.color});
  final IconData icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}
