import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';

class FetchTransactionsResponseEntity {
  final List<TransactionEntity> transactions;
  final bool hasMore;
  final bool isPaginate;
  FetchTransactionsResponseEntity({
    required this.transactions,
    required this.hasMore,
    required this.isPaginate,
  });
}
