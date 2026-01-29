import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomEmptyWidget.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/user_details_cubit/user_details_cubit.dart';
import 'package:sintir_dashboard/constant.dart';

import 'VerticalUserTransactionItem.dart';

class UserTransactionsSliverGrid extends StatelessWidget {
  const UserTransactionsSliverGrid({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    int crossAxisCount = width < 600 ? 2 : (width < 900 ? 3 : 4);
    return BlocBuilder<UserDetailsCubit, UserDetailsState>(
      buildWhen: (previous, current) =>
          current is GetUserTransactionsLoading ||
          current is GetUserTransactionsSuccess ||
          current is GetUserTransactionsFailure,
      builder: (context, state) {
        List<TransactionEntity> transactions = context
            .read<UserDetailsCubit>()
            .userTransactions;
        if (state is GetUserTransactionsLoading) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator(color: KMainColor)),
          );
        } else if (state is GetUserTransactionsFailure &&
            transactions.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: CustomErrorWidget(errormessage: state.errmessage),
            ),
          );
        } else if (transactions.isEmpty &&
            state is GetUserTransactionsSuccess) {
          return SliverToBoxAdapter(
            child: Center(
              child: CustomEmptyWidget(text: "لا توجد عمليات مالية حالياً"),
            ),
          );
        }
        return SliverGrid.builder(
          itemCount: transactions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            return VerticalUserTransactionItem(
              transaction: transactions[index],
            );
          },
        );
      },
    );
  }
}
