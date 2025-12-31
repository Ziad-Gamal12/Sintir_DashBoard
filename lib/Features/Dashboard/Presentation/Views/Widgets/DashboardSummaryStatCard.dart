import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Features/Dashboard/Data/Mappers/analytics_card_mapper.dart';
import 'package:sintir_dashboard/Features/Dashboard/Data/Models/AnalyticsCardViewModel.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/DashboardSummaryCardEntity.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_analytics_cubit/dashbaord_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_analytics_cubit/dashbaord_analytics_state.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/DashboardSummaryStatCardFooter.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DashboardSummaryStatCard extends StatelessWidget {
  const DashboardSummaryStatCard({super.key, required this.summaryCardEntity});

  final DashboardSummaryCardEntity summaryCardEntity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return BlocSelector<
      DashbaordAnalyticsCubit,
      DashbaordAnalyticsState,
      AnalyticsCardViewModel
    >(
      selector: (state) =>
          mapStateToAnalyticsCardVM(state, summaryCardEntity.type),
      builder: (context, vm) {
        final displayValue = vm.result?.currentTotal.toString() ?? '0';
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
                            DashboardSummaryStatCardFooter(
                              summaryCardStatusEntity: vm.result,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          summaryCardEntity.label,
                          style: AppTextStyles(context).regular13.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.2),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: Text(
                            displayValue,
                            key: ValueKey(displayValue),
                            style: AppTextStyles(context).bold19.copyWith(
                              fontSize: 26, // Larger for visual hierarchy
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: -0.5,
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
