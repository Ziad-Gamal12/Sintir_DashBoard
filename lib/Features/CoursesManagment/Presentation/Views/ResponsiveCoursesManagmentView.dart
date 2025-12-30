import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Helper/ResponsiveLayout%20.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/DesktopCoursesManagmentView.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/MobileCoursesManagmentView.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/TabletCoursesManagmentView.dart';

class ResponsiveCoursesManagmentView extends StatelessWidget {
  const ResponsiveCoursesManagmentView({super.key});
  static const routeName = '/courses-managment';
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: MobileCoursesManagmentView(),
      tablet: TabletCoursesManagmentView(),
      desktop: DesktopCoursesManagmentView(),
    );
  }
}
