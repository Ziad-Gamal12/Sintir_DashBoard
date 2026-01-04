import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/FetchTransactionsResponseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseTransactionsRepo.dart';

part 'course_transactions_state.dart';

class CourseTransactionsCubit extends Cubit<CourseTransactionsState> {
  CourseTransactionsCubit({required this.courseTransactionsRepo})
    : super(CourseTransactionsInitial());
  final CourseTransactionsRepo courseTransactionsRepo;
  List<TransactionEntity> transactions = [];
  bool hasMore = true;

  Future<void> fetchCourseTransactions({
    required String courseId,
    required bool isPaginate,
  }) async {
    emit(FetchCourseTransactionsLoading(isPaginate: isPaginate));
    final result = await courseTransactionsRepo.fetchCourseTransactions(
      courseId: courseId,
      isPaginate: isPaginate,
    );
    result.fold(
      (failure) {
        emit(FetchCourseTransactionsFailure(errMessage: failure.message));
      },
      (transactionsResponse) {
        handleFetchedTransactionsSuccessState(transactionsResponse);
        emit(FetchCourseTransactionsSuccess(response: transactionsResponse));
      },
    );
  }

  void handleFetchedTransactionsSuccessState(
    FetchTransactionsResponseEntity response,
  ) {
    if (response.isPaginate) {
      transactions.addAll(response.transactions);
    } else {
      transactions = response.transactions;
    }
    hasMore = response.hasMore;
  }
}
