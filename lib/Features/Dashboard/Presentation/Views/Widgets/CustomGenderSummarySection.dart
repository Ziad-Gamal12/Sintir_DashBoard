import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/GenderAnalysisEntity.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Managers/dashbaord_users_gender_analytics_cubit/dashbaord_users_gender_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/GenderChartBuilder.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomGenderSummarySection extends StatefulWidget {
  const CustomGenderSummarySection({super.key});

  @override
  State<CustomGenderSummarySection> createState() =>
      _CustomGenderSummarySectionState();
}

class _CustomGenderSummarySectionState
    extends State<CustomGenderSummarySection> {
  late final SnapshotController _snapshotController;

  @override
  void initState() {
    super.initState();
    _snapshotController = SnapshotController();
  }

  @override
  void dispose() {
    _snapshotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      child:
          BlocBuilder<
            DashbaordUsersGenderAnalyticsCubit,
            DashbaordUsersGenderAnalyticsState
          >(
            buildWhen: (previous, current) =>
                previous.runtimeType != current.runtimeType,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "تحليل المستخدمين",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    GenderChartBuilder(
                      snapshotController: _snapshotController,
                      entity: entity,
                      isLoading: isLoading,
                    ),

                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),

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
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
