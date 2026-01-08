import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAppBar.dart';
import 'package:sintir_dashboard/Core/widgets/Drawer/CustomDrawer.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Presentation/Views/Widgets/TicketsManagementViewBody.dart';

class TicketsManagementMobileView extends StatelessWidget {
  const TicketsManagementMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(appBartitle: "الدعم"),
      drawer: CustomDrawer(currentIndex: 3),
      body: TicketsManagementViewBody(),
    );
  }
}
