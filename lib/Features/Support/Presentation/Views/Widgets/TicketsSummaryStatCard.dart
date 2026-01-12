import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Models/CardAnalyticsModels/AnalyticsCardViewModel.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Features/Support/Data/Mappers/ticket_card_mapper.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/TicketsSummaryCardEntity.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Managers/TicketAnalyticsCubit/ticket_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Managers/TicketAnalyticsCubit/ticket_analytics_state.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/TicketsSummaryStatCardFooter.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TicketsSummaryStatCard extends StatelessWidget {
  const TicketsSummaryStatCard({super.key, required this.summaryCardEntity});

  final TicketsSummaryCardEntity summaryCardEntity;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocSelector<
      TicketAnalyticsCubit,
      TicketAnalyticsState,
      AnalyticsCardViewModel
    >(
      selector: (state) => mapTicketStateToVM(state, summaryCardEntity.type),
      builder: (context, vm) {
        final displayValue = vm.result?.currentTotal.toInt().toString() ?? '0';
        return Skeletonizer(
          enabled: vm.isLoading,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black26
                      : Colors.grey.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: summaryCardEntity.color.withOpacity(
                        0.05,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: summaryCardEntity.color.withOpacity(
                                  0.12,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                summaryCardEntity.icon,
                                color: summaryCardEntity.color,
                                size: 20,
                              ),
                            ),

                            TicketsSummaryStatCardFooter(
                              summaryCardStatusEntity:
                                  vm.result, // Now dynamic!
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          summaryCardEntity.label,
                          style: AppTextStyles(context).regular13.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Text(
                            displayValue,
                            key: ValueKey(displayValue),
                            style: AppTextStyles(context).bold20.copyWith(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
