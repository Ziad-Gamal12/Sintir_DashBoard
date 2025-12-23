import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/SignUpUserRoleEntity.dart';
import 'package:sintir_dashboard/constant.dart'; // Assuming KMainColor is here

class SignUpSelectUserRoleRowItem extends StatelessWidget {
  const SignUpSelectUserRoleRowItem({
    super.key,
    required this.entity,
    required this.isSelected,
  });

  final SignUpUserRoleEntity entity;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? KMainColor.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? KMainColor : Colors.grey.withOpacity(.2),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            entity.icon,
            size: 24,
            color: isSelected ? KMainColor : Colors.white.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          Text(
            entity.role,
            style: AppTextStyles(context).medium12.copyWith(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
