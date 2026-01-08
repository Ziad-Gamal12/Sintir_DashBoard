import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class UserStatus extends StatelessWidget {
  const UserStatus({super.key, required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    Color color = _getStatusStyle(status).color;
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
          Flexible(
            child: Text(
              _getStatusStyle(status).label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles(context).regular14.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _getStatusStyle(String status) {
    if (BackendEndpoints.activeStatus == status) {
      return const _StatusStyle(label: "نشط", color: Color(0xFF00C853));
    } else if (BackendEndpoints.pendingStatus == status) {
      return const _StatusStyle(
        label: "قيد الانتظار",
        color: Color(0xFFFFAB00),
      );
    } else if (BackendEndpoints.inActiveStatus == status) {
      return const _StatusStyle(label: "غير نشط", color: Colors.black54);
    } else if (BackendEndpoints.blockedStatus == status) {
      return const _StatusStyle(label: "محظور", color: Color(0xFFB00020));
    } else if (BackendEndpoints.rejectedStatus == status) {
      return const _StatusStyle(label: "مرفوض", color: Color(0xFFB00020));
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
