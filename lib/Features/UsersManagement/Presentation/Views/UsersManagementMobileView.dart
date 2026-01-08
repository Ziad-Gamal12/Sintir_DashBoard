import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAppBar.dart';
import 'package:sintir_dashboard/Core/widgets/Drawer/CustomDrawer.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Presentation/Views/Widgets/UsersManagementViewBody.dart';

class UsersManagementMobileView extends StatelessWidget {
  const UsersManagementMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBartitle: "ادارة المستخدمين",
        showBackButton: true,
      ),
      drawer: CustomDrawer(currentIndex: 2),
      body: const UsersManagementViewBody(),
    );
  }
}
