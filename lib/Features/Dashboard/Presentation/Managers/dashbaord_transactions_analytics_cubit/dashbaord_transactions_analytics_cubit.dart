import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Repos/DashbaordAnalyticsRepo.dart';

part 'dashbaord_transactions_analytics_state.dart';

class DashbaordTransactionsAnalyticsCubit
    extends Cubit<DashbaordTransactionsAnalyticsState> {
  DashbaordTransactionsAnalyticsCubit({required this.dashbaordAnalyticsRepo})
    : super(DashbaordTransactionsAnalyticsInitial());
  final DashbaordAnalyticsRepo dashbaordAnalyticsRepo;

  Future<void> fetchTransactionsAnalytics() async {
    emit(DashbaordTransactionsFetchTransactionsLoading());
    final result = await dashbaordAnalyticsRepo.getGraphTransactions();
    result.fold(
      (l) => emit(
        DashbaordTransactionsFetchTransactionsFailure(errMessage: l.message),
      ),
      (transactions) {
        emit(
          DashbaordTransactionsFetchTransactionsSuccess(
            transactions: transactions,
          ),
        );
      },
    );
  }
}
