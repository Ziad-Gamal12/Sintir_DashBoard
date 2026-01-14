import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportTicketEntity.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/CustomChatTicketInfoAndActions.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/CustomSupportChatSendMessageSection.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/SupportChatMessagesListView.dart';

class DesktopLayout extends StatelessWidget {
  final SupportTicketEntity ticket;
  const DesktopLayout({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool isLarge = width > 1200;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Stack(
            children: [
              Positioned.fill(
                child: SupportChatMessagesListView(ticketID: ticket.id),
              ),
              Positioned(
                left: isLarge ? width * 0.1 : 20,
                right: isLarge ? width * 0.1 : 20,
                bottom: 20,
                child: CustomSupportChatSendMessageSection(ticketId: ticket.id),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: CustomChatTicketInfoAndActions(ticket: ticket)),
      ],
    );
  }
}
