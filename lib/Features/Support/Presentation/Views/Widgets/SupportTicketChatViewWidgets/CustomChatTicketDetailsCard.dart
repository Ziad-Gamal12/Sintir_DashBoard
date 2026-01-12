import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportTicketEntity.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/TicketSenderInfo.dart';

import 'ticket_content_section.dart';
import 'ticket_status_badge.dart';

class CustomChatTicketDetailsCard extends StatelessWidget {
  final SupportTicketEntity supportTicketEntity;
  final bool isDesktop;

  const CustomChatTicketDetailsCard({
    super.key,
    required this.supportTicketEntity,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = supportTicketEntity.status.toTicketColor;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: isDesktop
          ? _buildVerticalSidebar(theme, statusColor)
          : _buildHorizontalHeader(theme, statusColor),
    );
  }

  Widget _buildVerticalSidebar(ThemeData theme, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TicketStatusBadge(status: supportTicketEntity.status),
            Text("#${supportTicketEntity.id.characters.take(5)}"),
          ],
        ),
        const SizedBox(height: 16),
        TicketContentSection(
          title: supportTicketEntity.title,
          description: supportTicketEntity.description,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(),
        ),
        TicketSenderInfo(sender: supportTicketEntity.sender),
      ],
    );
  }

  Widget _buildHorizontalHeader(ThemeData theme, Color statusColor) {
    return Row(
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TicketSenderInfo(sender: supportTicketEntity.sender),
              const SizedBox(height: 4),
              Text(
                supportTicketEntity.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Spacer(),
        TicketStatusBadge(status: supportTicketEntity.status),
      ],
    );
  }
}
