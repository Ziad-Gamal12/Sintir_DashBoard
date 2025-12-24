import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class GenderPieChart extends StatefulWidget {
  const GenderPieChart({
    super.key,
    required this.maleCount,
    required this.femaleCount,
  });

  final double maleCount;
  final double femaleCount;

  @override
  State<StatefulWidget> createState() => GenderPieChartState();
}

class GenderPieChartState extends State<GenderPieChart> {
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
        sectionsSpace: 4,
        centerSpaceRadius: 0,
        sections: showingSections(),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    final total = widget.maleCount + widget.femaleCount;
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 90.0 : 80.0;
      final widgetSize = isTouched ? 45.0 : 35.0;
      final isMale = i == 0;
      final malePerc = (widget.maleCount / total * 100);
      final femalePerc = (widget.femaleCount / total * 100);

      return PieChartSectionData(
        color: isMale ? const Color(0xff2196F3) : const Color(0xffE91E63),
        value: isMale ? widget.maleCount : widget.femaleCount,
        title: isMale
            ? '${malePerc.toStringAsFixed(1)}%'
            : '${femalePerc.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: AppTextStyles(
          context,
        ).semiBold16.copyWith(color: Colors.white),
        badgeWidget: _Badge(
          isMale ? Icons.male : Icons.female,
          size: widgetSize,
          borderColor: isMale
              ? const Color(0xff1565C0)
              : const Color(0xffAD1457),
        ),
        badgePositionPercentageOffset: .98,
      );
    });
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.icon, {required this.size, required this.borderColor});

  final IconData icon;

  final double size;

  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),

      width: size,

      height: size,

      decoration: BoxDecoration(
        color: Colors.white,

        shape: BoxShape.circle,

        border: Border.all(color: borderColor, width: 2),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.2),

            offset: const Offset(2, 2),

            blurRadius: 4,
          ),
        ],
      ),

      padding: EdgeInsets.all(size * .20),

      child: Center(
        child: Icon(icon, color: borderColor, size: size * .65),
      ),
    );
  }
}
