import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_transactions_analytics_cubit/dashbaord_transactions_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomRevenueGraph.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomRevenueSummaryCardTitle.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomRevenueSummaryCard extends StatefulWidget {
  const CustomRevenueSummaryCard({super.key});

  @override
  State<CustomRevenueSummaryCard> createState() =>
      _CustomRevenueSummaryCardState();
}

class _CustomRevenueSummaryCardState extends State<CustomRevenueSummaryCard> {
  late final SnapshotController _snapshotController;

  @override
  void initState() {
    super.initState();
    _snapshotController = SnapshotController();
  }

  @override
  void dispose() {
    _snapshotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double dynamicAspectRatio = width < 600
        ? 0.95
        : (width < 900 ? 0.85 : 0.98);

    return BlocBuilder<
      DashbaordTransactionsAnalyticsCubit,
      DashbaordTransactionsAnalyticsState
    >(
      builder: (context, state) {
        return AspectRatio(
          aspectRatio: dynamicAspectRatio,
          child: CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomRevenueSummaryCardTitle(),
                const SizedBox(height: 16),
                Expanded(child: _buildMainContent(state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(DashbaordTransactionsAnalyticsState state) {
    if (state is DashbaordTransactionsFetchTransactionsFailure) {
      return Center(child: CustomErrorWidget(errormessage: state.errMessage));
    }

    if (state is DashbaordTransactionsFetchTransactionsSuccess) {
      return SnapshotWidget(
        controller: _snapshotController,
        child: CustomRevenueGraph(transactions: state.transactions),
      );
    }

    return const Center(child: CircularProgressIndicator(color: KMainColor));
  }
}
