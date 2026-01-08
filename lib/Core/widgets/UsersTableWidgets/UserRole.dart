import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/UserRoleBadgeEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class UserRole extends StatelessWidget {
  const UserRole({super.key, required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    final badge = UserRoleBadgeEntity.getUserRoleBadgeEntity(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badge.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badge.color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badge.icon, size: 16, color: badge.color),
          const SizedBox(width: 8),
          Text(
            badge.title,
            style: AppTextStyles(context).regular11.copyWith(
              color: badge.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
