import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Helper/AppPadding.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomDashbaordWelcomeWidget.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomRevenueAndGenederSectionLayout.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomSummaryCardGrid.dart';

class DashboardViewBody extends StatelessWidget {
  const DashboardViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.horizontal(context),
        vertical: AppPadding.vertical(context),
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: CustomDashboardWelcomeWidget()),
          SliverToBoxAdapter(child: const SizedBox(height: 24)),
          CustomSummaryCardGrid(),
          SliverToBoxAdapter(child: Divider(height: 24)),
          SliverToBoxAdapter(child: CustomRevenueAndGenederSectionLayout()),
        ],
      ),
    );
  }
}
