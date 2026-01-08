import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAppBar.dart';
import 'package:sintir_dashboard/Core/widgets/Drawer/CustomDrawer.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserDetailsViewBody.dart';

class ResponsiveUserDetailsView extends StatelessWidget {
  const ResponsiveUserDetailsView({super.key, required this.uid});
  final String uid;
  static const routeName = '/responsive-user-details';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBartitle: "تفاصيل المستخدم",
        showBackButton: true,
      ),
      drawer: const CustomDrawer(currentIndex: 2),
      body: UserDetailsViewBody(userId: uid),
    );
  }
}
