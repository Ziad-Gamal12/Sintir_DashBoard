import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Helper/ResponsiveLayout%20.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Presentation/Views/TicketsManagementDesktopView.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Presentation/Views/TicketsManagementMobileView.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Presentation/Views/TicketsManagementTabletView.dart';

class ResponsiveTicketsManagementView extends StatelessWidget {
  const ResponsiveTicketsManagementView({super.key});
  static const String routeName = '/ResponsiveTicketsManagementView';
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: TicketsManagementMobileView(),
      tablet: TicketsManagementTabletView(),
      desktop: TicketsManagementDesktopView(),
    );
  }
}
