import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CourseTableWidgets/CustomCourseTable.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserActivityCardIsRow.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/SectionHeader.dart';

class UserDetailsMainContent extends StatelessWidget {
  const UserDetailsMainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CustomUserActivityCardsRow(),
        const SectionDivider(),
        const SectionHeader(title: "كورسات المستخدم"),
        const SizedBox(height: 16),
        SizedBox(
          height: 550,
          child: ResponsiveCourseTable(courses: CourseEntity.fakeCourses),
        ),
      ],
    );
  }
}
