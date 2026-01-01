import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseSectionEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseVideoItemEntities/CourseVedioItemEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseVideoItemEntities/CourseVideoviewnavigationsrequirmentsentity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCourseSectionItem/CustomContainerSectionItem.dart';
import 'package:sintir_dashboard/Core/widgets/customListTileWidget.dart';

class CustomVedioListViewItem extends StatelessWidget {
  const CustomVedioListViewItem({
    super.key,
    required this.item,
    required this.course,
    required this.section,
  });
  final CourseVideoItemEntity item;
  final CourseSectionEntity section;
  final CourseEntity course;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => item.ontap(
        context: context,
        requires: CourseVideoViewNavigationsRequirmentsEntity(
          sectionId: section.id,
          courseEntity: course,
          video: item,
        ),
        course: course,
      ),
      child: Stack(
        children: [
          Customcontainersectionitem(
            child: Customlisttilewidget(
              title: item.title,
              image: item.preffixImage,
              trailing: Text(
                "${item.durationTime} دقيقة",
                style: AppTextStyles(context).regular14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
