import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/DesktopLayoutBuilder/CustomDesktopDashbaordLayout.dart';

class TabletDashboardView extends StatefulWidget {
  const TabletDashboardView({super.key});

  @override
  State<TabletDashboardView> createState() => _TabletDashboardViewState();
}

class _TabletDashboardViewState extends State<TabletDashboardView> {
  final int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomDesktopDashboardLayout(currentIndex: _currentIndex),
    );
  }
}
