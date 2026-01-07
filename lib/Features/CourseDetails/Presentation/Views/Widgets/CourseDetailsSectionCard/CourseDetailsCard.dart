import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CourseDetailsCard extends StatelessWidget {
  final CourseEntity course;

  const CourseDetailsCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    AppTextStyles textStyles = AppTextStyles(context);
    ThemeData theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "تفاصيل الدورة",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          _buildDetailRow(
            "المادة",
            course.subject,
            Icons.science_outlined,
            textStyles,
          ),
          _buildDivider(),
          _buildDetailRow(
            "المستوى",
            course.level,
            Icons.bar_chart_rounded,
            textStyles,
          ),
          _buildDivider(),
          _buildDetailRow(
            "اللغة",
            course.language,
            Icons.language_rounded,
            textStyles,
          ),
          _buildDivider(),
          _buildDetailRow(
            "السعر",
            "${course.price} جنية",
            Icons.payments_outlined,
            textStyles,
          ),
          _buildDivider(),
          _buildDetailRow(
            "الطلاب",
            "${course.studentsCount} طالب",
            Icons.people_outline_rounded,
            textStyles,
          ),
          _buildDivider(),
          _buildDetailRow(
            "تاريخ النشر",
            DateFormat('yyyy/MM/dd').format(course.postedDate),
            Icons.calendar_today_rounded,
            textStyles,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    AppTextStyles textStyles,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8E99AF), size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8E99AF), fontSize: 15),
          ),
          const Spacer(),
          Text(value, style: textStyles.medium12),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.05),
      thickness: 1,
      height: 1,
    );
  }
}
