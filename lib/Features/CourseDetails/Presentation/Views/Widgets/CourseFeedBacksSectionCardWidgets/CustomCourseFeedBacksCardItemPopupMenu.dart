import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Helper/GetUserData.dart';
import 'package:sintir_dashboard/Core/Permissions/Permissions%20Mapping.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseFeedBacksCubit/course_feed_backs_cubit.dart';

class CustomCourseFeedBacksCardItemPopupMenu extends StatelessWidget {
  const CustomCourseFeedBacksCardItemPopupMenu({
    super.key,
    required this.theme,
    required this.feedbackId,
    required this.courseId,
    this.reportsCount = 0,
  });

  final String feedbackId, courseId;
  final int reportsCount;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final user = getUserData();

    final bool canDelete = PermissionsManager.can(
      Permission.deleteCourse,
      role: user.role,
      status: user.status,
    );

    if (!canDelete) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: theme.disabledColor, size: 20),
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'delete') {
          context.read<CourseFeedBacksCubit>().deleteCourseFeedBack(
                courseId: courseId,
                feedBackId: feedbackId,
              );
        }
        if (value == 'dismiss') {
          context.read<CourseFeedBacksCubit>().dismissReports(
                courseId: courseId,
                reviewUid: feedbackId,
              );
        }
      },
      itemBuilder: (context) => [
        if (reportsCount > 0)
          const PopupMenuItem(
            value: 'dismiss',
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(Icons.flag_outlined, size: 18),
                SizedBox(width: 8),
                Text(
                  'تجاهل البلاغات (التعليق سليم)',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
              SizedBox(width: 8),
              Text(
                'حذف التعليق',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}