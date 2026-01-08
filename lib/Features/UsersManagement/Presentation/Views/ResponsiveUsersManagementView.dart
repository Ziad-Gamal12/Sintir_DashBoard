import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Helper/ResponsiveLayout%20.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Presentation/Views/UsersManagementDesktoptView.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Presentation/Views/UsersManagementMobileView.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Presentation/Views/UsersManagementTabletView.dart';

class ResponsiveUsersManagementView extends StatelessWidget {
  const ResponsiveUsersManagementView({super.key});
  static const String routeName = '/ResponsiveUsersManagementView';
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: UsersManagementMobileView(),
      tablet: UsersManagementTabletView(),
      desktop: UsersManagementDesktoptView(),
    );
  }
}
