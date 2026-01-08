import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAppBar.dart';
import 'package:sintir_dashboard/Core/widgets/Drawer/CustomDrawer.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/Widgets/CoursesManagmentBody.dart';

class MobileCoursesManagmentView extends StatelessWidget {
  const MobileCoursesManagmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(currentIndex: 1),
      appBar: CustomAppBar(appBartitle: "إدارة الكورسات", showBackButton: true),
      body: CoursesManagmentBody(),
    );
  }
}
