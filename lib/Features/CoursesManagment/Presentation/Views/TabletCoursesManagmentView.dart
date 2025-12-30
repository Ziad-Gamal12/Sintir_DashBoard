import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomDesktopDashbaordLayout.dart';

class TabletCoursesManagmentView extends StatefulWidget {
  const TabletCoursesManagmentView({super.key});

  @override
  State<TabletCoursesManagmentView> createState() =>
      _TabletCoursesManagmentViewState();
}

class _TabletCoursesManagmentViewState
    extends State<TabletCoursesManagmentView> {
  final int _currentIndex = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomDesktopDashboardLayout(currentIndex: _currentIndex),
    );
  }
}
