import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAppBar.dart';
import 'package:sintir_dashboard/Core/widgets/Drawer/CustomDrawer.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/DashboardViewBody.dart';

class MobileDashboardView extends StatelessWidget {
  const MobileDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(currentIndex: 0),
      appBar: CustomAppBar(
        appBartitle: "الصفحة الرئيسية",
        showBackButton: false,
      ),
      body: DashboardViewBody(),
    );
  }
}
