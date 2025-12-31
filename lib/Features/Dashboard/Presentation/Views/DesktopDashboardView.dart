import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/DesktopLayoutBuilder/CustomDesktopDashbaordLayout.dart';

class DesktopDashboardView extends StatefulWidget {
  const DesktopDashboardView({super.key});

  @override
  State<DesktopDashboardView> createState() => _DesktopDashboardViewState();
}

class _DesktopDashboardViewState extends State<DesktopDashboardView> {
  final int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomDesktopDashboardLayout(currentIndex: _currentIndex),
    );
  }
}
