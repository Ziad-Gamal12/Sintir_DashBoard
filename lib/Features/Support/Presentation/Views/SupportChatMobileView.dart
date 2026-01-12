import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAppBar.dart';
import 'package:sintir_dashboard/Core/widgets/Drawer/CustomDrawer.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportTicketEntity.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/SupportTicketChatViewBody.dart';

class ResponsiveSupportChatView extends StatelessWidget {
  const ResponsiveSupportChatView({super.key, required this.supportTicket});
  static const String routeName = '/SupportChatView';
  final SupportTicketEntity supportTicket;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(appBartitle: "الدعم", showBackButton: true),
      drawer: const CustomDrawer(currentIndex: 3),
      body: SupportTicketChatViewBody(supportTicketEntity: supportTicket),
    );
  }
}
