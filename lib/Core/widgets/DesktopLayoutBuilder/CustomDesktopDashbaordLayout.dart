import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/DesktopLayoutBuilder/CustomDesktopDashbaordLayoutAppBar.dart';
import 'package:sintir_dashboard/Core/widgets/Drawer/CustomDrawerBody.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/Widgets/CoursesManagmentBody.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/DashboardViewBody.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Presentation/Views/Widgets/TicketsManagementViewBody.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Presentation/Views/Widgets/UsersManagementViewBody.dart';

class CustomDesktopDashboardLayout extends StatefulWidget {
  const CustomDesktopDashboardLayout({super.key, required this.currentIndex});
  final int currentIndex;

  @override
  State<CustomDesktopDashboardLayout> createState() =>
      _CustomDesktopDashboardLayoutState();
}

class _CustomDesktopDashboardLayoutState
    extends State<CustomDesktopDashboardLayout> {
  late int _localIndex;
  final List<Widget> _screens = [
    const DashboardViewBody(),
    const CoursesManagmentBody(),
    const UsersManagementViewBody(),
    const TicketsManagementViewBody(),
  ];

  @override
  void initState() {
    super.initState();
    _localIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant CustomDesktopDashboardLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _localIndex = widget.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final sidebarWidth = (screenWidth * 0.18).clamp(260.0, 300.0);
    return Row(
      children: [
        Container(
          width: sidebarWidth,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(4, 0),
              ),
            ],
          ),
          child: CustomDrawerBody(
            currentIndex: _localIndex,
            onItemTapped: (index) {
              if (_localIndex != index) {
                setState(() => _localIndex = index);
              }
            },
          ),
        ),
        Expanded(
          child: Column(
            children: [
              const CustomDesktopDashbaordLayoutAppBar(),
              Expanded(
                child: IndexedStack(index: _localIndex, children: _screens),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
