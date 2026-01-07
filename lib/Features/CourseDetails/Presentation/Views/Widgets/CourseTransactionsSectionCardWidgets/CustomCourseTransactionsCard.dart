import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/course_transactions_cubit/course_transactions_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseInfoAndSectionsSectionCardWidgets/CustomCourseSectionsCardHeader.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseTransactionsSectionCardWidgets/CustomCourseTransactionsListView.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomCourseTransactionsCard extends StatefulWidget {
  const CustomCourseTransactionsCard({super.key, required this.courseId});
  final String courseId;

  @override
  State<CustomCourseTransactionsCard> createState() =>
      _CustomCourseTransactionsCardState();
}

class _CustomCourseTransactionsCardState
    extends State<CustomCourseTransactionsCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CourseTransactionsCubit>();
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomCourseSectionsCardHeader(
              title: "العمليات المالية",
              showMore: cubit.hasMore
                  ? () {
                      if (context.read<CourseTransactionsCubit>().state
                          is! FetchCourseTransactionsLoading) {
                        context
                            .read<CourseTransactionsCubit>()
                            .fetchCourseTransactions(
                              isPaginate: true,
                              courseId: widget.courseId,
                            );
                      }
                    }
                  : null,
              action: IconButton(
                onPressed: () => setState(() => isExpanded = !isExpanded),
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: isExpanded ? KMainColor : theme.hintColor,
                ),
                tooltip: isExpanded ? "تصغير" : "توسيع",
              ),
            ),
            const SizedBox(height: 16),

            // Toggle Logic
            isExpanded ? _buildFullView(cubit) : _buildFixedView(cubit),
          ],
        ),
      ),
    );
  }

  // Dashboard View (Aligned with other cards)
  Widget _buildFixedView(CourseTransactionsCubit cubit) {
    return SizedBox(
      height: 450,
      child: CustomCourseTransactionsListView(
        transactions: cubit.transactions,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: false,
      ),
    );
  }

  Widget _buildFullView(CourseTransactionsCubit cubit) {
    return CustomCourseTransactionsListView(
      transactions: cubit.transactions,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
    );
  }
}
