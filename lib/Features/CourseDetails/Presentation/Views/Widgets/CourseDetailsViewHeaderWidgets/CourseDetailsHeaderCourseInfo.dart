import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseDetailsViewHeaderWidgets/CourseDetailsHeaderCourseStatusBadge.dart';

class CourseDetailsHeaderCourseInfo extends StatelessWidget {
  const CourseDetailsHeaderCourseInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final course = context.read<CourseEntity>();
    final style = AppTextStyles(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          course.title,
          style: style.semiBold24.copyWith(letterSpacing: -0.5),
        ),
        const SizedBox(height: 16),

        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            const CourseDetailsHeaderCourseStatusBadge(),

            _buildDivider(),

            _buildEnhancedInfo(
              context,
              icon: Icons.tag_rounded,
              label: "رقم الكورس",
              value: "#${course.id}",
            ),

            _buildDivider(),

            _buildEnhancedInfo(
              context,
              icon: Icons.event_available_rounded,
              label: "تاريخ الإنشاء",
              value: course.postedDate.toString().split(' ')[0],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedInfo(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final style = AppTextStyles(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: style.regular11.copyWith(color: Colors.grey[600]),
              ),
              Text(value, style: style.bold14.copyWith(height: 1.2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 24, width: 1, color: Colors.grey.withOpacity(0.2));
  }
}
