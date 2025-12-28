part of 'dashbaord_transactions_analytics_cubit.dart';

@immutable
sealed class DashbaordTransactionsAnalyticsState {}

final class DashbaordTransactionsAnalyticsInitial
    extends DashbaordTransactionsAnalyticsState {}

final class DashbaordTransactionsFetchTransactionsLoading
    extends DashbaordTransactionsAnalyticsState {}

final class DashbaordTransactionsFetchTransactionsSuccess
    extends DashbaordTransactionsAnalyticsState {
  final List<TransactionEntity> transactions;
  DashbaordTransactionsFetchTransactionsSuccess({required this.transactions});
}

final class DashbaordTransactionsFetchTransactionsFailure
    extends DashbaordTransactionsAnalyticsState {
  final String errMessage;
  DashbaordTransactionsFetchTransactionsFailure({required this.errMessage});
}
