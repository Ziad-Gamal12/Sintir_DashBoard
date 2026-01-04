import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAppBar.dart';
import 'package:sintir_dashboard/Core/widgets/Drawer/CustomDrawer.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDetailsBody.dart';

class ResponsiveCourseDeatilsView extends StatelessWidget {
  const ResponsiveCourseDeatilsView({super.key, required this.course});
  static const String routeName = '/responsive_course_details_view';
  final CourseEntity course;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(appBartitle: "تفاصيل الكورس", showBackButton: true),
      drawer: CustomDrawer(currentIndex: 1),
      body: CourseDetailsBody(course: course),
    );
  }
}
