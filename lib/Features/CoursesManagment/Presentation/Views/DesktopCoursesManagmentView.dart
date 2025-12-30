import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomDesktopDashbaordLayout.dart';

class DesktopCoursesManagmentView extends StatefulWidget {
  const DesktopCoursesManagmentView({super.key});

  @override
  State<DesktopCoursesManagmentView> createState() =>
      _DesktopCoursesManagmentViewState();
}

class _DesktopCoursesManagmentViewState
    extends State<DesktopCoursesManagmentView> {
  final int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomDesktopDashboardLayout(currentIndex: _currentIndex),
    );
  }
}
