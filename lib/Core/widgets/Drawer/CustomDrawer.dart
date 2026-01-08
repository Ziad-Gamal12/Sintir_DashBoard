import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/widgets/Drawer/CustomDrawerBody.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/ResponsiveCoursesManagmentView.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/ResponsiveDashboardView.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Presentation/Views/ResponsiveUsersManagementView.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late int _localIndex;

  @override
  void initState() {
    super.initState();
    _localIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant CustomDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _localIndex = widget.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: CustomDrawerBody(
        currentIndex: _localIndex,
        onItemTapped: (index) {
          if (index != _localIndex) {
            setState(() {
              _localIndex = index;
            });

            _handleNavigation(index);
          }
        },
      ),
    );
  }

  void _handleNavigation(int index) {
    Navigator.pop(context);
    if (index == 0) {
      GoRouter.of(context).push(ResponsiveDashboardView.routeName);
      return;
    } else if (index == 1) {
      GoRouter.of(context).push(ResponsiveCoursesManagmentView.routeName);
      return;
    } else if (index == 2) {
      GoRouter.of(context).push(ResponsiveUsersManagementView.routeName);
      return;
    }
  }
}
