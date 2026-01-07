import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseEntity.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CourseDetailsHeaderCourseStatusBadge extends StatefulWidget {
  const CourseDetailsHeaderCourseStatusBadge({super.key});

  @override
  State<CourseDetailsHeaderCourseStatusBadge> createState() =>
      _CourseDetailsHeaderCourseStatusBadgeState();
}

class _CourseDetailsHeaderCourseStatusBadgeState
    extends State<CourseDetailsHeaderCourseStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = context.read<CourseEntity>().state;
    final style = _getStatusStyle(status);

    return Container(
      decoration: BoxDecoration(
        color: style.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100), // Perfect pill
        border: Border.all(color: style.color.withOpacity(0.2), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: Tween(begin: 0.8, end: 1.1).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            ),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: style.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: style.color.withOpacity(0.6),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            style.label,
            style: AppTextStyles(context).bold13.copyWith(
              color: style.color,
              letterSpacing: 0.5,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _getStatusStyle(String status) {
    if (BackendEndpoints.coursePublishedState == status) {
      return const _StatusStyle(label: "منشور", color: Color(0xFF00C853));
    } else if (BackendEndpoints.coursePendingState == status) {
      return const _StatusStyle(
        label: "قيد المراجعة",
        color: Color(0xFFFFAB00),
      );
    } else if (BackendEndpoints.courseArchivedState == status) {
      return const _StatusStyle(label: "مؤرشف", color: Color(0xFF1976D2));
    } else if (BackendEndpoints.courseDeletedByTeacherState == status) {
      return const _StatusStyle(
        label: "محذوف بواسطة المعلم",
        color: Color(0xFF616161),
      );
    } else if (BackendEndpoints.courseDeletedByAdminState == status) {
      return const _StatusStyle(
        label: "محذوف بواسطة الادمن",
        color: Color(0xFFB00020),
      );
    } else {
      return const _StatusStyle(label: "مرفوض", color: Color(0xFFFF1744));
    }
  }
}

class _StatusStyle {
  final String label;
  final Color color;
  const _StatusStyle({required this.label, required this.color});
}
