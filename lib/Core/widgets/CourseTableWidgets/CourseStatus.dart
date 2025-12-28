import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CourseStatus extends StatelessWidget {
  const CourseStatus({super.key, required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusText(status),
            style: AppTextStyles(context).regular14.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? state) {
    if (state == BackendEndpoints.coursePublishedState) return Colors.green;
    if (state == BackendEndpoints.coursePendingState) return Colors.orange;
    return Colors.red;
  }

  String _getStatusText(String? state) {
    if (state == BackendEndpoints.coursePublishedState) return "منشور";
    if (state == BackendEndpoints.coursePendingState) return "قيد المراجعة";
    return "مرفوض";
  }
}
