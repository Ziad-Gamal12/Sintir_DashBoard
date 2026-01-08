import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/DesktopLayoutBuilder/CustomDesktopDashbaordLayout.dart';

class UsersManagementDesktoptView extends StatelessWidget {
  const UsersManagementDesktoptView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomDesktopDashboardLayout(currentIndex: 2);
  }
}