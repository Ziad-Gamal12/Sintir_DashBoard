import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/constant.dart';

class UserDetailsInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const UserDetailsInfoTile({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: KMainColor.withOpacity(0.7), size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles(context).regular14.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}
