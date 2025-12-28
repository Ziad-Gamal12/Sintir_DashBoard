import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomGenderSummarySection.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomRevenueSummaryCard.dart';

class CustomRevenueAndGenederSectionLayout extends StatelessWidget {
  const CustomRevenueAndGenederSectionLayout({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Column(
            children: [
              const CustomRevenueSummaryCard(),
              const SizedBox(height: 24),
              const CustomGenderSummarySection(),
            ],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(flex: 4, child: CustomRevenueSummaryCard()),
              const SizedBox(width: 24),
              SizedBox(width: 350, child: const CustomGenderSummarySection()),
            ],
          );
        }
      },
    );
  }
}
