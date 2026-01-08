import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Domain/Entities/SupportTicketEntity.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Presentation/Views/Widgets/TicketItem.dart';

class TicketsSliverList extends StatelessWidget {
  const TicketsSliverList({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: SupportTicketEntity.fakeSupportTickets().length,
      itemBuilder: (context, index) {
        return TicketItem(
          ticket: SupportTicketEntity.fakeSupportTickets()[index],
          onTap: () {},
        );
      },
    );
  }
}
