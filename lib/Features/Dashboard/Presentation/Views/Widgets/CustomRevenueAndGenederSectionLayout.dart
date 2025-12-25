import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomGenderSummarySection.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomRevenueSummaryCard.dart';

class CustomRevenueAndGenederSectionLayout extends StatelessWidget {
  const CustomRevenueAndGenederSectionLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              const CustomRevenueSummaryCard(),
              Divider(height: 32),
              CustomGenderSummarySection(),
            ],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: const CustomRevenueSummaryCard()),
              const SizedBox(width: 16),
              Expanded(child: CustomGenderSummarySection()),
            ],
          );
        }
      },
    );
  }
}
