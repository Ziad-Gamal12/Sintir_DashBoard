import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/DesktopLayoutBuilder/CustomDesktopDashbaordLayout.dart';

class UsersManagementTabletView extends StatelessWidget {
  const UsersManagementTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomDesktopDashboardLayout(currentIndex: 2);
  }
}
