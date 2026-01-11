// lib/Features/TicketsManagement/Presentation/Views/Widgets/TicketStatusIndicator.dart
import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportTicketEntity.dart';

class TicketStatusIndicator extends StatelessWidget {
  final String status;
  const TicketStatusIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 40,
      decoration: BoxDecoration(
        color: status.toTicketColor,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
