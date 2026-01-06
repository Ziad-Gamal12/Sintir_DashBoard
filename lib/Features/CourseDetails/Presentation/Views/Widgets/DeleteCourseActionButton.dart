import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/AppDialogs.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/course_details_actions_cubit/course_details_actions_cubit.dart';

class DeleteCourseActionButton extends StatelessWidget {
  const DeleteCourseActionButton({
    super.key,
    required this.course,
    required this.textStyles,
  });

  final CourseEntity course;
  final AppTextStyles textStyles;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      CourseDetailsActionsCubit,
      CourseDetailsActionsState,
      bool
    >(
      selector: (state) {
        return state is DeleteCourseLoading;
      },
      builder: (context, state) {
        if (state) {
          return Center(
            child: CircularProgressIndicator(color: Colors.red.shade700),
          );
        }
        return Custombutton(
          text: "",
          color: Colors.red.withOpacity(.1),
          textColor: Colors.red,
          onPressed: () {
            AppDialogs.warning(
              context,
              "هل أنت متأكد من رغبتك في حذف هذه الدورة؟ هذا الإجراء لا يمكن التراجع عنه.",
              onTap: () {
                context.read<CourseDetailsActionsCubit>().deleteCourse(
                  courseId: course.id,
                  teacherId: course.contentcreaterentity!.id,
                );
              },
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "حذف الدورة",
                style: textStyles.regular14.copyWith(
                  color: Colors.red.shade700,
                ),
              ),
              Icon(Icons.delete, color: Colors.red.shade700),
            ],
          ),
        );
      },
    );
  }
}
