import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Entities/CourseDetailsSummaryCardType.dart';

class CourseDetailsSummaryCardEntity {
  final IconData icon;
  final Color color;
  final String label;
  final CourseDetailsSummaryCardType type;

  CourseDetailsSummaryCardEntity({
    required this.icon,
    required this.color,
    required this.label,
    required this.type,
  });

  static List<CourseDetailsSummaryCardEntity> getCourseDetailsSummaryCards() =>
      [
        CourseDetailsSummaryCardEntity(
          label: "إجمالي الدخل",
          icon: FontAwesomeIcons.sackDollar,
          color: const Color(0xFF6366F1),
          type: CourseDetailsSummaryCardType.revenue,
        ),
        CourseDetailsSummaryCardEntity(
          label: "إجمالي المشتركين",
          icon: FontAwesomeIcons.usersViewfinder,
          color: const Color(0xFF22C55E),
          type: CourseDetailsSummaryCardType.subscribers,
        ),
        CourseDetailsSummaryCardEntity(
          label: "التقييمات",
          icon: FontAwesomeIcons.solidStar,
          color: const Color(0xFF8B5CF6),
          type: CourseDetailsSummaryCardType.feedbacks,
        ),
        CourseDetailsSummaryCardEntity(
          label: "الإبلاغات",
          icon: FontAwesomeIcons.triangleExclamation,
          color: const Color(0xFFF43F5E),
          type: CourseDetailsSummaryCardType.reports,
        ),
      ];
}
