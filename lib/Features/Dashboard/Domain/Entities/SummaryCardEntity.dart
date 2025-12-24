import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SummaryCardEntity {
  final IconData icon;
  final Color color;
  final String title;

  SummaryCardEntity({
    required this.icon,
    required this.color,
    required this.title,
  });

  static List<SummaryCardEntity> getSummaryCards() => [
    SummaryCardEntity(
      title: "إجمالي الدورات",
      icon: FontAwesomeIcons.bookOpen,
      color: const Color(0xFF6366F1),
    ),
    SummaryCardEntity(
      title: "إجمالي المستخدمين",
      icon: FontAwesomeIcons.users,
      color: const Color(0xFF10B981),
    ),
    SummaryCardEntity(
      title: "الدورات المباشرة",
      icon: FontAwesomeIcons.video,
      color: const Color(0xFFF59E0B),
    ),
    SummaryCardEntity(
      title: "التذاكر المفتوحة",
      icon: FontAwesomeIcons.ticket,
      color: const Color(0xFFEF4444),
    ),
  ];
}
