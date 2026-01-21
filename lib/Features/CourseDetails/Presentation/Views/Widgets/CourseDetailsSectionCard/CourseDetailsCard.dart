import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomInfoRow.dart';

class CourseDetailsCard extends StatelessWidget {
  final CourseEntity course;

  const CourseDetailsCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
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
          Text("تفاصيل الدورة", style: AppTextStyles(context).semiBold20),
          const SizedBox(height: 25),
          CustomInfoRow(
            label: "المادة",
            value: course.subject,
            icon: Icons.science_outlined,
          ),
          _buildDivider(),
          CustomInfoRow(
            label: "المستوى",
            value: course.level,
            icon: Icons.bar_chart_rounded,
          ),
          _buildDivider(),
          CustomInfoRow(
            label: "اللغة",
            value: course.language,
            icon: Icons.language_rounded,
          ),
          _buildDivider(),
          CustomInfoRow(
            label: "السعر",
            value: "${course.price} جنية",
            icon: Icons.payments_outlined,
          ),
          _buildDivider(),
          CustomInfoRow(
            label: "الطلاب",
            value: "${course.studentsCount} طالب",
            icon: Icons.people_outline_rounded,
          ),
          _buildDivider(),
          CustomInfoRow(
            label: "تاريخ النشر",
            value: DateFormat('yyyy/MM/dd').format(course.postedDate),
            icon: Icons.calendar_today_rounded,
          ),
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
