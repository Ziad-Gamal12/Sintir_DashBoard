import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/DesktopLayoutBuilder/CustomDesktopDashbaordLayout.dart';

class TicketsManagementTabletView extends StatelessWidget {
  const TicketsManagementTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomDesktopDashboardLayout(currentIndex: 3);
  }
}
