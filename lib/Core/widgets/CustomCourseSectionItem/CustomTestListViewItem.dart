import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseSectionEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseTestItemEntities/CourseTestEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseTestItemEntities/CourseTestViewNavigationsRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCourseSectionItem/CustomContainerSectionItem.dart';
import 'package:sintir_dashboard/Core/widgets/customListTileWidget.dart';

class Customtestlistviewitem extends StatelessWidget {
  const Customtestlistviewitem({
    super.key,
    required this.item,
    required this.section,
    required this.course,
  });
  final CourseTestEntity item;
  final CourseSectionEntity section;
  final CourseEntity course;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () => item.ontap(
            context: context,
            item: CourseExamViewNavigationsRequirmentsEntity(
              test: item,
              sectionId: section.id,
              course: course,
            ),
            course: course,
          ),
          child: Customcontainersectionitem(
            child: Customlisttilewidget(
              title: " ${item.title} ",
              image: item.preffixImage,
              subtitle: " (${item.durationTime} دقيقة)",
              trailing: Text(
                "${item.questions.length} سؤال",
                style: AppTextStyles(context).regular14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
