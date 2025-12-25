import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Helper/AppPadding.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_analytics_cubit/dashbaord_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomDashbaordWelcomeWidget.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomRevenueAndGenederSectionLayout.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomSummaryCardGrid.dart';

class DashboardViewBody extends StatefulWidget {
  const DashboardViewBody({super.key});

  @override
  State<DashboardViewBody> createState() => _DashboardViewBodyState();
}

class _DashboardViewBodyState extends State<DashboardViewBody> {
  @override
  void initState() {
    super.initState();
    final DashbaordAnalyticsCubit dashbaordAnalyticsCubit = context
        .read<DashbaordAnalyticsCubit>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      dashbaordAnalyticsCubit.fetchAll();
    });
  }

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
