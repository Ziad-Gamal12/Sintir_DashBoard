import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/DesktopLayoutBuilder/CustomDesktopDashbaordLayout.dart';

class TabletCoursesManagmentView extends StatelessWidget {
  const TabletCoursesManagmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CustomDesktopDashboardLayout(currentIndex: 1));
  }
}
