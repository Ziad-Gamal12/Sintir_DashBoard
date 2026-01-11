import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/DesktopLayoutBuilder/CustomDesktopDashbaordLayout.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportTicketEntity.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/SupportTicketChatViewBody.dart';

class SupportChatTabletView extends StatelessWidget {
  const SupportChatTabletView({super.key, required this.supportTicket});
  final SupportTicketEntity supportTicket;

  @override
  Widget build(BuildContext context) {
    return CustomDesktopDashboardLayout(
      currentIndex: 3,
      child: SupportTicketChatViewBody(supportTicketEntity: supportTicket),
    );
  }
}
