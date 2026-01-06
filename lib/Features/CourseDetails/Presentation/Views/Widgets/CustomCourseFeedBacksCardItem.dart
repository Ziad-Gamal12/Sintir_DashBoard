import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sintir_dashboard/Core/Entities/CourseFeedBackItemEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseFeedBacksCubit/course_feed_backs_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CustomCourseFeedBacksCardItemPopupMenu.dart';

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
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
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
                    )
                  else
                    const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.redAccent,
                    ),
                ],
              ),
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
