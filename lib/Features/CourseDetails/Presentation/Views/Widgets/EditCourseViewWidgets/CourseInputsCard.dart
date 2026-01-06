import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/UpdateCourseCubit/UpdateCourseCubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/EditCourseViewWidgets/AddCoursePoster.dart';

import 'course_code_input.dart';
import 'course_description_input.dart';
import 'course_language_selector.dart';
import 'course_level_selector.dart';
import 'course_price_input.dart';
import 'course_subject_selector.dart';
import 'course_title_input.dart';

class CourseInputsCard extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController codeController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final String? posterurl;
  final ValueChanged<String?> onLevelChange;
  final ValueChanged<String?> onSubjectChange;
  final ValueChanged<String?> onLanguageChange;
  final CourseEntity courseEntity;
  const CourseInputsCard({
    super.key,
    required this.titleController,
    required this.codeController,
    required this.descriptionController,
    required this.courseEntity,
    required this.posterurl,
    required this.priceController,
    required this.onLevelChange,
    required this.onSubjectChange,
    required this.onLanguageChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CourseTitleInput(controller: titleController),
        const SizedBox(height: 14),
        CourseCodeInput(controller: codeController),
        const SizedBox(height: 14),
        CourseDescriptionInput(controller: descriptionController),
        const SizedBox(height: 14),
        CoursePriceInput(controller: priceController),
        const SizedBox(height: 14),
        CourseLevelSelector(
          onChanged: onLevelChange,
          hintText: courseEntity.level,
        ),
        const SizedBox(height: 14),

        CourseSubjectSelector(
          onChanged: onSubjectChange,
          hintText: courseEntity.subject,
        ),
        const SizedBox(height: 14),
        CourseLanguageSelector(
          onChanged: onLanguageChange,
          hintText: courseEntity.language,
        ),

        const SizedBox(height: 14),
        Addcourseposter(
          coursePosterImage: context
              .watch<UpdateCourseCubit>()
              .coursePosterImage,
          coursePosterUrl: posterurl,
          onTap: () {
            context.read<UpdateCourseCubit>().pickCoursePosterImage();
          },
        ),
      ],
    );
  }
}
