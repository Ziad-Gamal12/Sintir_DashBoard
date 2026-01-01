import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseFileItemEntities/CourseFileEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseFileItemEntities/CourseFileviewnavigationsrequirmentsentity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseSectionEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCourseSectionItem/CustomContainerSectionItem.dart';
import 'package:sintir_dashboard/Core/widgets/customListTileWidget.dart';

class Customfilelistviewitem extends StatelessWidget {
  const Customfilelistviewitem({
    super.key,
    required this.item,
    required this.section,
    required this.course,
  });
  final CourseFileEntity item;
  final CourseSectionEntity section;
  final CourseEntity course;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () => item.ontap(
            context: context,
            item: Coursefileviewnavigationsrequirmentsentity(
              file: item,
              sectionId: section.id,
              course: course,
            ),
            course: course,
          ),
          child: Customcontainersectionitem(
            child: Customlisttilewidget(
              title: " ${item.title} ",
              image: item.preffixImage,
              subtitle: " (${item.description})",
            ),
          ),
        ),
      ],
    );
  }
}
