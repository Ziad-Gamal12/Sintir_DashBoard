import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sintir_dashboard/Core/Entities/CourseFeedBackItemEntity.dart';
import 'package:sintir_dashboard/Core/Entities/ReviewReportEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseFeedBacksCubit/course_feed_backs_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseFeedBacksSectionCardWidgets/CustomCourseFeedBacksCardItemPopupMenu.dart';

class CustomCourseFeedBacksCardItem extends StatelessWidget {
  final CoursefeedbackItemEntity feedback;
  final String courseId;
  const CustomCourseFeedBacksCardItem({
    super.key,
    required this.feedback,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyles = AppTextStyles(context);
    return BlocSelector<CourseFeedBacksCubit, CourseFeedBacksState, bool>(
      selector: (state) {
        return state is CourseFeedBacksDeleteFeedBackLoading &&
            (state).feedBackId == feedback.uid;
      },
      builder: (context, isLoading) {
        final reports = context.select<CourseFeedBacksCubit,
            List<ReviewReportEntity>>(
          (cubit) => cubit.reportsFor(feedback.uid),
        );
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: reports.isEmpty
                  ? theme.dividerColor.withOpacity(0.1)
                  : Colors.redAccent.withOpacity(0.6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildThemedAvatar(theme),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feedback.name,
                          style: textStyles.bold16.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('yyyy/MM/dd').format(feedback.datePosted),
                          style: textStyles.regular13.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLoading)
                    CustomCourseFeedBacksCardItemPopupMenu(
                      theme: theme,
                      feedbackId: feedback.uid,
                      courseId: courseId,
                      reportsCount: reports.length,
                    )
                  else
                    const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.redAccent,
                    ),
                ],
              ),
              if (reports.isNotEmpty) ...[
                const SizedBox(height: 12),
                _ReportsSummary(reports: reports),
              ],
              const SizedBox(height: 16),
              Text(
                feedback.fedBack,
                style: textStyles.regular14.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.85),
                  height: 1.6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemedAvatar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: theme.primaryColor.withOpacity(0.1),
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipOval(
            child: CustomCachedNetworkImage(imageUrl: feedback.userImage),
          ),
        ),
      ),
    );
  }
}

class _ReportsSummary extends StatelessWidget {
  const _ReportsSummary({required this.reports});

  final List<ReviewReportEntity> reports;

  @override
  Widget build(BuildContext context) {
    final reasons = {for (final report in reports) report.reasonLabel};
    final details = reports
        .map((report) => report.details.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, color: Colors.redAccent, size: 18),
              const SizedBox(width: 6),
              Text(
                'مُبلَّغ عنه (${reports.length}): ${reasons.join('، ')}',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          for (final text in details.take(3)) ...[
            const SizedBox(height: 6),
            Text('• $text'),
          ],
        ],
      ),
    );
  }
}
