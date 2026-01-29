import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Helper/GetUserData.dart'; // Added
import 'package:sintir_dashboard/Core/Helper/ShowSnackBar.dart';
import 'package:sintir_dashboard/Core/Permissions/Permissions%20Mapping.dart'; // Added
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/course_details_actions_cubit/course_details_actions_cubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDeatilsActionsButtonsSectionCard/DeleteCourseActionButton.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDeatilsActionsButtonsSectionCard/EditCourseActionButton.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDeatilsActionsButtonsSectionCard/HideCourseSwitcher.dart';
import 'package:sintir_dashboard/core/utils/backend_endpoints.dart';

class CustomCourseActionsCard extends StatelessWidget {
  const CustomCourseActionsCard({super.key, required this.course});
  final CourseEntity course;

  @override
  Widget build(BuildContext context) {
    final user = getUserData();
    final textStyles = AppTextStyles(context);
    final theme = Theme.of(context);
    final bool canPublish = PermissionsManager.can(
      Permission.publishCourse,
      role: user.role,
      status: user.status,
    );
    final bool canEdit = PermissionsManager.can(
      Permission.editCourse,
      role: user.role,
      status: user.status,
    );
    final bool canDelete = PermissionsManager.can(
      Permission.deleteCourse,
      role: user.role,
      status: user.status,
    );
    if (!canPublish && !canEdit && !canDelete) {
      return const SizedBox.shrink();
    }

    return BlocListener<CourseDetailsActionsCubit, CourseDetailsActionsState>(
      listener: (context, state) {
        if (state is DeleteCourseSuccess) {
          CustomSnackBar.show(
            context,
            message: "تم حذف الدورة بنجاح",
            type: SnackType.success,
          );
          GoRouter.of(context).pop();
        } else if (state is DeleteCourseFailure) {
          CustomSnackBar.show(
            context,
            message: state.errorMessage,
            type: SnackType.error,
          );
        } else if (state is UpdateCourseStateSuccess) {
          CustomSnackBar.show(
            context,
            message: "تم تحديث حالة الدورة بنجاح",
            type: SnackType.success,
          );
        } else if (state is UpdateCourseStateFailure) {
          CustomSnackBar.show(
            context,
            message: state.errorMessage,
            type: SnackType.error,
          );
        }
      },
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("إجراءات إدارية", style: textStyles.semiBold16),
            const SizedBox(height: 16),

            if (canPublish) ...[
              HideCourseSwitcher(
                isHiddin: course.state == BackendEndpoints.courseArchivedState,
                onChanged: (val) {
                  String newState = (val == true)
                      ? BackendEndpoints.courseArchivedState
                      : BackendEndpoints.coursePublishedState;
                  context.read<CourseDetailsActionsCubit>().updateCourseState(
                    courseId: course.id,
                    newState: newState,
                    teacherId: course.contentcreaterentity!.id,
                  );
                },
              ),
              if (canEdit || canDelete) const SizedBox(height: 12),
            ],
            if (canEdit) ...[
              EditCourseActionButton(
                theme: theme,
                textStyles: textStyles,
                currentCourse: course,
              ),
              if (canDelete) const SizedBox(height: 12),
            ],
            if (canDelete)
              DeleteCourseActionButton(course: course, textStyles: textStyles),
          ],
        ),
      ),
    );
  }
}
