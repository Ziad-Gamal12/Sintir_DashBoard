import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAppBar.dart';
import 'package:sintir_dashboard/Core/widgets/Drawer/CustomDrawer.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/DashboardViewBody.dart';

class MobileDashboardView extends StatefulWidget {
  const MobileDashboardView({super.key});

  @override
  State<MobileDashboardView> createState() => _MobileDashboardViewState();
}

class _MobileDashboardViewState extends State<MobileDashboardView> {
  final int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(currentIndex: _currentIndex),
      appBar: CustomAppBar(
        appBartitle: "الصفحة الرئيسية",
        showBackButton: false,
      ),
      body: DashboardViewBody(),
    );
  }
}
