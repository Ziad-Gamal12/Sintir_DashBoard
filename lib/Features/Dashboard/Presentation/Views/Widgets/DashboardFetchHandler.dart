import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Helper/AppPadding.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_analytics_cubit/dashbaord_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_most_viewed_courses_cubit/dashbaord_most_viewed_courses_cubit.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_transactions_analytics_cubit/dashbaord_transactions_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_users_gender_analytics_cubit/dashbaord_users_gender_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomDashbaordWelcomeWidget.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomMostViewedCoursesCard.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomRevenueAndGenederSectionLayout.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomSummaryCardGrid.dart';

class DashboardFetchHandler extends StatefulWidget {
  const DashboardFetchHandler({super.key});

  @override
  State<DashboardFetchHandler> createState() => _DashboardFetchHandlerState();
}

class _DashboardFetchHandlerState extends State<DashboardFetchHandler> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashbaordAnalyticsCubit>().fetchAll();
      context.read<DashbaordMostViewedCoursesCubit>().fetchMostViewedCourses(
        isPaginate: false,
      );
      context
          .read<DashbaordTransactionsAnalyticsCubit>()
          .fetchTransactionsAnalytics();
      context.read<DashbaordUsersGenderAnalyticsCubit>().analyzeUsersGender();
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
          const SliverToBoxAdapter(child: CustomDashboardWelcomeWidget()),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
          const CustomSummaryCardGrid(),
          const SliverToBoxAdapter(child: Divider(height: 48)),
          const SliverToBoxAdapter(
            child: CustomRevenueAndGenederSectionLayout(),
          ),
          const SliverToBoxAdapter(child: Divider(height: 48)),
          const SliverToBoxAdapter(child: CustomMostViewedCoursesCard()),
        ],
      ),
    );
  }
}
