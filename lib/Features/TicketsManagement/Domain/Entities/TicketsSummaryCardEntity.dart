import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Domain/Entities/TicketsSummaryCardType.dart';

class TicketsSummaryCardEntity {
  final IconData icon;
  final Color color;
  final String label;
  final TicketsSummaryCardType type;
  TicketsSummaryCardEntity({
    required this.icon,
    required this.color,
    required this.label,
    required this.type,
  });

  static List<TicketsSummaryCardEntity> getTicketsSummaryCards() => [
    TicketsSummaryCardEntity(
      label: "إجمالى التذاكر",
      icon: FontAwesomeIcons.folderOpen,
      color: const Color(0xFF6366F1),
      type: TicketsSummaryCardType.total,
    ),
    TicketsSummaryCardEntity(
      label: "بأنتظار الرد",
      icon: FontAwesomeIcons.clock,
      color: Colors.yellow,
      type: TicketsSummaryCardType.pending,
    ),
    TicketsSummaryCardEntity(
      label: "محلولة",
      type: TicketsSummaryCardType.resolved,
      icon: FontAwesomeIcons.check,
      color: const Color(0xFF10B981),
    ),
  ];
}
