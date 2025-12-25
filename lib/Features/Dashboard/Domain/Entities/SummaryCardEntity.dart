import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/SummaryCardType.dart';

class SummaryCardEntity {
  final IconData icon;
  final Color color;
  final String label;
  final SummaryCardType type;
  SummaryCardEntity({
    required this.icon,
    required this.color,
    required this.label,
    required this.type,
  });

  static List<SummaryCardEntity> getSummaryCards() => [
    SummaryCardEntity(
      label: "إجمالي الدخل",
      icon: FontAwesomeIcons.dollarSign,
      color: const Color(0xFF6366F1),
      type: SummaryCardType.revenue,
    ),
    SummaryCardEntity(
      label: "إجمالي المستخدمين",
      icon: FontAwesomeIcons.users,
      color: const Color(0xFF10B981),
      type: SummaryCardType.users,
    ),
    SummaryCardEntity(
      label: "الدورات المباشرة",
      icon: FontAwesomeIcons.video,
      color: const Color(0xFFF59E0B),
      type: SummaryCardType.courses,
    ),
    SummaryCardEntity(
      label: "التذاكر المفتوحة",
      type: SummaryCardType.tickets,
      icon: FontAwesomeIcons.ticket,
      color: const Color(0xFFEF4444),
    ),
  ];
}
