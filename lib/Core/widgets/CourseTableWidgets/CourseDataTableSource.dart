import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CourseTableWidgets/CourseInfo.dart';
import 'package:sintir_dashboard/Core/widgets/CourseTableWidgets/CourseStatus.dart';
import 'package:sintir_dashboard/Core/widgets/CourseTableWidgets/InstructorInfo.dart';
import 'package:sintir_dashboard/Core/widgets/CourseTableWidgets/SubjectBadge.dart';
import 'package:sintir_dashboard/Core/widgets/CourseTableWidgets/SubscribersCount.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/ResponsiveCourseDeatilsView.dart';
import 'package:sintir_dashboard/constant.dart';

class CourseDataTableSource extends DataTableSource {
  final List<CourseEntity> courses;
  final BuildContext context;

  CourseDataTableSource(this.courses, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= courses.length) return null;
    final course = courses[index];
    final textStyles = AppTextStyles(context);

    return DataRow2(
      onTap: () {
        GoRouter.of(
          context,
        ).push(ResponsiveCourseDeatilsView.routeName, extra: course);
      },
      cells: [
        DataCell(CourseInfo(course: course)),
        DataCell(SubjectBadge(subject: course.subject)),
        DataCell(InstructorInfo(instructor: course.contentcreaterentity)),
        DataCell(
          Text(
            "${course.price} ج.م",
            style: textStyles.bold14.copyWith(color: KSecondaryColor),
          ),
        ),
        DataCell(SubscribersCount(count: course.studentsCount)),
        DataCell(CourseStatus(status: course.state)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => courses.length;

  @override
  int get selectedRowCount => 0;
}
