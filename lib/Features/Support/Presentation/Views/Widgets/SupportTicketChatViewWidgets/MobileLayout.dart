import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportTicketEntity.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Helpers/ChatMobileLayoutHelper.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/CustomSupportChatSendMessageSection.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/SupportChatMessagesListView.dart';

class MobileLayout extends StatefulWidget {
  final SupportTicketEntity ticket;
  const MobileLayout({super.key, required this.ticket});

  @override
  State<MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<MobileLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Chat Messages
          Positioned.fill(
            child: SupportChatMessagesListView(ticketID: widget.ticket.id),
          ),

          // 2. Centered Floating Action Button on the Right
          Positioned(
            right: 12,
            top: MediaQuery.sizeOf(context).height * 0.4, // Center vertically
            child: Material(
              elevation: 8,
              shape: const CircleBorder(),
              color: Theme.of(context).primaryColor,
              child: IconButton(
                onPressed: () => ChatMobileLayoutHelper.showActionSheet(
                  context,
                  widget.ticket,
                ),
                icon: const Icon(Icons.manage_accounts, color: Colors.white),
                tooltip: "Manage Ticket",
              ),
            ),
          ),

          // 3. Bottom Send Section
          Positioned(
            left: 10,
            right: 10,
            bottom: 20,
            child: CustomSupportChatSendMessageSection(
              ticketId: widget.ticket.id,
            ),
          ),
        ],
      ),
    );
  }
}
