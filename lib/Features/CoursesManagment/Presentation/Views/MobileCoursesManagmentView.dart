import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAppBar.dart';
import 'package:sintir_dashboard/Core/widgets/Drawer/CustomDrawer.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/Widgets/CoursesManagmentBody.dart';

class MobileCoursesManagmentView extends StatefulWidget {
  const MobileCoursesManagmentView({super.key});

  @override
  State<MobileCoursesManagmentView> createState() =>
      _MobileCoursesManagmentViewState();
}

class _MobileCoursesManagmentViewState
    extends State<MobileCoursesManagmentView> {
  final int _currentIndex = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(currentIndex: _currentIndex),
      appBar: CustomAppBar(appBartitle: "إدارة الكورسات", showBackButton: true),
      body: CoursesManagmentBody(),
    );
  }
}
