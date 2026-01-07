import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomEmptyWidget.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/course_transactions_cubit/course_transactions_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseTransactionsSectionCardWidgets/CustomCourseTransactionsCardItem.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomCourseTransactionsListView extends StatelessWidget {
  const CustomCourseTransactionsListView({
    super.key,
    required this.transactions,
    this.shrinkWrap = false,
    this.physics = const BouncingScrollPhysics(),
  });

  final List<TransactionEntity> transactions;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseTransactionsCubit, CourseTransactionsState>(
      buildWhen: (previous, current) =>
          current is FetchCourseTransactionsLoading ||
          current is FetchCourseTransactionsSuccess ||
          current is FetchCourseTransactionsFailure,
      builder: (context, state) {
        if (state is FetchCourseTransactionsLoading && !state.isPaginate) {
          return const Center(
            child: CircularProgressIndicator(color: KMainColor),
          );
        } else if (state is FetchCourseTransactionsFailure) {
          return Center(
            child: CustomErrorWidget(errormessage: state.errMessage),
          );
        } else if (transactions.isEmpty) {
          return const Center(
            child: CustomEmptyWidget(text: "لا توجد عمليات مالية حالياً"),
          );
        }

        return ListView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics,
          itemCount:
              (state is FetchCourseTransactionsLoading && state.isPaginate)
              ? transactions.length + 1
              : transactions.length,
          itemBuilder: (context, index) {
            if (index == transactions.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: CircularProgressIndicator(color: KMainColor),
                ),
              );
            }
            return CustomCourseTransactionsCardItem(
              transaction: transactions[index],
            );
          },
        );
      },
    );
  }
}
