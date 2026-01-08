import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/DesktopLayoutBuilder/CustomDesktopDashbaordLayout.dart';

class DesktopCoursesManagmentView extends StatelessWidget {
  const DesktopCoursesManagmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CustomDesktopDashboardLayout(currentIndex: 1));
  }
}
