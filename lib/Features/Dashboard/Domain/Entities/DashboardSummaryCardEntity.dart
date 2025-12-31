import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/DashboardSummaryCardType.dart';

class DashboardSummaryCardEntity {
  final IconData icon;
  final Color color;
  final String label;
  final DashboardSummaryCardType type;
  DashboardSummaryCardEntity({
    required this.icon,
    required this.color,
    required this.label,
    required this.type,
  });

  static List<DashboardSummaryCardEntity> getDashboardSummaryCards() => [
    DashboardSummaryCardEntity(
      label: "إجمالي الدخل",
      icon: FontAwesomeIcons.dollarSign,
      color: const Color(0xFF6366F1),
      type: DashboardSummaryCardType.revenue,
    ),
    DashboardSummaryCardEntity(
      label: "إجمالي المستخدمين",
      icon: FontAwesomeIcons.users,
      color: const Color(0xFF10B981),
      type: DashboardSummaryCardType.users,
    ),
    DashboardSummaryCardEntity(
      label: "الدورات المباشرة",
      icon: FontAwesomeIcons.video,
      color: const Color(0xFFF59E0B),
      type: DashboardSummaryCardType.courses,
    ),
    DashboardSummaryCardEntity(
      label: "التذاكر المفتوحة",
      type: DashboardSummaryCardType.tickets,
      icon: FontAwesomeIcons.ticket,
      color: const Color(0xFFEF4444),
    ),
  ];
}
