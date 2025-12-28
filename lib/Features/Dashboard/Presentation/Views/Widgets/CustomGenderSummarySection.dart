import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/GenderAnalysisEntity.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_users_gender_analytics_cubit/dashbaord_users_gender_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/GenderPaiChart.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomGenderSummarySection extends StatelessWidget {
  const CustomGenderSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade100,
          width: 1,
        ),
      ),
      child:
          BlocBuilder<
            DashbaordUsersGenderAnalyticsCubit,
            DashbaordUsersGenderAnalyticsState
          >(
            builder: (context, state) {
              if (state is DashbaordUsersGenderAnalyticsFailure) {
                return CustomErrorWidget(errormessage: state.errMessage);
              }

              final bool isLoading =
                  state is DashbaordUsersGenderAnalyticsLoading;
              final entity = state is DashbaordUsersGenderAnalyticsSuccess
                  ? state.genderAnalytics
                  : GenderAnalysisEntity.empty();

              return Skeletonizer(
                enabled: isLoading,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "تحليل المستخدمين",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 200,
                            child: GenderPieChart(
                              femaleCount: entity.femaleCount.toDouble(),
                              maleCount: entity.maleCount.toDouble(),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                (entity.maleCount + entity.femaleCount)
                                    .toString(),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "إجمالي",
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    // New Detailed Info Rows
                    _DetailedStatRow(
                      label: "نسبة الذكور",
                      value: "${entity.malePercentage.toStringAsFixed(1)}%",
                      color: const Color(0xff2196F3),
                    ),
                    const SizedBox(height: 12),
                    _DetailedStatRow(
                      label: "نسبة الإناث",
                      value: "${entity.femalePercentage.toStringAsFixed(1)}%",
                      color: const Color(0xffE91E63),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}

class _DetailedStatRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _DetailedStatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
