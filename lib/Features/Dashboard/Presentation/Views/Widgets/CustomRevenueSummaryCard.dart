import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_transactions_analytics_cubit/dashbaord_transactions_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomRevenueGraph.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomRevenueSummaryCardTitle.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomRevenueSummaryCard extends StatelessWidget {
  const CustomRevenueSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;

    double dynamicAspectRatio = width < 600 ? .95 : (width < 900 ? .85 : .98);

    return AspectRatio(
      aspectRatio: dynamicAspectRatio,
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomRevenueSummaryCardTitle(),
            const SizedBox(height: 16),
            BlocBuilder<
              DashbaordTransactionsAnalyticsCubit,
              DashbaordTransactionsAnalyticsState
            >(
              builder: (context, state) {
                if (state is DashbaordTransactionsFetchTransactionsFailure) {
                  return Expanded(
                    child: Center(
                      child: CustomErrorWidget(errormessage: state.errMessage),
                    ),
                  );
                }
                return Expanded(
                  child: Skeletonizer(
                    enabled:
                        state is DashbaordTransactionsFetchTransactionsLoading,
                    child: CustomRevenueGraph(
                      transactions:
                          state is DashbaordTransactionsFetchTransactionsSuccess
                          ? state.transactions
                          : TransactionEntity.getTestTransactions(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
