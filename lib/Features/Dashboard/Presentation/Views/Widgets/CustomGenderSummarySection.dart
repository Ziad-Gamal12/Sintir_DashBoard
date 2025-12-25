import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomGenderSummaryInfo.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/GenderPaiChart.dart';

class CustomGenderSummarySection extends StatelessWidget {
  const CustomGenderSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    bool isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
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
        children: [
          Text("نسبة الجنس", style: AppTextStyles(context).semiBold16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 200,
                      child: GenderPieChart(femaleCount: 200, maleCount: 300),
                    ),
                    const SizedBox(height: 24),
                    CustomGenderSummaryInfo(femaleCount: 200, maleCount: 300),
                  ],
                );
              } else {
                // Desktop/Tablet Row
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 250,
                        child: GenderPieChart(femaleCount: 200, maleCount: 300),
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      flex: 3,
                      child: CustomGenderSummaryInfo(
                        femaleCount: 200,
                        maleCount: 300,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
