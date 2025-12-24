import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Helper/ResponsiveLayout%20.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/DesktopDashboardView.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/MobileDashboardView.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/TabletDashboardView.dart';

class ResponsiveDashboardView extends StatelessWidget {
  const ResponsiveDashboardView({super.key});
  static const routeName = '/dashboard';
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: MobileDashboardView(),
      tablet: TabletDashboardView(),
      desktop: DesktopDashboardView(),
    );
  }
}
