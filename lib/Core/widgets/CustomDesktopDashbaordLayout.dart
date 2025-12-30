import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/Drawer/CustomDrawerBody.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/Widgets/CoursesManagmentBody.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/DashboardViewBody.dart';

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

  final List<Widget> screens = [
    const DashboardViewBody(),
    const CoursesManagmentBody(),
    const Center(child: Text("إدارة المستخدمين")),
    const Center(child: Text("الدعم الفني")),
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
    double screenWidth = MediaQuery.sizeOf(context).width;
    double sidebarWidth = (screenWidth * 0.2).clamp(250.0, 320.0);

    return Row(
      children: [
        SizedBox(
          width: sidebarWidth,
          child: CustomDrawerBody(
            currentIndex: _localIndex,
            onItemTapped: (index) {
              if (_localIndex != index) {
                setState(() {
                  _localIndex = index;
                });
              }
            },
          ),
        ),
        Expanded(
          child: IndexedStack(index: _localIndex, children: screens),
        ),
      ],
    );
  }
}
